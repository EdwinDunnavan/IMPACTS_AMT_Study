%{
% generate_STL_projections.m

Description: This script generates example irregular Monte Carlo H and V
projections of STL models along with the ellipse data.

To use, just uncomment one of the code blocks below corresponding to the
habit you want to simulate projections.

%}

%% Set up paths based on Github Parent location
paths = init_project();

DataDir = paths.data;
utilsDir = paths.utils;
simDir = paths.simulations;

% Gamma distribution parameters. Note that plates/columns will have size
% sampled rather than specified.
mu = 0;
Dm = 2.0;
Dlow = 0.35;
Dhigh = 5.0;

%% DENDRITE EXAMPLE
particleDir = 'Dendrite_Example'; % Directory where STL particle_*_orig.stl files and particle parameter .nc file are located.
test_folder  = 'Random_100_TEST2';

Nsim = 1e2;
use_instrument_filter = false; % For simplicity, just let all particles get through the 2D-S filter
fill_holes = false;
fit_ellipsoids = false;
simulate_data = true;
save_pngs = false;
save_images = false;
save_meshes = false;

size_switch = 'fixed'; % sample - Sample sizes from hexagonal stl files.
% fixed - fixed size in mm
% gamma - Use gamma distribution to specify sizes.


particles2sim = 'random'; % all - simulate all particles in directory once
% random - Randomly select particle from directory
% and simulate Nsim number of times

% RANDOM
phimean = 0;
thetamean = 90;
kappa = 0.001;
psimean = 0.;
varpsi = 0.001;


%% IRREGULAR SIMULATIONS
% particleDir = 'Irregular_1k_fuse_TEST3'; % Directory where STL particle files and particle parameter .nc file are located.
% test_folder  = 'Irregular_2020_1k_1e6';
% 
% Nsim = 1e6;
% use_instrument_filter = true;
% fill_holes = true;
% fit_ellipsoids = true;
% simulate_data = true;
% save_pngs = false;
% save_images = false;
% save_meshes = false;
% 
% size_switch = 'gamma'; % sample - Sample sizes from hexagonal stl files.
%                         % fixed - fixed size in mm
%                         % gamma - Use gamma distribution to specify sizes.
% 
% 
% particles2sim = 'random'; % all - simulate all particles in directory once
%                        % random - Randomly select particle from directory
%                        % and simulate Nsim number of times
% 
% % IRREGULAR 2020
% ang_xz = -40;
% ang_xy = 45;
% kappa = 4.5;
% psimean = 0;
% varpsi = 0.001;
% 
% [phimean, thetamean, ~, ~] = ret_angle_3D_proj(ang_xz, ang_xy);

%% LINEAR SIMULATIONS
% particleDir = 'Linear_MA94_10k'; % Directory where STL particle files and particle parameter .nc file are located.
% test_folder = 'Linear_2022_2023_1e6';
% 
% Nsim = 1e6;
% use_instrument_filter = true;
% fit_ellipsoids = true;
% simulate_data = true;
% save_pngs = false;
% save_images = false;
% save_meshes = false;

% % Note: Sampled here to account for variable size-dependent aspect ratios
% size_switch = 'sample'; % sample - Sample sizes from hexagonal stl files.
%                         % fixed - fixed size in mm
%                         % gamma - Use gamma distribution to specify sizes.
% 
% 
% particles2sim = 'random'; % all - simulate all particles in directory once
%                           % random - Randomly select particle from directory
%                           % and simulate Nsim number of times


% NGL Linear 2020
%ang_xz = -70;
%ang_xy = 80;
%kappa = 8; % NEW
%psimean = 0;
%varpsi = 0.001;

% NGL Linear 2022-2023
% ang_xz = -80;
% ang_xy = -80;
% kappa = 8; 
% psimean = 0;
% varpsi = 0.001;
% 
% [phimean, thetamean, ~, ~] = ret_angle_3D_proj(ang_xz, ang_xy);

%% Dendrite
% particleDir = 'Simulation_Dendrite'; % Directory where STL particle files and particle parameter .nc file are located.
% test_folder = 'Random_fixed_1mm_1e6';
% 
% Nsim = 1e6;
% use_instrument_filter = true;
% fill_holes = false;
% fit_ellipsoids = true;
% simulate_data = true;
% save_pngs = false;
% save_images = false;
% save_meshes = false;

