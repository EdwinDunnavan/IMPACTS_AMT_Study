%function sobj = read_stl_particle_init(folder,part_ind)

function sobj = read_stl_particle_init(obj,part_ind)

%fname = fullfile(folder,strcat('particle_',string(part_ind),'_rotated.stl'));

%sobj.particle.TR  = stlread(fname);

%% Read ellipsoid/particle data for rotated particle

 %obj = read_stl_data_init(folder);

 sobj.particle_number = obj.particle_number(part_ind);

 sobj.ellipsoid.a = obj.a(part_ind);
 sobj.ellipsoid.b = obj.b(part_ind);
 sobj.ellipsoid.c = obj.c(part_ind);

 TR = triangulation(double(squeeze(obj.connectivity(part_ind,:,:))),double(squeeze(obj.vertices(part_ind,:,:))));

 sobj.particle.TR = TR;

 % Save 3D STL particle inertia tensor
 RBP = RigidBodyParams(TR);
 sobj.particle.moments = RBP.moments;
 sobj.particle.area = RBP.area;

 sobj.particle.aspect_ratio = obj.aspect_ratio(part_ind);
 sobj.particle.max_dim = obj.max_dim(part_ind);

end
