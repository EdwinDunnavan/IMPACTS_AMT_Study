
function writeparticle_init(fileout,sobj)

N = length(sobj.ellipsoid.a);

%nccreate(fileout,'N','Datatype','single');
nccreate(fileout,'particle_number','Dimensions',{'partNum',N},'Datatype','int32');

nccreate(fileout,'a','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'b','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'c','Dimensions',{'partNum',N},'Datatype','single');

%% ORIG
%nccreate(fileout,'particle_vertices','Dimensions',{'partNum',N,'points',size(sobj.particle.vertices,2),'dim',3},'Datatype','double');
%nccreate(fileout,'particle_connectivity','Dimensions',{'partNum',N,'connectivity',size(sobj.particle.connectivity,2),'dim',3},'Datatype','int32')

nccreate(fileout,'aspect_ratio','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'max_dim','Dimensions',{'partNum',N},'Datatype','single');

%% Write ellipsoid 3D properties

ncwrite(fileout,'particle_number',sobj.index)
ncwrite(fileout,'a',sobj.ellipsoid.a)
ncwrite(fileout,'b',sobj.ellipsoid.b);
ncwrite(fileout,'c',sobj.ellipsoid.c);

%% Write particle projection properties

%% ORIG
%ncwrite(fileout,'particle_vertices',sobj.particle.vertices)
%ncwrite(fileout,'particle_connectivity',sobj.particle.connectivity)

ncwrite(fileout,'aspect_ratio',sobj.particle.aspect_ratio)
ncwrite(fileout,'max_dim',sobj.particle.max_dim)



end















