

function sobj = particle2probe(sobj,pix_size,calculate_ellipses,do_fill_holes)

if nargin < 3 

    calculate_ellipses = true;

end

% Default to true for backward compatibility with old scripts
if nargin < 4
    do_fill_holes = true;
end

%% Dynamically size grid to fit the scaled particle
%max_radius = sobj.particle.max_dim / 2.0;
%buffer_factor = 1.20; % 20% extra padding to prevent edge-clipping in CGAL
%bound = ceil((max_radius * buffer_factor) / pix_size) * pix_size;
%bound = max(0.5, bound); % Safety floor (at least 0.5 mm radius / 1 mm box)

%% Dynamically size grid to fit the actual 3D rotated & scaled mesh points
max_coord = max(abs(sobj.particle.TR.Points(:)));
if max_coord == 0, max_coord = 0.5; end

buffer_factor = 1.20; % 20% margin around furthest vertex
bound = ceil((max_coord * buffer_factor) / pix_size) * pix_size;
bound = max(0.5, bound);

% max_coord = max(abs(sobj.particle.TR.Points(:)));
% buffer_width = 0.5;
% bound = ceil((max_coord + buffer_width) / pix_size) * pix_size;
% bound = max(1.0, bound); % Fallback to ensure minimum 1mm radius

sobj.grid_bound = bound; % Save this for the plotter

gridX = -bound:pix_size:bound;
gridY = -bound:pix_size:bound;
gridZ = -bound:pix_size:bound;

%% Set up grid
% gridX = -1:pix_size:1;
% gridY = -1:pix_size:1;
% gridZ = -1:pix_size:1;

%% Get STL points
tri = sobj.particle.TR.ConnectivityList;

%% GET X,Y,Z DATA for stl particle
Xt = sobj.particle.TR.Points(:,1);
Yt = sobj.particle.TR.Points(:,2);
Zt = sobj.particle.TR.Points(:,3);

xco = Xt(tri)';
yco = Yt(tri)';
zco = Zt(tri)';

OUTPUTgrid = VOXELISE(gridX,gridY,gridZ,xco,yco,zco);

GRID_xy = squeeze(sum(OUTPUTgrid,3));
GRID_xy(GRID_xy>0) = 1;

if do_fill_holes
GRID_xy = imclose(GRID_xy, strel('disk', 2));
GRID_xy = imfill(GRID_xy,4,'holes');
end

sobj.particle.projection.area.xy = sum(GRID_xy(:)).*pix_size.^2;
sobj.particle.projection.perimeter.xy = sum(bwperim(GRID_xy,4),'all').*pix_size;

GRID_xy = ~GRID_xy;

GRID_xz = squeeze(sum(OUTPUTgrid,2));

GRID_xz(GRID_xz>0) = 1;

if do_fill_holes
GRID_xz = imclose(GRID_xz, strel('disk', 2));
GRID_xz = imfill(GRID_xz,4,'holes');
end

sobj.particle.projection.area.xz = sum(GRID_xz(:)).*pix_size.^2;
sobj.particle.projection.perimeter.xz = sum(bwperim(GRID_xz,4),'all').*pix_size;

GRID_xz = ~GRID_xz;

sobj.particle.projection.grid.xy = GRID_xy';
sobj.particle.projection.grid.xz = GRID_xz';


