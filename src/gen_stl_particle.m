
function sobj = gen_stl_particle(folder,fname)

temp = stlread(fullfile(folder,fname));

part_ind = extractBetween(fname,'_','_');

part_ind = part_ind{1};

file_new = fullfile(folder,strcat('particle_',string(part_ind),'_init.stl'));

VertPoints = temp.Points;

%% Find minimum volume enclosing ellipsoid
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

phi_p = 0;
theta_p = 0;
psi_p = 0;

%% Rescale ellipsoid and particle to normalized particle maximum dimension
rescale = max(VertPoints(:,3))-min(VertPoints(:,3));

vert = a_ellip./rescale;
b = b_ellip./rescale;
c = c_ellip./rescale;

VertPoints = VertPoints./rescale;

%[ra_yz,rb_yz,Ellip_ang_yz]=ellipproj_axes(a,b,c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),1); % Horizontal1 (y-z plane); array perpendicular to aircraft direction
[ra_xz,rb_xz,Ellip_ang_xz]=ellipproj_axes(vert,b,c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),2); % Horizontal2 (x-z plane); array perpendicular to aircraft direction
[ra_xy,rb_xy,Ellip_ang_xy]=ellipproj_axes(vert,b,c,deg2rad(phi_p),deg2rad(theta_p),deg2rad(psi_p),3); % Vertical (x-y plane); array perpendicular to aircraft direction

%% Store data
sobj.ellipsoid.projection.xz.ra = ra_xz;
sobj.ellipsoid.projection.xz.rb = rb_xz;
sobj.ellipsoid.projection.xz.Ellip_ang = Ellip_ang_xz;

sobj.ellipsoid.projection.xy.ra = ra_xy;
sobj.ellipsoid.projection.xy.rb = rb_xy;
sobj.ellipsoid.projection.xy.Ellip_ang = Ellip_ang_xy;

sobj.ellipsoid.a = vert;
sobj.ellipsoid.b = b;
sobj.ellipsoid.c = c;
sobj.ellipsoid.phi = phi_p;
sobj.ellipsoid.theta = theta_p;
sobj.ellipsoid.psi = psi_p;

sobj.ellipsoid.projection.area.xy = pi.*ra_xy.*rb_xy;
sobj.ellipsoid.projection.area.xz = pi.*ra_xz.*rb_xz;

TR = triangulation(temp.ConnectivityList,VertPoints);

% area = 0; %initialize the area
% %loop over all the desired small triangles and accumulate the areas
% for i = 1:size(TR.ConnectivityList,1)   %the number of rows gives the number of triangles produced
% vert =  TR.Points(TR.ConnectivityList(i,:),:); %this gives the 3 vertices of the ith triangle
% if any(vert(:,3) > 0.4)
% continue;  %if the triangle has a vertex whose z - coordinate is > 0.4 ignore it
% end
% %extract the three vertices
% p1 = vert(1,:);
% p2 = vert(2,:);
% p3 = vert(3,:);
% area = area + 0.5 * norm(cross(p2-p1,p3-p1));  %calculate the area of the small triangle and add with previous result
% end

sobj.particle.TR = TR;

stlwrite(TR,file_new)

%% Save original setup
sobj.orig.ellipsoid = sobj.ellipsoid;
sobj.orig.particle = sobj.particle;



end
