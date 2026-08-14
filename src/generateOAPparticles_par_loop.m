%% generateOAPparticles_par.m

%{

Description: This script takes STL particle file(s), fits minimum-volume 
             ellipsoids to the STL particle shapes, calculates geometry
             parameters and produces 2D projections and statistics for 
             an assumed set of orientation parameters.

%}

tic

Nsim = 2e5;

sim_dir = '/localdata/edunnavan/Simulations/OAP_ellipsoid/';

fit_ellipsoids = {false,false,false,false};
simulate_data = {true,true,true,true};

size_switch = {'fixed','fixed','sample','fixed','fixed','fixed'}; % sample - Sample sizes from hexagonal stl files.
                                 % fixed - fixed size in mm
                                 % gamma - Use gamma distribution to specify sizes.
                   

particles2sim = {'random','random','random','random','random','random'}; % all - simulate all particles in directory once
                                     % random - Randomly select particle from directory
                                     % and simulate Nsim number of times

test_folder = {'IMPACTS_2020_N2e5_habit/','IMPACTS_2020_N2e5_habit/','IMPACTS_2020_N2e5_habit/','IMPACTS_2020_N2e5_habit/','IMPACTS_2020_N2e5_habit/','IMPACTS_2020_N2e5_habit/'};

%part_folder = {'Hexagonal_column_MA94'};

part_folder = {'Simulation_Columns_AR10/','Simulation_Dendrite_2/','Hexagonal_plate_D74/','Simulation_BR03/','Simulation_BR04/','Simulation_BR08/'};


folder = cell(1,length(part_folder));

for pp = 1 : length(part_folder)

    folder{pp} = strcat(sim_dir,part_folder{pp});

end


%% Orientations
% IRREGULAR IMPACTS 2020
%phimean = 45;
%thetamean = 116.341;
%kappa = 4;

% COLUMNS IMPACTS 2020
%phimean = 80;
%thetamean = 115.506;
%kappa = 3;
%psimean = 0;
%varpsi = 0.001;

% Plates flutter IMPACTS 2020
%phimean = 0;
%thetamean = 90;
%kappa = 6;
%psimean = 0;
%varpsi = 6;


% Misc. STL tests
phimean = [80 80 0 0 45 45 45];
thetamean = [115.506 115.506 90 90 116.341 116.341 116.341];
kappa = [3 3 6 6 4 4 4];
psimean = [0 0 0 0 0 0 0];
varpsi = [0.001 0.001 6 6 0.001 0.001 0.001];

%phimean = [];

orientations = cell(1,length(phimean));

for ii = 1 : length(phimean)

    orientations{ii} = struct('phimean',phimean(ii), ...
                              'thetamean',thetamean(ii),... 
                              'kappa',kappa(ii),...
                              'psimean',psimean(ii),...
                              'varpsi',varpsi(ii));
end


%% Loop through each simulation test

for ff = 1 : length(test_folder)

    fprintf('Running STL projection simulations %i out of %i\n',ff,length(test_folder))

    simulate_stl_particles(Nsim,orientations{ff},test_folder{ff},folder{ff},size_switch{ff},particles2sim{ff},simulate_data{ff},fit_ellipsoids{ff});

end


function simulate_stl_particles(Nsim,orientations,test_folder,folder,size_switch,particles2sim,simulate_data,fit_ellipsoids)

phimean = orientations.phimean;
thetamean = orientations.thetamean;
kappa = orientations.kappa;
psimean = orientations.psimean;
varpsi = orientations.varpsi;

%% Set up size distribution or specify size
%if strcmp(size_switch,'gamma')
mu = 0;
Dm = 1.5;
Dlow = 0.35;
Dhigh = 3.0;

Dn = Dm./(mu+4);
nu = mu+1;

nD = truncate(makedist('gamma','a',nu,'b',Dn),Dlow,Dhigh);

%end

numThreads = maxNumCompThreads;

pix_size = 0.01;

if ~isfolder(folder)

mkdir(folder)

end

% File(s) for original STL files
fdir = dir(strcat(folder,'particle_*_orig.stl'));


%% Create stl particle and ellipsoid properties and write corresponding netcdf output
if fit_ellipsoids

    part_params = strcat(folder,'particle_params.nc');

