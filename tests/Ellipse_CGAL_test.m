% Ellipse_CGAL_test.m

%clear all

function [L,W,Ang,xct,yct,mask_new] = Ellipse_CGAL_test(major_start,minor_start,ang_start,x0,y0)

%buf = 50;

m = 1700;
n = 128;

%m = major_start+buf;
%n = major_start+buf;

[Xt,Yt] = meshgrid(1:m,1:n);

%major_start = 120.0;
%minor_start = 30.0;

ra = major_start./2;
rb = minor_start./2;
%ang_start = -30;
%x0 = 50.0;
%y0 = 50.0;

ang_start = -ang_start;

a = ra.^2.*sind(ang_start).^2 + rb.^2.*cosd(ang_start).^2;
b = 2.*(ra.^2 - rb.^2).*sind(ang_start).*cosd(ang_start);
c = ra.^2.*cosd(ang_start).^2 + rb.^2 .* sind(ang_start).^2;
d = -2.*a.*x0 - b.*y0;
f = -b.*x0 - 2.*c.*y0;
g = a.*x0.^2+b.*x0.*y0+c.*y0.^2 - ra.^2 .* rb.^2;


major=2.*sqrt((2.*(a.*(f./2).^2+c.*(d./2).^2+g.*(b./2).^2-b.*d.*f./4-a.*c.*g))./(((b./2).^2-a.*c).*(sqrt((a-c).^2+(b).^2)-(a+c))));
minor=2.*sqrt((2.*(a.*(f./2).^2+c.*(d./2).^2+g.*(b./2).^2-b.*d.*f./4-a.*c.*g))./(((b./2).^2-a.*c).*(-sqrt((a-c).^2+(b).^2)-(a+c))));
    

xc = (2.*c.*d-b.*f)./(b.^2-4.*a.*c);
yc = (2.*a.*f-b.*d)./(b.^2-4.*a.*c);


% OLD C++ version
%     if (0==b && a<c)
%         ang=0; 
%     elseif ((0==b && a>c))
%         ang=pi/2;
%     elseif (0 ~= b && a<c)
%         ang=(atan(b/(a-c)))/2;
%     elseif (0 ~= b && a>c)
%         ang=(atan(b/(a-c)))/2+pi/2;
%     else
%         ang=0;
% 
%     end
%     
%     if (ang > 3.1415926/2)
%         ang = ang - 3.141592653;
%     end
%     
%     if (ang < -3.1415926/2)
%         ang = ang + 3.141592653;
%     end

