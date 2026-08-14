
function sobj = gen_stl_hexagonal(aspect_ratio)

%% STL particle vertices and Faces
VertPoints = [ 1.0000         0    1.0000;
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
-0.5000    1.0000    1.0000]./2;

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
12    11     9];

Faces = fliplr(Faces);

if aspect_ratio<1.0

    VertPoints(:,3) = VertPoints(:,3).*aspect_ratio;

end

if aspect_ratio>1.0

VertPoints(:,1) = VertPoints(:,1)./aspect_ratio;
VertPoints(:,2) = VertPoints(:,2)./aspect_ratio;

end

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

%% Store data

sobj.ellipsoid.a = a_ellip;
sobj.ellipsoid.b = b_ellip;
sobj.ellipsoid.c = c_ellip;

sobj.ellipsoid.phi = 0;
sobj.ellipsoid.theta = 0;
sobj.ellipsoid.psi = 0;

TR = triangulation(Faces,VertPoints);

sobj.RBP=RigidBodyParams(TR);

sobj.particle.TR = TR;

sobj.particle.aspect_ratio = aspect_ratio;

%stlwrite(TR,file_new)

%% Save original setup

sobj.orig.ellipsoid = sobj.ellipsoid;
sobj.orig.particle = sobj.particle;

sobj.particle_number = 1;


end

