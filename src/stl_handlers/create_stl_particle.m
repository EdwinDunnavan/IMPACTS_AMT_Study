
%{

UNIT HEXAGONAL PRISM;

Vertices = [ 1.0000         0    1.0000;
    0.5000   -1.0000   -1.0000;
    0.5000   -1.0000    1.0000;
   -0.5000   -1.0000   -1.0000;
   -1.0000         0   -1.0000;
    1.0000         0   -1.0000;
    0.5000    1.0000   -1.0000;
   -0.5000    1.0000   -1.0000;
   -1.0000         0    1.0000;
   -0.5000   -1.0000    1.0000;
    0.5000    1.0000    1.0000;
   -0.5000    1.0000    1.0000]


Faces = [ 1     2     3;
     4     2     5;
     4     3     2;
     6     5     2;
     6     2     1;
     7     5     6;
     7     6     1;
     8     5     7;
     9     4     5;
     9     1     3;
     9     5     8;
    10     3     4;
    10     4     9;
    10     9     3;
    11     7     1;
    11     8     7;
    11     1     9;
    12     9     8;
    12     8    11;
    12    11     9]

%}

function [sobj,fig] = create_stl_particle(folder,fname,varargin)

plot_ellipsoid = true;


for ii = 1 : length(varargin)

    switch varargin{ii}

        case 'show_fig'


            visible = varargin{ii+1};


        case 'plot_ellipsoid'

            plot_ellipsoid = varargin{ii+1};



    end


end

temp = stlread(fullfile(folder,fname));

%addpath C:\\Users\\edwin.dunnavan\\Documents\\IMPACTS\\Cases\\Ellipsoid_projection_example\


%% Get STL points
VertPoints = temp.Points;
%tri = temp.ConnectivityList;

%% GET X,Y,Z DATA for stl particle
%Xt = temp.Points(:,1);
%Yt = temp.Points(:,2);
%Zt = temp.Points(:,3);

%VertPoints_new = temp.Points;

%Xdata = Xt(tri)';
%Ydata = Yt(tri)';
%Zdata = Zt(tri)';

%Xdata = Xt';
%Ydata = Yt';
%Zdata = Zt';




%% Find enclosing ellipsoid
[~,c,~,~,a_ellip,b_ellip,c_ellip,phi1,theta1,psi1] = MinVolEllipse(VertPoints',1e-3);


if isnan(phi1)
    phi1 = 0;
end

if isnan(theta1)
    theta1 = 0;
end

if isnan(psi1)
    psi1 = 0;
end

%% ROTATE according to method in rotate.m

VertPoints = rotate_vertices(VertPoints,[0 0 1],-phi1,c);
VertPoints = rotate_vertices(VertPoints,[0 1 0],-theta1,c);
VertPoints = rotate_vertices(VertPoints,[1 0 0],-psi1,c);

VertPoints = VertPoints-c';

%% Rescale ellipsoid and particle to normalized particle maximum dimension
rescale = max(VertPoints(:,3))-min(VertPoints(:,3));

a_ellip = a_ellip./rescale;
b_ellip = b_ellip./rescale;
c_ellip = c_ellip./rescale;

VertPoints = VertPoints./rescale;

%% Store data

sobj.ellipsoid.a = a_ellip;
sobj.ellipsoid.b = b_ellip;
sobj.ellipsoid.c = c_ellip;

TR = triangulation(temp.ConnectivityList,VertPoints);

sobj.particle.TR = TR;


%% Plot ellipsoid



%rotate(ptemp,[0 0 1],-phi1,c) % rotation about z-axis
%rotate(ptemp,[0 1 0],-theta1,c) % rotation about y-axis
%rotate(ptemp,[1 0 0],-psi1,c) % rotation about x-axis

rmax = 1;

if plot_ellipsoid

    fig = figure('units','normalized');

%% get patch for stl object
ptemp = trisurf(TR,'FaceColor','c','EdgeColor','k','LineStyle','-','linewidth',0.5);

 [Z,Y,X] = ellipsoid(0,0,0,a_ellip,b_ellip,c_ellip,50);

 hold on; ellip = surf(X,Y,Z,'FaceAlpha',0.2,'EdgeColor',[0.5 0.5 0.5],'FaceColor','g','EdgeAlpha',0.2);


xlim([-rmax rmax])
ylim([-rmax rmax])
zlim([-rmax rmax])

xlabel('x','interpreter','latex','fontsize',26)
ylabel('y','interpreter','latex','fontsize',26)
zlabel('z','interpreter','latex','fontsize',26)

box on

set(gca,'TickLabelInterpreter','latex','fontsize',22)

axis equal

end

phi_p = 0;
theta_p = 0;
psi_p = 0;

a = a_ellip;
b = b_ellip;
c = c_ellip;

%[ra_yz,rb_yz,Ellip_ang_yz]=ellipproj_axes(a,b,c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),1); % Horizontal1 (y-z plane); array perpendicular to aircraft direction
[ra_xz,rb_xz,Ellip_ang_xz]=ellipproj_axes(a,b,c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),2); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
[ra_xy,rb_xy,Ellip_ang_xy]=ellipproj_axes(a,b,c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),3); % Vertical (x-y plane); array perpendicular to aircraft direction

