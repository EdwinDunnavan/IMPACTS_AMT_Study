
function sobj = rotate_stl_particle(sobj,phi_p,theta_p,psi_p)

 sobj = reset_stl_particle(sobj);

 [Nx,Ny] = size(sobj.ellipsoid.curr.XData);

% Z-Y-Z Euler angle rotation convention
rotm = [cosd(phi_p).*cosd(theta_p).*cosd(psi_p)-sind(phi_p).*sind(psi_p) -cosd(psi_p).*sind(phi_p)-cosd(phi_p).*cosd(theta_p).*sind(psi_p) cosd(phi_p).*sind(theta_p); ...
            cosd(phi_p).*sind(psi_p)+cosd(theta_p).*cosd(psi_p).*sind(phi_p) cosd(phi_p).*cosd(psi_p)-cosd(theta_p).*sind(phi_p).*sind(psi_p) sind(phi_p).*sind(theta_p); ...
            -cosd(psi_p).*sind(theta_p) sind(theta_p).*sind(psi_p) cosd(theta_p)];

WData = permute(cat(3,sobj.ellipsoid.curr.XData,sobj.ellipsoid.curr.YData,sobj.ellipsoid.curr.ZData),[3 1 2]);

X_rot = reshape(rotm(1,:)*WData(:,:),[Nx Ny]);
Y_rot = reshape(rotm(2,:)*WData(:,:),[Nx Ny]);
Z_rot = reshape(rotm(3,:)*WData(:,:),[Nx Ny]);

sobj.ellipsoid.curr.XData = X_rot;
sobj.ellipsoid.curr.YData = Y_rot;
sobj.ellipsoid.curr.ZData = Z_rot;

rotate(sobj.particle.curr,[0 0 1],phi_p)
rotate(sobj.particle.curr,[90+phi_p 0],theta_p)
rotate(sobj.particle.curr,[phi_p 90-theta_p],psi_p)

%[ra_yz,rb_yz,Ellip_ang_yz]=ellipproj_axes(sobj.ellipsoid.a,sobj.ellipsoid.b,sobj.ellipsoid.c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),1); % Horizontal1 (y-z plane); array perpendicular to aircraft direction
[ra_xz,rb_xz,Ellip_ang_xz]=ellipproj_axes(sobj.ellipsoid.a,sobj.ellipsoid.b,sobj.ellipsoid.c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),2); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
[ra_xy,rb_xy,Ellip_ang_xy]=ellipproj_axes(sobj.ellipsoid.a,sobj.ellipsoid.b,sobj.ellipsoid.c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),3); % Vertical (x-y plane); array perpendicular to aircraft direction

%delete(sobj.particle.projection.curr.xy)
%delete(sobj.particle.projection.curr.xz)

%sobj.particle.projection.curr.xz = fill3(sobj.particle.curr.XData,sobj.rmax.*ones(size(sobj.particle.curr.YData)),sobj.particle.curr.ZData,'c','linestyle','none','FaceAlpha',1);
%sobj.particle.projection.curr.xy = fill3(sobj.particle.curr.XData,sobj.particle.curr.YData,-sobj.rmax.*ones(size(sobj.particle.curr.ZData)),'c','linestyle','none','FaceAlpha',1);

ellipseCoords_xy = ellipse3D(ra_xy,rb_xy,0,0,-sobj.rmax,50,0,0,deg2rad(Ellip_ang_xy),0,'r',gca); % Vertical (x-y plane); array perpendicular to aircraft direction
ellipseCoords_xz= ellipse3D(ra_xz,rb_xz,0,sobj.rmax,0,50,pi./2,-deg2rad(Ellip_ang_xz),0,0,'r',gca); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
%ellipseCoords_yz= ellipse3D(ra_yz,rb_yz,rmax,0,0,50,pi./2,-deg2rad(Ellip_ang_yz),pi./2,2,'r',ax); % Horizontal1 (y-z plane); array perpendicular to aircraft direction

sobj.ellipsoid.projection.curr.xy.XData = ellipseCoords_xy(1,:);
sobj.ellipsoid.projection.curr.xy.YData = ellipseCoords_xy(2,:);
sobj.ellipsoid.projection.curr.xy.ZData = ellipseCoords_xy(3,:);

sobj.ellipsoid.projection.curr.xz.XData = ellipseCoords_xz(1,:);
sobj.ellipsoid.projection.curr.xz.YData = ellipseCoords_xz(2,:);
sobj.ellipsoid.projection.curr.xz.ZData = ellipseCoords_xz(3,:);

sobj.ellipsoid.phi_p = phi_p;
sobj.ellipsoid.theta_p = theta_p;
sobj.ellipsoid.psi_p = psi_p;

sobj.ellipsoid.projection.xy.ra = ra_xy;
sobj.ellipsoid.projection.xy.rb = rb_xy;
sobj.ellipsoid.projection.xy.Ellip_ang = Ellip_ang_xy;

sobj.ellipsoid.projection.xz.ra = ra_xz;
sobj.ellipsoid.projection.xz.rb = rb_xz;
sobj.ellipsoid.projection.xz.Ellip_ang = Ellip_ang_xz;

sobj.ellipsoid.projection.area.xy = pi.*ra_xy.*rb_xy;
sobj.ellipsoid.projection.area.xz = pi.*ra_xz.*rb_xz;





end