if isfile(part_params)

    %% Open particle params netcdf file to get 3D properties for particles
    max_dim = ncread(part_params,'max_dim');

else

    max_dim = ones(1,length(fdir));

end

%% Calculate subfiles for parallel processing
N = length(fdir);

if N > 50

splitlength = floor(N/numThreads);
sublengths = ones(1,floor(N/splitlength))*splitlength;
sublengths(end) = sublengths(end)+N-sum(sublengths);
subfiles = mat2cell(1:N,1,sublengths);
else

    subfiles = {1:N};

end


if isfolder(folder)
    % Overwrite netcdf files if rerunning simulations
    delete(strcat(folder,'stl_ellipsoids_*.nc'))

end

parfor pp = 1 : length(subfiles)

%for pp = 1 : length(subfiles)
    output_ellip = sprintf('stl_ellipsoids_%i.nc',pp);

    spart = struct();

    %out_folder = folder;

    %fdir_temp = fdir;

    %sfiles = subfiles{pp};

    Nt = length(subfiles{pp});

    spart.index = subfiles{pp};
    spart.ellipsoid.a = NaN(1,Nt,'single');
    spart.ellipsoid.b = NaN(1,Nt,'single');
    spart.ellipsoid.c = NaN(1,Nt,'single');

    spart.particle.aspect_ratio = NaN(1,Nt,'single');
    spart.particle.max_dim = NaN(1,Nt,'single');

    % NOTE: hardcoded for level 3 meshes
    %spart.particle.vertices = NaN(Nt,642,3,'double');
    %spart.particle.connectivity = zeros(Nt,1280,3,'int32');

for ff = 1 : Nt

fprintf('Generating ellipsoids for particle %i out of %i\n',ff,Nt)

ftemp =  sprintf('particle_%i_orig.stl',subfiles{pp}(ff));

if strcmp(size_switch,'sample')

    %AR = aspect_ratio;
    m_dim = max_dim;

    spart.particle.max_dim(ff) = m_dim(subfiles{pp}(ff));

end

%% Create stl particle and minimum enclosing ellipsoid
sobj = gen_stl_particle_init(folder,ftemp);

spart.ellipsoid.a(ff) = sobj.ellipsoid.a;
spart.ellipsoid.b(ff) = sobj.ellipsoid.b;
spart.ellipsoid.c(ff) = sobj.ellipsoid.c;

spart.particle.vertices(ff,:,:) = sobj.particle.TR.Points;
spart.particle.connectivity(ff,:,:) = sobj.particle.TR.ConnectivityList;

end

%file_subfile = strcat(folder,output_ellip);

%% Write stl particle meshes + ellipsoids to netcdf files 
writeparticle_init(strcat(folder,output_ellip),spart)

end

clearvars spart

end

%% Simulate rotations, rescaling, and particle/ellipsoid/ellipse properties
if simulate_data

    %% Set up folder and delete old files for netcdf writing
    % output folder for rotated particle/ellipsoid statistics
    output_folder = strcat(folder,test_folder,'/');
    if isfolder(output_folder)
        % Overwrite netcdf files if rerunning simulations
        delete(strcat(output_folder,'stl_ellipsoids_sim_*.nc'))
    else
        % Make subdirectory for orientation/projection test
        mkdir(output_folder)
    end

    %% Set up projection image folder and delete old files for netcdf writing
    % output folder for rotated particle/ellipsoid statistics
    output_folder_H = strcat(folder,test_folder,'/H_Projections/');
    if isfolder(output_folder_H)
        % Overwrite netcdf files if rerunning simulations
        delete(strcat(output_folder_H,'particle_*.png'))
    else
        % Make subdirectory for orientation/projection test
        mkdir(output_folder_H)
    end

    output_folder_V = strcat(folder,test_folder,'/V_Projections/');
    if isfolder(output_folder_V)
        % Overwrite netcdf files if rerunning simulations
        delete(strcat(output_folder_V,'particle_*.png'))
    else
        % Make subdirectory for orientation/projection test
        mkdir(output_folder_V)
    end

   %% Calculate subfiles for parallel processing

