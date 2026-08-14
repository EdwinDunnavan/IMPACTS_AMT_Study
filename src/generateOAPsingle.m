%% generateOAPsingle.m

tic

fit_ellipsoids = true;
simulate_data = true;
particles2sim = 'all';

numThreads = maxNumCompThreads;

pix_size = 0.01;

% folder for stl particles
%folder = '/localdata/edunnavan/Simulations/OAP_ellipsoid/Simulation_Plates/';

folder = '/localdata/edunnavan/Simulations/OAP_ellipsoid/Simulation_Columns_AR4/';

% File(s) for original STL files
fdir = dir(strcat(folder,'particle_*_orig.stl'));

% Test folder
test_folder = 'Random_Fixed_1mm'; 

Nsim = 1e4;

%phimean = 135;
%thetamean = 110;
%kappa = 5;

aspect_ratio = 4.0;

phimean = 0;
thetamean = 0;
kappa = 0.001;

psimean = 0;
varpsi = 0.001;

%% Create stl particle and ellipsoid properties and write corresponding netcdf output
if fit_ellipsoids

%% Calculate subfiles for parallel processing
N = length(fdir);

subfiles = fdir;

if isfolder(folder)
    % Overwrite netcdf files if rerunning simulations
    delete(strcat(folder,'stl_ellipsoids_*.nc'))

end

for pp = 1 : length(subfiles)

    output_ellip = 'stl_ellipsoids_1.nc';

    spart = struct();

    out_folder = folder;

    fdir_temp = fdir;

    sfiles = subfiles{pp};

    Nt = length(subfiles{pp});

    spart.index = subfiles{pp};
    spart.ellipsoid.a = NaN(1,Nt,'single');
    spart.ellipsoid.b = NaN(1,Nt,'single');
    spart.ellipsoid.c = NaN(1,Nt,'single');

    % NOTE: hardcoded for level 3 meshes
    spart.particle.vertices = NaN(Nt,642,3,'double');
    spart.particle.connectivity = zeros(Nt,1280,3,'int32');

for ff = 1 : Nt

fprintf('Generating ellipsoids for particle %i out of %i\n',ff,Nt)

ftemp =  sprintf('particle_%i_orig.stl',subfiles{pp}(ff));

%% Create stl particle and minimum enclosing ellipsoid
sobj = gen_stl_particle_init(folder,ftemp);

spart.ellipsoid.a(ff) = sobj.ellipsoid.a;
spart.ellipsoid.b(ff) = sobj.ellipsoid.b;
spart.ellipsoid.c(ff) = sobj.ellipsoid.c;

spart.particle.vertices(ff,:,:) = sobj.particle.TR.Points;
spart.particle.connectivity(ff,:,:) = sobj.particle.TR.ConnectivityList;

end

file_subfile = strcat(folder,output_ellip);

%% Write stl particle meshes + ellipsoids to netcdf files 
writeparticle_init(strcat(folder,output_ellip),spart)

end



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
        delete(strcat(output_folder_H,'particle_*.nc'))
    else
        % Make subdirectory for orientation/projection test
        mkdir(output_folder_H)
    end

    output_folder_V = strcat(folder,test_folder,'/V_Projections/');
    if isfolder(output_folder_V)
        % Overwrite netcdf files if rerunning simulations
        delete(strcat(output_folder_V,'particle_*.nc'))
    else
        % Make subdirectory for orientation/projection test
        mkdir(output_folder_V)
    end

    %% Set up size distribution or specify size
    mu = 0;
    Dm = 2.0;
    Dlow = 0.4;
    Dhigh = 1.0;

    Dn = Dm./(mu+4);
    nu = mu+1;

    nD = truncate(makedist('gamma','a',nu,'b',Dn),Dlow,Dhigh);

    %max_dim = nD.random(1,Nsim);

   %% Calculate subfiles for parallel processing
%N = Nsim;
N = length(fdir);

splitlength = floor(N/numThreads);
sublengths = ones(1,floor(N/splitlength))*splitlength;
sublengths(end) = sublengths(end)+N-sum(sublengths);
subfiles = mat2cell(1:N,1,sublengths); 

