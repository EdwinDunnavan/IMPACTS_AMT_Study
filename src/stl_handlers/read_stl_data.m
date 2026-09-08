
function obj = read_stl_data(folder)

%% get netcdf file names
fdir = dir(strcat(folder,'stl_ellipsoids*.nc'));

if isempty(fdir)

    error('Folder does not exist!')

end


N = length(fdir);

obj.index = [];

obj.particle_number = [];

obj.a = [];
obj.b = [];
obj.c = [];
obj.phi = [];
obj.theta = [];
obj.psi = [];
obj.moments = [];
obj.surface_area = [];

obj.ra_xy = [];
obj.rb_xy = [];
obj.EllipAng_xy = [];

obj.ra_xz = [];
obj.rb_xz = [];
obj.EllipAng_xz = [];

%obj.vertices = [];
%obj.connectivity=[];

obj.max_dim = [];

obj.particle_area_xy = [];
obj.particle_area_xz = [];

obj.particle_perimeter_xy = [];
obj.particle_perimeter_xz = [];

%obj.image_xy = [];
%obj.image_xz = [];

obj.Dmax_xy_cgal = [];
obj.xcirc_xy_cgal = [];
obj.ycirc_xy_cgal = [];
obj.ra_xy_cgal = [];
obj.rb_xy_cgal = [];
obj.EllipAng_xy_cgal = [];
obj.xpos_xy_cgal = [];
obj.ypos_xy_cgal = [];
obj.habit_xy = [];

obj.Dmax_xz_cgal = [];
obj.xcirc_xz_cgal = [];
obj.ycirc_xz_cgal = [];
obj.ra_xz_cgal = [];
obj.rb_xz_cgal = [];
obj.EllipAng_xz_cgal = [];
obj.xpos_xz_cgal = [];
obj.ypos_xz_cgal = [];
obj.habit_xz = [];

%% Loop through files and read variables into arrays
for ff = 1 : N

    ftemp = fullfile(fdir(ff).folder,fdir(ff).name);

    finfo = ncinfo(ftemp);

    fnames = string({finfo.Variables.Name});

    if ff == 1

        obj.folder = ncreadatt(ftemp,'/','folder');
        obj.test_folder = ncreadatt(ftemp,'/','test_folder');

        obj.phimean = ncread(ftemp,'phimean');
        obj.thetamean = ncread(ftemp,'thetamean');
        obj.kappa = ncread(ftemp,'kappa');
        obj.psimean = ncread(ftemp,'psimean');
        obj.varpsi = ncread(ftemp,'varpsi');


    end

