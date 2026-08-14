
% run_binary_SPEC_dates.m

% 2DS 2020 dates
%date_list = {'20200118','20200125','20200201','20200205','20200207','20200213','20200218','20200220'};

% 2DS 2022 dates
%date_list = {'20220129','20220208','20220213','20220217','20220219','20220225'};

% 2DS 2023 dates
%date_list = {'20230113','20230115','20230119','20230123','20230125','20230129','20230205','20230209','20230212','20230214',...
%             '20230216','20230223','20230228'};

% HVPS 2020 dates
%date_list = {'20200207','20200213','20200218','20200220','20200225'};

date_list = {'20200207'};

% HVPS 2022 dates
%date_list_HVPS = {'20220114','20220129','20220204','20220208','20220213','20220217','20220219','20220225'};

% HVPS 2023 dates
%date_list = {'20230113','20230115','20230119','20230123','20230125','20230129','20230205','20230209','20230212','20230214',...
%             '20230216','20230223','20230228'};



%date_list = {'20200207','20200213','20200218','20200220','20200225','20220114','20220129','20220204','20220208','20220213',...
%	     '20220217','20220219','20220225','20230113','20230115','20230119','20230123','20230129','20230205','20230209',...
%	     '20230212','20230214','20230216','20230223','20230228'};

%date_list = {'20230125'};

%date_list = {'20230115'};

data_dir = '/localdata/edunnavan/P3_probe_data/IMPACTS/';

probe_name = 'HVPSB';
probe_type = 'SPEC';


for hh = 1 : length(date_list)

if strcmp(probe_name,'HVPSA') || strcmp(probe_name,'HVPSB')

    data_dir = strcat('/localdata/edunnavan/P3_probe_data/IMPACTS/',date_list{hh},'/HVPS/',probe_name,'/');

    probe_name_new = 'HVPS';

else

    data_dir = strcat('/localdata/edunnavan/P3_probe_data/IMPACTS/',date_list{hh},'/',probe_name,'/');

    probe_name_new = probe_name;

end

% Find base* files
base_files= dir(strcat(data_dir,'base*'));

base_list = {base_files.name};

for ii = 1:length(base_list)

read_binary_SPEC_new(strcat(data_dir,base_list{ii}),...
		     strcat(data_dir,'imgData_',base_list{ii}(5:end),'_'))

%read_binary_SPEC_ORIGINAL(strcat(data_dir,base_list{ii}),...
%		     strcat(data_dir,'imgData_new3_',base_list{ii},'_'))

end


end

