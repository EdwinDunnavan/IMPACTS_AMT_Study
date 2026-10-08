%{
% generate_Linear_examples.m

Description: This script generates example irregular Monte Carlo H and V
projections of STL models along with the ellipse data.
%}

%% Set up paths based on Github Parent location
paths = get_project_paths();

DataDir = paths.data;
utilsDir = paths.utils;
simDir = paths.simulations;

%% LINEAR: Set up folder and config
particleDir = 'Linear_MA94_10k'; % Directory where STL particle files and particle parameter .nc file are located.
%test_folder     = 'Random_Gamma_Example';
test_folder = 'Linear_2022_2023_neg80deg_1e6';

Nsim = 1e6;
fit_ellipsoids = false;
simulate_data = true;
save_pngs = false;
save_images = false;
save_meshes = false;

size_switch = 'sample'; % sample - Sample sizes from hexagonal stl files.
                        % fixed - fixed size in mm
                        % gamma - Use gamma distribution to specify sizes.
                   

particles2sim = 'random'; % all - simulate all particles in directory once
                       % random - Randomly select particle from directory
                       % and simulate Nsim number of times


%% NGL Linear 2020
%ang_xz = -70;
%ang_xy = 80;
%kappa = 8; % NEW
%psimean = 0;
%varpsi = 0.001;

%% NGL Linear 2022-2023
ang_xz = -80;
%ang_xy = -70;
ang_xy = -80;
kappa = 8; % NEW
psimean = 0;
varpsi = 0.001;

[phimean, thetamean, ~, ~] = ret_angle_3D_proj(ang_xz, ang_xy);

orientations = struct('phimean',phimean, ...
                      'thetamean',thetamean,... 
                      'kappa',kappa,...
                      'psimean',psimean,...
                      'varpsi',varpsi);

%% Assume you already have the Irregular_Test/ folder in /Simulations/.

folder = fullfile(simDir,particleDir);

config = struct();

config.save_pngs = save_pngs;
config.save_images = save_images;
config.save_meshes = save_meshes;

config.Nsim = Nsim;
config.folder = folder;
config.test_folder = test_folder;
config.fit_ellipsoids = fit_ellipsoids;
config.simulate_data = simulate_data;
config.size_switch = size_switch;
config.particles2sim = particles2sim;
config.orientations = orientations;

%% Instrument Filters for 2D-S
config.use_instrument_filter = true;
config.W_array       = 1.28;  
config.Dthresh       = 0.35;   
config.ar_thresh     = 0.1;   
config.area_thresh   = 0.2;   
config.NPixel_thresh = 800;   
config.pixel_area    = 1e-4;

simulate_stl_particles(config)