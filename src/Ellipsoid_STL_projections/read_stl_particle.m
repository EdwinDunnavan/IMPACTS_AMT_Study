
function sobj = read_stl_particle(folder,ind)

%fname = fullfile(folder,strcat('particle_',string(part_ind),'_rotated.stl'));

%sobj.particle.TR  = stlread(fname);

%% Read all ellipsoid/particle data for rotated particles
 obj = read_stl_data(folder);

 

 sobj.folder = obj.folder;

 sobj.test_folder = folder;

 sobj.index = obj.index(ind);

 sobj.particle_number = obj.particle_number(ind);


 %sobj.particle_number = obj.particle_number(part_ind);

 sobj.phimean = obj.phimean;
 sobj.thetamean = obj.thetamean;
 sobj.psimean = obj.psimean;
 sobj.kappa = obj.kappa;
 sobj.varpsi = obj.varpsi;

 sobj.ellipsoid.a = obj.a(ind);
 sobj.ellipsoid.b = obj.b(ind);
 sobj.ellipsoid.c = obj.c(ind);
 sobj.ellipsoid.phi = obj.phi(ind);
 sobj.ellipsoid.theta = obj.theta(ind);
 sobj.ellipsoid.psi = obj.psi(ind);
 sobj.ellipsoid.projection.xy.ra = obj.ra_xy(ind);
 sobj.ellipsoid.projection.xy.rb = obj.rb_xy(ind);
 sobj.ellipsoid.projection.xy.Ellip_ang = obj.EllipAng_xy(ind);
 sobj.ellipsoid.projection.xz.ra = obj.ra_xz(ind);
 sobj.ellipsoid.projection.xz.rb = obj.rb_xz(ind);
 sobj.ellipsoid.projection.xz.Ellip_ang = obj.EllipAng_xz(ind);

 %TR = triangulation(double(squeeze(obj.connectivity(part_ind,:,:))),squeeze(obj.vertices(part_ind,:,:)));

 %sobj.particle.TR = TR;

 sobj.particle.max_dim = obj.max_dim(ind);

 sobj.particle.projection.area.xy = obj.particle_area_xy(ind);
 sobj.particle.projection.area.xz = obj.particle_area_xz(ind);

 sobj.particle.projection.perimeter.xy = obj.particle_perimeter_xy(ind);
 sobj.particle.projection.perimeter.xz = obj.particle_perimeter_xz(ind);

 %sobj.particle.projection.grid.xy = squeeze(obj.image_xy(part_ind,:,:));
 %sobj.particle.projection.grid.xz = squeeze(obj.image_xz(part_ind,:,:));

 sobj.particle.projection.xy.ra = obj.ra_xy_cgal(ind);
 sobj.particle.projection.xy.rb = obj.rb_xy_cgal(ind);
 sobj.particle.projection.xy.Ellip_ang = obj.EllipAng_xy_cgal(ind);
 sobj.particle.projection.xy.xpos = obj.xpos_xy_cgal(ind);
 sobj.particle.projection.xy.ypos = obj.ypos_xy_cgal(ind); 

 sobj.particle.projection.xz.ra = obj.ra_xz_cgal(ind);
 sobj.particle.projection.xz.rb = obj.rb_xz_cgal(ind);
 sobj.particle.projection.xz.Ellip_ang = obj.EllipAng_xz_cgal(ind);
 sobj.particle.projection.xz.xpos = obj.xpos_xz_cgal(ind);
 sobj.particle.projection.xz.ypos = obj.ypos_xz_cgal(ind); 

 %stl_obj = read_stl_particle_init(sobj.folder,part_ind);

 %% Rotate particle to sampled orientation
%sobj = rotate_particle(sobj,sobj.ellipsoid.phi,sobj.ellipsoid.theta,sobj.ellipsoid.psi);

%% Resize particle based on PSD
%sobj = resize_stl_particle(sobj,sobj.max_size);

%% Generate probe images
%sobj = particle2probe(sobj);

sobj.particle.projection.grid.xz = imread(strcat(folder,'H_Projections/',sprintf('particle_%i.png',ind)));
sobj.particle.projection.grid.xy = imread(strcat(folder,'V_Projections/',sprintf('particle_%i.png',ind)));



end
