
function sobj = reset_stl_particle(sobj)

phi_p = 0;
theta_p = 0;
psi_p = 0;

sobj.ellipsoid.curr.XData = sobj.ellipsoid.orig.XData;
sobj.ellipsoid.curr.YData = sobj.ellipsoid.orig.YData;
sobj.ellipsoid.curr.ZData = sobj.ellipsoid.orig.ZData;

sobj.particle.curr.Vertices = sobj.particle.orig.Vertices;
sobj.particle.curr.XData = sobj.particle.orig.XData;
sobj.particle.curr.YData = sobj.particle.orig.YData;
sobj.particle.curr.ZData = sobj.particle.orig.ZData;

sobj.ellipsoid.projection.curr.xy.XData = sobj.ellipsoid.projection.orig.xy.XData;
sobj.ellipsoid.projection.curr.xy.YData = sobj.ellipsoid.projection.orig.xy.YData;
sobj.ellipsoid.projection.curr.xy.ZData = sobj.ellipsoid.projection.orig.xy.ZData;

%delete(sobj.particle.projection.curr.xy)
%delete(sobj.particle.projection.curr.xz)

%sobj.particle.projection.curr.xz = fill3(sobj.particle.curr.XData,sobj.rmax.*ones(size(sobj.particle.curr.YData)),sobj.particle.curr.ZData,'c','linestyle','none','FaceAlpha',1);
%sobj.particle.projection.curr.xy = fill3(sobj.particle.curr.XData,sobj.particle.curr.YData,-sobj.rmax.*ones(size(sobj.particle.curr.ZData)),'c','linestyle','none','FaceAlpha',1);

a = sobj.ellipsoid.a;
b = sobj.ellipsoid.b;
c = sobj.ellipsoid.c;

%[ra_yz,rb_yz,Ellip_ang_yz]=ellipproj_axes(a,b,c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),1); % Horizontal1 (y-z plane); array perpendicular to aircraft direction
[ra_xz,rb_xz,Ellip_ang_xz]=ellipproj_axes(a,b,c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),2); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
[ra_xy,rb_xy,Ellip_ang_xy]=ellipproj_axes(a,b,c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),3); % Vertical (x-y plane); array perpendicular to aircraft direction

sobj.ellipsoid.projection.xz.ra = ra_xz;
sobj.ellipsoid.projection.xz.rb = rb_xz;
sobj.ellipsoid.projection.xz.Ellip_ang = Ellip_ang_xz;

sobj.ellipsoid.projection.xy.ra = ra_xy;
sobj.ellipsoid.projection.xy.rb = rb_xy;
sobj.ellipsoid.projection.xy.Ellip_ang = Ellip_ang_xy;

end