function imgProc_par_new(infile, outfile, probename, iRectEllipse, iCalcAllDiodeStats, varargin)
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
		case '2DC'
			boundary = [255 255 255 255];
			boundarytime = 85;
			
			ds = 0.025;			     % Size of diode in millimeters
			handles.diodesize = ds;
			handles.diodenum  = 32;  % Diode number
			handles.current_image = 1;
			probetype = 0;
			
		case '2DP'
			boundary = [255 255 255 255];
			boundarytime = 85;
			
			ds = 0.200;			     % Size of diode in millimeters
			handles.diodesize = ds;
			handles.diodenum  = 32;  % Diode number
			handles.current_image = 1;
			probetype = 0;
			
		case 'CIP'
			boundary = [170, 170, 170, 170, 170, 170, 170, 170];
			boundarytime = NaN;
			
			ds = 0.025;			     % Size of diode in millimeters
			handles.diodesize = ds;
			handles.diodenum  = 64;  % Diode number
			handles.current_image = 1;
			probetype = 1;
			
		case 'PIP'
			boundary = [170, 170, 170, 170, 170, 170, 170, 170];
			boundarytime = NaN;
			
			ds = 0.100;			     % Size of diode in millimeters
			handles.diodesize = ds;
			handles.diodenum  = 64;  % Diode number
			handles.current_image = 1;
			probetype = 1;
			
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
            
        case 'Fast2DC' % Added support for Fast2DC ~ Joe Finlon 12/28/17
            boundary = [170, 170, 170];
			boundarytime = NaN;
			
			ds = 0.025;			     % Size of diode in millimeters
			handles.diodesize = ds;
			handles.diodenum  = 64;  % Diode number
			handles.current_image = 1;
			probetype = 3;
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
	%netcdf.putAtt(f, NC_GLOBAL, 'Software', software_string);
% 	netcdf.putAtt(f, NC_GLOBAL, 'Institution', 'Univ. Illinois, Dept. Atmos. Sciences');
	netcdf.putAtt(f, NC_GLOBAL, 'Creation Time', datestr(now, 'yyyy/mm/dd HH:MM:SS'));
	netcdf.putAtt(f, NC_GLOBAL, 'Description', ['Contains size, morphological, ',...
		'and other particle properties from an uncompressed image file.']);
	netcdf.putAtt(f, NC_GLOBAL, 'Image Source', infile);
	netcdf.putAtt(f, NC_GLOBAL, 'Probe Type', probename);
	if iRectEllipse && iCalcAllDiodeStats
		netcdf.putAtt(f, NC_GLOBAL, 'Optional parameters active',...
			'Rectangle & elliptical fits & per-particle diode statistics');
	elseif iRectEllipse && ~iCalcAllDiodeStats
		netcdf.putAtt(f, NC_GLOBAL, 'Optional parameters active',...
			'Rectangle & elliptical fits');
	elseif ~iRectEllipse && iCalcAllDiodeStats
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
	%varid3 = netcdf.defVar(f,'wkday','double',dimid0);
	varid4  = netcdf.defVar(f,'position','short',[dimid1 dimid0]);
	netcdf.putAtt(f, varid4, 'Units', '--')
	netcdf.putAtt(f, varid4, 'Description', 'Slice within image record where particle is first sampled')
    netcdf.defVarDeflate(f, varid4, true, true, 9);
	
	varid5  = netcdf.defVar(f,'particle_time','int',dimid0);
	netcdf.putAtt(f, varid5, 'Units', 'HHMMSS')
	netcdf.putAtt(f, varid5, 'Description', 'Particle time (not available for 2DS/HVPS)')
    netcdf.defVarDeflate(f, varid5, true, true, 9);
	
	varid6  = netcdf.defVar(f,'particle_millisec','short',dimid0);
	netcdf.putAtt(f, varid6, 'Units', 'ms')
	netcdf.putAtt(f, varid6, 'Description', 'Sub-second particle time (not available for 2DS/HVPS)')
    netcdf.defVarDeflate(f, varid6, true, true, 9);
	
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
	
	if 1==iRectEllipse
