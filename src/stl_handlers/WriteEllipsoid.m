
function WriteEllipsoid(fileout,sobj)

fid = fopen(fileout,'w');

fprintf(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f',sobj.ellipsoid.a,sobj.ellipsoid.b,sobj.ellipsoid.c,...
                                                 sobj.ellipsoid.phi_p,sobj.ellipsoid.theta_p,sobj.ellipsoid.psi_p,...
                                                 sobj.ellipsoid.projection.xy.ra,sobj.ellipsoid.projection.xy.rb,...
                                                 sobj.ellipsoid.projection.xy.Ellip_ang,sobj.ellipsoid.projection.xz.ra,...
                                                 sobj.ellipsoid.projection.xz.rb,sobj.ellipsoid.projection.xz.Ellip_ang,...
                                                 sobj.particle.projection.area.xy,sobj.particle.projection.area.xz);



fclose(fid);

end