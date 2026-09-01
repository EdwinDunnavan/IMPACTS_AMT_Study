%{
% generate_Irregular_examples.m

Description: This script generates example irregular Monte Carlo H and V
projections of STL models along with the ellipse data.
%}

%% Set up paths based on Github Parent location
paths = get_project_paths();

DataDir = paths.data;
utilsDir = paths.utils;
simDir = paths.simulations;

addpath paths

%% Set up folder and config
particleDir = 'Irregular_Test'; % Directory where STL particle files and particle parameter .nc file are located.
%test_folder     = 'Random_Gamma_Example';
test_folder = 'Irregular_2020';

Nsim = 1e3;
fit_ellipsoids = false;
simulate_data = true;

size_switch = 'gamma'; % sample - Sample sizes from hexagonal stl files.
                        % fixed - fixed size in mm
                        % gamma - Use gamma distribution to specify sizes.
                   

particles2sim = 'all'; % all - simulate all particles in directory once
                       % random - Randomly select particle from directory
                       % and simulate Nsim number of times

%mu = 0;
mu = -0.8;
%Dm = 1.5;
Dm = 2.0;
Dlow = 0.35;
Dhigh = 5.0;

ang_xz = -40;
ang_xy = 45;
kappa = 4; % NEW
psimean = 0;
varpsi = 0.001;

 [phimean, thetamean, ~, ~] = ret_angle_3D_proj(ang_xz, ang_xy);

% phimean = 0;
% thetamean = 90;
% kappa = 0.001;
% psimean = 0;
% varpsi = 0.001;

orientations = struct('phimean',phimean, ...
                      'thetamean',thetamean,... 
                      'kappa',kappa,...
                      'psimean',psimean,...
                      'varpsi',varpsi);

%% Assume you already have the Irregular_Test/ folder in /Simulations/.

folder = fullfile(simDir,particleDir);

config = struct();

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

%% Gamma distribution parameters
config.mu = mu;
config.Dm = Dm;
config.Dlow = Dlow;
config.Dhigh = Dhigh;

simulate_stl_particles(config)
