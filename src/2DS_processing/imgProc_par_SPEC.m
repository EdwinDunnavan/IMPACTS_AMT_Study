function imgProc_par_SPEC(infile, outfile, probename, iEllipse, iCalcAllDiodeStats, iNewHabit, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function is the image processing part of OAP processing using
%  distributed memory parallisation. The function use one simple interface
%  for all probes.
%
%  Interface:
%    infile   :   The input file name
%    outfile  :   The output file name
%    probename:   One of the following: '2DC','2DP','CIP','PIP','HVPS',
%                 '2DS', and 'Fast2DC'
%    iRectEllipse: 0 - Do not process rectangle/ellipse fit dimensions; 1 - Process this info
%    iCalcAllDiodeStats: 0 - Do not save diode stats for every particle (large
%                        files); 1 - Save
%    varargin :   OPTIONAL arguments for the 2DS/HVPS, in the following order:
%                       tasTime:    Flight time in HHMMSS
%                       tas:        Flight TAS in m/s
%                       tasRatio:   Ratio between aircraft and probe TAS to correct time dimension
%
%  Note other important variables used in the program
%    handles:  a structure to store information. It is convinient to use a
%          struture to store the global information rather than using
%          various variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setting probe information according to probe type
%    use ProbeType to indicate four types of probes:
%       0: 2DC/2DP, 32 diodes, boundary 85,
%       1: CIP/PIP, 64 diodes, boundary 170
%       2: HVPS/2DS, 128 diodes, boundary 170
%       3: Fast2DC, 64 diodes, boundary 170 % Added support for Fast2DC ~ Joe Finlon 12/28


% 	iRectEllipse = 0;  % Set default to no Rectangle fit and Ellipse fit

% Option to save diode stats for every particle
% More than doubles filesize, and increase computation time
% Only enable if actually needed
% 	iCalcAllDiodeStats = 0;

fprintf('***********************************************************\n')
fprintf('* UNIVERSITY OF ILLINOIS/OKLAHOMA OAP PROCESSING SOFTWARE *\n')
fprintf('*                  Copyright (C) 2020                     *\n')
fprintf('***********************************************************\n')
fprintf('* This program is free software: you can redistribute it\n')
fprintf('* and/or modify it under the terms of the GNU General Public \n')
fprintf('* License as published by the Free Software Foundation,\n')
fprintf('* either version 3 of the License, or (at your option) any\n')
fprintf('* later version.\n\n')
fprintf('* This program is distributed in the hope that it will be\n')
fprintf('* useful, but WITHOUT ANY WARRANTY; without even the implied\n')
fprintf('* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR\n')
fprintf('* PURPOSE. See the GNU General Public License for more details.\n\n')

pix_thresh = 5;

switch probename

    case 'HVPS'
        boundary = [43690, 43690, 43690, 43690, 43690, 43690, 43690, 43690];
        boundarytime = 0;

        ds = 0.150;			     % Size of diode in millimeters
        handles.diodesize = ds;
        handles.diodenum  = 128; % Diode number
        handles.current_image = 1;
        probetype = 2;

    case '2DS'
        boundary = [43690, 43690, 43690, 43690, 43690, 43690, 43690, 43690];
        boundarytime = 0;

        ds = 0.010;			     % Size of diode in millimeters
        handles.diodesize = ds;
        handles.diodenum  = 128; % Diode number
        handles.current_image = 1;
        probetype = 2;

end

% Read in the TAS probe ratio if the user wants to correct the time
% dimension of 2DS/HVPS images ~ Joe Finlon - 02/07/20
if length(varargin)==3
    iTAS = 1;
    tasRatio = varargin{3};
else
    iTAS = 0;
end

diodenum = handles.diodenum;
handles.disagree = 0;

diode_size = handles.diodesize;

%% Read the particle image files
handles.f = netcdf.open(infile,'nowrite');
[~, handles.img_count] = netcdf.inqDim(handles.f,0);
warning off all
diode_stats = zeros(1,diodenum);

%% Create output NETCDF file and variables
% Added dynamic software version to netCDF metadata - Joe Finlon
% 02/07/20
%versionID = fopen('version.txt', 'r');
%software_string = fscanf(versionID, '%s');
% fclose(versionID);

f = netcdf.create(outfile,'NETCDF4'); % netCDF-4/HDF5 compression support - Added by Joe Finlon 02/13/19
dimid0 = netcdf.defDim(f,'time',netcdf.getConstant('NC_UNLIMITED'));
dimid1 = netcdf.defDim(f,'pos_count',2);
dimid2 = netcdf.defDim(f,'bin_count',diodenum);

NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(f, NC_GLOBAL, 'Creation Time', datestr(datetime('now'), 'yyyy/mm/dd HH:MM:SS'));
netcdf.putAtt(f, NC_GLOBAL, 'Description', ['Contains size, morphological, ',...
    'and other particle properties from an uncompressed image file.']);
netcdf.putAtt(f, NC_GLOBAL, 'Image Source', infile);
netcdf.putAtt(f, NC_GLOBAL, 'Probe Type', probename);
if iEllipse && iCalcAllDiodeStats
    netcdf.putAtt(f, NC_GLOBAL, 'Optional parameters active',...
        'Ellipse fits & per-particle diode statistics');
elseif iEllipse && ~iCalcAllDiodeStats
    netcdf.putAtt(f, NC_GLOBAL, 'Optional parameters active',...
        'Ellipse fits');
elseif ~iEllipse && iCalcAllDiodeStats
    netcdf.putAtt(f, NC_GLOBAL, 'Optional parameters active',...
        'Per-particle diode statistics');
else
    netcdf.putAtt(f, NC_GLOBAL, 'Optional parameters active', 'None')
end

varid1 = netcdf.defVar(f,'Date','int',dimid0);
netcdf.putAtt(f, varid1, 'Units', 'YYYYMMDD')
netcdf.putAtt(f, varid1, 'Description', 'Date of image record in which the particle resides')
netcdf.defVarDeflate(f, varid1, true, true, 9);

varid0  = netcdf.defVar(f,'Time','int',dimid0);
netcdf.putAtt(f, varid0, 'Units', 'HHMMSS')
netcdf.putAtt(f, varid0, 'Description', 'Time (UTC) of image record in which the particle resides')
netcdf.defVarDeflate(f, varid0, true, true, 9);

varid2  = netcdf.defVar(f,'msec','short',dimid0);
netcdf.putAtt(f, varid2, 'Units', 'ms')
netcdf.putAtt(f, varid2, 'Description', 'Sub-second time of image record in which the particle resides')
netcdf.defVarDeflate(f, varid2, true, true, 9);

varid101  = netcdf.defVar(f,'Time_in_seconds','double',dimid0);
netcdf.putAtt(f, varid101, 'Units', 'sec')
netcdf.putAtt(f, varid101, 'Description', 'Time since probe was activated')
netcdf.defVarDeflate(f, varid101, true, true, 9);

varid102  = netcdf.defVar(f,'SliceCount','short',dimid0);
netcdf.putAtt(f, varid102, 'Units', '--')
netcdf.putAtt(f, varid102, 'Description', 'Number of slices containing particle')
netcdf.defVarDeflate(f, varid102, true, true, 9);

varid103  = netcdf.defVar(f,'DMT_DOF_SPEC_OVERLOAD','double',dimid0); % Modified variable to handle PMS dead time ~ Joe Finlon 11/06/17
netcdf.putAtt(f, varid103, 'Units', 'ms (Fast2DC/2DC/2DP only)')
netcdf.putAtt(f, varid103, 'Description', 'Unitless flag denoting out-of-focus (DMT) or overloaded (SPEC) particles. Dead time for corresponding image record for PMS probes.')
netcdf.defVarDeflate(f, varid103, true, true, 9);

if probetype~=0 || probetype~=3 % Added by Joe Finlon - 06/22/17
    varid104  = netcdf.defVar(f,'Particle_number_all','int',dimid0);
    netcdf.putAtt(f, varid104, 'Units', '--')
    netcdf.putAtt(f, varid104, 'Description', 'Index of particle in 2-D buffer')
    netcdf.defVarDeflate(f, varid104, true, true, 9);
end

varid4  = netcdf.defVar(f,'position','short',[dimid1 dimid0]);
netcdf.putAtt(f, varid4, 'Units', '--')
netcdf.putAtt(f, varid4, 'Description', 'Slice within image record where particle is first sampled')
netcdf.defVarDeflate(f, varid4, true, true, 9);

varid7  = netcdf.defVar(f,'particle_microsec','double',dimid0);
netcdf.putAtt(f, varid7, 'Units', 'microsec')
netcdf.putAtt(f, varid7, 'Description', 'Sub-second particle time (unitless clock count for 2DS/HVPS)')
netcdf.defVarDeflate(f, varid7, true, true, 9);

varid8  = netcdf.defVar(f,'parent_rec_num','int',dimid0);
netcdf.putAtt(f, varid8, 'Units', '--')
netcdf.putAtt(f, varid8, 'Description', 'Index of image record in which the particle resides')
netcdf.defVarDeflate(f, varid8, true, true, 9);

varid9  = netcdf.defVar(f,'particle_num','short',dimid0);
netcdf.putAtt(f, varid9, 'Units', '--')
netcdf.putAtt(f, varid9, 'Description', 'Particle index within current image record')
netcdf.defVarDeflate(f, varid9, true, true, 9);

varid9b  = netcdf.defVar(f,'subparticle_num','short',dimid0);
netcdf.putAtt(f, varid9b, 'Units', '--')
netcdf.putAtt(f, varid9b, 'Description', 'Number of subparticles in image')
netcdf.defVarDeflate(f, varid9b, true, true, 9);

varid9c  = netcdf.defVar(f,'subparticle_mindist','short',dimid0);
netcdf.putAtt(f, varid9c, 'Units', '--')
netcdf.putAtt(f, varid9c, 'Description', 'Minimum distance between subparticles in image')
netcdf.defVarDeflate(f, varid9c, true, true, 9);

varidx = netcdf.defVar(f,'image_xpos','short',dimid0);
netcdf.putAtt(f,varidx,'Units','--')
netcdf.putAtt(f,varidx,'Description','Particle x (time) center position in buffer strip')
netcdf.defVarDeflate(f,varidx,true,true,9);

varidy = netcdf.defVar(f,'image_ypos','short',dimid0);
netcdf.putAtt(f,varidy,'Units','--')
netcdf.putAtt(f,varidy,'Description','Particle y (width) center position in buffer strip')
netcdf.defVarDeflate(f,varidy,true,true,9);

varid10 = netcdf.defVar(f,'image_length','short',dimid0);
netcdf.putAtt(f, varid10, 'Units', '--')
netcdf.putAtt(f, varid10, 'Description', 'Particle length in time direction using # photodiodes')
netcdf.defVarDeflate(f, varid10, true, true, 9);

varid11 = netcdf.defVar(f,'image_width','short',dimid0);
netcdf.putAtt(f, varid11, 'Units', '--')
netcdf.putAtt(f, varid11, 'Description', 'Particle length in photodiode direction using # photodiodes')
netcdf.defVarDeflate(f, varid11, true, true, 9);

varid12 = netcdf.defVar(f,'image_area','double',dimid0);
netcdf.putAtt(f, varid12, 'Units', 'mm^2')
netcdf.putAtt(f, varid12, 'Description', 'Projected area using the # shadowed photodiodes')
netcdf.defVarDeflate(f, varid12, true, true, 9);

varid13 = netcdf.defVar(f,'image_longest_y','short',dimid0);
netcdf.putAtt(f, varid13, 'Units', '--')
netcdf.putAtt(f, varid13, 'Description', 'Longest vertically-oriented chord through particle in time direction')
netcdf.defVarDeflate(f, varid13, true, true, 9);

varid14 = netcdf.defVar(f,'image_max_top_edge_touching','short',dimid0);
netcdf.putAtt(f, varid14, 'Units', '--')
netcdf.putAtt(f, varid14, 'Description', 'Maximum # of times the bottom diode is shadowed in succession')
netcdf.defVarDeflate(f, varid14, true, true, 9);

varid15 = netcdf.defVar(f,'image_max_bottom_edge_touching','short',dimid0);
netcdf.putAtt(f, varid15, 'Units', '--')
netcdf.putAtt(f, varid15, 'Description', 'Maximum # of times the top diode is shadowed in succession')
netcdf.defVarDeflate(f, varid15, true, true, 9);

varid16 = netcdf.defVar(f,'image_touching_edge','byte',dimid0);
netcdf.putAtt(f, varid16, 'Units', '--')
netcdf.putAtt(f, varid16, 'Description', '0 denotes image entirely in array; 1 denotes image touching edge')
netcdf.defVarDeflate(f, varid16, true, true, 9);

varid17 = netcdf.defVar(f,'image_auto_reject','short',dimid0);
netcdf.putAtt(f, varid17, 'Units', '--')
netcdf.putAtt(f, varid17, 'Description', ['ASCII reject code ("0" or 48: accepted; "a" or 97: aspect ratio > 6; ',...
    '"t" or 116: aspect ratio > 5 + image touching edge; ',...
    '"p" or 112: < 25% shadowed diodes in rectangle encompassing particle; ',...
    '"h" or 104 or 72 or 117: hollow particle; "s" or 115: split image; ',...
    '"z" or 122: zero area image; "f" or 102: zero area image)'])
netcdf.defVarDeflate(f, varid17, true, true, 9);

varid18 = netcdf.defVar(f,'image_hollow','byte',dimid0);
netcdf.putAtt(f, varid18, 'Units', '--')
netcdf.putAtt(f, varid18, 'Description', '0 denotes not hollow; 1 denotes a hollow image')
netcdf.defVarDeflate(f, varid18, true, true, 9);

varid19 = netcdf.defVar(f,'image_center_in','byte',dimid0);
netcdf.putAtt(f, varid19, 'Units', '--')
netcdf.putAtt(f, varid19, 'Description', '0 denotes center of particle outside array; 1 denotes center is inside')
netcdf.defVarDeflate(f, varid19, true, true, 9);

varid20 = netcdf.defVar(f,'image_axis_ratio','double',dimid0);
netcdf.putAtt(f, varid20, 'Units', '--')
netcdf.putAtt(f, varid20, 'Description', 'Ratio between maximum vertical length and maximum horizontal length')
netcdf.defVarDeflate(f, varid20, true, true, 9);

varid26 = netcdf.defVar(f,'image_diam_minR','double',dimid0);
netcdf.putAtt(f, varid26, 'Units', 'mm')
netcdf.putAtt(f, varid26, 'Description', 'Dmax of smallest circle enclosing the particle')
netcdf.defVarDeflate(f, varid26, true, true, 9);

varid27 = netcdf.defVar(f,'image_diam_AreaR','double',dimid0);
netcdf.putAtt(f, varid27, 'Units', 'mm')
netcdf.putAtt(f, varid27, 'Description', 'Area equivalent diameter')
netcdf.defVarDeflate(f, varid27, true, true, 9);

varid45 = netcdf.defVar(f,'image_perimeter','double',dimid0);
netcdf.putAtt(f, varid45, 'Units', 'mm')
netcdf.putAtt(f, varid45, 'Description', 'Perimeter following the particle boundary')
netcdf.defVarDeflate(f, varid45, true, true, 9);

if 1==iEllipse

    varid48 = netcdf.defVar(f,'image_EllipseL','double',dimid0);
    netcdf.putAtt(f, varid48, 'Units', 'mm')
    netcdf.putAtt(f, varid48, 'Description', 'Length of smallest ellipse enclosing the particle')
    netcdf.defVarDeflate(f, varid48, true, true, 9);

    varid49 = netcdf.defVar(f,'image_EllipseW','double',dimid0);
    netcdf.putAtt(f, varid49, 'Units', 'mm')
    netcdf.putAtt(f, varid49, 'Description', 'Width of smallest ellipse enclosing the particle')
    netcdf.defVarDeflate(f, varid49, true, true, 9);

    varid69 = netcdf.defVar(f,'image_EllipseAngle','double',dimid0);
    netcdf.putAtt(f, varid69, 'Units', 'radians')
    netcdf.putAtt(f, varid69, 'Description', 'Angle of ellipse with respect to the time direction')
    netcdf.defVarDeflate(f, varid69, true, true, 9);

    varidxe = netcdf.defVar(f,'image_Ellipse_xpos','double',dimid0);
    netcdf.putAtt(f, varidxe, 'Units', '--')
    netcdf.putAtt(f, varidxe, 'Description', 'Ellipse x (time) center position in buffer strip')
    netcdf.defVarDeflate(f, varidxe, true, true, 9);

    varidye = netcdf.defVar(f,'image_Ellipse_ypos','double',dimid0);
    netcdf.putAtt(f, varidye, 'Units', '--')
    netcdf.putAtt(f, varidye, 'Description', 'Ellipse y (width) center position in buffer strip')
    netcdf.defVarDeflate(f, varidye, true, true, 9);

end
varid28 = netcdf.defVar(f,'percent_shadow_area','double',dimid0);
netcdf.putAtt(f, varid28, 'Units', 'percent')
netcdf.putAtt(f, varid28, 'Description', 'Ratio between the projected area and L*W')
netcdf.defVarDeflate(f, varid28, true, true, 9);

varid29 = netcdf.defVar(f,'edge_at_max_hole','short',dimid0);
netcdf.putAtt(f, varid29, 'Units', '--')
netcdf.putAtt(f, varid29, 'Description', ['# diodes between edges of the particle for the slice ',...
    'containing the largest gap inside the particle'])
netcdf.defVarDeflate(f, varid29, true, true, 9);

varid30 = netcdf.defVar(f,'max_hole_diameter','short',dimid0);
netcdf.putAtt(f, varid30, 'Units', '--')
netcdf.putAtt(f, varid30, 'Description', 'Diameter of the largest hole inside the particle')
netcdf.defVarDeflate(f, varid30, true, true, 9);

varid31 = netcdf.defVar(f,'part_z','double',dimid0);
netcdf.putAtt(f, varid31, 'Units', '--')
netcdf.putAtt(f, varid31, 'Description', 'Particle depth in object plane calculated via lookup table')
netcdf.defVarDeflate(f, varid31, true, true, 9);

varid32 = netcdf.defVar(f,'size_factor','double',dimid0);
netcdf.putAtt(f, varid32, 'Units', '--')
netcdf.putAtt(f, varid32, 'Description', 'Dmax reduction factor folowing Korolev (2007) correction')
netcdf.defVarDeflate(f, varid32, true, true, 9);

varid33 = netcdf.defVar(f,'holroyd_habit','short',dimid0);
netcdf.putAtt(f, varid33, 'Units', '--')
if 1 == iNewHabit
	    netcdf.putAtt(f, varid33, 'Description', ['ASCII habit code following the Holroyd (1987) algorithm ',...
		    '("M" or 77: zero image; "C" or 67: center-out image; "t" or 116: tiny; "o" or 111: bad/split; ',...
		    '"l" or 108: linear; "a" or 97: aggregate; "g" or 103: graupel; "s" or 115: sphere; ',...
		    '"h" or 104: hexagonal; "i" or 105: irregular; "d" or 100: dendrite)'])
else
    netcdf.putAtt(f, varid33, 'Description', ['ASCII habit code following the Holroyd (1987) algorithm ',...
	    '("M" or 77: zero image; "C" or 67: center-out image; "t" or 116: tiny; "o" or 111: oriented; ',...
	    '"l" or 108: linear; "a" or 97: aggregate; "g" or 103: graupel; "s" or 115: sphere; ',...
	    '"h" or 104: hexagonal; "i" or 105: irregular; "d" or 100: dendrite)'])
end


% netcdf.putAtt(f, varid33, 'Description', ['ASCII habit code following the Holroyd (1987) algorithm ',...
%     '("M" or 77: zero image; "C" or 67: center-out image; "t" or 116: tiny; "o" or 111: oriented; ',...
%     '"l" or 108: linear; "a" or 97: aggregate; "g" or 103: graupel; "s" or 115: sphere; ',...
%     '"h" or 104: hexagonal; "i" or 105: irregular; "d" or 100: dendrite)'])
netcdf.defVarDeflate(f, varid33, true, true, 9);

varid331 = netcdf.defVar(f,'fine_detail_ratio','double',dimid0); % added variable to file output ~ Joe Finlon 11/3/19
netcdf.putAtt(f, varid331, 'Units', '--')
netcdf.putAtt(f, varid331, 'Description', 'Perim*Diam/Area following Holroyd (1987)')
netcdf.defVarDeflate(f,varid331,true,true,9);

if 1 == iNewHabit
    varid333 = netcdf.defVar(f,'width_length_percentile','double',dimid0);
    netcdf.putAtt(f, varid333, 'Units', 'mm')
    netcdf.putAtt(f, varid333, 'Description', 'Minimum difference between the 25th and 75th percentiles of particle length and width')
    netcdf.defVarDeflate(f, varid333, true, true, 9);
    
    varid334 = netcdf.defVar(f,'circle_area_ratio','double',dimid0);
    netcdf.putAtt(f, varid334, 'Units', '--')
    netcdf.putAtt(f, varid334, 'Description', 'Ratio between particle area and that of the approximated smallest circle enclosing the particle')
    netcdf.defVarDeflate(f, varid334, true, true, 9);
    
    varid335 = netcdf.defVar(f,'edge_maximum_dimension_ratio','double',dimid0);
    netcdf.putAtt(f, varid335, 'Units', '--')
    netcdf.putAtt(f, varid335, 'Description', 'Ratio between number of diodes illuminated along the frame edge with the most illuminated diodes and the particle maximum dimension')
    netcdf.defVarDeflate(f, varid335, true, true, 9);
    
    varid336 = netcdf.defVar(f,'maximum_gap','double',dimid0);
    netcdf.putAtt(f, varid336, 'Units', 'mm')
    netcdf.putAtt(f, varid336, 'Description', 'Maximum gap between any two separate illuminated areas along the x or y axes')
    netcdf.defVarDeflate(f, varid336, true, true, 9);
    
    varid337 = netcdf.defVar(f,'opacity_coefficient','double',dimid0);
    netcdf.putAtt(f, varid337, 'Units', '--')
    netcdf.putAtt(f, varid337, 'Description', 'Fraction (0-1) approximating the transparency of a particle')
    netcdf.defVarDeflate(f, varid337, true, true, 9);
    
    varid338 = netcdf.defVar(f,'aspect_ratio','double',dimid0);
    netcdf.putAtt(f, varid338, 'Units', '--')
    netcdf.putAtt(f, varid338, 'Description', 'Ratio between length of longest axis and length of shortest axis of particle')
    netcdf.defVarDeflate(f, varid338, true, true, 9);
    
    varid339 = netcdf.defVar(f,'holroyd_perimeter','double',dimid0);
    netcdf.putAtt(f, varid339, 'Units', 'mm')
    netcdf.putAtt(f, varid339, 'Description', 'Particle perimeter following Holroyd (1987) including perimeter added by holes within particle')
    netcdf.defVarDeflate(f, varid339, true, true, 9);
end

varid34 = netcdf.defVar(f,'area_hole_ratio','double',dimid0);
netcdf.putAtt(f, varid34, 'Units', '--')
netcdf.putAtt(f, varid34, 'Description', 'Ratio between the projected area and the area of hole inside particle')
netcdf.defVarDeflate(f, varid34, true, true, 9);

varid35 = netcdf.defVar(f,'inter_arrival','double',dimid0);
netcdf.putAtt(f, varid35, 'Units', 'sec')
netcdf.putAtt(f, varid35, 'Description', ['Inter-arrival time between particles ',...
    '(use diff(time_in_seconds) for all but 2DC/2DP)'])
netcdf.defVarDeflate(f, varid35, true, true, 9);

varid36 = netcdf.defVar(f,'bin_stats','int',dimid2);
netcdf.putAtt(f, varid36, 'Units', '--')
netcdf.putAtt(f, varid36, 'Description', '# times specified photodiode is shadowed for particles in this file')
netcdf.defVarDeflate(f, varid36, true, true, 9);

if iCalcAllDiodeStats
    varid37 = netcdf.defVar(f,'image_bin_stats','int',[dimid2 dimid0]);
    netcdf.putAtt(f, varid37, 'Units', '--')
    netcdf.putAtt(f, varid37, 'Description', '# times specified photodiode is shadowed for each particle')
    netcdf.defVarDeflate(f, varid37, true, true, 9);
end

netcdf.endDef(f)

%% Variables initialization
%wstart = 0;

num_particles = 0;

%% Analyze each individual particle images and output the particle by particle information
for parent_rec_num= 1 : handles.img_count % i = buffer strip

    %% Read in Buffer strip info
    handles.year     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'year'    ),parent_rec_num-1,1);
    handles.month    = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'month'  ),parent_rec_num-1,1);
    handles.day      = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'day'  ),parent_rec_num-1,1);
    handles.hour     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'hour'    ),parent_rec_num-1,1);
    handles.minute   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'minute'  ),parent_rec_num-1,1);
    handles.second   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'second'  ),parent_rec_num-1,1);
    handles.millisec = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'millisec'),parent_rec_num-1,1);

    % Optionally use TAS ratio between the probe value and the aircraft
    % value ~ Joe Finlon 11/3/19, 02/07/20
    if iTAS==1
        handles.tasRatio = tasRatio(parent_rec_num);
    else
        handles.tasRatio = 1.0;
    end

    if mod(parent_rec_num,100) == 0
        disp([num2str(parent_rec_num),'/',num2str(handles.img_count), ', ', num2str(double(handles.hour)*10000+double(handles.minute)*100+double(handles.second))])

    end
    varid = netcdf.inqVarID(handles.f,'data');

    temp = netcdf.getVar(handles.f,varid,[0, 0, parent_rec_num-1], [8,1700,1]);

    data(:,:) = temp';

    %% Find number of slices in buffer strip i

    data_size = size(data,1);

    bind = zeros(1,data_size-1);
    for ll = 1 : data_size-1
        bind(ll) = (isequal(data(ll,1:length(boundary)), boundary) && ( (isequal(data(ll+1,1), boundarytime) ) ) && data(ll,1)~=-1);
    end

    bind = find(bind==1); % Get index of slices

    start_arr = ones(1,length(bind)); % Left edge of slice
    start_arr(2:end) = 2+bind(1:end-1);

    %% Allocate arrays for number of particles
    num_slices = length(bind);

    if num_slices==0

        continue % Skip buffer strip if there are no particles

    end

    part_micro_prev = 0;
    time_in_seconds_prev = 0;

    %% Loop through all slices to find all particles in buffer strip
    for kk = 1 : num_slices

        %% Each slice goes (columnwise): start (1), header (2), j index = photodiode array (3:end)

        start = start_arr(kk);

        j = bind(kk);

        if start > (j-1) % Remove Corrupted Data

          continue % Properly treat zero-image particle ~ Joe Finlon & Adam Majewski 11/06/17
        end

        header_loc = j+1;

        ind_matrix = ones(j-start,8,'uint32');

        ind_matrix(1:j-start,:) = 65535 - data(start:j-1,:); % I used 1 to indicate the illuminated doides for HVPS
        c_orig=[dec2bin(ind_matrix(:,1),16), dec2bin(ind_matrix(:,2),16),dec2bin(ind_matrix(:,3),16),dec2bin(ind_matrix(:,4),16), ...
            dec2bin(ind_matrix(:,5),16), dec2bin(ind_matrix(:,6),16),dec2bin(ind_matrix(:,7),16),dec2bin(ind_matrix(:,8),16)];

        % Correct images for noise: ensure that at least 5 or
        % pix_thresh percent of total shadowed pixels are needed for
        % connected pixels

        c_logical = bwareaopen('1'-c_orig,max(5,floor(0.01*pix_thresh*sum(sum(c_orig=='0'))))); % Logical


        if max(c_logical(:))==0
            
            continue

        end

        c_parts = bwconncomp(c_logical,8);

        num_subparticles = c_parts.NumObjects;

        %% Determine minimum distance separating subparticles if num_subparticles > 1

        if num_subparticles>1

        darr = cell(1,num_subparticles); % darr contains the distance transforms of each subparticle
        for ll = 1 : num_subparticles
            ctemp =c_logical;
            ctemp(~ismember(1:numel(ctemp),c_parts.PixelIdxList{ll})) = 0; % Find all pixels that are part of subparticle ll
            darr{ll} = bwdist(ctemp,'chessboard'); % distance transform
        end

        combos = nchoosek(1:num_subparticles,2); % This finds all combinations between each 2 subparticles

        comb_size = size(combos,1);


        %% Find distances between each combination of two subparticles
        dist_arr = zeros(1,comb_size);
        for ll = 1 : comb_size

            comb_temp = combos(ll,:);

            % To calculate distances between subparticles, this adds up the
            % distance transform for each separate subparticle. The minimum
            % distance between each two subparticles is just the minimum of
            % the summed distance transform (minus 1 for convention).
            dist_arr(ll) = min(min(darr{comb_temp(1)}+darr{comb_temp(2)}))-1; 
         
        end

        % 
        dist_min = max(mink(dist_arr,num_subparticles-1));

        else % If there is only one particle (i.e., num_subparticles = 1), then there is no min distance between subparticles.

            dist_min = 0;

        end

               
        if dist_min<5 % if num_subparticles - 1 is less than threshold (in this case, 5) then consider both elements to be same particle

            num_subparticles = 1;

        end

        c = char('1'-c_logical); % get new image based on all these corrections

        % Find number of particles in between slices in case multiple
        % particles are found.

        %c_parts = bwconncomp(c_logical,8);

        %num_subparticles = c_parts.NumObjects;

        % Duplicate 'c' array for each particle

        %% Find number of particles in slice
        %for pp = 1 : num_subparticles

        %% Set up index arrays for slices for each particle

        %ctemp = c_logical;

        %ctemp(~ismember(1:numel(ctemp),c_parts.PixelIdxList{pp})) = 0; % Censor all shadowed pixels outside of particle

        %c = char('1'-ctemp);

        % Just to test if there are bad images, usually 0 area images
        figsize = size(c,2);
        if figsize~=diodenum
            disp('Not equal to diode number');
            return
        end

        position = [start, j-1];
        particle_num = mod(kk,66536);

        particle_DOF=bitand(data(header_loc,4), 32768);
        particle_partNum=double(data(header_loc,5));
        particle_sliceCount=double(data(header_loc,6));

        part_micro = double(data(header_loc,7))*65536+double(data(header_loc,8)); % particle time in clock cycles

        if part_micro_prev == 0

            timeDiff = (part_micro-part_micro_prev)*(handles.diodesize/(1000)/170);

            if timeDiff>=-250 % clock cycle hasn't rolled back
                time_in_seconds = time_in_seconds_prev + timeDiff;
            else % perform correction when clock cycle exceeds 2^32 and rolls back
                time_in_seconds = time_in_seconds_prev + (2^32-1-part_micro_prev+part_micro)*...
                    (handles.diodesize/(1000)/170);
            end


        else % run for the first particle in data file

            time_in_seconds = part_micro*(handles.diodesize/(1000)/170);

        end

        if(kk>1) % ** Use diff(time_in_seconds) to compute int-arr time in post-processing **
            int_arrival = time_in_seconds-time_in_seconds_prev;
        else
            int_arrival = 0;
        end

        part_micro_prev = part_micro; % assign the clock cycle for use in next iteration

        time_in_seconds_prev = time_in_seconds;

        rec_time=double(handles.hour)*10000+double(handles.minute)*100+double(handles.second);
        rec_date=double(handles.year)*10000+double(handles.month)*100+double(handles.day);
        rec_millisec=handles.millisec;

        %% Determine the Particle Habit: We use the Holroyd algorithm here
        handles.bits_per_slice = diodenum;
        if iCalcAllDiodeStats
            diode_stats = sum(c=='0',1); % Option to save diode stats for every particle
        end
        diode_stats = diode_stats + sum(c=='0',1);

        tempreturn = CGAL_minR(c, handles.tasRatio);

        minR = tempreturn(1); % diameter of minimum enclosing circle
        ctx = tempreturn(2); % position
        cty = tempreturn(3);

        % improved [EXPERIMENTAL] particle hollow identification ~ Wei Wu & Joe Finlon 11/3/19
        [xImgMax, ~] = size(c);
        if(minR*handles.diodesize<0.3 && length(find(c(max(1,floor(ctx)):min(xImgMax,ceil(ctx)),...
                max(1,floor(cty)):min(handles.diodenum,ceil(cty)))=='1')) >=1)

                if iNewHabit == 0 % use existing Holroyd scheme
                        [~, FS] = holroyd(handles, c);
                else % use modified Holroyd scheme
                    if strcmp(probename, 'HVPS') % special version for HVPS
                            [~, FS, wid_len_perc, circ_ratio, edge_max_dim_ratio,...
                                max_gap, Opacity, aspect_ratio,...
                                holroyd_perimeter] = holroyd_new_HVPS(handles, c);
                    else
                            [~, FS, wid_len_perc, circ_ratio, edge_max_dim_ratio,...
                                max_gap, Opacity, aspect_ratio,holroyd_perimeter] = holroyd_new(handles, c);
                    end
                end


            %[~, FS] = holroyd(handles, c);
            holroyd_habit = 's';
            is_hollow = 1;
        else
            %[holroyd_habit, FS] = holroyd(handles, c);

            if iNewHabit == 0 % use existing Holroyd scheme
                [holroyd_habit, FS] = holroyd(handles, c);
            else
                if strcmp(probename, 'HVPS') % special version for HVPS
                    [holroyd_habit, FS, wid_len_perc, circ_ratio, edge_max_dim_ratio,...
                     max_gap, Opacity, aspect_ratio, holroyd_perimeter] = holroyd_new_HVPS(handles, c);
                else
                    [holroyd_habit, FS, wid_len_perc, circ_ratio, edge_max_dim_ratio,...
                     max_gap,Opacity,aspect_ratio,holroyd_perimeter] = holroyd_new(handles, c);
                end
            end

            is_hollow = 0;
        end

        %% Determine if the particle is rejected or not
        %  Calculate the Particle Length, Width, Area, Auto Reject
        %  Status And more... See calculate_reject_unified()
        %  funtion for more information

        [image_length,image_width,~, longest_y_within_a_slice, ...
            max_top_edge_touching,max_bottom_edge_touching,image_touching_edge, ...
            auto_reject,is_hollow,~,part_z,sf,area_hole_ratio,max_hole_diameter, ...
            edge_at_max_hole,center_in] =calculate_reject_unified(c,handles,holroyd_habit,is_hollow);

        image_area = sum(sum(c=='0'));
        disttoedge = min(abs(handles.diodenum-cty),cty);
        if(center_in==1 && image_touching_edge~='0')
            image_area=image_area*2*(image_width-disttoedge)/image_width;
        end
        AreaR=2*sqrt(image_area/pi/handles.tasRatio);  % Calculate the Darea (area-equivalent diameter)
        Perimeter=ParticlePerimeter(c)/sqrt(handles.tasRatio);

        %% perform Korolev correction ~ Wei Wu 11/3/19
        if(auto_reject=='H')
            minR = minR/sf;
            if (holroyd_habit~= 's')
                disp(['WARNING: Habit should be spherical but is '  , char(holroyd_habit)]);
            end
        end

        if (image_width~=0)
            axis_ratio=image_length/image_width;
        else
            axis_ratio=0;
        end

        if 1==iEllipse

            [EllipseL, EllipseW, EllipseAngle,Ellipse_ypos, Ellipse_xpos] = CGAL_EllipseSize_UIOPS(c);


            if EllipseAngle >=0

                EllipseAngle = pi./2-EllipseAngle;

            elseif EllipseAngle<0

                EllipseAngle = -(pi./2-abs(EllipseAngle));

            end


        end

        %% Get the area ratio using the DL=max(DT,DP), only observed area are used
        if image_length > image_width
            percent_shadow = image_area / (0.25.*pi * image_length.^2);
        elseif image_width ~= 0
            percent_shadow = image_area / (0.25.*pi * image_width.^2);
        else
            percent_shadow = 0;
        end


        %% Write out the processed information on NETCDF
        netcdf.putVar ( f, varid0, num_particles, rec_time );
        netcdf.putVar ( f, varid1, num_particles, rec_date );

        netcdf.putVar ( f, varid101, num_particles, time_in_seconds );
        netcdf.putVar ( f, varid102, num_particles, particle_sliceCount ); % Used by all probes ~ Joe Finlon 11/06/17
        netcdf.putVar ( f, varid103, num_particles, double(particle_DOF) ); % Used by all probes ~ Joe Finlon 11/06/17
        netcdf.putVar ( f, varid104, num_particles, particle_partNum );

        netcdf.putVar ( f, varid2, num_particles, rec_millisec );
        netcdf.putVar ( f, varid4, [0 num_particles], [2 1], position' );
        netcdf.putVar ( f, varid7, num_particles, part_micro );
        netcdf.putVar ( f, varid8, num_particles, parent_rec_num );
        netcdf.putVar ( f, varid9, num_particles, particle_num );
        netcdf.putVar ( f, varid9b,num_particles,num_subparticles);
        netcdf.putVar ( f, varid9c,num_particles,dist_min);
        netcdf.putVar ( f, varidx,  num_particles, ctx);
        netcdf.putVar ( f, varidy,  num_particles, cty);
        netcdf.putVar ( f, varid10, num_particles, image_length);
        netcdf.putVar ( f, varid11, num_particles, image_width);
        netcdf.putVar ( f, varid12, num_particles, image_area*diode_size*diode_size/handles.tasRatio);
        netcdf.putVar ( f, varid13, num_particles, longest_y_within_a_slice);
        netcdf.putVar ( f, varid14, num_particles, max_top_edge_touching);
        netcdf.putVar ( f, varid15, num_particles, max_bottom_edge_touching);
        netcdf.putVar ( f, varid16, num_particles, image_touching_edge-'0');
        netcdf.putVar ( f, varid17, num_particles, int16(auto_reject));
        netcdf.putVar ( f, varid18, num_particles, is_hollow);
        netcdf.putVar ( f, varid19, num_particles, center_in);
        netcdf.putVar ( f, varid20, num_particles, axis_ratio);
        netcdf.putVar ( f, varid26, num_particles, minR*diode_size);
        netcdf.putVar ( f, varid27, num_particles, AreaR*diode_size);
        netcdf.putVar ( f, varid45, num_particles, Perimeter*diode_size);
        if 1==iEllipse
            netcdf.putVar ( f, varid48, num_particles, EllipseL*diode_size);
            netcdf.putVar ( f, varid49, num_particles, EllipseW*diode_size);
            netcdf.putVar ( f, varid69, num_particles, EllipseAngle);
            netcdf.putVar ( f, varidxe, num_particles, Ellipse_xpos);
            netcdf.putVar ( f, varidye, num_particles, Ellipse_ypos);
        end
        netcdf.putVar ( f, varid28, num_particles, percent_shadow);
        netcdf.putVar ( f, varid29, num_particles, max_hole_diameter);
        netcdf.putVar ( f, varid30, num_particles, edge_at_max_hole);
        netcdf.putVar ( f, varid31, num_particles, part_z);
        netcdf.putVar ( f, varid32, num_particles, sf);
        netcdf.putVar ( f, varid33, num_particles, int16(holroyd_habit));
        netcdf.putVar ( f, varid331, num_particles, FS); % Added variable ~ Joe Finlon 11/3/19
        if 1 == iNewHabit % Added variables ~ Julian Schima 11/16/22
            netcdf.putVar ( f, varid333, num_particles, wid_len_perc*diode_size);
    	    netcdf.putVar ( f, varid334, num_particles, circ_ratio);
    	    netcdf.putVar ( f, varid335, num_particles, edge_max_dim_ratio);
    	    netcdf.putVar ( f, varid336, num_particles, max_gap*diode_size);
    	    netcdf.putVar ( f, varid337, num_particles, Opacity);
    	    netcdf.putVar ( f, varid338, num_particles, aspect_ratio);
    	    netcdf.putVar ( f, varid339, num_particles, holroyd_perimeter*diode_size);
        end
        netcdf.putVar ( f, varid34, num_particles, area_hole_ratio);
        netcdf.putVar ( f, varid35, num_particles, int_arrival);
        netcdf.putVar ( f, varid36, diode_stats )

        if iCalcAllDiodeStats
            netcdf.putVar(f, varid37,[0 num_particles], [diodenum 1],diode_stats');
        end

        num_particles = num_particles+1; % Increment number of particles by 1



    end



end

%
%         %% Preallocate particle arrays
%
%         particle_num = zeros(1,num_particles);
%
%         parent_rec_num = i.*ones(1,num_particles);
%
%         particle_DOF = zeros(1,num_particles);
%
%         particle_partNum = zeros(1,num_particles);
%
%         particle_sliceCount = zeros(1,num_particles);
%
%         part_micro = zeros(1,num_particles);
%
%         time_in_seconds = zeros(1,num_particles);
%
%         rec_time = zeros(1,num_particles);
%         rec_date = zeros(1,num_particles);
%         rec_millisec = zeros(1,num_particles);
%
%
%         for kk = 1 : num_particles
%
%             c = c_arr{kk};
%
%             % Just to test if there are bad images, usually 0 area images
%             figsize = size(c);
%             if figsize(2)~=diodenum
%                 disp('Not equal to doide number');
%                 return
%             end
%
%             images.position(kk,:) = [start, j-1];
%             particle_num(kk) = mod(kk,66536);
%
%             particle_DOF(kk)=bitand(data(header_loc,4), 32768);
%             particle_partNum(kk)=double(data(header_loc,5));
%             particle_sliceCount(kk)=double(data(header_loc,6));
%
%             part_time = double(data(header_loc,7))*65536+double(data(header_loc,8)); % particle time in clock cycles
%
%             part_micro(kk) = part_time;
%
%             time_in_seconds(kk) = part_time*(handles.diodesize/(1000)/170);
%
%             if(kk>1) % ** Use diff(time_in_seconds) to compute int-arr time in post-processing **
%                 images.int_arrival(kk) = time_in_seconds(kk)-time_in_seconds(kk-1);
%             else
%                 images.int_arrival(kk) = 0;
%             end
%
%             rec_time(kk)=double(handles.hour)*10000+double(handles.minute)*100+double(handles.second);
%             rec_date(kk)=double(handles.year)*10000+double(handles.month)*100+double(handles.day);
%             rec_millisec(kk)=handles.millisec;
%
%             %% Determine the Particle Habit: We use the Holroyd algorithm here
%             handles.bits_per_slice = diodenum;
%             if iCalcAllDiodeStats
%                 images.diode_stats(kk,:) = sum(c=='0',1); % Option to save diode stats for every particle
%             end
%             diode_stats = diode_stats + sum(c=='0',1);
%
%             tempreturn = CGAL_minR(c, handles.tasRatio);
%             images.minR(kk) = tempreturn(1); % diameter of minimum enclosing circle
%             images.ctx(kk) = tempreturn(2); % position
%             images.cty(kk) = tempreturn(3);
%
%
%             % improved [EXPERIMENTAL] particle hollow identification ~ Wei Wu & Joe Finlon 11/3/19
%             [xImgMax, ~] = size(c);
%             if(images.minR(kk)*handles.diodesize<0.3 && length(find(c(max(1,floor(images.ctx(kk))):min(xImgMax,ceil(images.ctx(kk))),...
%                         max(1,floor(images.cty(kk))):min(handles.diodenum,ceil(images.cty(kk))))=='1')) >=1)
%                [~, images.FS(kk)] = holroyd(handles, c);
%                images.holroyd_habit(kk) = 's';
%                images.is_hollow(kk) = 1;
%             else
%                 [images.holroyd_habit(kk), images.FS(kk)] = holroyd(handles, c);
%                 images.is_hollow(kk) = 0;
%             end
%
%             %% Determine if the particle is rejected or not
%             %  Calculate the Particle Length, Width, Area, Auto Reject
%             %  Status And more... See calculate_reject_unified()
%             %  funtion for more information
%
%             [images.image_length(kk),images.image_width(kk),images.image_area(kk), images.longest_y_within_a_slice(kk), ...
%              images.max_top_edge_touching(kk),images.max_bottom_edge_touching(kk),images.image_touching_edge(kk),    ...
%              images.auto_reject(kk),images.is_hollow(kk),images.percent_shadow(kk),images.part_z(kk),images.sf(kk),  ...
%              images.area_hole_ratio(kk),images.max_hole_diameter(kk),images.edge_at_max_hole(kk),images.center_in(kk)] ...
%                 =calculate_reject_unified(c,handles,images.holroyd_habit(kk),images.is_hollow(kk));
%
%             images.image_area(kk) = sum(sum(c=='0'));
%             disttoedge = min(abs(handles.diodenum-images.cty(kk)),images.cty(kk));
%             if(images.center_in(kk)==1 && images.image_touching_edge(kk)~='0')
%                 images.image_area(kk)=images.image_area(kk)*2*(images.image_width(kk)-disttoedge)/images.image_width(kk);
%             end
%             images.AreaR(kk)=2*sqrt(images.image_area(kk)/3.1415926/handles.tasRatio);  % Calculate the Darea (area-equivalent diameter)
%             images.Perimeter(kk)=ParticlePerimeter(c)/sqrt(handles.tasRatio);
%
%             %% perform Korolev correction ~ Wei Wu 11/3/19
%             if(images.auto_reject(kk)=='H')
%                images.minR(kk) = images.minR(kk)/images.sf(kk);
%                 if (images.holroyd_habit(kk)~= 's')
%                     disp(['WARNING: Habit should be spherical but is '  , char(images.holroyd_habit(kk))]);
%                 end
%             end
%
%             if (images.image_width(kk)~=0)
%                 images.axis_ratio(kk)=images.image_length(kk)/images.image_width(kk);
%             else
%                 images.axis_ratio(kk)=0;
%             end
%
%                 if 1==iEllipse
%
%                     [images.EllipseL(kk), images.EllipseW(kk), images.EllipseAngle(kk), ...
%                      images.Ellipse_ypos(kk), images.Ellipse_xpos(kk)] = CGAL_EllipseSize_UIOPS(c);
%
%                 end
%
%                 %% Get the area ratio using the DL=max(DT,DP), only observed area are used
%                 if images.image_length(kk) > images.image_width(kk)
%                     images.percent_shadow(kk) = images.image_area(kk) / (pi * images.image_length(kk).^ 2 / 4);
%                 elseif images.image_width(kk) ~= 0
%                     images.percent_shadow(kk) = images.image_area(kk) / (pi * images.image_width(kk).^ 2 / 4);
%                 else
%                     images.percent_shadow(kk) = 0;
%                 end
%
%                 %clear c ind_matrix Not sure if this is necessary
%
%
%             %end
%
%
%
%          end
%
%         %% Flip image Ellipse Angles so that angles are defined based on time dimension
%          images.EllipseAngle(images.EllipseAngle>=0) = pi./2-images.EllipseAngle(images.EllipseAngle>=0);
%          images.EllipseAngle(images.EllipseAngle<0)  = -(pi./2 - abs(images.EllipseAngle(images.EllipseAngle<0)));
%
% 		%% Write out the processed information on NETCDF
% 		 netcdf.putVar ( f, varid0, wstart, num_slices, rec_time(:) );
% 		 netcdf.putVar ( f, varid1, wstart, num_slices, rec_date(:) );
%
% 		 netcdf.putVar ( f, varid101, wstart, num_slices, time_in_seconds(:) );
%          netcdf.putVar ( f, varid102, wstart, num_slices, particle_sliceCount ); % Used by all probes ~ Joe Finlon 11/06/17
%          netcdf.putVar ( f, varid103, wstart, num_slices, particle_DOF ); % Used by all probes ~ Joe Finlon 11/06/17
% 		 netcdf.putVar ( f, varid104, wstart, num_slices, particle_partNum );
%
% 		 netcdf.putVar ( f, varid2, wstart, num_slices, rec_millisec(:) );
% 		 netcdf.putVar ( f, varid4, [0 wstart], [2 num_slices], images.position' );
% 		 netcdf.putVar ( f, varid7, wstart, num_slices, part_micro(:) );
% 		 netcdf.putVar ( f, varid8, wstart, num_slices, parent_rec_num );
% 		 netcdf.putVar ( f, varid9, wstart, num_slices, particle_num(:) );
% 		 netcdf.putVar ( f, varidx,  wstart, num_slices, images.ctx);
% 		 netcdf.putVar ( f, varidy,  wstart, num_slices, images.cty);
% 		 netcdf.putVar ( f, varid10, wstart, num_slices, images.image_length);
% 		 netcdf.putVar ( f, varid11, wstart, num_slices, images.image_width);
% 		 netcdf.putVar ( f, varid12, wstart, num_slices, images.image_area*diode_size*diode_size/handles.tasRatio);
% 		 netcdf.putVar ( f, varid13, wstart, num_slices, images.longest_y_within_a_slice);
% 		 netcdf.putVar ( f, varid14, wstart, num_slices, images.max_top_edge_touching);
% 		 netcdf.putVar ( f, varid15, wstart, num_slices, images.max_bottom_edge_touching);
% 		 netcdf.putVar ( f, varid16, wstart, num_slices, images.image_touching_edge-'0');
% 		 netcdf.putVar ( f, varid17, wstart, num_slices, int16(images.auto_reject));
% 		 netcdf.putVar ( f, varid18, wstart, num_slices, images.is_hollow);
% 		 netcdf.putVar ( f, varid19, wstart, num_slices, images.center_in);
% 		 netcdf.putVar ( f, varid20, wstart, num_slices, images.axis_ratio);
% 		 netcdf.putVar ( f, varid26, wstart, num_slices, images.minR*diode_size);
% 		 netcdf.putVar ( f, varid27, wstart, num_slices, images.AreaR*diode_size);
% 		 netcdf.putVar ( f, varid45, wstart, num_slices, images.Perimeter*diode_size);
% 		 if 1==iEllipse
% 			netcdf.putVar ( f, varid48, wstart, num_slices, images.EllipseL*diode_size);
% 			netcdf.putVar ( f, varid49, wstart, num_slices, images.EllipseW*diode_size);
% 			netcdf.putVar ( f, varid69, wstart, num_slices, images.EllipseAngle);
%             netcdf.putVar ( f, varidxe, wstart, num_slices, images.Ellipse_xpos);
%             netcdf.putVar ( f, varidye, wstart, num_slices, images.Ellipse_ypos);
% 		 end
% 		 netcdf.putVar ( f, varid28, wstart, num_slices, images.percent_shadow);
% 		 netcdf.putVar ( f, varid29, wstart, num_slices, images.max_hole_diameter);
% 		 netcdf.putVar ( f, varid30, wstart, num_slices, images.edge_at_max_hole);
% 		 netcdf.putVar ( f, varid31, wstart, num_slices, images.part_z);
% 		 netcdf.putVar ( f, varid32, wstart, num_slices, images.sf);
% 		 netcdf.putVar ( f, varid33, wstart, num_slices, int16(images.holroyd_habit));
%          netcdf.putVar ( f, varid331, wstart, num_slices, images.FS); % Added variable ~ Joe Finlon 11/3/19
% 		 netcdf.putVar ( f, varid34, wstart, num_slices, images.area_hole_ratio);
% 		 netcdf.putVar ( f, varid35, wstart, num_slices, images.int_arrival);
% 		 netcdf.putVar ( f, varid36, diode_stats );
%
% 		 if iCalcAllDiodeStats
% 			netcdf.putVar ( f, varid37, [0 wstart], [diodenum num_slices], images.diode_stats' ); % Option to save diode stats for every particle
% 		 end
%
% 		%wstart = w+1;
%
%         wstart = wstart+num_slices+1; % Increment to new element
%
% 		clear rec_time rec_date rec_millisec part_hour part_min part_sec part_mil part_micro parent_rec_num particle_num images time_in_seconds particle_sliceCount particle_DOF particle_partNum
%
% 		clear images

%end


warning on all

netcdf.close(f);
end
