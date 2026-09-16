

function [sobj,fig] = plot_stl_particle(sobj,varargin)

plot_OAP_ellipses = true;

%% Try reading in particle index number here from sobj
part_ind = sobj.particle_number;

sdata = read_stl_data_init(sobj.folder);

stl_obj = read_stl_particle_init(sdata,part_ind);

sobj.particle.TR = stl_obj.particle.TR;

%% Rotate particle to sampled orientation
sobj = rotate_particle(sobj,sobj.ellipsoid.phi,sobj.ellipsoid.theta,sobj.ellipsoid.psi);

%% Resize particle based on PSD
VertPoints = sobj.particle.max_dim.*sobj.particle.TR.Points;
sobj.particle.TR = triangulation(double(sobj.particle.TR.ConnectivityList),double(VertPoints));

sobj = resize_stl_particle(sobj,sobj.particle.max_dim);

%Generate/read probe images
sobj = particle2probe(sobj,0.01);

fig = figure('units','normalized','position',[0.0891    0.0574    0.6000    0.8000]);

%% NOTE: try modifying so that rotations/scaling/etc are performed on direct read of particle from stl file
temp = sobj.particle.TR;

a_ellip = sobj.ellipsoid.a;
b_ellip = sobj.ellipsoid.b;
c_ellip = sobj.ellipsoid.c;

phi_p = sobj.ellipsoid.phi;
theta_p = sobj.ellipsoid.theta;
psi_p = sobj.ellipsoid.psi;

%% get patch for stl object
ax_3d = subplot(2,2,[1 3]);
ptemp = trisurf(temp,'FaceColor','c','EdgeColor','k','LineStyle','-','linewidth',0.01);

 [Z,Y,X] = ellipsoid(0,0,0,a_ellip,b_ellip,c_ellip,50);

 %% Rotate ellipsoid
 [Nx,Ny] = size(X);

% Z-Y-Z Euler angle rotation convention
rotm = [cosd(phi_p).*cosd(theta_p).*cosd(psi_p)-sind(phi_p).*sind(psi_p) -cosd(psi_p).*sind(phi_p)-cosd(phi_p).*cosd(theta_p).*sind(psi_p) cosd(phi_p).*sind(theta_p); ...
            cosd(phi_p).*sind(psi_p)+cosd(theta_p).*cosd(psi_p).*sind(phi_p) cosd(phi_p).*cosd(psi_p)-cosd(theta_p).*sind(phi_p).*sind(psi_p) sind(phi_p).*sind(theta_p); ...
            -cosd(psi_p).*sind(theta_p) sind(theta_p).*sind(psi_p) cosd(theta_p)];

WData = permute(cat(3,X,Y,Z),[3 1 2]);

X = reshape(rotm(1,:)*WData(:,:),[Nx Ny]);
Y = reshape(rotm(2,:)*WData(:,:),[Nx Ny]);
Z = reshape(rotm(3,:)*WData(:,:),[Nx Ny]);

 hold on; 
 
 ellip = surf(X,Y,Z,'FaceAlpha',0.2,'EdgeColor',[0.5 0.5 0.5],'FaceColor','g','EdgeAlpha',0.2);

axis equal

rmax = 1;

xlim([-rmax rmax])
ylim([-rmax rmax])
zlim([-rmax rmax])

set(gca,'TickLabelInterpreter','latex','fontsize',22)

xlabel('x','interpreter','latex','fontsize',42)
ylabel('y','interpreter','latex','fontsize',42)
zlabel('z','interpreter','latex','fontsize',42,'rotation',0)

box on

set(gca,'xtick',-1:0.5:1,'ytick',-1:0.5:1,'ztick',-1:0.5:1)

%[ra_yz,rb_yz,Ellip_ang_yz]=ellipproj_axes(a,b,c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),1); % Horizontal1 (y-z plane); array perpendicular to aircraft direction
[ra_xz,rb_xz,Ellip_ang_xz]=ellipproj_axes(a_ellip,b_ellip,c_ellip,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),2); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
[ra_xy,rb_xy,Ellip_ang_xy]=ellipproj_axes(a_ellip,b_ellip,c_ellip,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),3); % Vertical (x-y plane); array perpendicular to aircraft direction

