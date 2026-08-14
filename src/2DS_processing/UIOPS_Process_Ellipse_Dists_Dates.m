% UIOPS_Process_Ellipse_Dists.m

% Description: 
% 
% 1.) Read in probe images from directory
% 2.) Generate .cdf file 
% 3.) Compute Ellipse fits
% 4.) Compute Size Distributions
% 5.) Sort all data in time for .cdf output file.

%% Set up some boring stuff

% Convert to datetime for time
% Time =datetime(strcat(string(ncread('procHVPS.20151205_subset.V.cdf','Date')),'-',string(ncread('procHVPS.20151205_subset.V.cdf','Time')),'.',...
% string(ncread('procHVPS.20151205_subset.V.cdf','msec'))),'InputFormat','yyyyMMdd-HHmmss.SSS');

maxThreads = maxNumCompThreads;

%p = gcp('nocreate');

%if isempty(gcp('nocreate'))
%parpool(maxThreads); % Assign n CPUs to process

%end
%gcpp = gcp('nocreate')

% Dates for Song:
% 20200207, 20220217, 20200220, 20200125

% 2020 2DS dates
%date_list = {'20200118','20200125','20200201','20200205','20200207','20200213','20200218','20200220'};

date_list = {'20200218'};

% 2022 2DS dates
%date_list = {'20220208','20220213','20220217','20220219','20220225'};

% 2023 2DS dates
%date_list = {'20230113','20230115','20230119','20230123','20230125','20230129','20230205',...
 %            '20230209','20230212','20230214','20230216','20230223','20230228'};

%date_list = {'20230125','20230129','20230205','20230209','20230212','20230214','20230216','20230223','20230228'};

%date_list = {'20230123','20230125','20230129','20230205',...
%             '20230209','20230212','20230214','20230216','20230223','20230228'};


% 2020-2022 HVPS dates
% date_list = {'20200207','20200213','20200218','20200220','20200225','20220114','20220129',...
%              '20220204','20220208','20220213','20220217','20220219','20220225'};

%date_list = {'20220213','20220217','20220219','20220225'};


%date_list = {'20200207'};

%orientation = {'V'};

probe_name = '2DS';
probe_type = 'SPEC';

UIOPS_dir = '/home/edwin.dunnavan/Documents/UIOPS/'; % UIOPS directory

tic

for hh = 1 : length(date_list)

    if strcmp(probe_name,'HVPSA') || strcmp(probe_name,'HVPSB')

    data_dir =strcat( '/localdata/edunnavan/P3_probe_data/IMPACTS/',date_list{hh},'/HVPS/',probe_name,'/');

    probe_name_new = 'HVPS';

    orientation = {'V'};

    else

    data_dir =strcat('/localdata/edunnavan/P3_probe_data/IMPACTS/',date_list{hh},'/',probe_name,'/');

    probe_name_new = probe_name;

    orientation = {'H','V'};

    end


        % Find base* files

base_files = dir(strcat(data_dir,'base*'));
        
base_names = {base_files.name};

%imgData_files= dir(strcat(data_dir,'imgData_new*',orient_temp,'.nc'));

%imgData_list = {imgData_files.name};


for jj = 1 : length(base_names)

    base_temp = base_names{jj}(5:16);


for kk = 1 : length(orientation)

    orient_temp = orientation{kk};

   %basename_temp = imgData_temp(17:end);


% NEW

parfor ii = 1:maxThreads

   base_name_temp = base_temp;
   orient_new_temp = orient_temp;

   imgData_temp = dir(strcat(data_dir,'imgData_',base_name_temp,'.',probe_name_new,'_',num2str(ii),'.',orient_new_temp,'.nc'));

   imgData_name = imgData_temp.name;


%orientation_temp = orientation;

%im_temp_out = strcat(data_dir,'imgData_new_base',basename_temp{hh},'_',num2str(ii),'.',orientation_temp{hh},'.nc');


%im_temp_out = strcat(data_dir,'imgData_',basename_temp{hh},'.',probe_name,'_',num2str(ii),'.',orientation_temp{hh},'.nc');


%proc_out = strcat(data_dir,'proctemp.',basename_temp{hh},'.',num2str(ii),'.',probe_name,'.',orientation_temp{hh},'.nc');

%imgProc_par_SPEC(im_temp_out,proc_out,probe_name_new,1,0)


im_temp_out = strcat(data_dir,imgData_name);

proc_out = strcat(data_dir,'proc_5.',base_name_temp,'.',num2str(ii),'.',probe_name,'.',orient_new_temp,'.nc');

%imgProc_par_SPEC(im_temp_out,proc_out,probe_name_new,1,0)

imgProc_par_SPEC(im_temp_out,proc_out,probe_name_new,1,0,1)

%disp(proc_out)

%disp(im_temp_out)


end


end

end

end

toc


%% Resort all variables in file according to time
%delete(gcp)