% 		varid46 = netcdf.defVar(f,'image_RectangleL','double',dimid0);
% 		netcdf.putAtt(f, varid46, 'Units', 'mm')
% 		netcdf.putAtt(f, varid46, 'Description', 'Length of smallest rectangle enclosing the particle')
%         netcdf.defVarDeflate(f, varid46, true, true, 9);
% 		
% 		varid47 = netcdf.defVar(f,'image_RectangleW','double',dimid0);
% 		netcdf.putAtt(f, varid47, 'Units', 'mm')
% 		netcdf.putAtt(f, varid47, 'Description', 'Width of smallest rectangle enclosing the particle')
%         netcdf.defVarDeflate(f, varid47, true, true, 9);
% 		
% 		varid67 = netcdf.defVar(f,'image_RectangleAngle','double',dimid0);
% 		netcdf.putAtt(f, varid67, 'Units', 'radians')
% 		netcdf.putAtt(f, varid67, 'Description', 'Angle of rectangle with respect to the time direction')
%         netcdf.defVarDeflate(f, varid67, true, true, 9);
		
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
	netcdf.putAtt(f, varid33, 'Description', ['ASCII habit code following the Holroyd (1987) algorithm ',...
		'("M" or 77: zero image; "C" or 67: center-out image; "t" or 116: tiny; "o" or 111: oriented; ',...
		'"l" or 108: linear; "a" or 97: aggregate; "g" or 103: graupel; "s" or 115: sphere; ',...
		'"h" or 104: hexagonal; "i" or 105: irregular; "d" or 100: dendrite)'])
    netcdf.defVarDeflate(f, varid33, true, true, 9);
    
    varid331 = netcdf.defVar(f,'fine_detail_ratio','double',dimid0); % added variable to file output ~ Joe Finlon 11/3/19
    netcdf.putAtt(f, varid331, 'Units', '--')
    netcdf.putAtt(f, varid331, 'Description', 'Perim*Diam/Area following Holroyd (1987)')
    netcdf.defVarDeflate(f,varid331,true,true,9);
	
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
	w=-1;
	wstart = 0;
	
	%% Analyze each individual particle images and output the particle by particle information
	for i= 1 : handles.img_count % i = buffer strip
	
        %% Read in Buffer strip info
		handles.year     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'year'    ),i-1,1);
		handles.month    = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'month'  ),i-1,1);
		handles.day      = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'day'  ),i-1,1);
		handles.hour     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'hour'    ),i-1,1);
		handles.minute   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'minute'  ),i-1,1);
		handles.second   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'second'  ),i-1,1);
		handles.millisec = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'millisec'),i-1,1);
        if probetype == 0 || probetype == 3 % Contains dead time for PMS probes ~ Joe Finlon & Adam Majewski 11/06/17
            handles.wkday = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'wkday'),i-1,1);
        end
        
        % Optionally use TAS ratio between the probe value and the aircraft
        % value ~ Joe Finlon 11/3/19, 02/07/20
        if iTAS==1
            handles.tasRatio = tasRatio(i);
        else
            handles.tasRatio = 1.0;
        end
        
		if mod(i,100) == 0
			disp([num2str(i),'/',num2str(handles.img_count), ', ', num2str(double(handles.hour)*10000+double(handles.minute)*100+double(handles.second))])

		end
		varid = netcdf.inqVarID(handles.f,'data');

        temp = netcdf.getVar(handles.f,varid,[0, 0, i-1], [8,1700,1],'uint16');

		data(:,:) = temp';
		
		j=1; % j= portions of buffer strip with particles
        
        % Find number of slices in buffer strip i
        bind = zeros(1,size(data,1));

        for ll = 1 : size(data,1)
        bind(ll) = (isequal(data(ll,1:length(boundary)), boundary) && ( (isequal(data(ll+1,1), boundarytime) ) ) && data(ll,1)~=-1);
        end

        bind = find(bind==1);

        start_arr = ones(1,length(bind));
        start_arr(2:end) = 2+bind(2:end);


        %% Allocate arrays for number of particles 
        num_particles = length(bind);

        if num_particles==0

            continue

        end

        particle_num = zeros(1,num_particles);

        parent_rec_num = i.*ones(1,num_particles);

        particle_DOF = zeros(1,num_particles);

        particle_partNum = zeros(1,num_particles);

        particle_sliceCount = zeros(1,num_particles);

        part_micro = zeros(1,num_particles);
        part_mil = zeros(1,num_particles);
        part_sec = zeros(1,num_particles);
        part_min = zeros(1,num_particles);
        part_hour = zeros(1,num_particles);

        time_in_seconds = zeros(1,num_particles);

        rec_time = zeros(1,num_particles);
        rec_date = zeros(1,num_particles);
        rec_millisec = zeros(1,num_particles);

        for kk = 1 : length(start_arr)

            start = start_arr(kk);

            header_loc = start+1;

            w=w+1; % counter for writing particle data in order from all buffer strips

            ind_matrix(1:j-start,:) = 65535 - data(start:j-1,:); % I used 1 to indicate the illuminated doides for HVPS
            c=[dec2bin(ind_matrix(:,1),16), dec2bin(ind_matrix(:,2),16),dec2bin(ind_matrix(:,3),16),dec2bin(ind_matrix(:,4),16), ...
               dec2bin(ind_matrix(:,5),16), dec2bin(ind_matrix(:,6),16),dec2bin(ind_matrix(:,7),16),dec2bin(ind_matrix(:,8),16)];

            % Correct images for noise: ensure that at least 5 or
            % pix_thresh percent of total shadowed pixels are needed for
            % connected pixels
            c = char('1'-bwareaopen('1'-c,max(5,floor(0.01*pix_thresh*sum(sum(c=='0'))))));

            % Just to test if there are bad images, usually 0 area images
            figsize = size(c);
            if figsize(2)~=diodenum
                disp('Not equal to doide number');
                return
            end
                
                
            images.position(kk,:) = [start, j-1];
            parent_rec_num(kk)=i;
            particle_num(kk) = mod(kk,66536); %hex2dec([dec2hex(data(start-1,7)),dec2hex(data(start-1,8))]);
                


            particle_DOF(kk)=bitand(data(header_loc,4), 32768);
            particle_partNum(kk)=double(data(header_loc,5));
            particle_sliceCount(kk)=double(data(header_loc,6));
                    
            part_time = double(data(header_loc,7))*65536+double(data(header_loc,8)); % particle time in clock cycles

            part_micro(kk) = part_time;
            part_mil(kk)   = 0;
            part_sec(kk)   = 0;
            part_min(kk)   = 0;
            part_hour(kk)  = 0;
                   
            time_in_seconds(kk) = part_time*(handles.diodesize/(10^3)/170);
                    
            if(kk>1) % ** Use diff(time_in_seconds) to compute int-arr time in post-processing **
                images.int_arrival(kk) = time_in_seconds(kk)-time_in_seconds(kk-1);
            else
                images.int_arrival(kk) = 0;
            end      
    
            rec_time(kk)=double(handles.hour)*10000+double(handles.minute)*100+double(handles.second);
            rec_date(kk)=double(handles.year)*10000+double(handles.month)*100+double(handles.day);
            rec_millisec(kk)=handles.millisec;

            %% Determine the Particle Habit: We use the Holroyd algorithm here
            handles.bits_per_slice = diodenum;
            if iCalcAllDiodeStats
                images.diode_stats(kk,:) = sum(c=='0',1); % Option to save diode stats for every particle
            end
            diode_stats = diode_stats + sum(c=='0',1);
                
            tempreturn = CGAL_minR(c, handles.tasRatio);
            images.minR(kk) = tempreturn(1); % diameter of minimum enclosing circle
            images.ctx(kk) = tempreturn(2); % position
            images.cty(kk) = tempreturn(3);
                
            % improved [EXPERIMENTAL] particle hollow identification ~ Wei Wu & Joe Finlon 11/3/19
            [xImgMax, ~] = size(c);
            if(images.minR(kk)*handles.diodesize<0.3 && length(find(c(max(1,floor(images.ctx(kk))):min(xImgMax,ceil(images.ctx(kk))),...
                        max(1,floor(images.cty(kk))):min(handles.diodenum,ceil(images.cty(kk))))=='1')) >=1)
               [~, images.FS(kk)] = holroyd(handles, c);
               images.holroyd_habit(kk) = 's';
               images.is_hollow(kk) = 1;
            else 
                [images.holroyd_habit(kk), images.FS(kk)] = holroyd(handles, c);
                images.is_hollow(kk) = 0;
            end
                
            %% Determine if the particle is rejected or not
            %  Calculate the Particle Length, Width, Area, Auto Reject
            %  Status And more... See calculate_reject_unified()
            %  funtion for more information
                
            [images.image_length(kk),images.image_width(kk),images.image_area(kk), images.longest_y_within_a_slice(kk), ...
             images.max_top_edge_touching(kk),images.max_bottom_edge_touching(kk),images.image_touching_edge(kk),    ...
             images.auto_reject(kk),images.is_hollow(kk),images.percent_shadow(kk),images.part_z(kk),images.sf(kk),  ...
             images.area_hole_ratio(kk),images.max_hole_diameter(kk),images.edge_at_max_hole(kk),images.center_in(kk)] ...
                =calculate_reject_unified(c,handles,images.holroyd_habit(kk),images.is_hollow(kk));
                
            images.image_area(kk) = sum(sum(c=='0'));
            disttoedge = min(abs(handles.diodenum-images.cty(kk)),images.cty(kk));
            if(images.center_in(kk)==1 && images.image_touching_edge(kk)~='0')
                images.image_area(kk)=images.image_area(kk)*2*(images.image_width(kk)-disttoedge)/images.image_width(kk);
            end
            images.AreaR(kk)=2*sqrt(images.image_area(kk)/3.1415926/handles.tasRatio);  % Calculate the Darea (area-equivalent diameter)
            images.Perimeter(kk)=ParticlePerimeter(c)/sqrt(handles.tasRatio);
                
            %% perform Korolev correction ~ Wei Wu 11/3/19
            if(images.auto_reject(kk)=='H')
               images.minR(kk) = images.minR(kk)/images.sf(kk);
                if (images.holroyd_habit(kk)~= 's')
                    disp(['WARNING: Habit should be spherical but is '  , char(images.holroyd_habit(kk))]);
                end
            end
                
            if (images.image_width(kk)~=0)
                images.axis_ratio(kk)=images.image_length(kk)/images.image_width(kk);
            else
                images.axis_ratio(kk)=0;
            end
                    
                if 1==iRectEllipse

                    [images.EllipseL(kk), images.EllipseW(kk), images.EllipseAngle(kk), ...
                     images.Ellipse_ypos(kk), images.Ellipse_xpos(kk)] = CGAL_EllipseSize_UIOPS(c);

                end

                %% Get the area ratio using the DL=max(DT,DP), only observed area are used
                if images.image_length(kk) > images.image_width(kk)
                    images.percent_shadow(kk) = images.image_area(kk) / (pi * images.image_length(kk).^ 2 / 4);
                elseif images.image_width(kk) ~= 0
                    images.percent_shadow(kk) = images.image_area(kk) / (pi * images.image_width(kk).^ 2 / 4);
                else
                    images.percent_shadow(kk) = 0;
                end
                
                clear c ind_matrix

         end

        %% Flip image Ellipse Angles so that angles are defined based on time dimension
         images.EllipseAngle(images.EllipseAngle>=0) = pi./2-images.EllipseAngle(images.EllipseAngle>=0);
         images.EllipseAngle(images.EllipseAngle<0)  = -(pi./2 - abs(images.EllipseAngle(images.EllipseAngle<0)));
		

		%% Write out the processed information on NETCDF
		 netcdf.putVar ( f, varid0, wstart, w-wstart+1, rec_time(:) );
		 netcdf.putVar ( f, varid1, wstart, w-wstart+1, rec_date(:) );
		
		 netcdf.putVar ( f, varid101, wstart, w-wstart+1, time_in_seconds(:) );
         netcdf.putVar ( f, varid102, wstart, w-wstart+1, particle_sliceCount ); % Used by all probes ~ Joe Finlon 11/06/17
         netcdf.putVar ( f, varid103, wstart, w-wstart+1, particle_DOF ); % Used by all probes ~ Joe Finlon 11/06/17
		 netcdf.putVar ( f, varid104, wstart, w-wstart+1, particle_partNum );
         
		
		 netcdf.putVar ( f, varid2, wstart, w-wstart+1, rec_millisec(:) );
		 netcdf.putVar ( f, varid4, [0 wstart], [2 w-wstart+1], images.position' );
		 netcdf.putVar ( f, varid5, wstart, w-wstart+1, part_hour(:)*10000+part_min(:)*100+part_sec(:) );
		 netcdf.putVar ( f, varid6, wstart, w-wstart+1, part_mil(:) );
		 netcdf.putVar ( f, varid7, wstart, w-wstart+1, part_micro(:) );
		 netcdf.putVar ( f, varid8, wstart, w-wstart+1, parent_rec_num );
		 netcdf.putVar ( f, varid9, wstart, w-wstart+1, particle_num(:) );
		 netcdf.putVar ( f, varidx,  wstart, w-wstart+1, images.ctx);
		 netcdf.putVar ( f, varidy,  wstart, w-wstart+1, images.cty);
		 netcdf.putVar ( f, varid10, wstart, w-wstart+1, images.image_length);
		 netcdf.putVar ( f, varid11, wstart, w-wstart+1, images.image_width);
		 netcdf.putVar ( f, varid12, wstart, w-wstart+1, images.image_area*diode_size*diode_size/handles.tasRatio);
		 netcdf.putVar ( f, varid13, wstart, w-wstart+1, images.longest_y_within_a_slice);
		 netcdf.putVar ( f, varid14, wstart, w-wstart+1, images.max_top_edge_touching);
		 netcdf.putVar ( f, varid15, wstart, w-wstart+1, images.max_bottom_edge_touching);
		 netcdf.putVar ( f, varid16, wstart, w-wstart+1, images.image_touching_edge-'0');
		 netcdf.putVar ( f, varid17, wstart, w-wstart+1, int16(images.auto_reject));
		 netcdf.putVar ( f, varid18, wstart, w-wstart+1, images.is_hollow);
		 netcdf.putVar ( f, varid19, wstart, w-wstart+1, images.center_in);
		 netcdf.putVar ( f, varid20, wstart, w-wstart+1, images.axis_ratio);
		 netcdf.putVar ( f, varid26, wstart, w-wstart+1, images.minR*diode_size);
		 netcdf.putVar ( f, varid27, wstart, w-wstart+1, images.AreaR*diode_size);
		 netcdf.putVar ( f, varid45, wstart, w-wstart+1, images.Perimeter*diode_size);
		 if 1==iRectEllipse
% 				netcdf.putVar ( f, varid46, wstart, w-wstart+1, images.RectangleL*diode_size);
% 				netcdf.putVar ( f, varid47, wstart, w-wstart+1, images.RectangleW*diode_size);
% 				netcdf.putVar ( f, varid67, wstart, w-wstart+1, images.RectangleAngle);
			netcdf.putVar ( f, varid48, wstart, w-wstart+1, images.EllipseL*diode_size);
			netcdf.putVar ( f, varid49, wstart, w-wstart+1, images.EllipseW*diode_size);
			netcdf.putVar ( f, varid69, wstart, w-wstart+1, images.EllipseAngle);
            netcdf.putVar ( f, varidxe, wstart, w-wstart+1, images.Ellipse_xpos);
            netcdf.putVar ( f, varidye, wstart, w-wstart+1, images.Ellipse_ypos);
		 end
		 netcdf.putVar ( f, varid28, wstart, w-wstart+1, images.percent_shadow);
		 netcdf.putVar ( f, varid29, wstart, w-wstart+1, images.max_hole_diameter);
		 netcdf.putVar ( f, varid30, wstart, w-wstart+1, images.edge_at_max_hole);
		 netcdf.putVar ( f, varid31, wstart, w-wstart+1, images.part_z);
		 netcdf.putVar ( f, varid32, wstart, w-wstart+1, images.sf);
		 netcdf.putVar ( f, varid33, wstart, w-wstart+1, int16(images.holroyd_habit));
         netcdf.putVar ( f, varid331, wstart, w-wstart+1, images.FS); % Added variable ~ Joe Finlon 11/3/19
		 netcdf.putVar ( f, varid34, wstart, w-wstart+1, images.area_hole_ratio);
		 netcdf.putVar ( f, varid35, wstart, w-wstart+1, images.int_arrival);
		 netcdf.putVar ( f, varid36, diode_stats );
		
		 if iCalcAllDiodeStats
			netcdf.putVar ( f, varid37, [0 wstart], [diodenum w-wstart+1], images.diode_stats' ); % Option to save diode stats for every particle
		 end
		
		%wstart = w+1;

        wstart = wstart+num_particles+1;

		clear rec_time rec_date rec_millisec part_hour part_min part_sec part_mil part_micro parent_rec_num particle_num images time_in_seconds particle_sliceCount particle_DOF particle_partNum
		
		
		clear images
		
	end
	
	
	warning on all
	
	netcdf.close(f);
end
