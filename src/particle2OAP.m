
function sobj = particle2OAP(sobj,varargin)

%% Set up pixels
pix_size = 0.01;
scale_factor = 1;

if isempty(varargin)

    array_switch = 'full';

else

    array_switch = varargin{1};

end

%% Find max/min of projected ellipsoid for x-z and x-y planes

switch array_switch

    case 'full'

        xlim_xz = [-1 1];
        ylim_xz = [-1 1];

        xlim_xy = [-1 1];
        ylim_xy = [-1 1];

        xarray_xy = xlim_xy(1):pix_size:xlim_xy(end);
        yarray_xy = ylim_xy(1):pix_size:ylim_xy(end);

        xarray_xz = xlim_xz(1):pix_size:xlim_xz(end);
        yarray_xz = ylim_xz(1):pix_size:ylim_xz(end);

    case 'truncated'

        xlen_xy = sqrt(ra_xy.^2.*cosd(Ellip_ang_xy).^2+rb_xy.^2.*sind(Ellip_ang_xy).^2);
        ylen_xy = sqrt(rb_xy.^2.*cosd(Ellip_ang_xy).^2+ra_xy.^2.*sind(Ellip_ang_xy).^2);

        xlen_xz = sqrt(ra_xz.^2.*cosd(Ellip_ang_xz).^2+rb_xz.^2.*sind(Ellip_ang_xz).^2);
        ylen_xz = sqrt(rb_xz.^2.*cosd(Ellip_ang_xz).^2+ra_xz.^2.*sind(Ellip_ang_xz).^2);

        xlim_xy = round([-xlen_xy xlen_xy],2);
        ylim_xy = round([-ylen_xy ylen_xy],2);

        xlim_xz = round([-xlen_xz xlen_xz],2);
        ylim_xz = round([-ylen_xz ylen_xz],2);


        xarray_xy = xlim_xy(1)-pix_size:pix_size:xlim_xy(end)+pix_size;
        yarray_xy = ylim_xy(1)-pix_size:pix_size:ylim_xy(end)+pix_size;

        xarray_xz = xlim_xz(1)-pix_size:pix_size:xlim_xz(end)+pix_size;
        yarray_xz = ylim_xz(1)-pix_size:pix_size:ylim_xz(end)+pix_size;


end

sobj.ellipsoid.projection.grid.xarray_xy = xarray_xy;
sobj.ellipsoid.projection.grid.yarray_xy = yarray_xy;

sobj.ellipsoid.projection.grid.xarray_xz = xarray_xz;
sobj.ellipsoid.projection.grid.yarray_xz = yarray_xz;

%% Come up with binary mask
 patch_xy = patch(sobj.particle.curr.XData,sobj.particle.curr.YData,'c','linestyle','none','FaceAlpha',1,'Visible','off');
 patch_xy.FaceVertexCData = ones(size(patch_xy.XData,2),1);
 Z = patch2binary(patch_xy,sobj.ellipsoid.projection.grid.xarray_xy,sobj.ellipsoid.projection.grid.yarray_xy);
Z(isnan(Z)) = 0;
sobj.particle.projection.area.xy = sum(Z(:)).*pix_size.^2;
sobj.particle.projection.grid.xy = ~logical(Z);
delete(patch_xy)

 patch_xz = patch(sobj.particle.curr.XData,sobj.particle.curr.ZData,'c','linestyle','none','FaceAlpha',1,'Visible','off');
 patch_xz.FaceVertexCData = ones(size(patch_xz.XData,2),1);
 Z = patch2binary(patch_xz,sobj.ellipsoid.projection.grid.xarray_xz,sobj.ellipsoid.projection.grid.yarray_xz);
Z(isnan(Z)) = 0;

%% Find area
sobj.particle.projection.area.xz = sum(Z(:)).*pix_size.^2;
sobj.particle.projection.grid.xz = ~logical(Z);
delete(patch_xz)

end