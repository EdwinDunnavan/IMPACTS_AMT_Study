

%% Read in stl particle and minimum volume enclosing ellipsoid

gif_filename = 'Irregular_ex.gif';
folder = './Simulation_plot_irreg_example/';

ellipsoid_switch = false;


%% Read in stl particle and properties
sdata = read_stl_data_init(folder);

t = sdata.particle_number;

[~,sort_ind] = sort(t);

phi_series = 0.*ones(size(t));
theta_series = 90.*ones(size(t));
psi_series = 0.*ones(size(t));


%% Set up figure and axes
fig = figure('units','normalized','position',[0.0891    0.0574    0.6000    0.8000],'visible','off','color','w');
ax_3d = subplot(2,2,[1 3]);
ax_h = subplot(2,2,2);
ax_v = subplot(2,2,4);

set(ax_h,'position',[0.6910    0.6407    0.3347    0.2931])
set(ax_v,'position',[0.6910    0.0986    0.3347    0.2931])
set(ax_3d,'units','normalized','innerposition',[0.0847   -0.1172    0.5232    1.2931])

axis(ax_3d,'equal')

rmax = 1;

xlim(ax_3d,[-rmax rmax])
ylim(ax_3d,[-rmax rmax])
zlim(ax_3d,[-rmax rmax])
set(ax_3d,'TickLabelInterpreter','latex','fontsize',22)
xlabel(ax_3d,'x','interpreter','latex','fontsize',42)
ylabel(ax_3d,'y','interpreter','latex','fontsize',42)
zlabel(ax_3d,'z','interpreter','latex','fontsize',42,'rotation',0)

grid(ax_3d,'on')

colormap(ax_h,gray); 
shading(ax_h,'flat');

grid(ax_h,'on')
box(ax_h,'on')
axis(ax_h,'equal')

xlim(ax_h,[-1 1])
ylim(ax_h,[-1 1])

set(ax_h,'xtick',-1:0.5:1,'ytick',-1:0.5:1)
set(ax_v,'xtick',-1:0.5:1,'ytick',-1:0.5:1)

set(ax_h,'TickLabelInterpreter','latex','fontsize',16)
set(ax_v,'TickLabelInterpreter','latex','fontsize',16)

xlabel(ax_h,'x','interpreter','latex','fontsize',42)
ylabel(ax_h,'z','interpreter','latex','fontsize',42,'rotation',0)
title(ax_h,'H Projection','interpreter','latex','fontsize',32)

xlabel(ax_v,'x','interpreter','latex','fontsize',42)
ylabel(ax_v,'y','interpreter','latex','fontsize',42,'rotation',0)
title(ax_v,'V Projection','interpreter','latex','fontsize',32)

colormap(ax_v,gray); 
shading(ax_v,'flat');

grid(ax_v,'on')
box(ax_v,'on')
axis(ax_v,'equal')

xlim(ax_v,[-1 1])
ylim(ax_v,[-1 1])

box(ax_3d,'on')

set(ax_3d,'xtick',-1:0.5:1,'ytick',-1:0.5:1,'ztick',-1:0.5:1)
%set(ax_3d,'view',[-54 32])

set(ax_3d,'view',[-37.5 30])

hold(ax_3d,'on');
hold(ax_h,'on');
hold(ax_v,'on');

im = cell(1,length(t));

for ff = t

%part_ind = ff;
sobj = read_stl_particle_init(sdata,ff);


    fprintf('Generating frame %i out of %i\n',ff,length(t))

    sobj.ellipsoid.phi = phi_series(ff);
    sobj.ellipsoid.theta = theta_series(ff);
    sobj.ellipsoid.psi = psi_series(ff);

%% Rotate particle to sampled orientation
sobj = rotate_particle(sobj,sobj.ellipsoid.phi,sobj.ellipsoid.theta,sobj.ellipsoid.psi);

%% Generate/read probe images
sobj = particle2probe(sobj,pix_size);

%% NOTE: try modifying so that rotations/scaling/etc are performed on direct read of particle from stl file
temp = sobj.particle.TR;

a_ellip = sobj.ellipsoid.a;
b_ellip = sobj.ellipsoid.b;
c_ellip = sobj.ellipsoid.c;

phi_p = sobj.ellipsoid.phi;
theta_p = sobj.ellipsoid.theta;
psi_p = sobj.ellipsoid.psi;

 [Z,Y,X] = ellipsoid(0,0,0,a_ellip,b_ellip,c_ellip,50);

 [X,Y,Z] = rotate_ellipsoid(X,Y,Z,phi_p,theta_p,psi_p);

 [ra_xz,rb_xz,Ellip_ang_xz]=ellipproj_axes(a_ellip,b_ellip,c_ellip,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),2); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
 [ra_xy,rb_xy,Ellip_ang_xy]=ellipproj_axes(a_ellip,b_ellip,c_ellip,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),3); % Vertical (x-y plane); array perpendicular to aircraft direction

 
 if ff == 1
 ptemp = trisurf(temp,'FaceColor','c','EdgeColor','k','LineStyle','-','linewidth',0.01,'Parent',ax_3d);
 if ellipsoid_switch
 ellip = surf(ax_3d,X,Y,Z,'FaceAlpha',0.2,'EdgeColor',[0.5 0.5 0.5],'FaceColor','g','EdgeAlpha',0.2);
 end

 %% Plot projections
 ptemp_xz = fill3(ax_3d,ptemp.XData,rmax.*ones(size(ptemp.YData)),ptemp.ZData,'c','linestyle','none','FaceAlpha',1);
 ptemp_xy = fill3(ax_3d,ptemp.XData,ptemp.YData,-rmax.*ones(size(ptemp.ZData)),'c','linestyle','none','FaceAlpha',1);

