
tic;
%Plot the original STL mesh:
figure


fname= 'C:\\Users\\edwin.dunnavan\\Documents\\IMPACTS\\Simulations\\SHPSG\\Simulation4\\particle_7.stl';

[stlcoords] = READ_stl(fname);
xco = squeeze( stlcoords(:,1,:) )';
yco = squeeze( stlcoords(:,2,:) )';
zco = squeeze( stlcoords(:,3,:) )';
[hpat] = patch(xco,yco,zco,'b');
axis equal

xgrid = -1:0.01:1;
ygrid = xgrid;
zgrid = ygrid;

%Voxelise the STL:
[OUTPUTgrid] = VOXELISE(xgrid,ygrid,zgrid,fname,'x');

GRID_xy = squeeze(sum(OUTPUTgrid,3));

GRID_xy(GRID_xy>0) = 1;

GRID_xy = ~GRID_xy;

GRID_xz = squeeze(sum(OUTPUTgrid,2));

GRID_xz(GRID_xz>0) = 1;

GRID_xz = ~GRID_xz;

GRID_yz = squeeze(sum(OUTPUTgrid,1));

GRID_yz(GRID_yz>0) = 1;

GRID_yz = ~GRID_yz;

GRID_xy = GRID_xy';
GRID_xz = GRID_xz';
GRID_yz = GRID_yz';


%Show the voxelised result:
figure;
subplot(1,3,1);
%imagesc(squeeze(sum(OUTPUTgrid,1)));
pcolor(ygrid,zgrid,double(GRID_yz));

%colormap(gray(256));
xlabel('Y-direction');
ylabel('Z-direction');
axis equal tight

subplot(1,3,2);
%imagesc(squeeze(sum(OUTPUTgrid,2)));
pcolor(xgrid,zgrid,double(GRID_xz))
%colormap(gray(256));
xlabel('X-direction');
ylabel('Z-direction');
axis equal tight

subplot(1,3,3);
pcolor(xgrid,ygrid,double(GRID_xy))
%imagesc(squeeze(sum(OUTPUTgrid,3)));
%colormap(gray(256));
xlabel('X-direction');
ylabel('Y-direction');
axis equal tight

toc;
