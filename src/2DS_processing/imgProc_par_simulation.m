function imgProc_par_simulation(infile, outfile, probename, iEllipse, iCalcAllDiodeStats, iNewHabit, varargin)
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

fprintf('**********************************************************************\n')
fprintf('* UNIVERSITY OF ILLINOIS/OKLAHOMA OAP SIMULATION PROCESSING SOFTWARE *\n')
fprintf('*                  Copyright (C) 2024                                *\n')
fprintf('**********************************************************************\n')
fprintf('* This program is free software: you can redistribute it\n')
fprintf('* and/or modify it under the terms of the GNU General Public \n')
fprintf('* License as published by the Free Software Foundation,\n')
fprintf('* either version 3 of the License, or (at your option) any\n')
fprintf('* later version.\n\n')
fprintf('* This program is distributed in the hope that it will be\n')
fprintf('* useful, but WITHOUT ANY WARRANTY; without even the implied\n')
fprintf('* warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR\n')
fprintf('* PURPOSE. See the GNU General Public License for more details.\n\n')

switch probename

    case 'HVPS'

        ds = 0.150;			     % Size of diode in millimeters
        handles.diodesize = ds;
        handles.diodenum  = 128; % Diode number
        handles.current_image = 1;
        probetype = 2;

    case '2DS'

        ds = 0.010;			     % Size of diode in millimeters
        handles.diodesize = ds;
        handles.diodenum  = 128; % Diode number
        handles.current_image = 1;
        probetype = 2;

end


diodenum = handles.diodenum;
handles.disagree = 0;

diode_size = handles.diodesize;

%% Read the particle image files
handles.f = netcdf.open(infile,'nowrite');
[~, handles.img_count] = netcdf.inqDim(handles.f,0);
warning off all

%% Create output NETCDF file and variables

f = netcdf.create(outfile,'NETCDF4'); % netCDF-4/HDF5 compression support - Added by Joe Finlon 02/13/19
dimid1 = netcdf.defDim(f,'pos_count',2);
dimid2 = netcdf.defDim(f,'bin_count',diodenum);

NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(f, NC_GLOBAL, 'Creation Time', datestr(datetime('now'), 'yyyy/mm/dd HH:MM:SS'));
netcdf.putAtt(f, NC_GLOBAL, 'Description', ['Contains size, morphological, ',...
    'and other particle properties from simulation image file.']);
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

num_particles = 0;

%% Analyze each individual particle images and output the particle by particle information
for parent_rec_num= 1 : handles.img_count % i = buffer strip


    varid = netcdf.inqVarID(handles.f,'data');


    %% Allocate arrays for number of particles

        %% Each slice goes (columnwise): start (1), header (2), j index = photodiode array (3:end)


        c_orig=[dec2bin(ind_matrix(:,1),16), dec2bin(ind_matrix(:,2),16),dec2bin(ind_matrix(:,3),16),dec2bin(ind_matrix(:,4),16), ...
            dec2bin(ind_matrix(:,5),16), dec2bin(ind_matrix(:,6),16),dec2bin(ind_matrix(:,7),16),dec2bin(ind_matrix(:,8),16)];
        
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

            holroyd_habit = 's';
            is_hollow = 1;
        else

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
        netcdf.putVar ( f, varid104, num_particles, particle_partNum );
        netcdf.putVar ( f, varid4, [0 num_particles], [2 1], position' );
        netcdf.putVar ( f, varid7, num_particles, part_micro );
        netcdf.putVar ( f, varid8, num_particles, parent_rec_num );
        netcdf.putVar ( f, varid9, num_particles, particle_num );
        netcdf.putVar ( f, varidx,  num_particles, ctx);
        netcdf.putVar ( f, varidy,  num_particles, cty);
        netcdf.putVar ( f, varid10, num_particles, image_length);
        netcdf.putVar ( f, varid11, num_particles, image_width);
        netcdf.putVar ( f, varid12, num_particles, image_area*diode_size*diode_size/handles.tasRatio);
        netcdf.putVar ( f, varid13, num_particles, longest_y_within_a_slice);
        netcdf.putVar ( f, varid17, num_particles, int16(auto_reject));
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

        num_particles = num_particles+1; % Increment number of particles by 1


end


warning on all

netcdf.close(f);
end
