function write_hexagon_params(fileout,max_dim,aspect_ratio,mu,Dm,Dlow,Dhigh)

N = length(max_dim);

Ei = ones(size(aspect_ratio));
Fi = ones(size(aspect_ratio));

Ei(aspect_ratio>1.) = 1./aspect_ratio(aspect_ratio>1.);
Fi(aspect_ratio<1.) = aspect_ratio(aspect_ratio<1.);

D2_8 = zeros(size(aspect_ratio));
D9_15 = zeros(size(aspect_ratio));

nccreate(fileout,'mu','Datatype','single')
nccreate(fileout,'Dm','Datatype','single')
nccreate(fileout,'Dlow','Datatype','single')
nccreate(fileout,'Dhigh','Datatype','single')

%nccreate(fileout,'N','Datatype','single');
nccreate(fileout,'particle_number','Dimensions',{'partNum',N},'Datatype','int32');

nccreate(fileout,'max_dim','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'Ei','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'Fi','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'D2_8','Dimensions',{'partNum',N},'Datatype','single');
nccreate(fileout,'D9_15','Dimensions',{'partNum',N},'Datatype','single');

%% Write gamma distribution properties
ncwrite(fileout,'mu',mu)
ncwrite(fileout,'Dm',Dm)
ncwrite(fileout,'Dlow',Dlow)
ncwrite(fileout,'Dhigh',Dhigh)

%% Write hexagon 3D properties

ncwrite(fileout,'particle_number',1:N)
ncwrite(fileout,'max_dim',max_dim)
ncwrite(fileout,'Ei',Ei)
ncwrite(fileout,'Fi',Fi)
ncwrite(fileout,'D2_8',D2_8)
ncwrite(fileout,'D9_15',D9_15)


end

