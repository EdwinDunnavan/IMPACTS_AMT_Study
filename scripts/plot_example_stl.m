

%{
plot_example_stl.m

Description: This script takes an example STL model with fitted ellipsoid
from the Monte Carlo dataset and plots the 3D view along with the H and V
projections and fitted ellipses in the X-Y and X-Z projection planes.

%}

paths = init_project();

%sim_example = 'CappedColumns_10k';
%test_example = 'Random_1e5_randsamp';

sim_example = 'Irregular_1k_fuse_TEST3';
test_example = 'Irregular_2020_1e6';

%sim_example = 'Simulation_Dendrite';
%test_example = 'IMPACTS_2020_N2e5_habit';

%sim_example = 'Irregular_Test';
%test_example = 'Random_Gamma_Example';

%sim_example = 'Irregular_10k_gaussian_means';
%test_example = 'Irregular_2020_10k_ALL';

%sim_example = 'Rosettes_10k';

%sim_example = 'Rosettes_10k';
%test_example = 'Irregular_2020_1e5';
%test_example = 'Irregular_2020_1e6';

%sim_example = 'Irregular_10k_round_05_rough_1';
%test_example = 'Irregular_2020_10k_ALL';

%sim_example = 'Irregular_10k_random_constrained';
%test_example = 'Irregular_2020_1e6';

%sim_example = 'Rosettes_10k';
%test_example = 'Irregular_10k_ALL';

sim_dir = fullfile(paths.simulations,sim_example,test_example,'/');

ind = 3;

stemp = read_stl_data(sim_dir);

%% Find all particles that passed the 2D-S filter
ind_filt = stemp.index(~isnan(stemp.a));

sobj_2 = read_stl_particle(sim_dir,ind_filt(ind));
%sobj_2 = read_stl_particle(sim_dir,42168);
plot_stl_particle(sobj_2);