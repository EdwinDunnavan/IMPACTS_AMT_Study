function sobj = resize_stl_particle(sobj,new_size)

VertPoints = sobj.particle.TR.Points;

a_ellip = sobj.ellipsoid.a;
b_ellip = sobj.ellipsoid.b;
c_ellip = sobj.ellipsoid.c;

%% Rescale ellipsoid and particle to normalized particle maximum dimension
%rescale = max(VertPoints(:,3))-min(VertPoints(:,3));

vert = new_size.*(a_ellip);
b    = new_size.*(b_ellip);
c    = new_size.*(c_ellip);

VertPoints = new_size.*(VertPoints);

%% Store data

sobj.ellipsoid.a = vert;
sobj.ellipsoid.b = b;
sobj.ellipsoid.c = c;


TR = triangulation(double(sobj.particle.TR.ConnectivityList),double(VertPoints));

sobj.particle.TR = TR;

% Save 3D STL particle inertia tensor
RBP = RigidBodyParams(TR);
sobj.particle.moments = RBP.moments;
sobj.particle.area = RBP.area;

%% Recalculate probe properties
%sobj = particle2probe(sobj,pix_size);



end