%% CGAL routines
if calculate_ellipses
%% XZ plane
 tempreturn = CGAL_minR(char('1'-~sobj.particle.projection.grid.xz'), 1.);
 minR_xz = tempreturn(1); % diameter of minimum enclosing circle
 ctx_xz = tempreturn(2); % position
 cty_xz = tempreturn(3);

% Fit ellipses using CGAL library
[EllipseL_xz, EllipseW_xz, EllipseAngle_xz,Ellipse_ypos_xz, Ellipse_xpos_xz] = CGAL_EllipseSize_UIOPS(char('1'-~sobj.particle.projection.grid.xz'));

if EllipseAngle_xz >=0

    EllipseAngle_xz = pi./2-EllipseAngle_xz;

elseif EllipseAngle_xz<0

    EllipseAngle_xz = -(pi./2-abs(EllipseAngle_xz));

end

 tempreturn = CGAL_minR(char('1'-~sobj.particle.projection.grid.xy'), 1.);
 minR_xy = tempreturn(1); % diameter of minimum enclosing circle
 ctx_xy = tempreturn(2); % position
 cty_xy = tempreturn(3);

[EllipseL_xy, EllipseW_xy, EllipseAngle_xy,Ellipse_ypos_xy, Ellipse_xpos_xy] = CGAL_EllipseSize_UIOPS(char('1'-~sobj.particle.projection.grid.xy'));

if EllipseAngle_xy >=0

    EllipseAngle_xy = pi./2-EllipseAngle_xy;

elseif EllipseAngle_xy<0

    EllipseAngle_xy = -(pi./2-abs(EllipseAngle_xy));

end

%% Use Schima et al (2024) habit identification algorithm?

sobj.particle.projection.xy.habit = holroyd_schima_sim(char('1'-~sobj.particle.projection.grid.xy'),pix_size);
sobj.particle.projection.xz.habit = holroyd_schima_sim(char('1'-~sobj.particle.projection.grid.xz'),pix_size);

sobj.particle.projection.xy.Dmax = minR_xy.*pix_size;
sobj.particle.projection.xy.xpos_circ = (ctx_xy - 1).*pix_size - bound;
sobj.particle.projection.xy.ypos_circ = (cty_xy - 1).*pix_size - bound;

%sobj.particle.projection.xy.xpos_circ = ctx_xy.*pix_size;
%sobj.particle.projection.xy.ypos_circ = cty_xy.*pix_size;

sobj.particle.projection.xy.ra = 0.5.*EllipseL_xy.*pix_size;
sobj.particle.projection.xy.rb = 0.5.*EllipseW_xy.*pix_size;
sobj.particle.projection.xy.Ellip_ang = rad2deg(EllipseAngle_xy);
sobj.particle.projection.xy.xpos = (Ellipse_xpos_xy - 1).*pix_size - bound;
sobj.particle.projection.xy.ypos = (Ellipse_ypos_xy - 1).*pix_size - bound;

%sobj.particle.projection.xy.xpos = (Ellipse_xpos_xy).*pix_size - bound;
%sobj.particle.projection.xy.ypos = (Ellipse_ypos_xy).*pix_size - bound;

%ORIG
%sobj.particle.projection.xy.xpos = (Ellipse_xpos_xy).*pix_size-1;
%sobj.particle.projection.xy.ypos = (Ellipse_ypos_xy).*pix_size-1;

sobj.particle.projection.xz.Dmax = minR_xz.*pix_size;
sobj.particle.projection.xz.xpos_circ = (ctx_xz - 1).*pix_size - bound;
sobj.particle.projection.xz.ypos_circ = (cty_xz - 1).*pix_size - bound;

%sobj.particle.projection.xz.xpos_circ = ctx_xz.*pix_size;
%sobj.particle.projection.xz.ypos_circ = cty_xz.*pix_size;

sobj.particle.projection.xz.ra = 0.5.*EllipseL_xz.*pix_size;
sobj.particle.projection.xz.rb = 0.5.*EllipseW_xz.*pix_size;
sobj.particle.projection.xz.Ellip_ang = rad2deg(EllipseAngle_xz);

sobj.particle.projection.xz.xpos = (Ellipse_xpos_xz - 1).*pix_size - bound;
sobj.particle.projection.xz.ypos = (Ellipse_ypos_xz - 1).*pix_size - bound;

%sobj.particle.projection.xz.xpos = (Ellipse_xpos_xz).*pix_size - bound;
%sobj.particle.projection.xz.ypos = (Ellipse_ypos_xz).*pix_size - bound;

%sobj.particle.projection.xz.xpos = (Ellipse_xpos_xz).*pix_size-1;
%sobj.particle.projection.xz.ypos = (Ellipse_ypos_xz).*pix_size-1;

end


end