switch particles2sim

    case 'all'

        N = length(fdir);

        splitlength = floor(N/numThreads);
        sublengths = ones(1,floor(N/splitlength))*splitlength;
        sublengths(end) = sublengths(end)+N-sum(sublengths);
        subfiles = mat2cell(1:N,1,sublengths); 
        subfile_indices = mat2cell(1:N,1,sublengths);

    case 'random'

    N = Nsim;

    %% Create subfile cell array where each cell has 1/numthreads number of 
    % particles that will be used for simulation.
    % Get total number of stl particles in directory

    rand_files = randi(length(fdir),1,N);

   splitlength = floor(N/numThreads);
   sublengths = ones(1,floor(N/splitlength))*splitlength;
   sublengths(end) = sublengths(end)+N-sum(sublengths);

   subfiles = mat2cell(rand_files,1,sublengths); 
   subfile_indices = mat2cell(1:Nsim,1,sublengths);


end


%% Read stl netcdf data for all particles
sdata =read_stl_data_init(folder);

parfor pp = 1 : length(subfiles)

%for pp = 1 : length(subfiles)

    %% For each simulation, randomly select a particle in directory

    addpath /home/edwin.dunnavan/Documents/UIOPS/EllipsoidProjection/
    addpath /home/edwin.dunnavan/Documents/UIOPS/

    save_images = false;
    save_meshes = false;

    output_ellip = sprintf('stl_ellipsoids_sim_%i.nc',pp);

    spart = struct();

    out_folder = output_folder;
    %H_folder = output_folder_H;
    %V_folder = output_folder_V;

    if strcmp(size_switch,'gamma')
    nD_part = nD;
    end

    %fdir_temp = fdir;

    %sfiles = subfiles{pp};

    Nt = length(subfiles{pp});

    %% Get angles from von Mises Fisher orientation distributions
    [phi_p,theta_p,psi_p] = getEulerAngles(Nt,phimean,thetamean,kappa,psimean,varpsi);

    %% Specify sizes

    switch size_switch

        case 'gamma'

            spart.particle.max_dim = nD_part.random(1,Nt);

        case 'fixed' % Fixed maximum dimension

            spart.particle.max_dim = ones(1,Nt);

        case 'sample'

            %% Read maximum dimension from sampled particle

            spart.particle.max_dim = NaN(1,Nt);

    end

    spart.folder = folder;
    spart.test_folder = test_folder;

    spart.N = Nt;
    spart.phimean = phimean;
    spart.thetamean = thetamean;
    spart.kappa = kappa;

    spart.psimean = psimean;
    spart.varpsi = varpsi;

    spart.index = subfile_indices{pp};
    spart.particle_number = subfiles{pp};

    spart.ellipsoid.a = NaN(1,Nt,'single');
    spart.ellipsoid.b = NaN(1,Nt,'single');
    spart.ellipsoid.c = NaN(1,Nt,'single');

    spart.ellipsoid.phi = phi_p;
    spart.ellipsoid.theta = theta_p;
    spart.ellipsoid.psi = psi_p;

    spart.particle.projection.xy.Dmax = NaN(1,Nt,'single');
    spart.particle.projection.xy.xpos_circ = NaN(1,Nt,'single');
    spart.particle.projection.xy.ypos_circ = NaN(1,Nt,'single');    
    spart.particle.projection.xy.ra = NaN(1,Nt,'single');
    spart.particle.projection.xy.rb = NaN(1,Nt,'single');
    spart.particle.projection.xy.Ellip_ang = NaN(1,Nt,'single');
    spart.particle.projection.xy.xpos = NaN(1,Nt,'single');
    spart.particle.projection.xy.ypos = NaN(1,Nt,'single');
    spart.particle.projection.xy.habit = ones(1,Nt,'single');

    spart.particle.projection.xz.Dmax = NaN(1,Nt,'single');
    spart.particle.projection.xz.xpos_circ = NaN(1,Nt,'single');
    spart.particle.projection.xz.ypos_circ = NaN(1,Nt,'single');   
    spart.particle.projection.xz.ra = NaN(1,Nt,'single');
    spart.particle.projection.xz.rb = NaN(1,Nt,'single');
    spart.particle.projection.xz.Ellip_ang = NaN(1,Nt,'single');
    spart.particle.projection.xz.xpos = NaN(1,Nt,'single');
    spart.particle.projection.xz.ypos = NaN(1,Nt,'single');
    spart.particle.projection.xz.habit = ones(1,Nt,'single');

    spart.particle.moments = NaN(10,Nt,'single');
    spart.particle.area = NaN(1,Nt,'single');

    % NOTE: hardcoded for level 3 meshes
    %if save_meshes
    %spart.particle.vertices = NaN(Nt,642,3,'double');
    %spart.particle.connectivity = zeros(Nt,1280,3,'int32');
    %end

    spart.particle.projection.area.xy = NaN(1,Nt,'single');
    spart.particle.projection.area.xz = NaN(1,Nt,'single');

    spart.particle.projection.perimeter.xy = NaN(1,Nt,'single');
    spart.particle.projection.perimeter.xz = NaN(1,Nt,'single');

    %if save_images
    %spart.particle.projection.grid.xy = ones(Nt,201,201,'int8');
    %spart.particle.projection.grid.xz= ones(Nt,201,201,'int8');
    %end