%% Plot projections
sobj.particle.projection.curr.xz = fill3(ptemp.XData,rmax.*ones(size(ptemp.YData)),ptemp.ZData,'c','linestyle','none','FaceAlpha',1);
sobj.particle.projection.curr.xy = fill3(ptemp.XData,ptemp.YData,-rmax.*ones(size(ptemp.ZData)),'c','linestyle','none','FaceAlpha',1);

%% Plot ellipses

 [ellipse_xy, sobj.ellipsoid.projection.curr.xy] = ellipse3D(ra_xy,rb_xy,0,0,-rmax,50,0,0,deg2rad(Ellip_ang_xy),2,'g',gca); % Vertical (x-y plane); array perpendicular to aircraft direction
 [ellipse_xz, sobj.ellipsoid.projection.curr.xz] = ellipse3D(ra_xz,rb_xz,0,rmax,0,50,pi./2,-deg2rad(Ellip_ang_xz),0,2,'g',gca); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
% [~, h_yz] = ellipse3D(ra_yz,rb_yz,rmax,0,0,50,pi./2,-deg2rad(Ellip_ang_yz),pi./2,2,'r',ax); % Horizontal1 (y-z plane); array perpendicular to aircraft direction

sobj.ellipsoid.curr = ellip;
sobj.particle.curr = ptemp;


grid_xz = double(sobj.particle.projection.grid.xz);
grid_xy = double(sobj.particle.projection.grid.xy);


grid_xz(grid_xz==1) = NaN;
grid_xy(grid_xy==1) = NaN;

ax_h = subplot(2,2,2);
pcolor(-1:0.01:1,-1:0.01:1,grid_xz);
colormap(gray); shading flat;
hold on;
line(ellipse_xz(1,:),ellipse_xz(3,:),'linewidth',1,'color','g'); % plot ellipse in 3D

set(gca,'TickLabelInterpreter','latex','fontsize',16)

xlabel('x','interpreter','latex','fontsize',42)
ylabel('z','interpreter','latex','fontsize',42,'rotation',0)
title('H Projection','interpreter','latex','fontsize',32)

grid on

axis equal

xlim([-1 1])
ylim([-1 1])

set(gca,'xtick',-1:0.5:1,'ytick',-1:0.5:1)

set(ax_h,'position',[0.6910    0.6407    0.3347    0.2931])

ax_v = subplot(2,2,4);
pcolor(-1:0.01:1,-1:0.01:1,grid_xy);
colormap(gray); shading flat;
hold on;
line(ellipse_xy(1,:),ellipse_xy(2,:),'linewidth',1,'color','g'); % plot ellipse in 3D

set(gca,'TickLabelInterpreter','latex','fontsize',16)

xlabel('x','interpreter','latex','fontsize',42)
ylabel('y','interpreter','latex','fontsize',42,'rotation',0)
title('V Projection','interpreter','latex','fontsize',32)

grid on

axis equal

xlim([-1 1])
ylim([-1 1])

set(gca,'xtick',-1:0.5:1,'ytick',-1:0.5:1)

set(ax_v,'position',[0.6910    0.0986    0.3347    0.2931])

set(ax_3d,'units','normalized','innerposition',[0.0847   -0.1172    0.5232    1.2931])

%set(ax_3d,'zdir','reverse')

%set(ax_3d,'view',[-54 32])

%set(ax_h,'ydir','reverse')


% fprintf('EllipseL_xz = %f\n',EllipseL_xz.*0.01)
% fprintf('EllipseW_xz = %f\n',EllipseW_xz.*0.01)
% fprintf('EllipseAngle_xz = %f\n',EllipseAngle_xz)
% fprintf('Ellipse_ypos_xz = %f\n',Ellipse_ypos_xz.*0.01-1)
% fprintf('Ellipse_xpos_xz = %f\n',Ellipse_xpos_xz.*0.01-1)
% 
% fprintf('EllipseL_xz = %f\n',EllipseL_xy.*0.01)
% fprintf('EllipseW_xz = %f\n',EllipseW_xy.*0.01)
% fprintf('EllipseAngle_xz = %f\n',EllipseAngle_xy)
% fprintf('Ellipse_ypos_xz = %f\n',Ellipse_ypos_xy.*0.01-1)
% fprintf('Ellipse_xpos_xz = %f\n',Ellipse_xpos_xy.*0.01-1)

