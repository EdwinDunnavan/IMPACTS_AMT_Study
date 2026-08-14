function Z = patch2binary(P,xgv,ygv)
% PATCH2BINARY  Convert patch data to binary data.
%   Z = patch2grid(P,xgv,ygv) converts the patch data from PATCH object (or
%   handle) P into gridded data Z. Each element in Z is calculated by
%   taking the Cdata of the patch which occupies the largest area on a
%   given grid point. xgv and ygv are grid vectors and the size of Z is
%   numel(ygv)-by-numel(xgv). Note that the grid point is rectangular in
%   shape and its dimensions are (xgv(2)-xgv(1))-by-(ygv(2)-ygv(1)).
% 
% 
%   Requires the functions POLY2CW and POLYBOOL from the Mapping Toolbox�.
% 
%   Copyright 2015 Ivan Kostylev
%   Version: 1.0
if numel(xgv)==1||numel(ygv)==1 %Error check
    error('The grid vectors xgv and ygv both need to have at least 2 elements.')
end
%Determine the type of patch data input
fvc.vertices = P.Vertices;
fvc.faces = P.Faces;

%Extract parameters
x0=xgv(1);
y0=ygv(1);
dX=xgv(2)-xgv(1);
dY=ygv(2)-ygv(1);
sizeX=numel(xgv);
sizeY=numel(ygv);
%Determine area contribution of each patch on each grid rectangle
M = patchareaongrid(fvc,x0,y0,dX,dY,sizeX,sizeY);
%Create 2D grid with C values
    Z = cellfun(@(x) MaxAreaCValue(x),M);
end
%-----------------------------------------------------------------
function M = patchareaongrid(fvc,x0,y0,dX,dY,sizeX,sizeY)
%Determine Input Type
if iscell(fvc)
    getxy = @(x,y) cell2xy(x,y) ; %Function to extract polygon vertices from cell array
    NoP = size(fvc{1},2); %Number of polygons
else %structure
    getxy = @(x,y) fv2xy(x,y); %Function to extract polygon vertices from structure
    NoP = size(fvc.faces,1); %Number of polygons
end
A2=dX*dY; %area of a single grid rectangle
M=cell(sizeY,sizeX); %preallocate
for p=1:NoP %Loop over all the polygons
    [x,y]=getxy(fvc,p); %extract x and y vectors
    %upper and lower bounds on affected grid points by patch
    jmin=floor((min(x)-x0)/dX)+1;
    jmax=floor((max(x)-x0)/dX)+1;
    kmin=floor((min(y)-y0)/dY)+1;
    kmax=floor((max(y)-y0)/dY)+1;
    for j=jmin:jmax %for all horizontal grid points
        if (j>=1&&j<=sizeX) %If within bounds of the sampling grid
            x2=([j j j+1 j+1 j]-1)*dX+x0;
            for k=kmin:kmax %for all vertical grid points
                if (k>=1&&k<=sizeY) %If within bounds of the sampling grid
                    y2=([k k+1 k+1 k k]-1)*dY+y0;
                    [xb, yb] = polybool('intersection', x, y, x2, y2); %#ok<PLBL> %Polygon defining the intersection between the grid point and the patch
                    A1=polyarea(xb, yb); %Area of the intersecting polygon
                    if A1~=0 %A1 returns 0 if xb,yb are empty so this value isn't recorded
                        M{k,j}=[M{k,j} [A1/A2;p]]; %A1/A2 was originally used
                    end
                end
            end
        end
    end
end
end
%-----------------------------------------------------------------
function [x,y]=fv2xy(fvc,p)
% Convert patch face and vertices to x and y polygonal region
xy=fvc.vertices(fvc.faces(p,:),:);
x=xy(:,1)';
y=xy(:,2)';
if ~ispolycw(x, y) %Make CW instead of CCW for polybool
    [x, y] = poly2cw(x, y);
end
end
%-----------------------------------------------------------------
function [x,y]=cell2xy(fvc,p)
% Split XY cell array to x and y variables
x=fvc{1}(:,p)';
y=fvc{2}(:,p)';
end
%-----------------------------------------------------------------
function y=MaxAreaCValue(x)
% Take the C value of the patch that occupies the most area on the grid
if ~isempty(x)&&sum(x(1,:))>=0.5 %unoccupied area should be less than 50% of total area
    x(:,isnan(x(1,:)))=[]; %Remove NaNs
    if ~isempty(x)
        y=1; %(1) ensures it takes only the 1st index if there are multiple with the same maximum value
    else
        y=NaN;
    end
else
    y=NaN;
end
end