% NEW version
    if (0==b && a<c)
        ang=0; 
    elseif ((0==b && a>c))
        ang=pi/2;
    elseif (0 ~= b && a<c)
        ang=(atan(b/(a-c)))/2;
        %ang=(atan(b./(c-a-sqrt((a-c).^2+b.^2))));
    elseif (0 ~= b && a>c)
        ang=(atan(b/(a-c)))/2+pi/2;
        %ang=(atan(b./(c-a-sqrt((a-c).^2+b.^2))))+pi/2;
    elseif (a==c && b<0)
        ang = pi./4;

    elseif (a==c && b>0)
        ang = -pi./4;
    else
        ang=0;

    end
    
    if (ang > pi/2)
        ang = ang - pi;
    end
    
    if (ang < -pi/2)
        ang = ang + pi;
    end


    ang = rad2deg(ang);

    fprintf('major = %f\n',major)
    fprintf('minor = %f\n',minor)
    fprintf('aspect ratio = %f\n',minor./major)
    fprintf('ellipse angle = %f\n',ang)
    fprintf('x center = %f\n',xc)
    fprintf('y center = %f\n',yc)

    hfig = figure('units','normalized','position',[0.1656 0.6361 0.7260 0.1296]);
    %set(hfig,'color','w')
    fimplicit(@(x,y) a.*(x).^2 + c.*(y).^2 + b.*(x).*(y)+d.*(x)+f.*(y)+g,[1 m 1 n],'linewidth',5)
    %hold on;
    %scatter(xc,yc,'o','filled')
    hold on;
    [xt,yt] =plot_ellipse(gca,major./2,minor./2,xc,yc,ang,'k');

    %ellipse(major./2,minor./2,deg2rad(ang),xc,yc,'r',50)
    axis equal
    %axis off

    xlim([0 m]);
    ylim([0 n])


    mask = a.*(Xt).^2 + c.*(Yt).^2 + b.*(Xt).*(Yt)+d.*(Xt)+f.*(Yt)+g<=1;

    %mask = mask;

    [sa,sb] = size(mask);

    for ii = 1 : sa
        for jj = 1 :sb
            mask_new(ii,jj) = num2str(~mask(ii,jj));
        end
    end

    tic
    [L, W, Ang, xct, yct]       = CGAL_EllipseSize_UIOPS(mask_new');
    toc

    Ang = -rad2deg(Ang);

    ellipse(L./2,W./2,-deg2rad(Ang),x0,y0,'g',50)

    fprintf('L = %f\n',L)
    fprintf('W = %f\n',W)
    fprintf('CGAL aspect ratio = %f\n',W./L)
    fprintf('CGAL angle = %f\n',-Ang)
    fprintf('CGAL xc = %f\n',xct)
    fprintf('CGAL yc = %f\n',yct)
    %fprintf('CGAL a = %f\n',ac)
    %fprintf('CGAL c = %f\n',cc)
    %fprintf('CGAL b = %f\n',bc)
    %fprintf('CGAL d = %f\n',dc)
    %fprintf('CGAL f = %f\n',fc)
    %fprintf('CGAL g = %f\n',gc)

    tightfig(hfig);

end


function [L, W, Ang, xct, yct,ac,cc,bc,dc,fc,gc] = call_EllipseCGAL(mask_new)

 [L, W, Ang, xct, yct,ac,cc,bc,dc,fc,gc]       = CGAL_EllipseSize_new(mask_new);


end


function [x,y] =plot_ellipse(ax,a,b,cx,cy,angle,color)


r = linspace(0,360,50);

p = [(a.*cosd(r))' (b.*sind(r))'];

alpha = [cosd(angle) -sind(angle); sind(angle) cosd(angle)]';

p1 = p*alpha;

x = cx+p1(:,1);
y = cy+p1(:,2);


patch(ax,x,y,color,'EdgeColor','None','FaceAlpha',1.0);


end




function h=ellipse(ra,rb,ang,x0,y0,C,Nb)
% Ellipse adds ellipses to the current plot
%
% ELLIPSE(ra,rb,ang,x0,y0) adds an ellipse with semimajor axis of ra,
% a semiminor axis of radius rb, and an orientation of the semimajor
% axis with an angle of ang (in radians) rotated counter-clockwise 
% from the x-axis.  The ellipse is centered at the point x0,y0.
%
% The length of ra, rb, and ang should be the same. 
% If ra is a vector of length L and x0,y0 scalars, L ellipses
% are added at point x0,y0.
% If ra is a scalar and x0,y0 vectors of length M, M ellipse are with the same 
% radii are added at the points x0,y0.
% If ra, x0, y0 are vectors of the same length L=M, M ellipses are added.
% If ra is a vector of length L and x0, y0 are  vectors of length
% M~=L, L*M ellipses are added, at each point x0,y0, L ellipses of radius ra.
%
% ELLIPSE(ra,rb,ang,x0,y0,C)
% adds ellipses of color C. C may be a string ('r','b',...) or the RGB value. 
% If no color is specified, it makes automatic use of the colors specified by 
% the axes ColorOrder property. For several ellipses C may be a vector.
%
% ELLIPSE(ra,rb,ang,x0,y0,C,Nb), Nb specifies the number of points
% used to draw the ellipse. The default value is 300. Nb may be specified
% for each ellipse individually, in which case it should be the same
% length as ra, rb, etc.
%
% h=ELLIPSE(...) returns the handles to the ellipses.
%
% usage exmple: the following produces a red ellipse centered at 1,1
% and tipped down at a 45 deg axis from the x axis
% ellipse(1,2,pi/4,1,1,'r')
%
% note that if ra=rb, ELLIPSE plots a circle
%
% written by D.G. Long, Brigham Young University, based on the
% CIRCLES.m original written by Peter Blattner, Institute of 
% Microtechnology, University of Neuchatel, Switzerland, blattner@imt.unine.ch
% Check the number of input arguments 
if nargin<1
  ra=[];
end
if nargin<2
  rb=[];
end
if nargin<3
  ang=[];
end
if nargin<5
  x0=[];
  y0=[];
end
 
if nargin<6
  C=[];
end
if nargin<7
  Nb=[];
end
% set up the default values
if isempty(ra),ra=1;end
if isempty(rb),rb=1;end
if isempty(ang),ang=0;end
if isempty(x0),x0=0;end
if isempty(y0),y0=0;end
if isempty(Nb),Nb=300;end
if isempty(C),C=get(gca,'colororder');end
% work on the variable sizes
x0=x0(:);
y0=y0(:);
ra=ra(:);
rb=rb(:);
ang=ang(:);
Nb=Nb(:);
if isstr(C),C=C(:);end
if length(ra)~=length(rb)
  error('length(ra)~=length(rb)');
end
if length(x0)~=length(y0)
  error('length(x0)~=length(y0)');
end
% how many inscribed elllipses are plotted
if length(ra)~=length(x0)
  maxk=length(ra)*length(x0);
else
  maxk=length(ra);
end
% drawing loop
for k=1:maxk
  
  if length(x0)==1
    xpos=x0;
    ypos=y0;
    radm=ra(k);
    radn=rb(k);
    if length(ang)==1
      an=ang;
    else
      an=ang(k);
    end
  elseif length(ra)==1
    xpos=x0(k);
    ypos=y0(k);
    radm=ra;
    radn=rb;
    an=ang;
  elseif length(x0)==length(ra)
    xpos=x0(k);
    ypos=y0(k);
    radm=ra(k);
    radn=rb(k);
    an=ang(k);
  else
    rada=ra(fix((k-1)/size(x0,1))+1);
    radb=rb(fix((k-1)/size(x0,1))+1);
    an=ang(fix((k-1)/size(x0,1))+1);
    xpos=x0(rem(k-1,size(x0,1))+1);
    ypos=y0(rem(k-1,size(y0,1))+1);
  end
  % draw ellipse
  
  co=cos(an);
  si=sin(an);
  the=linspace(0,2*pi,Nb(rem(k-1,size(Nb,1))+1,:)+1);
  %  x=radm*cos(the)*co-si*radn*sin(the)+xpos;
  %  y=radm*cos(the)*si+co*radn*sin(the)+ypos;
  p=line(radm*cos(the)*co-si*radn*sin(the)+xpos,radm*cos(the)*si+co*radn*sin(the)+ypos);
  set(p,'color',C(rem(k-1,size(C,1))+1,:));
  
  % output handles to each ellipse if output variable specified
  
  if nargout > 0
    h(k)=p;
  end
  
end

end