for ff = 1 : Nt

    fprintf('Calculating statistics for particle %i out of %i\n',ff,Nt)

    %ftemp =  sprintf('particle_%i_orig.stl',subfiles{pp}(ff));

    imtemp = sprintf('particle_%i.png',subfile_indices{pp}(ff));

    %% Read stl particle meshes and minimum volume ellipsoid fit axis lengths
    %sobj = read_stl_particle_init(folder,subfiles{pp}(ff));
    sobj = read_stl_particle_init(sdata,subfiles{pp}(ff));


    %% Rotate particle to sampled orientation
    sobj = rotate_particle(sobj,phi_p(ff),theta_p(ff),psi_p(ff));

    if strcmp(size_switch,'sample')

        spart.particle.max_dim(ff) = sobj.particle.max_dim;

    end

    %% Resize particle based on PSD
    sobj = resize_stl_particle(sobj,spart.particle.max_dim(ff));  

    %% Calculate probe arrays and ellipse statistics
    sobj = particle2probe(sobj,pix_size);

    %% Save projection images as png files
    imwrite(sobj.particle.projection.grid.xz,strcat(output_folder_H,imtemp),'BitDepth',1);
    imwrite(sobj.particle.projection.grid.xy,strcat(output_folder_V,imtemp),'BitDepth',1);

    %% Save rotated particle
    %file_new = fullfile(folder,strcat('particle_',string(ff),'_rotated.stl'));
    %stlwrite(sobj.particle.TR,file_new)

    %% Store single ellipsoid/ellipses data in arrays

    % Save ellipsoid axis lengths
    spart.ellipsoid.a(ff) = sobj.ellipsoid.a;
    spart.ellipsoid.b(ff) = sobj.ellipsoid.b;
    spart.ellipsoid.c(ff) = sobj.ellipsoid.c;

    % Save 3D particle properties
    spart.particle.moments(:,ff) = sobj.particle.moments;
    spart.particle.area(ff) = sobj.particle.area;

    %if save_meshes
    %spart.particle.vertices(ff,:,:) = sobj.particle.TR.Points;
    %spart.particle.connectivity(ff,:,:) = sobj.particle.TR.ConnectivityList;
    %end

    %% Store single particle in array for netcdf output
    spart.particle.projection.area.xy(ff) = sobj.particle.projection.area.xy;
    spart.particle.projection.area.xz(ff) = sobj.particle.projection.area.xz;

    spart.particle.projection.perimeter.xy(ff) = sobj.particle.projection.perimeter.xy;
    spart.particle.projection.perimeter.xz(ff) = sobj.particle.projection.perimeter.xz;

    %if save_images
    %spart.particle.projection.grid.xy(ff,:,:) = sobj.particle.projection.grid.xy;
    %spart.particle.projection.grid.xz(ff,:,:) = sobj.particle.projection.grid.xz;
    %end
   
    spart.particle.projection.xy.Dmax(ff) = sobj.particle.projection.xy.Dmax;
    spart.particle.projection.xy.xpos_circ(ff) = sobj.particle.projection.xy.xpos_circ;
    spart.particle.projection.xy.ypos_circ(ff) = sobj.particle.projection.xy.ypos_circ;
    spart.particle.projection.xy.ra(ff) = sobj.particle.projection.xy.ra;
    spart.particle.projection.xy.rb(ff) = sobj.particle.projection.xy.rb;
    spart.particle.projection.xy.Ellip_ang(ff) = sobj.particle.projection.xy.Ellip_ang;
    spart.particle.projection.xy.xpos(ff) = sobj.particle.projection.xy.xpos;
    spart.particle.projection.xy.ypos(ff) = sobj.particle.projection.xy.ypos;
    spart.particle.projection.xy.habit(ff) = 1.*sobj.particle.projection.xy.habit;

    spart.particle.projection.xz.Dmax(ff) = sobj.particle.projection.xz.Dmax;
    spart.particle.projection.xz.xpos_circ(ff) = sobj.particle.projection.xz.xpos_circ;
    spart.particle.projection.xz.ypos_circ(ff) = sobj.particle.projection.xz.ypos_circ;
    spart.particle.projection.xz.ra(ff) = sobj.particle.projection.xz.ra;
    spart.particle.projection.xz.rb(ff) = sobj.particle.projection.xz.rb;
    spart.particle.projection.xz.Ellip_ang(ff) = sobj.particle.projection.xz.Ellip_ang;
    spart.particle.projection.xz.xpos(ff) =  sobj.particle.projection.xz.xpos;
    spart.particle.projection.xz.ypos(ff) = sobj.particle.projection.xz.ypos;
    spart.particle.projection.xz.habit(ff) = 1.*sobj.particle.projection.xz.habit;

