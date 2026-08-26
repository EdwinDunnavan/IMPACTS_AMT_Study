%% generateOAPparticles_par.m

%{

Description: This script takes STL particle file(s), fits minimum-volume 
             ellipsoids to the STL particle shapes, calculates geometry
             parameters and produces 2D projections and statistics for 
             an assumed set of orientation parameters.

%}

tic

Nsim = 2e5;
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

sim_dir = paths.simulations;
%sim_dir = '/localdata/edunnavan/Simulations/OAP_ellipsoid/';

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

orientations = cell(1,length(phimean));

for ii = 1 : length(phimean)

    orientations{ii} = struct('phimean',phimean(ii), ...
                              'thetamean',thetamean(ii),... 
                              'kappa',kappa(ii),...
                              'psimean',psimean(ii),...
                              'varpsi',varpsi(ii));
end

folder = cell(1,length(part_folder));

for pp = 1 : length(part_folder)

    folder{pp} = strcat(sim_dir,part_folder{pp});

end


%% Loop through each simulation test

for ff = 1 : length(test_folder)

    fprintf('Running STL projection simulations %i out of %i\n',ff,length(test_folder))

    config = struct();

    config.Nsim = Nsim;
    config.orientations = orientations{ff};
    config.folder = folder{ff};
    config.test_folder = test_folder{ff};
    config.size_switch = size_switch{ff};
    config.particles2sim = particles2sim{ff};
    config.simulate_data = simulate_data{ff};
    config.fit_ellipsoids = fit_ellipsoids{ff};

    simulate_stl_particles(config);

end



