
%% generateOAPparticles.m

% folder for stl particles
folder = 'C:\\Users\\edwin.dunnavan\\Documents\\IMPACTS\\Simulations\\SHPSG\\Simulation2\\';

output_ellip = 'stl_ellipsoids.nc';

fdir = dir(strcat(folder,'*.stl'));

N = length(fdir);

%% Specify von Mises orientation distributions
addpath C:\\Users\\edwin.dunnavan\\Documents\\IMPACTS\\Cases\\Ellipsoid_projection_example\\

phimean = 135;
thetamean = 110;
kappa = 5;

psimean = 0;
varpsi = 0.001;

[phi_p,theta_p,psi_p] = getEulerAngles(N,phimean,thetamean,kappa,psimean,varpsi);

spart.N = N;
spart.phimean = phimean;
spart.thetamean = thetamean;
spart.kappa = kappa;

spart.psimean = psimean;
spart.varpsi = varpsi;

spart.index = ones(1,N,'int32');
spart.ellipsoid.a = NaN(1,N,'single');
spart.ellipsoid.b = NaN(1,N,'single');
spart.ellipsoid.c = NaN(1,N,'single');

spart.ellipsoid.phi_p = phi_p;
spart.ellipsoid.theta_p = theta_p;
spart.ellipsoid.psi_p = psi_p;

spart.ellipsoid.projection.xy.ra = NaN(1,N,'single');
spart.ellipsoid.projection.xy.rb = NaN(1,N,'single');
spart.ellipsoid.projection.xy.Ellip_ang = NaN(1,N,'single');

spart.ellipsoid.projection.xz.ra = NaN(1,N,'single');
spart.ellipsoid.projection.xz.rb = NaN(1,N,'single');
spart.ellipsoid.projection.xz.Ellip_ang = NaN(1,N,'single');

spart.particle.projection.area.xy = NaN(1,N,'single');
spart.particle.projection.area.xz = NaN(1,N,'single');
spart.particle.projection.grid.xy = ones(N,201,201,'int8');
spart.particle.projection.grid.xz= ones(N,201,201,'int8');

%% Create stl particle and ellipsoid

for ff = 1 : N

    fprintf('Calculating statistics for particle %i out of %i\n',ff,N)

    ftemp =  fullfile(fdir(ff).folder,fdir(ff).name);

    %% Create stl particle and minimum enclosing ellipsoid
    [sobj,fig] = create_stl_particle(fdir(ff).folder,fdir(ff).name,'off');

    %% Rotate particle to sampled orientation
    sobj = rotate_stl_particle(sobj,phi_p(ff),theta_p(ff),psi_p(ff));
    
    %% Generate OAP arrays for x-y and x-z planes
    sobj = particle2OAP(sobj);

    %% Store particle data in arrays

    spart.ellipsoid.a(ff) = sobj.ellipsoid.a;
    spart.ellipsoid.b(ff) = sobj.ellipsoid.b;
    spart.ellipsoid.c(ff) = sobj.ellipsoid.c;

    spart.ellipsoid.projection.xy.ra(ff) =  sobj.ellipsoid.projection.xy.ra;
    spart.ellipsoid.projection.xy.rb(ff) =  sobj.ellipsoid.projection.xy.rb;
    spart.ellipsoid.projection.xy.Ellip_ang(ff) =  sobj.ellipsoid.projection.xy.Ellip_ang;

    spart.ellipsoid.projection.xz.ra(ff) =  sobj.ellipsoid.projection.xz.ra;
    spart.ellipsoid.projection.xz.rb(ff) =  sobj.ellipsoid.projection.xz.rb;
    spart.ellipsoid.projection.xz.Ellip_ang(ff) =  sobj.ellipsoid.projection.xz.Ellip_ang;

    spart.particle.projection.area.xy(ff) = sobj.particle.projection.area.xy;
    spart.particle.projection.area.xz(ff) = sobj.particle.projection.area.xz;

    spart.particle.projection.grid.xy(ff,:,:) = sobj.particle.projection.grid.xy;
    spart.particle.projection.grid.xz(ff,:,:) = sobj.particle.projection.grid.xz;

    close(fig)

end

%% Save netcdf file
writeparticle(strcat(folder,output_ellip),spart)


function [phi_p,theta_p,psi_p] = getEulerAngles(N,phimean,thetamean,kappa,psimean,varpsi)

x = sind(thetamean).*cosd(phimean);
y = sind(thetamean).*sind(phimean);
z = cosd(thetamean);

mu_tot = [x,y,z];

mu = mu_tot./norm(mu_tot);

RandVMF= randVMF(N, mu, kappa);

xrand = RandVMF(:,1)';
yrand = RandVMF(:,2)';
zrand = RandVMF(:,3)';

theta_p = acos(zrand./sqrt(xrand.^2+yrand.^2+zrand.^2));

phi_p = atan2(yrand,xrand);

phi_p(phi_p<0) = phi_p(phi_p<0)+2.*pi;

psi_p =  (randraw('vonmises',[2.*deg2rad(psimean),varpsi],[1 N]))./2;

psi_p(psi_p>pi) = psi_p(psi_p>pi)-pi;
psi_p(psi_p<0) = psi_p(psi_p<0)+pi;

phi_p = rad2deg(phi_p);
theta_p = rad2deg(theta_p);
psi_p = rad2deg(psi_p);

end