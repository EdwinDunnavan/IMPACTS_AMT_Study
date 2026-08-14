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

basename = {'200118222055'};

ddate = {'20200118'};

orientation = {'H'};


%basename = {'20230115'};

%ddate = {'20230115'};

%orientation = {'V'};


% 
% basename = {'200118174232','200118174232','200118222055','200118222055','200119000000','200119000000',...
%             '200201111513','200201111513','200201133541','200201133541',...
%             '200205181349','200205181349','200205222121','200205222121','200206000000','200206000000',...
%             '200213054727','200213054727','200213093449','200213093449','200213114305','200213114305',...
%             '200218165957','200218165957'};
% 
% ddate = {'20200118','20200118','20200118','20200118','20200118','20200118',...
%          '20200201','20200201','20200201','20200201',...
%          '20200205','20200205','20200205','20200205','20200205','20200205',...
%          '20200213','20200213','20200213','20200213','20200213','20200213',...
%          '20200218','20200218'};
% 
% orientation = {'H','V','H','V','H','V',...
%                'H','V','H','V',...
%                'H','V','H','V','H','V',...
%                'H','V','H','V','H','V',...
%                'H','V'};

probe_name = '2DS';
probe_type = 'SPEC';

UIOPS_dir = '/home/edwin.dunnavan/Documents/UIOPS/'; % UIOPS directory

tic

for hh = 1 : length(basename)

    if strcmp(probe_name,'HVPSA') || strcmp(probe_name,'HVPSB')

    data_dir =strcat( '/localdata/edunnavan/P3_probe_data/IMPACTS/',ddate{hh},'/HVPS/',probe_name,'/');

    probe_name_new = 'HVPS';

    else

    data_dir =strcat( '/localdata/edunnavan/P3_probe_data/IMPACTS/',ddate{hh},'/',probe_name,'/');

    probe_name_new = probe_name;

    end



% NEW
%parfor ii = 1:maxThreads

for ii = 2:2

basename_temp = basename;
orientation_temp = orientation;

%im_temp_out = strcat(data_dir,'imgData_test_',basename_temp{hh},'_',num2str(ii),'.',orientation_temp{hh},'.nc');

%im_temp_out = strcat(data_dir,'imgData_',basename_temp{hh},'_',num2str(ii),'.',orientation_temp{hh},'.nc');

im_temp_out = strcat(data_dir,'imgData_',basename_temp{hh},'.',probe_name,'_',num2str(ii),'.',orientation_temp{hh},'.nc');


proc_out = strcat(data_dir,'proc_new.',basename_temp{hh},'.',num2str(ii),'.',probe_name,'.',orientation_temp{hh},'.nc');

imgProc_par_SPEC(im_temp_out,proc_out,probe_name_new,1,0)

%imgProc_par(im_temp_out,proc_out,probe_name_new,0,0)

%% TESTING
%imgProc_par_new(im_temp_out,proc_out,probe_name_new,0,0)


end

end

toc


%% Resort all variables in file according to time
%delete(gcp)
