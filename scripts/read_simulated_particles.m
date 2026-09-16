
% read_simulated_particles.m

% Reads in Aaron Bansemer's 2DS SODA2 simulation particles

paths = init_project();

fdir = paths.data;

fnameH = '2DS_H-projectionsGamma.pbp.nc';
fnameV = '2DS_V-projectionsGamma.pbp.nc';

fdirH = fullfile(fdir,'SODA2',fnameH);
fdirV = fullfile(fdir,'SODA2',fnameV);

imageH = ncread(fdirH,'image');
imageV = ncread(fdirV,'image');

xpartH = ncread(fdirH,'xpos');
ypartH = ncread(fdirH,'ypos');

xpartV = ncread(fdirV,'xpos');
ypartV = ncread(fdirV,'ypos');

startH =  ncread(fdirH,'starty');
stopH =  ncread(fdirH,'stopy');

startV =  ncread(fdirV,'starty');
stopV =  ncread(fdirV,'stopy');

allinH = ncread(fdirH,'allin');
allinV = ncread(fdirV,'allin');

numparts = 15;

xposH = zeros(1,numparts);
yposH = zeros(1,numparts);
widthH = zeros(1,numparts);
lengthH = zeros(1,numparts);
ellipAngH = zeros(1,numparts);

xposV = zeros(1,numparts);
yposV = zeros(1,numparts);
widthV = zeros(1,numparts);
lengthV = zeros(1,numparts);
ellipAngV = zeros(1,numparts);

%% Plot each particle
for ii = 1 : numparts

    buffpartH = imageH(:,startH(ii):stopH(ii));
    buffpartV = imageV(:,startV(ii):stopV(ii));

    cH = char('1'-buffpartH); 
    cV = char('1'-buffpartV);

    [LH,WH,angH,xH,yH] = CGAL_EllipseSize_UIOPS(cH);
    [LV,WV,angV,xV,yV] = CGAL_EllipseSize_UIOPS(cV);

    if ii ==1

        begxH = 0;

    else

        begxH = stopH(ii-1);

    end


    if ii ==1

        begxV = 0;

    else

        begxV = stopV(ii-1);

    end


    xposH(ii) = startH(ii)+xH;
    yposH(ii) = yH;
    widthH(ii) = WH;
    lengthH(ii) = LH;
    ellipAngH(ii) = angH;

    xposV(ii) = startV(ii)+xV;
    yposV(ii) = yV;
    widthV(ii) = WV;
    lengthV(ii) = LV;
    ellipAngV(ii) = angV;

end


figure;
ax1 = subplot(2,1,1);
imH_fig = imagesc(imageH(:,startH(1):stopH(numparts))); colormap(flipud(gray));
ax1.set('ydir','reverse');
axis equal;
hold(ax1,'on')
for ii = 1 : numparts
    ellipse_xy = ellipse3D(lengthH(ii)/2,widthH(ii)/2,xposH(ii),yposH(ii),0,50,0,0,ellipAngH(ii) ,0,'r',ax1); % Vertical (x-y plane); array perpendicular to aircraft direction

    line(ellipse_xy(1,:),ellipse_xy(2,:),'color','r');

end

ax2 = subplot(2,1,2);
hold(ax2,'on')
imV_fig = imagesc(imageV(:,startV(1):stopV(numparts))); colormap(flipud(gray));
ax2.set('ydir','reverse');
axis equal;
hold on;
for ii = 1 : numparts
    ellipse_xy = ellipse3D(lengthV(ii)/2,widthV(ii)/2,xposV(ii),yposV(ii),0,50,0,0,ellipAngV(ii) ,0,'r',ax2); % Vertical (x-y plane); array perpendicular to aircraft direction

    line(ellipse_xy(1,:),ellipse_xy(2,:),'color','r');

end
