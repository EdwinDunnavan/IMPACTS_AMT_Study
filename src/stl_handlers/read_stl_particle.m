

function sobj = read_stl_particle(folder,ind)

%% Read all ellipsoid/particle data for rotated particles
obj = read_stl_data(folder);

sobj.folder = obj.folder;
sobj.test_folder = folder;
sobj.index = obj.index(ind);
sobj.particle_number = obj.particle_number(ind);
sobj.phimean = obj.phimean;
sobj.thetamean = obj.thetamean;
sobj.psimean = obj.psimean;
sobj.kappa = obj.kappa;
sobj.varpsi = obj.varpsi;

sobj.particle.max_dim = obj.max_dim(ind);

if isfield(obj, 'grid_bound') && ~isnan(obj.grid_bound(ind))
    sobj.grid_bound = obj.grid_bound(ind);
end

% Direct read: Parameters in simulation NetCDF are ALREADY physical mm dimensions
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

sobj.particle.projection.area.xy = obj.particle_area_xy(ind);
sobj.particle.projection.area.xz = obj.particle_area_xz(ind);
sobj.particle.projection.perimeter.xy = obj.particle_perimeter_xy(ind);
sobj.particle.projection.perimeter.xz = obj.particle_perimeter_xz(ind);

% CGAL fit parameters (already physical mm)
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

%% Load pre-aligned base mesh
init_file = fullfile(sobj.folder, sprintf('particle_%i_init.stl', sobj.particle_number));
if ~exist(init_file, 'file')
    error('Pre-aligned STL missing: %s', init_file);
end
TR = stlread(init_file);
VertPoints = double(TR.Points);

%% Apply Monte Carlo rotations (your exact a -> Z convention)
phi_p = sobj.ellipsoid.phi;
theta_p = sobj.ellipsoid.theta;
psi_p = sobj.ellipsoid.psi;

VertPoints = rotate_vertices(VertPoints, [0 0 1], phi_p, [0 0 0]);
VertPoints = rotate_vertices(VertPoints, [90+phi_p 0], theta_p, [0 0 0]);
VertPoints = rotate_vertices(VertPoints, [phi_p 90-theta_p], psi_p, [0 0 0]);

% Scale unit vertices to physical max_dim
VertPoints = sobj.particle.max_dim .* VertPoints;

sobj.particle.TR = triangulation(double(TR.ConnectivityList), double(VertPoints));

%% Load 2D projection images
Hproj_file = fullfile(folder, 'H_Projections', sprintf('particle_%i.png', sobj.particle_number));
Vproj_file = fullfile(folder, 'V_Projections', sprintf('particle_%i.png', sobj.particle_number));

if exist(Hproj_file,'file') && exist(Vproj_file,'file')
    sobj.particle.projection.grid.xz = imread(Hproj_file);
    sobj.particle.projection.grid.xy = imread(Vproj_file);
else
    pix_size = 0.01; 
    temp_sobj = particle2probe(sobj, pix_size, false);

    sobj.particle.projection.grid.xy = temp_sobj.particle.projection.grid.xy;
    sobj.particle.projection.grid.xz = temp_sobj.particle.projection.grid.xz;
    sobj.grid_bound = temp_sobj.grid_bound;
end

end