end

%% recalculate ellipsoid projection properties
 %% Update ellipse projections
%[ra_yz,rb_yz,Ellip_ang_yz]=ellipproj_axes(sobj.ellipsoid.a,sobj.ellipsoid.b,sobj.ellipsoid.c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),1); % Horizontal1 (y-z plane); array perpendicular to aircraft direction
[spart.ellipsoid.projection.xz.ra,...
 spart.ellipsoid.projection.xz.rb,...
 spart.ellipsoid.projection.xz.Ellip_ang]=...
 ellipproj_axes(spart.ellipsoid.a,spart.ellipsoid.b,spart.ellipsoid.c,...
 deg2rad(spart.ellipsoid.phi),deg2rad(spart.ellipsoid.theta),deg2rad(spart.ellipsoid.psi),2); % Horizontal2 (x-z plane); array perpendicular to aircraft direction

[spart.ellipsoid.projection.xy.ra,...
 spart.ellipsoid.projection.xy.rb,...
 spart.ellipsoid.projection.xy.Ellip_ang]=...
 ellipproj_axes(spart.ellipsoid.a,spart.ellipsoid.b,spart.ellipsoid.c,...
 deg2rad(spart.ellipsoid.phi),deg2rad(spart.ellipsoid.theta),deg2rad(spart.ellipsoid.psi),3); % Vertical (x-y plane); array perpendicular to aircraft direction


%% Save netcdf file
writeparticle(strcat(out_folder,output_ellip),spart,'save_images',save_images,'save_meshes',save_meshes)

end

particle_folder = strcat(folder,test_folder,'/');

stemp = read_stl_data(particle_folder);

plot_ellipse_simulation_joint(stemp,'outdir',particle_folder,'save_fig',true,'show_fig',false);

end

toc

end

function [phi_p,theta_p,psi_p] = getEulerAngles(N,phimean,thetamean,kappa,psimean,varpsi)

x = sind(thetamean).*cosd(phimean);
y = sind(thetamean).*sind(phimean);
z = cosd(thetamean);

mu_tot = [x,y,z];

mu = mu_tot./norm(mu_tot);

RandVMF= randVMF(N, mu, kappa);

xrand = RandVMF(:,1)';
yrand = RandVMF(:,2)';
zrand = RandVMF(:,3)';

theta_p = acos(zrand./sqrt(xrand.^2+yrand.^2+zrand.^2));

phi_p = atan2(yrand,xrand);

phi_p(phi_p<0) = phi_p(phi_p<0)+2.*pi;

psi_p =  (randraw('vonmises',[2.*deg2rad(psimean),varpsi],[1 N]))./2;

psi_p(psi_p>pi) = psi_p(psi_p>pi)-pi;
psi_p(psi_p<0) = psi_p(psi_p<0)+pi;

phi_p = rad2deg(phi_p);
theta_p = rad2deg(theta_p);
psi_p = rad2deg(psi_p);

end