% % Note: Sampled here to account for variable size-dependent aspect ratios
% size_switch = 'fixed'; % sample - Sample sizes from hexagonal stl files.
%                         % fixed - fixed size in mm
%                         % gamma - Use gamma distribution to specify sizes.
% 
% 
% particles2sim = 'random'; % all - simulate all particles in directory once
%                           % random - Randomly select particle from directory
%                           % and simulate Nsim number of times


% RANDOM
% phimean = 0;
% thetamean = 90;
% kappa = 0.001;
% psimean = 0.;
% varpsi = 0.001;

%% Plates SIMULATIONS
% particleDir = 'Plates_AV70_10k'; % Directory where STL particle files and particle parameter .nc file are located.
% test_folder = 'Random_1e6';
% 
% Nsim = 1e6;
% use_instrument_filter = true;
% fill_holes = false;
% fit_ellipsoids = true;
% simulate_data = true;
% save_pngs = false;
% save_images = false;
% save_meshes = false;

% % Note: Sampled here to account for variable size-dependent aspect ratios
% size_switch = 'sample'; % sample - Sample sizes from hexagonal stl files.
%                         % fixed - fixed size in mm
%                         % gamma - Use gamma distribution to specify sizes.
% 
% 
% particles2sim = 'random'; % all - simulate all particles in directory once
%                           % random - Randomly select particle from directory
%                           % and simulate Nsim number of times


% RANDOM
% phimean = 0;
% thetamean = 90;
% kappa = 0.001;
% psimean = 0.;
% varpsi = 0.001;

%% CAPPED COLUMNS SIMULATIONS
% particleDir = 'CappedColumns_10k'; % Directory where STL particle files and particle parameter .nc file are located.
% test_folder = 'Linear_2020_1e6';
% 
% Nsim = 1e6;
% use_instrument_filter = true;
% fill_holes = false;
% fit_ellipsoids = true;
% simulate_data = true;
% save_pngs = false;
% save_images = false;
% save_meshes = false;

% % Note: Sampled here to account for variable size-dependent aspect ratios
% size_switch = 'gamma'; % sample - Sample sizes from hexagonal stl files.
%                         % fixed - fixed size in mm
%                         % gamma - Use gamma distribution to specify sizes.
% 
% 
% particles2sim = 'random'; % all - simulate all particles in directory once
%                           % random - Randomly select particle from directory
%                           % and simulate Nsim number of times

% NGL Linear 2020
%ang_xz = -70;
%ang_xy = 80;
%kappa = 8; % NEW
%psimean = 0;
%varpsi = 0.001;

% NGL Linear 2022-2023
% ang_xz = -80;
% ang_xy = -80;
% kappa = 8; 
% psimean = 0;
% varpsi = 0.001;
% 
% [phimean, thetamean, ~, ~] = ret_angle_3D_proj(ang_xz, ang_xy);

%% BULLET ROSETTE SIMULATIONS
% particleDir = 'Rosettes_10k'; % Directory where STL particle files and particle parameter .nc file are located.
% test_folder  = 'Irregular_2020_1e6';
% 
% Nsim = 1e6;
% use_instrument_filter = true;
% fill_holes = true;
% fit_ellipsoids = true;
% simulate_data = true;
% save_pngs = false;
% save_images = false;
% save_meshes = false;
% 
% size_switch = 'gamma'; % sample - Sample sizes from hexagonal stl files.
% fixed - fixed size in mm
% gamma - Use gamma distribution to specify sizes.
% 
% 
% particles2sim = 'random'; % all - simulate all particles in directory once
% random - Randomly select particle from directory
% and simulate Nsim number of times
% 
% 
% IRREGULAR 2020
% ang_xz = -40;
% ang_xy = 45;
% kappa = 4.5;
% psimean = 0;
% varpsi = 0.001;

% [phimean, thetamean, ~, ~] = ret_angle_3D_proj(ang_xz, ang_xy);

%% Store orientations in structure
orientations = struct('phimean',phimean, ...
                      'thetamean',thetamean,... 
                      'kappa',kappa,...
                      'psimean',psimean,...
                      'varpsi',varpsi);


%% Set up configuration structure.
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
config.use_instrument_filter = use_instrument_filter;
config.fill_holes    = fill_holes;
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