% function sobj = read_stl_particle(folder,ind)
% 
% %% Read all ellipsoid/particle data for rotated particles
% obj = read_stl_data(folder);
% 
% sobj.folder = obj.folder;
% sobj.test_folder = folder;
% sobj.index = obj.index(ind);
% sobj.particle_number = obj.particle_number(ind);
% sobj.phimean = obj.phimean;
% sobj.thetamean = obj.thetamean;
% sobj.psimean = obj.psimean;
% sobj.kappa = obj.kappa;
% sobj.varpsi = obj.varpsi;
% 
% sobj.particle.max_dim = obj.max_dim(ind);
% 
% % Direct read: Parameters in NetCDF are ALREADY physical mm dimensions
% sobj.ellipsoid.a = obj.a(ind);
% sobj.ellipsoid.b = obj.b(ind);
% sobj.ellipsoid.c = obj.c(ind);
% 
% sobj.ellipsoid.phi = obj.phi(ind);
% sobj.ellipsoid.theta = obj.theta(ind);
% sobj.ellipsoid.psi = obj.psi(ind);
% 
% sobj.ellipsoid.projection.xy.ra = obj.ra_xy(ind);
% sobj.ellipsoid.projection.xy.rb = obj.rb_xy(ind);
% sobj.ellipsoid.projection.xy.Ellip_ang = obj.EllipAng_xy(ind);
% 
% sobj.ellipsoid.projection.xz.ra = obj.ra_xz(ind);
% sobj.ellipsoid.projection.xz.rb = obj.rb_xz(ind);
% sobj.ellipsoid.projection.xz.Ellip_ang = obj.EllipAng_xz(ind);
% 
% sobj.particle.projection.area.xy = obj.particle_area_xy(ind);
% sobj.particle.projection.area.xz = obj.particle_area_xz(ind);
% sobj.particle.projection.perimeter.xy = obj.particle_perimeter_xy(ind);
% sobj.particle.projection.perimeter.xz = obj.particle_perimeter_xz(ind);
% 
% % CGAL fit parameters (already physical mm)
% sobj.particle.projection.xy.ra = obj.ra_xy_cgal(ind);
% sobj.particle.projection.xy.rb = obj.rb_xy_cgal(ind);
% sobj.particle.projection.xy.Ellip_ang = obj.EllipAng_xy_cgal(ind);
% sobj.particle.projection.xy.xpos = obj.xpos_xy_cgal(ind);
% sobj.particle.projection.xy.ypos = obj.ypos_xy_cgal(ind); 
% 
% sobj.particle.projection.xz.ra = obj.ra_xz_cgal(ind);
% sobj.particle.projection.xz.rb = obj.rb_xz_cgal(ind);
% sobj.particle.projection.xz.Ellip_ang = obj.EllipAng_xz_cgal(ind);
% sobj.particle.projection.xz.xpos = obj.xpos_xz_cgal(ind);
% sobj.particle.projection.xz.ypos = obj.ypos_xz_cgal(ind); 
% 
% %% Load pre-aligned base mesh
% init_file = fullfile(sobj.folder, sprintf('particle_%i_init.stl', sobj.particle_number));
% if ~exist(init_file, 'file')
%     error('Pre-aligned STL missing: %s', init_file);
% end
% TR = stlread(init_file);
% VertPoints = double(TR.Points);
% 
% %% Apply Monte Carlo rotations (your exact a -> Z convention)
% phi_p = sobj.ellipsoid.phi;
% theta_p = sobj.ellipsoid.theta;
% psi_p = sobj.ellipsoid.psi;
% 
% VertPoints = rotate_vertices(VertPoints, [0 0 1], phi_p, [0 0 0]);
% VertPoints = rotate_vertices(VertPoints, [90+phi_p 0], theta_p, [0 0 0]);
% VertPoints = rotate_vertices(VertPoints, [phi_p 90-theta_p], psi_p, [0 0 0]);
% 
% % Scale unit vertices to physical max_dim
% VertPoints = sobj.particle.max_dim .* VertPoints;
% 
% sobj.particle.TR = triangulation(double(TR.ConnectivityList), double(VertPoints));
% 
% %% Load 2D projection images
% Hproj_file = fullfile(folder, 'H_Projections', sprintf('particle_%i.png', sobj.particle_number));
% Vproj_file = fullfile(folder, 'V_Projections', sprintf('particle_%i.png', sobj.particle_number));
% 
% if exist(Hproj_file,'file') && exist(Vproj_file,'file')
%     sobj.particle.projection.grid.xz = imread(Hproj_file);
%     sobj.particle.projection.grid.xy = imread(Vproj_file);
% else
%     pix_size = 0.01; 
%     temp_sobj = particle2probe(sobj, pix_size, false);
% 
%     sobj.particle.projection.grid.xy = temp_sobj.particle.projection.grid.xy;
%     sobj.particle.projection.grid.xz = temp_sobj.particle.projection.grid.xz;
%     sobj.grid_bound = temp_sobj.grid_bound;
% end
% 
% end


