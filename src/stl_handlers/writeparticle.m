
function writeparticle(fileout,sobj,varargin)

save_images = false;
save_meshes = false;

for ff = 1 : length(varargin)

    if strcmp(varargin{ff},'save_images')

        save_images = varargin{ff+1};

    end


    if strcmp(varargin{ff},'save_mesh')

        save_meshes = varargin{ff+1};

    end

end

N = length(sobj.ellipsoid.a);

%nccreate(fileout,'N','Datatype','single');
nccreate(fileout,'phimean','Datatype','single');
nccreate(fileout,'thetamean','Datatype','single');
nccreate(fileout,'kappa','Datatype','single');
nccreate(fileout,'psimean','Datatype','single');
nccreate(fileout,'varpsi','Datatype','single');

nccreate(fileout,'index','Dimensions',{'partNum',N},'Datatype','int32');

nccreate(fileout,'particle_number','Dimensions',{'partNum',N},'Datatype','int32');
nccreate(fileout,'a','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'b','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'c','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'phi','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'theta','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'psi','Dimensions',{'partNum',N},'Datatype','single');

nccreate(fileout,'ra_xy','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'rb_xy','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'EllipAng_xy','Dimensions',{'partNum',N},'Datatype','single');

nccreate(fileout,'ra_xz','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'rb_xz','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'EllipAng_xz','Dimensions',{'partNum',N},'Datatype','single');

if save_meshes
nccreate(fileout,'particle_vertices','Dimensions',{'partNum',N,'points',size(sobj.particle.vertices,2),'dim',3},'Datatype','double');
nccreate(fileout,'particle_connectivity','Dimensions',{'partNum',N,'connectivity',size(sobj.particle.connectivity,2),'dim',3},'Datatype','int32')
end

nccreate(fileout,'max_dim','Dimensions',{'partNum',N},'Datatype','single');

nccreate(fileout,'particle_area_xy','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'particle_area_xz','Dimensions',{'partNum',N},'Datatype','single');

nccreate(fileout,'particle_perimeter_xy','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'particle_perimeter_xz','Dimensions',{'partNum',N},'Datatype','single');

nccreate(fileout,'Dmax_xy_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'xcirc_xy_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'ycirc_xy_cgal','Dimensions',{'partNum',N},'Datatype','single');

nccreate(fileout,'ra_xy_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'rb_xy_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'EllipAng_xy_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'xpos_xy_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'ypos_xy_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'habit_xy','Dimensions',{'partNum',N},'Datatype','int32');

nccreate(fileout,'Dmax_xz_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'xcirc_xz_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'ycirc_xz_cgal','Dimensions',{'partNum',N},'Datatype','single');

nccreate(fileout,'ra_xz_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'rb_xz_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'EllipAng_xz_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'xpos_xz_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'ypos_xz_cgal','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'habit_xz','Dimensions',{'partNum',N},'Datatype','int32');

nccreate(fileout,'moments','Dimensions',{'dim10',10,'partNum',N},'Datatype','single');
nccreate(fileout,'surface_area','Dimensions',{'partNum',N},'Datatype','single');

if save_images
nccreate(fileout,'image_xy','Dimensions',{'partNum',N,'x_xy',size(sobj.particle.projection.grid.xy,2),'y_xy',size(sobj.particle.projection.grid.xy,3)},'Datatype','int8')
nccreate(fileout,'image_xz','Dimensions',{'partNum',N,'x_xz',size(sobj.particle.projection.grid.xz,2),'y_xz',size(sobj.particle.projection.grid.xz,3)},'Datatype','int8')

end

nccreate(fileout,'grid_bound','Dimensions',{'partNum',N},'Datatype','single');

%% Write ellipsoid 3D properties
ncwriteatt(fileout,'/','folder',sobj.folder)
ncwriteatt(fileout,'/','test_folder',sobj.test_folder)

ncwrite(fileout,'phimean',sobj.phimean)
ncwrite(fileout,'thetamean',sobj.thetamean)
ncwrite(fileout,'kappa',sobj.kappa)
ncwrite(fileout,'psimean',sobj.psimean)
ncwrite(fileout,'varpsi',sobj.varpsi)

ncwrite(fileout,'index',sobj.index)

ncwrite(fileout,'particle_number',sobj.particle_number)
ncwrite(fileout,'a',sobj.ellipsoid.a)
ncwrite(fileout,'b',sobj.ellipsoid.b);
ncwrite(fileout,'c',sobj.ellipsoid.c);
ncwrite(fileout,'phi',sobj.ellipsoid.phi)
ncwrite(fileout,'theta',sobj.ellipsoid.theta)
ncwrite(fileout,'psi',sobj.ellipsoid.psi)

%% Write ellipsoid projection properties


ncwrite(fileout,'ra_xy',sobj.ellipsoid.projection.xy.ra)
ncwrite(fileout,'rb_xy',sobj.ellipsoid.projection.xy.rb)
ncwrite(fileout,'EllipAng_xy',sobj.ellipsoid.projection.xy.Ellip_ang)

ncwrite(fileout,'ra_xz',sobj.ellipsoid.projection.xz.ra)
ncwrite(fileout,'rb_xz',sobj.ellipsoid.projection.xz.rb)
ncwrite(fileout,'EllipAng_xz',sobj.ellipsoid.projection.xz.Ellip_ang)

%% Write particle projection properties
if save_meshes
ncwrite(fileout,'particle_vertices',sobj.particle.vertices)
ncwrite(fileout,'particle_connectivity',sobj.particle.connectivity)
end

ncwrite(fileout,'max_dim',sobj.particle.max_dim)

ncwrite(fileout,'particle_area_xy',sobj.particle.projection.area.xy)
ncwrite(fileout,'particle_area_xz',sobj.particle.projection.area.xz)

ncwrite(fileout,'particle_perimeter_xy',sobj.particle.projection.perimeter.xy)
ncwrite(fileout,'particle_perimeter_xz',sobj.particle.projection.perimeter.xz)

ncwrite(fileout,'Dmax_xy_cgal',sobj.particle.projection.xy.Dmax)
ncwrite(fileout,'xcirc_xy_cgal',sobj.particle.projection.xy.xpos_circ)
ncwrite(fileout,'ycirc_xy_cgal',sobj.particle.projection.xy.ypos_circ)

ncwrite(fileout,'ra_xy_cgal',sobj.particle.projection.xy.ra)
ncwrite(fileout,'rb_xy_cgal',sobj.particle.projection.xy.rb)
ncwrite(fileout,'EllipAng_xy_cgal',sobj.particle.projection.xy.Ellip_ang)
ncwrite(fileout,'xpos_xy_cgal',sobj.particle.projection.xy.xpos)
ncwrite(fileout,'ypos_xy_cgal',sobj.particle.projection.xy.ypos)
ncwrite(fileout,'habit_xy',sobj.particle.projection.xy.habit)

ncwrite(fileout,'Dmax_xz_cgal',sobj.particle.projection.xz.Dmax)
ncwrite(fileout,'xcirc_xz_cgal',sobj.particle.projection.xz.xpos_circ)
ncwrite(fileout,'ycirc_xz_cgal',sobj.particle.projection.xz.ypos_circ)

ncwrite(fileout,'ra_xz_cgal',sobj.particle.projection.xz.ra)
ncwrite(fileout,'rb_xz_cgal',sobj.particle.projection.xz.rb)
ncwrite(fileout,'EllipAng_xz_cgal',sobj.particle.projection.xz.Ellip_ang)
ncwrite(fileout,'xpos_xz_cgal',sobj.particle.projection.xz.xpos)
ncwrite(fileout,'ypos_xz_cgal',sobj.particle.projection.xz.ypos)
ncwrite(fileout,'habit_xz',sobj.particle.projection.xz.habit)

ncwrite(fileout,'moments',sobj.particle.moments)
ncwrite(fileout,'surface_area',sobj.particle.area)

%% Write OAP logical arrays
if save_images
ncwrite(fileout,'image_xy',int8(sobj.particle.projection.grid.xy))
ncwrite(fileout,'image_xz',int8(sobj.particle.projection.grid.xz))
end

ncwrite(fileout,'grid_bound',sobj.grid_bound);

end