%% Plot projections
sobj.particle.projection.curr.xz = fill3(ptemp.XData,rmax.*ones(size(ptemp.YData)),ptemp.ZData,'c','linestyle','none','FaceAlpha',1);
sobj.particle.projection.curr.xy = fill3(ptemp.XData,ptemp.YData,-rmax.*ones(size(ptemp.ZData)),'c','linestyle','none','FaceAlpha',1);

%% Plot ellipses

 [~, sobj.ellipsoid.projection.curr.xy] = ellipse3D(ra_xy,rb_xy,0,0,-rmax,50,0,0,deg2rad(Ellip_ang_xy),2,'r',gca); % Vertical (x-y plane); array perpendicular to aircraft direction
 [~, sobj.ellipsoid.projection.curr.xz] = ellipse3D(ra_xz,rb_xz,0,rmax,0,50,pi./2,-deg2rad(Ellip_ang_xz),0,2,'r',gca); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
% [~, h_yz] = ellipse3D(ra_yz,rb_yz,rmax,0,0,50,pi./2,-deg2rad(Ellip_ang_yz),pi./2,2,'r',ax); % Horizontal1 (y-z plane); array perpendicular to aircraft direction


%% Store data
sobj.ellipsoid.projection.xz.ra = ra_xz;
sobj.ellipsoid.projection.xz.rb = rb_xz;
sobj.ellipsoid.projection.xz.Ellip_ang = Ellip_ang_xz;

sobj.ellipsoid.projection.xy.ra = ra_xy;
sobj.ellipsoid.projection.xy.rb = rb_xy;
sobj.ellipsoid.projection.xy.Ellip_ang = Ellip_ang_xy;

sobj.ellipsoid.orig.XData = ellip.XData;
sobj.ellipsoid.orig.YData = ellip.YData;
sobj.ellipsoid.orig.ZData = ellip.ZData;

sobj.particle.orig.Vertices = ptemp.Vertices;
sobj.particle.orig.XData = ptemp.XData;
sobj.particle.orig.YData = ptemp.YData;
sobj.particle.orig.ZData = ptemp.ZData;

sobj.ellipsoid.curr = ellip;
sobj.particle.curr = ptemp;

sobj.ellipsoid.projection.orig.xy(:).XData = sobj.ellipsoid.projection.curr.xy(:).XData;
sobj.ellipsoid.projection.orig.xy(:).YData = sobj.ellipsoid.projection.curr.xy(:).YData;
sobj.ellipsoid.projection.orig.xy(:).ZData = sobj.ellipsoid.projection.curr.xy(:).ZData;

sobj.ellipsoid.projection.orig.xz(:).XData = sobj.ellipsoid.projection.curr.xz(:).XData;
sobj.ellipsoid.projection.orig.xz(:).YData = sobj.ellipsoid.projection.curr.xz(:).YData;
sobj.ellipsoid.projection.orig.xz(:).ZData = sobj.ellipsoid.projection.curr.xz(:).ZData;

sobj.rmax = rmax;
sobj.ellipsoid.a = a;
sobj.ellipsoid.b = b;
sobj.ellipsoid.c = c;

sobj.ellipsoid.projection.area.xy = pi.*ra_xy.*rb_xy;
sobj.ellipsoid.projection.area.xz = pi.*ra_xz.*rb_xz;

end