% Plot ellipses as would be calculated from cloud probe image
  %ellipse_xy_probe = ellipse3D(0.5.*EllipseL_xy.*0.01,0.5.*EllipseW_xy.*0.01-1,Ellipse_xpos_xy.*0.01-1,Ellipse_ypos_xy.*0.01-1,-rmax,50,0,0,EllipseAngle_xy,0,'g',ax_v); % Vertical (x-y plane); array perpendicular to aircraft direction
  %ellipse_xz_probe = ellipse3D(0.5.*EllipseL_xz.*0.01,0.5.*EllipseW_xz.*0.01-1,Ellipse_xpos_xz.*0.01-1,rmax,Ellipse_ypos_xz.*0.01-1,50,pi./2,-EllipseAngle_xz,0,0,'g',ax_h); % Horizontal2 (x-z plane); array perpendicular to aircraft direction

  %ellipse_xy_probe = ellipse3D(0.5.*EllipseL_xy.*0.01,0.5.*EllipseW_xy.*0.01,(Ellipse_xpos_xy).*0.01-1,(Ellipse_ypos_xy).*0.01-1,-rmax,50,0,0,EllipseAngle_xy,0,'g',ax_v); % Vertical (x-y plane); array perpendicular to aircraft direction
  %ellipse_xz_probe = ellipse3D(0.5.*EllipseL_xz.*0.01,0.5.*EllipseW_xz.*0.01,(Ellipse_xpos_xz).*0.01-1,rmax,(Ellipse_ypos_xz).*0.01-1,50,pi./2,-EllipseAngle_xz,0,0,'g',ax_h); % Horizontal2 (x-z plane); array perpendicular to aircraft direction

if plot_OAP_ellipses

  ra_xy_cgal = sobj.particle.projection.xy.ra;
  rb_xy_cgal = sobj.particle.projection.xy.rb;
  EllipAng_xy_cgal = sobj.particle.projection.xy.Ellip_ang;
  xpos_xy_cgal = sobj.particle.projection.xy.xpos;
  ypos_xy_cgal = sobj.particle.projection.xy.ypos;

  ra_xz_cgal = sobj.particle.projection.xz.ra;
  rb_xz_cgal = sobj.particle.projection.xz.rb;
  EllipAng_xz_cgal = sobj.particle.projection.xz.Ellip_ang;
  xpos_xz_cgal = sobj.particle.projection.xz.xpos;
  ypos_xz_cgal = sobj.particle.projection.xz.ypos;

  ellipse_xy_probe = ellipse3D(ra_xy_cgal,rb_xy_cgal,xpos_xy_cgal,ypos_xy_cgal,-rmax,50,0,0,deg2rad(EllipAng_xy_cgal),0,'r',ax_v); % Vertical (x-y plane); array perpendicular to aircraft direction
  ellipse_xz_probe = ellipse3D(ra_xz_cgal,rb_xz_cgal,xpos_xz_cgal,rmax,ypos_xz_cgal,50,pi./2,-deg2rad(EllipAng_xz_cgal),0,0,'r',ax_h); % Horizontal2 (x-z plane); array perpendicular to aircraft direction


  hold(ax_h,'on');
  line(ax_h,ellipse_xz_probe(1,:),ellipse_xz_probe(3,:),'linewidth',1,'color','r'); % plot ellipse in 3D
  hold(ax_h,'off');

  hold(ax_v,'on');
  line(ax_v,ellipse_xy_probe(1,:),ellipse_xy_probe(2,:),'linewidth',1,'color','r'); % plot ellipse in 3D
  hold(ax_v,'off'); 

end




end