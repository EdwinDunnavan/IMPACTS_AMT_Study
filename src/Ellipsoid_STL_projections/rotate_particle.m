
function sobj = rotate_particle(sobj,phi_p,theta_p,psi_p)

 %% Reset particle
 %sobj.ellipsoid = sobj.orig.ellipsoid;
 %sobj.particle = sobj.orig.particle;

 %% Rotate particle vertices
 VertPoints = double(sobj.particle.TR.Points);
 VertPoints = rotate_vertices(VertPoints,[0 0 1],phi_p,[0 0 0]);
 VertPoints = rotate_vertices(VertPoints,[90+phi_p 0],theta_p,[0 0 0]);
 VertPoints = rotate_vertices(VertPoints,[phi_p 90-theta_p],psi_p,[0 0 0]);

 VertPoints = double(VertPoints);

 %% Update ellipse projections
%[ra_yz,rb_yz,Ellip_ang_yz]=ellipproj_axes(sobj.ellipsoid.a,sobj.ellipsoid.b,sobj.ellipsoid.c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),1); % Horizontal1 (y-z plane); array perpendicular to aircraft direction
[ra_xz,rb_xz,Ellip_ang_xz]=ellipproj_axes(sobj.ellipsoid.a,sobj.ellipsoid.b,sobj.ellipsoid.c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),2); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
[ra_xy,rb_xy,Ellip_ang_xy]=ellipproj_axes(sobj.ellipsoid.a,sobj.ellipsoid.b,sobj.ellipsoid.c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),3); % Vertical (x-y plane); array perpendicular to aircraft direction

%% Calculate ellipsoid projection parameters
sobj.ellipsoid.phi = phi_p;
sobj.ellipsoid.theta = theta_p;
sobj.ellipsoid.psi = psi_p;

sobj.ellipsoid.projection.xy.ra = ra_xy;
sobj.ellipsoid.projection.xy.rb = rb_xy;
sobj.ellipsoid.projection.xy.Ellip_ang = Ellip_ang_xy;

sobj.ellipsoid.projection.xz.ra = ra_xz;
sobj.ellipsoid.projection.xz.rb = rb_xz;
sobj.ellipsoid.projection.xz.Ellip_ang = Ellip_ang_xz;

sobj.ellipsoid.projection.area.xy = pi.*ra_xy.*rb_xy;
sobj.ellipsoid.projection.area.xz = pi.*ra_xz.*rb_xz;

%% Store new triangulation based on rotated particle
TR = triangulation(sobj.particle.TR.ConnectivityList,VertPoints);

sobj.particle.TR = TR;


end