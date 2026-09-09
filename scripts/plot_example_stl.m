

%{
plot_example_stl.m

Description: This script takes an example STL model with fitted ellipsoid
from the Monte Carlo dataset and plots the 3D view along with the H and V
projections and fitted ellipses in the X-Y and X-Z projection planes.

%}

paths = get_project_paths();

sim_example = 'Irregular_Test';
test_example = 'Random_Gamma_Example';

sim_dir = fullfile(paths.simulations,sim_example,test_example,'/');

ind = 1;

stemp = read_stl_data(sim_dir);
sobj_2 = read_stl_particle(sim_dir,ind);
plot_stl_particle(sobj_2);