parfor pp = 1 : length(subfiles)
%for pp = 1 : 1

    %% For each simulation, randomly select a particle in directory

    addpath /home/edwin.dunnavan/Documents/UIOPS/EllipsoidProjection/

    addpath /home/edwin.dunnavan/Documents/UIOPS/

    save_images = false;
    save_meshes = false;

    output_ellip = sprintf('stl_ellipsoids_sim_%i.nc',pp);

    spart = struct();

    out_folder = output_folder;
    H_folder = output_folder_H;
    V_folder = output_folder_V;

    fdir_temp = fdir;

    sfiles = subfiles{pp};

    Nt = length(subfiles{pp});

    %% Get angles from von Mises Fisher orientation distributions
    [phi_p,theta_p,psi_p] = getEulerAngles(Nt,phimean,thetamean,kappa,psimean,varpsi);

    %% Specify sizes
    spart.particle.max_dim = ones(1,Nt);

    spart.folder = folder;

    spart.N = Nt;
    spart.phimean = phimean;
    spart.thetamean = thetamean;
    spart.kappa = kappa;

    spart.psimean = psimean;
    spart.varpsi = varpsi;

    spart.index = subfiles{pp};
    spart.ellipsoid.a = NaN(1,Nt,'single');
    spart.ellipsoid.b = NaN(1,Nt,'single');
    spart.ellipsoid.c = NaN(1,Nt,'single');

    spart.ellipsoid.phi = phi_p;
    spart.ellipsoid.theta = theta_p;
    spart.ellipsoid.psi = psi_p;

    spart.ellipsoid.projection.xy.ra = NaN(1,Nt,'single');
    spart.ellipsoid.projection.xy.rb = NaN(1,Nt,'single');
    spart.ellipsoid.projection.xy.Ellip_ang = NaN(1,Nt,'single');

    spart.ellipsoid.projection.xz.ra = NaN(1,Nt,'single');
    spart.ellipsoid.projection.xz.rb = NaN(1,Nt,'single');
    spart.ellipsoid.projection.xz.Ellip_ang = NaN(1,Nt,'single');

    spart.particle.projection.xy.ra = NaN(1,Nt,'single');
    spart.particle.projection.xy.rb = NaN(1,Nt,'single');
    spart.particle.projection.xy.Ellip_ang = NaN(1,Nt,'single');
    spart.particle.projection.xy.xpos = NaN(1,Nt,'single');
    spart.particle.projection.xy.ypos = NaN(1,Nt,'single');

    spart.particle.projection.xz.ra = NaN(1,Nt,'single');
    spart.particle.projection.xz.rb = NaN(1,Nt,'single');
    spart.particle.projection.xz.Ellip_ang = NaN(1,Nt,'single');
    spart.particle.projection.xz.xpos = NaN(1,Nt,'single');
    spart.particle.projection.xz.ypos = NaN(1,Nt,'single');

    % NOTE: hardcoded for level 3 meshes
    if save_meshes
    spart.particle.vertices = NaN(Nt,642,3,'double');
    spart.particle.connectivity = zeros(Nt,1280,3,'int32');
    end

    spart.particle.projection.area.xy = NaN(1,Nt,'single');
    spart.particle.projection.area.xz = NaN(1,Nt,'single');

    spart.particle.projection.perimeter.xy = NaN(1,Nt,'single');
    spart.particle.projection.perimeter.xz = NaN(1,Nt,'single');

    if save_images
    spart.particle.projection.grid.xy = ones(Nt,201,201,'int8');
    spart.particle.projection.grid.xz= ones(Nt,201,201,'int8');
    end

for ff = 1 : Nt

    fprintf('Calculating statistics for particle %i out of %i\n',ff,Nt)

    ftemp =  sprintf('particle_%i_orig.stl',subfiles{pp}(ff));

    imtemp = sprintf('particle_%i.png',subfiles{pp}(ff))

    %sobj = gen_stl_particle(folder,ftemp);

    %% Read stl particle meshes and minimum volume ellipsoid fit axis lengths
    sobj = read_stl_particle_init(folder,subfiles{pp}(ff));

    %% Rotate particle to sampled orientation
    sobj = rotate_particle(sobj,phi_p(ff),theta_p(ff),psi_p(ff));

    %% Resize particle based on PSD
    %sobj = resize_stl_particle(sobj,spart.particle.max_dim(ff));

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

    % Save ellipsoid projections
    spart.ellipsoid.projection.xy.ra(ff) =  sobj.ellipsoid.projection.xy.ra;
    spart.ellipsoid.projection.xy.rb(ff) =  sobj.ellipsoid.projection.xy.rb;
    spart.ellipsoid.projection.xy.Ellip_ang(ff) =  sobj.ellipsoid.projection.xy.Ellip_ang;

    spart.ellipsoid.projection.xz.ra(ff) =  sobj.ellipsoid.projection.xz.ra;
    spart.ellipsoid.projection.xz.rb(ff) =  sobj.ellipsoid.projection.xz.rb;
    spart.ellipsoid.projection.xz.Ellip_ang(ff) =  sobj.ellipsoid.projection.xz.Ellip_ang;

    if save_meshes
    spart.particle.vertices(ff,:,:) = sobj.particle.TR.Points;
    spart.particle.connectivity(ff,:,:) = sobj.particle.TR.ConnectivityList;
    end

    %% Store single particle in array for netcdf output
    spart.particle.projection.area.xy(ff) = sobj.particle.projection.area.xy;
    spart.particle.projection.area.xz(ff) = sobj.particle.projection.area.xz;

    spart.particle.projection.perimeter.xy(ff) = sobj.particle.projection.perimeter.xy;
    spart.particle.projection.perimeter.xz(ff) = sobj.particle.projection.perimeter.xz;

    if save_images
    spart.particle.projection.grid.xy(ff,:,:) = sobj.particle.projection.grid.xy;
    spart.particle.projection.grid.xz(ff,:,:) = sobj.particle.projection.grid.xz;
    end

    spart.particle.projection.xy.ra(ff) = sobj.particle.projection.xy.ra;
    spart.particle.projection.xy.rb(ff) = sobj.particle.projection.xy.rb;
    spart.particle.projection.xy.Ellip_ang(ff) = sobj.particle.projection.xy.Ellip_ang;
    spart.particle.projection.xy.xpos(ff) = sobj.particle.projection.xy.xpos;
    spart.particle.projection.xy.ypos(ff) = sobj.particle.projection.xy.ypos;

    spart.particle.projection.xz.ra(ff) = sobj.particle.projection.xz.ra;
    spart.particle.projection.xz.rb(ff) = sobj.particle.projection.xz.rb;
    spart.particle.projection.xz.Ellip_ang(ff) = sobj.particle.projection.xz.Ellip_ang;
    spart.particle.projection.xz.xpos(ff) =  sobj.particle.projection.xz.xpos;
    spart.particle.projection.xz.ypos(ff) = sobj.particle.projection.xz.ypos;

end

%% Save netcdf file

%file_subfile = strcat(out_folder,output_ellip);

writeparticle(strcat(out_folder,output_ellip),spart,'save_images',save_images,'save_meshes',save_meshes)

end

end

toc

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