% function sobj = read_stl_particle(folder,ind)
% 
% %% Read all ellipsoid/particle data for rotated particles
% obj = read_stl_data(folder);
% 
% sobj.folder = obj.folder;
% sobj.test_folder = folder;
% sobj.index = obj.index(ind);
% sobj.particle_number = obj.particle_number(ind);
% sobj.phimean = obj.phimean;
% sobj.thetamean = obj.thetamean;
% sobj.psimean = obj.psimean;
% sobj.kappa = obj.kappa;
% sobj.varpsi = obj.varpsi;
% 
% sobj.particle.max_dim = obj.max_dim(ind);
% 
% % 1. Scale normalized 3D ellipsoid radii to physical size (mm)
% sobj.ellipsoid.a = obj.a(ind) .* sobj.particle.max_dim;
% sobj.ellipsoid.b = obj.b(ind) .* sobj.particle.max_dim;
% sobj.ellipsoid.c = obj.c(ind) .* sobj.particle.max_dim;
% 
% sobj.ellipsoid.phi = obj.phi(ind);
% sobj.ellipsoid.theta = obj.theta(ind);
% sobj.ellipsoid.psi = obj.psi(ind);
% 
% % 2. Scale normalized analytical projection radii to physical size (mm)
% sobj.ellipsoid.projection.xy.ra = obj.ra_xy(ind) .* sobj.particle.max_dim;
% sobj.ellipsoid.projection.xy.rb = obj.rb_xy(ind) .* sobj.particle.max_dim;
% sobj.ellipsoid.projection.xy.Ellip_ang = obj.EllipAng_xy(ind);
% 
% sobj.ellipsoid.projection.xz.ra = obj.ra_xz(ind) .* sobj.particle.max_dim;
% sobj.ellipsoid.projection.xz.rb = obj.rb_xz(ind) .* sobj.particle.max_dim;
% sobj.ellipsoid.projection.xz.Ellip_ang = obj.EllipAng_xz(ind);
% 
% sobj.particle.projection.area.xy = obj.particle_area_xy(ind);
% sobj.particle.projection.area.xz = obj.particle_area_xz(ind);
% sobj.particle.projection.perimeter.xy = obj.particle_perimeter_xy(ind);
% sobj.particle.projection.perimeter.xz = obj.particle_perimeter_xz(ind);
% 
% % 3. CGAL parameters (Already stored in physical mm by particle2probe)
% sobj.particle.projection.xy.ra = obj.ra_xy_cgal(ind);
% sobj.particle.projection.xy.rb = obj.rb_xy_cgal(ind);
% sobj.particle.projection.xy.Ellip_ang = obj.EllipAng_xy_cgal(ind);
% sobj.particle.projection.xy.xpos = obj.xpos_xy_cgal(ind);
% sobj.particle.projection.xy.ypos = obj.ypos_xy_cgal(ind); 
% 
% sobj.particle.projection.xz.ra = obj.ra_xz_cgal(ind);
% sobj.particle.projection.xz.rb = obj.rb_xz_cgal(ind);
% sobj.particle.projection.xz.Ellip_ang = obj.EllipAng_xz_cgal(ind);
% sobj.particle.projection.xz.xpos = obj.xpos_xz_cgal(ind);
% sobj.particle.projection.xz.ypos = obj.ypos_xz_cgal(ind); 
% 
% %% Load pre-aligned base mesh and apply Monte Carlo rotations/scaling
% init_file = fullfile(sobj.folder, sprintf('particle_%i_init.stl', sobj.particle_number));
% if ~exist(init_file, 'file')
%     error('Pre-aligned STL missing: %s', init_file);
% end
% TR = stlread(init_file);
% VertPoints = double(TR.Points);
% 
% phi_p = sobj.ellipsoid.phi;
% theta_p = sobj.ellipsoid.theta;
% psi_p = sobj.ellipsoid.psi;
% 
% VertPoints = rotate_vertices(VertPoints, [0 0 1], phi_p, [0 0 0]);
% VertPoints = rotate_vertices(VertPoints, [90+phi_p 0], theta_p, [0 0 0]);
% VertPoints = rotate_vertices(VertPoints, [phi_p 90-theta_p], psi_p, [0 0 0]);
% 
% VertPoints = sobj.particle.max_dim .* VertPoints;
% 
% sobj.particle.TR = triangulation(double(TR.ConnectivityList), double(VertPoints));
% 
% %% Load or Generate 2D projection images
% Hproj_file = fullfile(folder, 'H_Projections', sprintf('particle_%i.png', sobj.particle_number));
% Vproj_file = fullfile(folder, 'V_Projections', sprintf('particle_%i.png', sobj.particle_number));
% 
% if exist(Hproj_file,'file') && exist(Vproj_file,'file')
%     sobj.particle.projection.grid.xz = imread(Hproj_file);
%     sobj.particle.projection.grid.xy = imread(Vproj_file);
% else
%     pix_size = 0.01; 
%     temp_sobj = particle2probe(sobj, pix_size, false);
% 
%     sobj.particle.projection.grid.xy = temp_sobj.particle.projection.grid.xy;
%     sobj.particle.projection.grid.xz = temp_sobj.particle.projection.grid.xz;
%     sobj.grid_bound = temp_sobj.grid_bound;
% end
% 
% end