obj.index = [obj.index ncread(ftemp,'index')'];

obj.particle_number = [obj.particle_number ncread(ftemp,'particle_number')'];
obj.a = [obj.a ncread(ftemp,'a')'];
obj.b = [obj.b ncread(ftemp,'b')'];
obj.c = [obj.c ncread(ftemp,'c')'];
obj.phi = [obj.phi ncread(ftemp,'phi')'];
obj.theta = [obj.theta ncread(ftemp,'theta')'];
obj.psi = [obj.psi ncread(ftemp,'psi')'];

obj.moments = [obj.moments; ncread(ftemp,'moments')'];
obj.surface_area = [obj.surface_area ncread(ftemp,'surface_area')'];

obj.ra_xy = [obj.ra_xy ncread(ftemp,'ra_xy')'];
obj.rb_xy = [obj.rb_xy ncread(ftemp,'rb_xy')'];
obj.EllipAng_xy = [obj.EllipAng_xy ncread(ftemp,'EllipAng_xy')'];

obj.ra_xz = [obj.ra_xz ncread(ftemp,'ra_xz')'];
obj.rb_xz = [obj.rb_xz ncread(ftemp,'rb_xz')'];
obj.EllipAng_xz = [obj.EllipAng_xz ncread(ftemp,'EllipAng_xz')'];

%obj.vertices = [obj.vertices; ncread(ftemp,'particle_vertices')];
%obj.connectivity = [obj.connectivity; ncread(ftemp,'particle_connectivity')];

obj.max_dim = [obj.max_dim ncread(ftemp,'max_dim')'];

obj.particle_area_xy = [obj.particle_area_xy ncread(ftemp,'particle_area_xy')'];
obj.particle_area_xz = [obj.particle_area_xz ncread(ftemp,'particle_area_xz')'];

obj.particle_perimeter_xy = [obj.particle_perimeter_xy ncread(ftemp,'particle_perimeter_xy')'];
obj.particle_perimeter_xz = [obj.particle_perimeter_xz ncread(ftemp,'particle_perimeter_xz')'];

%obj.image_xy = [obj.image_xy; ncread(ftemp,'image_xy')];
%obj.image_xz = [obj.image_xz; ncread(ftemp,'image_xz')];

obj.Dmax_xy_cgal = [obj.Dmax_xy_cgal ncread(ftemp,'Dmax_xy_cgal')'];
obj.xcirc_xy_cgal = [obj.xcirc_xy_cgal ncread(ftemp,'xcirc_xy_cgal')'];
obj.ycirc_xy_cgal = [obj.ycirc_xy_cgal ncread(ftemp,'ycirc_xy_cgal')'];
obj.ra_xy_cgal = [obj.ra_xy_cgal ncread(ftemp,'ra_xy_cgal')'];
obj.rb_xy_cgal = [obj.rb_xy_cgal ncread(ftemp,'rb_xy_cgal')'];
obj.EllipAng_xy_cgal = [obj.EllipAng_xy_cgal ncread(ftemp,'EllipAng_xy_cgal')'];
obj.xpos_xy_cgal = [obj.xpos_xy_cgal ncread(ftemp,'xpos_xy_cgal')'];
obj.ypos_xy_cgal = [obj.ypos_xy_cgal ncread(ftemp,'ypos_xy_cgal')'];

if any(fnames=='habit_xy')

    obj.habit_xy = [obj.habit_xy; ncread(ftemp,'habit_xy')];

else

    obj.habit_xy = [obj.habit_xy; zeros(size(ncread(ftemp,'max_dim')))];

end

obj.Dmax_xz_cgal = [obj.Dmax_xz_cgal ncread(ftemp,'Dmax_xz_cgal')'];
obj.xcirc_xz_cgal = [obj.xcirc_xz_cgal ncread(ftemp,'xcirc_xz_cgal')'];
obj.ycirc_xz_cgal = [obj.ycirc_xz_cgal ncread(ftemp,'ycirc_xz_cgal')'];
obj.ra_xz_cgal = [obj.ra_xz_cgal ncread(ftemp,'ra_xz_cgal')'];
obj.rb_xz_cgal = [obj.rb_xz_cgal ncread(ftemp,'rb_xz_cgal')'];
obj.EllipAng_xz_cgal = [obj.EllipAng_xz_cgal ncread(ftemp,'EllipAng_xz_cgal')'];
obj.xpos_xz_cgal = [obj.xpos_xz_cgal ncread(ftemp,'xpos_xz_cgal')'];
obj.ypos_xz_cgal = [obj.ypos_xz_cgal ncread(ftemp,'ypos_xz_cgal')'];

if any(fnames=='habit_xz')

    obj.habit_xz = [obj.habit_xz; ncread(ftemp,'habit_xz')];

else

    obj.habit_xz = [obj.habit_xz; zeros(size(ncread(ftemp,'max_dim')))];

end


end


%% Resort all data

%[obj.particle_number,sort_ind] = sort(obj.particle_number);

[obj.index,sort_ind] = sort(obj.index);

obj.particle_number = obj.particle_number(sort_ind);

obj.a = obj.a(sort_ind);
obj.b = obj.b(sort_ind);
obj.c = obj.c(sort_ind);
obj.phi = obj.phi(sort_ind);
obj.theta = obj.theta(sort_ind);
obj.psi = obj.psi(sort_ind);
obj.moments = obj.moments(sort_ind,:)';
obj.surface_area = obj.surface_area(sort_ind);

obj.ra_xy = obj.ra_xy(sort_ind);
obj.rb_xy = obj.rb_xy(sort_ind);
obj.EllipAng_xy = obj.EllipAng_xy(sort_ind);

obj.ra_xz = obj.ra_xz(sort_ind);
obj.rb_xz = obj.rb_xz(sort_ind);
obj.EllipAng_xz = obj.EllipAng_xz(sort_ind);

obj.max_dim = obj.max_dim(sort_ind);

obj.particle_area_xy = obj.particle_area_xy(sort_ind);
obj.particle_area_xz = obj.particle_area_xz(sort_ind);

obj.particle_perimeter_xy = obj.particle_perimeter_xy(sort_ind);
obj.particle_perimeter_xz = obj.particle_perimeter_xz(sort_ind);

obj.Dmax_xy_cgal = obj.Dmax_xy_cgal(sort_ind);
obj.xcirc_xy_cgal = obj.xcirc_xy_cgal(sort_ind);
obj.ycirc_xy_cgal = obj.ycirc_xy_cgal(sort_ind);
obj.ra_xy_cgal = obj.ra_xy_cgal(sort_ind);
obj.rb_xy_cgal = obj.rb_xy_cgal(sort_ind);
obj.EllipAng_xy_cgal = obj.EllipAng_xy_cgal(sort_ind);
obj.xpos_xy_cgal = obj.xpos_xy_cgal(sort_ind);
obj.ypos_xy_cgal = obj.ypos_xy_cgal(sort_ind);
obj.habit_xy = obj.habit_xy(sort_ind);

obj.Dmax_xz_cgal = obj.Dmax_xz_cgal(sort_ind);
obj.xcirc_xz_cgal = obj.xcirc_xz_cgal(sort_ind);
obj.ycirc_xz_cgal = obj.ycirc_xz_cgal(sort_ind);
obj.ra_xz_cgal = obj.ra_xz_cgal(sort_ind);
obj.rb_xz_cgal = obj.rb_xz_cgal(sort_ind);
obj.EllipAng_xz_cgal = obj.EllipAng_xz_cgal(sort_ind);
obj.xpos_xz_cgal = obj.xpos_xz_cgal(sort_ind);
obj.ypos_xz_cgal = obj.ypos_xz_cgal(sort_ind);
obj.habit_xz = obj.habit_xz(sort_ind);

obj.area_ratio_xy = obj.particle_area_xy./(pi.*obj.ra_xy.*obj.rb_xy);
obj.area_ratio_xz = obj.particle_area_xz./(pi.*obj.ra_xz.*obj.rb_xz);
obj.area_ratio_xy_cgal = obj.particle_area_xy./(pi.*obj.ra_xy_cgal.*obj.rb_xy_cgal);
obj.area_ratio_xz_cgal = obj.particle_area_xz./(pi.*obj.ra_xz_cgal.*obj.rb_xz_cgal);

%% Compute ellipsoid surface areas
[obj.Sellip,obj.Vellip] = ellipsoid_geometry(obj.a,obj.b,obj.c);

%% Calculate ellipse geometry
[obj.ellipse_perimeter_xy,obj.ellipse_area_xy] = ellipse_geometry(obj.ra_xy,obj.rb_xy);
[obj.ellipse_perimeter_xz,obj.ellipse_area_xz] = ellipse_geometry(obj.ra_xz,obj.rb_xz);
[obj.ellipse_perimeter_xy_cgal,obj.ellipse_area_xy_cgal] = ellipse_geometry(obj.ra_xy_cgal,obj.rb_xy_cgal);
[obj.ellipse_perimeter_xz_cgal,obj.ellipse_area_xz_cgal] = ellipse_geometry(obj.ra_xz_cgal,obj.rb_xz_cgal);

obj.volume = obj.moments(1,:);
obj.sphericity = pi^(1/3).*((6.*obj.volume).^(2/3))./(obj.surface_area);
obj.ellipsoid_sphericity = pi^(1/3).*((6.*obj.Vellip).^(2/3))./(obj.Sellip);

obj.ellipsoidity_ratio = obj.sphericity./obj.ellipsoid_sphericity;

obj.effective_density = obj.volume./obj.Vellip;
obj.effective_area = obj.surface_area./obj.Sellip;

obj.circularity_xy = 4.*pi.*obj.particle_area_xy./(obj.particle_perimeter_xy.^2);
obj.circularity_xz = 4.*pi.*obj.particle_area_xz./(obj.particle_perimeter_xz.^2);

obj.circularity_ellipse_xy = 4.*pi.*obj.ellipse_area_xy./(obj.ellipse_perimeter_xy.^2);
obj.circularity_ellipse_xz = 4.*pi.*obj.ellipse_area_xz./(obj.ellipse_perimeter_xz.^2);

obj.circularity_ellipse_xy_cgal = 4.*pi.*obj.ellipse_area_xy_cgal./(obj.ellipse_perimeter_xy_cgal.^2);
obj.circularity_ellipse_xz_cgal = 4.*pi.*obj.ellipse_area_xz_cgal./(obj.ellipse_perimeter_xz_cgal.^2);

obj.ellipticity_xy = obj.circularity_xy./obj.circularity_ellipse_xy;
obj.ellipticity_xz = obj.circularity_xz./obj.circularity_ellipse_xz;

obj.ellipticity_xy_cgal = obj.circularity_xy./obj.circularity_ellipse_xy_cgal;
obj.ellipticity_xz_cgal = obj.circularity_xz./obj.circularity_ellipse_xz_cgal;

%% Compute complexity parameters
obj.complexity_xy = (1./(sqrt(obj.ellipse_area_xy.*obj.particle_area_xy)./obj.particle_perimeter_xy.^2));
obj.complexity_xz = (1./(sqrt(obj.ellipse_area_xz.*obj.particle_area_xz)./obj.particle_perimeter_xz.^2));

obj.complexity_xy_cgal = (1./(sqrt(obj.ellipse_area_xy_cgal.*obj.particle_area_xy)./obj.particle_perimeter_xy.^2));
obj.complexity_xz_cgal = (1./(sqrt(obj.ellipse_area_xz_cgal.*obj.particle_area_xz)./obj.particle_perimeter_xz.^2));

end




function [S,V] = ellipsoid_geometry(a,b,c)

phi = acos(c./a);
kap = sqrt((a.^2.*(b.^2-c.^2))./(b.^2.*(a.^2-c.^2)));

F = NaN(1,length(a));
E = NaN(1,length(a));
for ii = 1 : length(a)

    if (isnan(phi(ii))) || (isnan(kap(ii)))
        continue
    else

        [F(ii),E(ii)] = elliptic12(phi(ii),kap(ii),1e-16);
    end

end

S = 2.*pi.*c.^2+((2.*pi.*a.*b)./sin(phi)).*(E.*sin(phi).^2+F.*cos(phi).^2);

V = (4./3).*pi.*a.*b.*c;

end


function [P,A] = ellipse_geometry(a,b)

kap = sqrt(1-(b./a).^2);

E = NaN(1,length(a));

for ii = 1 : length(a)

    if isnan(kap(ii))

        continue

    end

[~,E(ii)] = elliptic12(pi/2,kap(ii),1e-16);

end

P = 4.*a.*E;

A = pi.*a.*b;



end