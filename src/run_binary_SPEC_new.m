
% run_binary_SPEC_new.m

base_list = {'230115191025'};
date_list = {'20230115'};

data_dir = '/localdata/edunnavan/P3_probe_data/IMPACTS/';

probe_name = 'HVPSA';
probe_type = 'SPEC';


for hh = 1 : length(base_list)

if strcmp(probe_name,'HVPSA') || strcmp(probe_name,'HVPSB')

    data_dir = strcat('/localdata/edunnavan/P3_probe_data/IMPACTS/',date_list{hh},'/HVPS/',probe_name,'/');

    probe_name_new = 'HVPS';

else

    data_dir = strcat('/localdata/edunnavan/P3_probe_data/IMPACTS/',date_list{hh},'/',probe_name,'/');

    probe_name_new = probe_name;

end

%date_dir = strcat(data_dir,date_list{hh})

%read_binary_SPEC_new(strcat(date_dir,'/2DS/','base',base_list{hh},'.2DS'),strcat(date_dir,'/2DS/','imgData_',base_list{hh},'_'))	


read_binary_SPEC_new(strcat(data_dir,'base',base_list{hh},'.',probe_name_new),...
		     strcat(data_dir,'imgData_new_',base_list{hh},'_'))


%read_binary_SPEC(strcat(data_dir,'base',base_list{hh},'.',probe_name_new),...
%		     strcat(data_dir,'imgData_OLDmethod_',base_list{hh},'_'))


end