% function sobj = read_stl_particle(folder,ind)
% 
% %% Read all ellipsoid/particle data for rotated particles
% obj = read_stl_data(folder);
% 
% sobj.folder = obj.folder;
% sobj.test_folder = folder;
% sobj.index = obj.index(ind);
% sobj.particle_number = obj.particle_number(ind);
% sobj.phimean = obj.phimean;
% sobj.thetamean = obj.thetamean;
% sobj.psimean = obj.psimean;
% sobj.kappa = obj.kappa;
% sobj.varpsi = obj.varpsi;
% 
% sobj.particle.max_dim = obj.max_dim(ind);
% 
% % Scale the unit-normalized ellipsoid parameters by max_dim
% sobj.ellipsoid.a = obj.a(ind) .* sobj.particle.max_dim;
% sobj.ellipsoid.b = obj.b(ind) .* sobj.particle.max_dim;
% sobj.ellipsoid.c = obj.c(ind) .* sobj.particle.max_dim;
% 
% sobj.ellipsoid.phi = obj.phi(ind);
% sobj.ellipsoid.theta = obj.theta(ind);
% sobj.ellipsoid.psi = obj.psi(ind);
% 
% sobj.ellipsoid.projection.xy.ra = obj.ra_xy(ind);
% sobj.ellipsoid.projection.xy.rb = obj.rb_xy(ind);
% sobj.ellipsoid.projection.xy.Ellip_ang = obj.EllipAng_xy(ind);
% 
% sobj.ellipsoid.projection.xz.ra = obj.ra_xz(ind);
% sobj.ellipsoid.projection.xz.rb = obj.rb_xz(ind);
% sobj.ellipsoid.projection.xz.Ellip_ang = obj.EllipAng_xz(ind);
% 
% sobj.particle.projection.area.xy = obj.particle_area_xy(ind);
% sobj.particle.projection.area.xz = obj.particle_area_xz(ind);
% sobj.particle.projection.perimeter.xy = obj.particle_perimeter_xy(ind);
% sobj.particle.projection.perimeter.xz = obj.particle_perimeter_xz(ind);
% 
% sobj.particle.projection.xy.ra = obj.ra_xy_cgal(ind);
% sobj.particle.projection.xy.rb = obj.rb_xy_cgal(ind);
% sobj.particle.projection.xy.Ellip_ang = obj.EllipAng_xy_cgal(ind);
% sobj.particle.projection.xy.xpos = obj.xpos_xy_cgal(ind);
% sobj.particle.projection.xy.ypos = obj.ypos_xy_cgal(ind); 
% 
% sobj.particle.projection.xz.ra = obj.ra_xz_cgal(ind);
% sobj.particle.projection.xz.rb = obj.rb_xz_cgal(ind);
% sobj.particle.projection.xz.Ellip_ang = obj.EllipAng_xz_cgal(ind);
% sobj.particle.projection.xz.xpos = obj.xpos_xz_cgal(ind);
% sobj.particle.projection.xz.ypos = obj.ypos_xz_cgal(ind); 
% 
% %% 1. Always load pre-aligned base mesh
% init_file = fullfile(sobj.folder, sprintf('particle_%i_init.stl', sobj.particle_number));
% if ~exist(init_file, 'file')
%     error('Pre-aligned STL missing: %s', init_file);
% end
% TR = stlread(init_file);
% VertPoints = double(TR.Points);
% 
% %% 2. Apply Monte Carlo rotations
% phi_p = sobj.ellipsoid.phi;
% theta_p = sobj.ellipsoid.theta;
% psi_p = sobj.ellipsoid.psi;
% 
% VertPoints = rotate_vertices(VertPoints, [0 0 1], phi_p, [0 0 0]);
% VertPoints = rotate_vertices(VertPoints, [90+phi_p 0], theta_p, [0 0 0]);
% VertPoints = rotate_vertices(VertPoints, [phi_p 90-theta_p], psi_p, [0 0 0]);
% 
% %% 3. Scale vertices to PSD max_dim
% VertPoints = sobj.particle.max_dim .* VertPoints;
% 
% sobj.particle.TR = triangulation(double(TR.ConnectivityList), double(VertPoints));
% 
% %% 4. Load or Generate 2D projection images
% Hproj_file = fullfile(folder, 'H_Projections', sprintf('particle_%i.png', sobj.particle_number));
% Vproj_file = fullfile(folder, 'V_Projections', sprintf('particle_%i.png', sobj.particle_number));
% 
% if exist(Hproj_file,'file') && exist(Vproj_file,'file')
%     sobj.particle.projection.grid.xz = imread(Hproj_file);
%     sobj.particle.projection.grid.xy = imread(Vproj_file);
% else
%     pix_size = 0.01; 
%     temp_sobj = particle2probe(sobj, pix_size, false);
% 
%     sobj.particle.projection.grid.xy = temp_sobj.particle.projection.grid.xy;
%     sobj.particle.projection.grid.xz = temp_sobj.particle.projection.grid.xz;
%     sobj.grid_bound = temp_sobj.grid_bound;
% end
% 
% end