%% Plot ellipses
if ellipsoid_switch
%[ra_yz,rb_yz,Ellip_ang_yz]=ellipproj_axes(a,b,c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),1); % Horizontal1 (y-z plane); array perpendicular to aircraft direction
 [ellipse_xy, etemp_xy] = ellipse3D(ra_xy,rb_xy,0,0,-rmax,50,0,0,deg2rad(Ellip_ang_xy),2,'g',ax_3d); % Vertical (x-y plane); array perpendicular to aircraft direction
 [ellipse_xz, etemp_xz] = ellipse3D(ra_xz,rb_xz,0,rmax,0,50,pi./2,-deg2rad(Ellip_ang_xz),0,2,'g',ax_3d); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
end

 else 

    ptemp.Vertices = sobj.particle.TR.Points;
    if ellipsoid_switch
    ellip.XData = X;
    ellip.YData = Y;
    ellip.ZData = Z;
    end
    %% Plot projections
    delete(ptemp_xz)
    delete(ptemp_xy)
    ptemp_xz = fill3(ax_3d,ptemp.XData,rmax.*ones(size(ptemp.YData)),ptemp.ZData,'c','linestyle','none','FaceAlpha',1);
    ptemp_xy = fill3(ax_3d,ptemp.XData,ptemp.YData,-rmax.*ones(size(ptemp.ZData)),'c','linestyle','none','FaceAlpha',1);

    if ellipsoid_switch

    ellipse_xy = ellipse3D(ra_xy,rb_xy,0,0,-rmax,50,0,0,deg2rad(Ellip_ang_xy),0,'g',ax_3d); % Vertical (x-y plane); array perpendicular to aircraft direction
    ellipse_xz= ellipse3D(ra_xz,rb_xz,0,rmax,0,50,pi./2,-deg2rad(Ellip_ang_xz),0,0,'g',ax_3d); % Horizontal2 (x-z plane); array perpendicular to aircraft direction

    etemp_xy.XData = ellipse_xy(1,:);
    etemp_xy.YData = ellipse_xy(2,:);

    etemp_xz.XData = ellipse_xz(1,:);
    etemp_xz.ZData = ellipse_xz(3,:);
    end

 end


sobj.ellipsoid.curr = ellip;
sobj.particle.curr = ptemp;

grid_xz = double(sobj.particle.projection.grid.xz);
grid_xy = double(sobj.particle.projection.grid.xy);

grid_xz(grid_xz==1) = NaN;
grid_xy(grid_xy==1) = NaN;

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

 ellipse_xz_probe = ellipse3D(ra_xz_cgal,rb_xz_cgal,xpos_xz_cgal,rmax,ypos_xz_cgal,50,pi./2,-deg2rad(EllipAng_xz_cgal),0,0,'r',ax_h); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
ellipse_xy_probe = ellipse3D(ra_xy_cgal,rb_xy_cgal,xpos_xy_cgal,ypos_xy_cgal,-rmax,50,0,0,deg2rad(EllipAng_xy_cgal),0,'r',ax_v); % Vertical (x-y plane); array perpendicular to aircraft direction


if ff == 1
ph = pcolor(ax_h,-1:0.01:1,-1:0.01:1,grid_xz);
pv = pcolor(ax_v,-1:0.01:1,-1:0.01:1,grid_xy);

shading(ax_h,'flat')
shading(ax_v,'flat')

if ellipsoid_switch
lg_xz = line(ax_h,ellipse_xz(1,:),ellipse_xz(3,:),'linewidth',1,'color','g'); % plot ellipse in 3D
lg_xy = line(ax_v,ellipse_xy(1,:),ellipse_xy(2,:),'linewidth',1,'color','g'); % plot ellipse in 3D

lr_xz = line(ax_h,ellipse_xz_probe(1,:),ellipse_xz_probe(3,:),'linewidth',1,'color','r'); % plot ellipse in 3D
lr_xy = line(ax_v,ellipse_xy_probe(1,:),ellipse_xy_probe(2,:),'linewidth',1,'color','r'); % plot ellipse in 3D
end

else

    %% Update properties of ellipses and shading

    ph.CData = grid_xz;
    pv.CData = grid_xy;

    if ellipsoid_switch
    lg_xz.XData = ellipse_xz(1,:);
    lg_xz.YData = ellipse_xz(3,:);

    lg_xy.XData = ellipse_xy(1,:);
    lg_xy.YData = ellipse_xy(2,:);

    lr_xz.XData = ellipse_xz_probe(1,:);
    lr_xz.YData = ellipse_xz_probe(3,:);

    lr_xy.XData = ellipse_xy_probe(1,:);
    lr_xy.YData = ellipse_xy_probe(2,:);
    end

end

%pause(1)

drawnow
frame = getframe(fig);
im{ff}=frame2im(frame);

end

close(fig)

%% Generate GIF

for ff = 1 : length(im)

    im_temp = im{sort_ind(ff)};

    [A,map] = rgb2ind(im_temp,256);

    if ff == 1 

        imwrite(A,map,strcat(folder,gif_filename),'gif',LoopCount=0,DelayTime=1./30)

    else

        imwrite(A,map,strcat(folder,gif_filename),'gif',WriteMode='append',DelayTime=1./30)

    end


end

  function [X,Y,Z] = rotate_ellipsoid(X,Y,Z,phi_p,theta_p,psi_p)

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

  end

