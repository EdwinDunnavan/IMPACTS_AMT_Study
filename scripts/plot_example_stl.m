

%{
plot_example_stl.m

Description: This script takes an example STL model with fitted ellipsoid
from the Monte Carlo dataset and plots the 3D view along with the H and V
projections and fitted ellipses in the X-Y and X-Z projection planes.

%}

paths = get_project_paths();

sim_example = 'Irregular_Test';

sim_dir = fullfile(paths.simulations,sim_example);

ind = 1;

%stemp = read_stl_data('/localdata/edunnavan/Simulations/OAP_ellipsoid/Simulation_Dendrite_2/IMPACTS_2020_N2e5_habit/');
stemp = read_stl_data(sim_example);
sobj_2 = read_stl_particle(fullfile(stemp.folder,stemp.test_folder),ind);
plot_stl_particle(sobj_2);