% function sobj = read_stl_particle(folder,ind)
% 
% %fname = fullfile(folder,strcat('particle_',string(part_ind),'_rotated.stl'));
% 
% %sobj.particle.TR  = stlread(fname);
% 
% %% Read all ellipsoid/particle data for rotated particles
%  obj = read_stl_data(folder);
% 
%  sobj.folder = obj.folder;
% 
%  sobj.test_folder = folder;
% 
%  sobj.index = obj.index(ind);
% 
%  sobj.particle_number = obj.particle_number(ind);
% 
% 
%  %sobj.particle_number = obj.particle_number(part_ind);
% 
%  sobj.phimean = obj.phimean;
%  sobj.thetamean = obj.thetamean;
%  sobj.psimean = obj.psimean;
%  sobj.kappa = obj.kappa;
%  sobj.varpsi = obj.varpsi;
% 
%  sobj.ellipsoid.a = obj.a(ind);
%  sobj.ellipsoid.b = obj.b(ind);
%  sobj.ellipsoid.c = obj.c(ind);
%  sobj.ellipsoid.phi = obj.phi(ind);
%  sobj.ellipsoid.theta = obj.theta(ind);
%  sobj.ellipsoid.psi = obj.psi(ind);
%  sobj.ellipsoid.projection.xy.ra = obj.ra_xy(ind);
%  sobj.ellipsoid.projection.xy.rb = obj.rb_xy(ind);
%  sobj.ellipsoid.projection.xy.Ellip_ang = obj.EllipAng_xy(ind);
%  sobj.ellipsoid.projection.xz.ra = obj.ra_xz(ind);
%  sobj.ellipsoid.projection.xz.rb = obj.rb_xz(ind);
%  sobj.ellipsoid.projection.xz.Ellip_ang = obj.EllipAng_xz(ind);
% 
%  %TR = triangulation(double(squeeze(obj.connectivity(part_ind,:,:))),squeeze(obj.vertices(part_ind,:,:)));
% 
%  %sobj.particle.TR = TR;
% 
%  sobj.particle.max_dim = obj.max_dim(ind);
% 
%  sobj.particle.projection.area.xy = obj.particle_area_xy(ind);
%  sobj.particle.projection.area.xz = obj.particle_area_xz(ind);
% 
%  sobj.particle.projection.perimeter.xy = obj.particle_perimeter_xy(ind);
%  sobj.particle.projection.perimeter.xz = obj.particle_perimeter_xz(ind);
% 
%  %sobj.particle.projection.grid.xy = squeeze(obj.image_xy(part_ind,:,:));
%  %sobj.particle.projection.grid.xz = squeeze(obj.image_xz(part_ind,:,:));
% 
%  sobj.particle.projection.xy.ra = obj.ra_xy_cgal(ind);
%  sobj.particle.projection.xy.rb = obj.rb_xy_cgal(ind);
%  sobj.particle.projection.xy.Ellip_ang = obj.EllipAng_xy_cgal(ind);
%  sobj.particle.projection.xy.xpos = obj.xpos_xy_cgal(ind);
%  sobj.particle.projection.xy.ypos = obj.ypos_xy_cgal(ind); 
% 
%  sobj.particle.projection.xz.ra = obj.ra_xz_cgal(ind);
%  sobj.particle.projection.xz.rb = obj.rb_xz_cgal(ind);
%  sobj.particle.projection.xz.Ellip_ang = obj.EllipAng_xz_cgal(ind);
%  sobj.particle.projection.xz.xpos = obj.xpos_xz_cgal(ind);
%  sobj.particle.projection.xz.ypos = obj.ypos_xz_cgal(ind); 
% 
%  %stl_obj = read_stl_particle_init(sobj.folder,part_ind);
% 
%  %% Rotate particle to sampled orientation
% %sobj = rotate_particle(sobj,sobj.ellipsoid.phi,sobj.ellipsoid.theta,sobj.ellipsoid.psi);
% 
% %% Resize particle based on PSD
% %sobj = resize_stl_particle(sobj,sobj.max_size);
% 
% %% Generate probe images
% %sobj = particle2probe(sobj);
% 
% Hproj_file = strcat(folder,'H_Projections/',sprintf('particle_%i.png',ind));
% Vproj_file = strcat(folder,'V_Projections/',sprintf('particle_%i.png',ind));
% 
% if exist(Hproj_file,'file') && exist(Vproj_file,'file')
% 
%     sobj.particle.projection.grid.xz = imread(Hproj_file);
%     sobj.particle.projection.grid.xy = imread(Vproj_file);
% 
% else
% 
%     %% 1. Read the raw original STL mesh from the parent folder
%     % sobj.folder points to the base directory containing the STLs
%     orig_file = fullfile(sobj.folder, sprintf('particle_%i_orig.stl', sobj.particle_number));
%     TR = stlread(orig_file);
%     sobj.particle.TR = TR;
% 
%     VertPoints = double(sobj.particle.TR.Points);
% 
%     %% 1b. RECONSTRUCT INITIAL ALIGNMENT (Matches gen_stl_particle_init.m)
%     % The simulator aligns and centers the raw STL before applying Monte Carlo
%     % rotations. We must replicate this exact sequence to match the NetCDF metadata.
%     [~, c_align, ~, ~, ~, ~, ~, phi1, theta1, psi1] = MinVolEllipse(VertPoints', 1e-3);
% 
%     if isnan(phi1), phi1 = 0; end
%     if isnan(theta1), theta1 = 0; end
%     if isnan(psi1), psi1 = 0; end
% 
%     % Apply inverse rotations and centering
%     VertPoints = rotate_vertices(VertPoints, [0 0 1], -phi1, c_align);
%     VertPoints = rotate_vertices(VertPoints, [0 1 0], -theta1, c_align);
%     VertPoints = rotate_vertices(VertPoints, [1 0 0], -psi1, c_align);
%     VertPoints = VertPoints - c_align';
% 
%     %% 1c. Normalize aligned STL to unit maximum dimension (1.0)
%     rescale = max(VertPoints(:,3)) - min(VertPoints(:,3)); 
%     VertPoints = VertPoints ./ rescale;
% 
%     %% 2. Rotate ONLY the vertices 
%     % We do this manually to avoid rotate_particle.m overwriting the exact 
%     % ellipsoid projections already loaded perfectly from the NetCDF.
%     phi_p = sobj.ellipsoid.phi;
%     theta_p = sobj.ellipsoid.theta;
%     psi_p = sobj.ellipsoid.psi;
% 
%     VertPoints = rotate_vertices(VertPoints, [0 0 1], phi_p, [0 0 0]);
%     VertPoints = rotate_vertices(VertPoints, [90+phi_p 0], theta_p, [0 0 0]);
%     VertPoints = rotate_vertices(VertPoints, [phi_p 90-theta_p], psi_p, [0 0 0]);
% 
%     %% 3. Scale ONLY the vertices
%     % We bypass resize_stl_particle.m so we don't accidentally double-scale 
%     % sobj.ellipsoid.a (which is already scaled in the NetCDF).
%     VertPoints = sobj.particle.max_dim .* VertPoints;
% 
%     % Update the triangulation with the finalized 3D vertices
%     sobj.particle.TR = triangulation(double(sobj.particle.TR.ConnectivityList), double(VertPoints));
% 
%     %% 4. Generate the 2D pixel grids
%     % Run particle2probe into a temporary struct so it doesn't overwrite 
%     % the precise CGAL fits and areas already stored in sobj.
%     pix_size = 0.01; 
%     temp_sobj = particle2probe(sobj, pix_size);
% 
%     % Map ONLY the generated grids back to the main object
%     sobj.particle.projection.grid.xy = temp_sobj.particle.projection.grid.xy;
%     sobj.particle.projection.grid.xz = temp_sobj.particle.projection.grid.xz;
% 
%     % TR = triangulation(double(squeeze(obj.connectivity(ind,:,:))),squeeze(obj.vertices(ind,:,:)));
%     % 
%     % sobj.particle.TR = TR;
%     % 
%     %  %% Rotate particle to sampled orientation
%     % sobj = rotate_particle(sobj,sobj.ellipsoid.phi,sobj.ellipsoid.theta,sobj.ellipsoid.psi);
%     % 
%     % %% Resize particle based on PSD
%     % sobj = resize_stl_particle(sobj,sobj.max_size);
%     % 
%     % %% Generate probe images
%     % sobj = particle2probe(sobj);
% 
% end
% 
% 
% 
% end
