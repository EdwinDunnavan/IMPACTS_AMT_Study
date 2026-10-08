
function obj = read_stl_data_init(folder)

%% get netcdf file names
fdir = dir(fullfile(folder,'stl_ellipsoids*.nc'));

if isempty(fdir)
    error('No init NetCDF files found in folder!');
end

N = length(fdir);

obj.particle_number = [];
obj.a = [];
obj.b = [];
obj.c = [];
obj.aspect_ratio = [];
obj.max_dim = [];

%% Loop through files and read variables into arrays
for ff = 1 : N
    ftemp = fullfile(fdir(ff).folder,fdir(ff).name);
    finfo = ncinfo(ftemp);
    fnames = string({finfo.Variables.Name});

    obj.particle_number = [obj.particle_number ncread(ftemp,'particle_number')'];
    obj.a = [obj.a ncread(ftemp,'a')'];
    obj.b = [obj.b ncread(ftemp,'b')'];
    obj.c = [obj.c ncread(ftemp,'c')'];

    if any(fnames=='aspect_ratio')
        obj.aspect_ratio = [obj.aspect_ratio ncread(ftemp,'aspect_ratio')'];
    else
        obj.aspect_ratio = [obj.aspect_ratio NaN(size(ncread(ftemp,'particle_number')))'];
    end

    if any(fnames=='max_dim')
        obj.max_dim = [obj.max_dim ncread(ftemp,'max_dim')'];
    else
        obj.max_dim = [obj.max_dim NaN(size(ncread(ftemp,'particle_number')))'];
    end
end

%% CRITICAL FIX: Resort all data by particle_number
[obj.particle_number, sort_ind] = sort(obj.particle_number);

obj.a = obj.a(sort_ind);
obj.b = obj.b(sort_ind);
obj.c = obj.c(sort_ind);
obj.aspect_ratio = obj.aspect_ratio(sort_ind);
obj.max_dim = obj.max_dim(sort_ind);

end


% function obj = read_stl_data_init(folder)
% 
% %% get netcdf file names
% %fdir = dir(strcat(folder,'stl_ellipsoids*.nc'));
% 
% fdir = dir(fullfile(folder,'stl_ellipsoids*.nc'));
% 
% N = length(fdir);
% 
% %obj.index = [];
% 
% obj.particle_number = [];
% 
% obj.a = [];
% obj.b = [];
% obj.c = [];
% obj.vertices = [];
% obj.connectivity=[];
% 
% obj.aspect_ratio = [];
% obj.max_dim = [];
% 
% %% Loop through files and read variables into arrays
% for ff = 1 : N
% 
%     ftemp = fullfile(fdir(ff).folder,fdir(ff).name);
% 
%     finfo = ncinfo(ftemp);
% 
%     fnames = string({finfo.Variables.Name});
% 
% 
% %obj.index = [obj.index ncread(ftemp,'index')'];
% obj.particle_number = [obj.particle_number ncread(ftemp,'particle_number')'];
% obj.a = [obj.a ncread(ftemp,'a')'];
% obj.b = [obj.b ncread(ftemp,'b')'];
% obj.c = [obj.c ncread(ftemp,'c')'];
% 
% %% ORIG
% %obj.vertices = [obj.vertices; ncread(ftemp,'particle_vertices')];
% %obj.connectivity = [obj.connectivity; ncread(ftemp,'particle_connectivity')];
% 
% if any(fnames=='aspect_ratio')
% 
%     obj.aspect_ratio = [obj.aspect_ratio; ncread(ftemp,'aspect_ratio')];
% 
% else
% 
%         obj.aspect_ratio = [obj.aspect_ratio; NaN(size(ncread(ftemp,'particle_number')'))];
% 
% end
% 
% if any(fnames=='max_dim')
% 
%     obj.max_dim = [obj.max_dim; ncread(ftemp,'max_dim')];
% 
% else
% 
%     obj.max_dim = [obj.max_dim; NaN(size(ncread(ftemp,'particle_number')'))];
% 
% end
% 
% end
% 
% 
% 
% 
% 
% end