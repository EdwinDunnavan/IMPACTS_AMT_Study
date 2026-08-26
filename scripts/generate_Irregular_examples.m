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

%% Set up folder and config
particleDir = 'Irregular_Test'; % Directory where STL particle files and particle parameter .nc file are located.
test_folder     = 'Random_Gamma_Example';

Nsim = 1e3;
fit_ellipsoids = true;
simulate_data = true;

size_switch = 'gamma'; % sample - Sample sizes from hexagonal stl files.
                        % fixed - fixed size in mm
                        % gamma - Use gamma distribution to specify sizes.
                   

particles2sim = 'all'; % all - simulate all particles in directory once
                       % random - Randomly select particle from directory
                       % and simulate Nsim number of times

mu = 0;
Dm = 1.5;
Dlow = 0.35;
Dhigh = 3.0;

phimean = 0;
thetamean = 90;
kappa = 0.001;
psimean = 0;
varpsi = 0.001;

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

config.mu = mu;
config.Dm = Dm;
config.Dlow = Dlow;
config.Dhigh = Dhigh;

simulate_stl_particles(config)
