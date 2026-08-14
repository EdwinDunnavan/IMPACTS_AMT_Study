% EllipProj_fwd_sim_marg.m
% Description: Takes in 3D ellipsoid shape and orientation distribution
% parameters and spits out marginal distributions of 2D projected ellipse aspect
% ratios and angles for horizontal and vertical views

function [p_proj_horz, phi_proj_horz,p_proj_vert,phi_proj_vert]= EllipProj_fwd_sim_marg(N,xedge,ang_edges,pba,pcb,abatog,ap,bp,at,bt,as,bs)

%% OLD METHOD: 3D ellipsoid orientation distribution
% p_orient_phi = @(phi) (1./2).*(1./beta(ap./2,bp./2)).*abs(sin(phi)).^(ap-1).*abs(cos(phi)).^(bp-1);
% p_orient_psi = @(psi) (1./2).*(1./beta(as./2,bs./2)).*abs(sin(psi)).^(as-1).*abs(cos(psi)).^(bs-1);
% p_orient_theta = @(theta) (1./beta((at+1)./2,bt./2)).*abs(sin(theta)).^(at).*abs(cos(theta)).^(bt-1);

%% Points for 3D orientations to evaluate orientation distribution function (ODF)
% phibins = 0:5:360;
% thetabins = 0:5:180; 
% 
% phibins_rad = deg2rad(phibins);
% thetabins_rad = deg2rad(thetabins); 

%Note: Need to check if 

% p_phi = p_orient_phi(phibins_rad);
% p_psi = p_orient_psi(phibins_rad);
% p_theta = p_orient_theta(thetabins_rad);


%% Randomly sample orientation separate assuming mutual independence of phi, theta, and psi.
% phi_p = randdf([1 N],[p_phi;phibins_rad],'pdf');
% phi_p(phi_p<0) = 2*pi-phi_p(phi_p<0);
% phi_p(phi_p>2*pi) = phi_p(phi_p>2*pi)-2*pi;
% 
% psi_p = randdf([1 N],[p_psi;phibins_rad],'pdf');
% psi_p(psi_p<0) = 2*pi-psi_p(psi_p<0);
% psi_p(psi_p>2*pi) = psi_p(psi_p>2*pi)-2*pi;
% 
% theta_p = randdf([1 N],[p_theta;thetabins_rad],'pdf');
% theta_p(theta_p<0) = pi-theta_p(theta_p<0);
% theta_p(theta_p>pi) = theta_p(theta_p>pi)-pi;

%% Put in new method that samples the individual beta distributions and performs the trig transformation: u =sin^2(theta_p) 
% Note: Definitely a better approach. Much more accurate.

phi_p = [asin((betarnd(ap./2,bp./2,[1 round(N/4)]).^(0.5))) ...
        (pi-asin((betarnd(ap./2,bp./2,[1 round(N/4)]).^(0.5)))) ...
            (asin((betarnd(ap./2,bp./2,[1 round(N/4)]).^(0.5)))+pi) ...
  (2.*pi)-asin((betarnd(ap./2,bp./2,[1 round(N/4)]).^(0.5)))];

theta_p = [asin((betarnd((at+1)./2,bt./2,[1 round(N/2)])).^(0.5)) ...
              pi-asin((betarnd((at+1)./2,bt./2,[1 round(N/2)])).^(0.5))];
 
psi_p = [asin((betarnd(as./2,bs./2,[1 round(N/4)]).^(0.5))) ...
                      (pi-asin((betarnd(as./2,bs./2,[1 round(N/4)]).^(0.5)))) ...
                          (asin((betarnd(as./2,bs./2,[1 round(N/4)]).^(0.5)))+pi) ...
                (2.*pi)-asin((betarnd(as./2,bs./2,[1 round(N/4)]).^(0.5)))];


pbmin = pba./(1-pba);
pcmin = pba.*pcb./(1-pcb);
abamin = max(pbmin,pcmin);
abamax = 20;

a_ba = abatog.*abamax+(1-abatog).*abamin;
b_ba = ((1./pba)-1).*a_ba;
b_cb =((1./pcb)-1).*a_ba./pba;


%% NEW: Sample phiba and phicb which are independent beta distributions

phiba_samp1 = betarnd(a_ba,b_ba,[1 N]);
phica_samp1 = phiba_samp1.*betarnd(a_ba+b_ba,b_cb,[1 N]);

phiba_samp1(phiba_samp1<0.1) = 0.1;
phica_samp1(phica_samp1<0.1) = 0.1;

%% OLD METHOD: Get bivariate beta distribution for phiba and phica
%[nphi_biv,phib_bins,phic_bins] = nphi_biv_agg(a_ba,b_ba,b_cb);

%nphi_biv(isnan(nphi_biv)) = 0;

%nphi_biv(isinf(nphi_biv)) = 1000;

%phiba_samp1 = ones(1,N);
%phica_samp1 = phiba_samp1;

%% MC sampling
%for i = 1 : N
    

% [phiba_samp1(i),phica_samp1(i)] = pinky(phib_bins,phic_bins,nphi_biv');   



%end


%% Calculate ellipse projections

  [AR_masc_horz,Ellip_ang_horz]=ellipproj_new(phiba_samp1,phica_samp1,phi_p,theta_p,psi_p,pi./2,0); % Horizontal; array perpendicular to aircraft direction

  [AR_masc_vert,Ellip_ang_vert]=ellipproj_new(phiba_samp1,phica_samp1,phi_p,theta_p,psi_p,pi./2,pi./2); % Vertical; array perpendicular to aircraft direction


%% Estimate marginal 2D projected ellipse + orientation angle for assumed viewing angle phi_r and theta_r

p_proj_horz = histcounts(AR_masc_horz,xedge,'normalization','count')./N;
phi_proj_horz = histcounts(abs(Ellip_ang_horz),ang_edges,'normalization','count')./N;

p_proj_vert = histcounts(AR_masc_vert,xedge,'normalization','count')./N;
phi_proj_vert = histcounts(abs(Ellip_ang_vert),ang_edges,'normalization','count')./N;



end




function [ap,EllipAng]=ellipproj_new(phiba,phica,phi,theta,psi,phi_r,theta_r)

B11 = cos(psi).*cos(theta).*sin(phi-phi_r)+cos(phi-phi_r).*sin(psi);
B12 = sin(phi-phi_r).*sin(theta_r).*sin(psi)-cos(psi).*(cos(theta).*sin(theta_r).*cos(phi-phi_r)+sin(theta).*cos(theta_r));
B21 = cos(phi-phi_r).*cos(psi)-sin(phi-phi_r).*cos(theta).*sin(psi);
B22 = sin(theta_r).*(cos(phi-phi_r).*cos(theta).*sin(psi)+sin(phi-phi_r).*cos(psi))+cos(theta_r).*sin(theta).*sin(psi); 
B31 = sin(phi-phi_r) .*sin(theta);
B32 = cos(theta_r).*cos(theta)-cos(phi-phi_r).*sin(theta).*sin(theta_r);

tmp_c2 = (B11./phica).^2 + (B21./phiba).^2 + B31.^2;
tmp_c3 = (B12./phica).^2 + (B22./phiba).^2 + B32.^2;
tmp_c1 = 2.*(((B11.*B12)./(phica.^2))+((B21.*B22)./(phiba.^2))+B31.*B32);

ap = sqrt((tmp_c2+tmp_c3-sqrt(tmp_c1.^2+((tmp_c2-tmp_c3)).^2))./(tmp_c2+tmp_c3+sqrt(tmp_c1.^2+((tmp_c2-tmp_c3)).^2)));

thresh = 1e-8;

EllipAng = zeros(size(ap));

EllipAng(tmp_c2>tmp_c3) = 90;

ind = abs(tmp_c1)>thresh;

EllipAng(ind)= atand((tmp_c3(ind) - tmp_c2(ind) - sqrt(((tmp_c2(ind)-tmp_c3(ind)).^2)+tmp_c1(ind).^2))./tmp_c1(ind));

EllipAng = abs(EllipAng);



end




function y=randdf(size1,df1,flag)
% This function is to generate random numbers
% according to a user defined probability density function (pdf)
% or cumulative distribution function (cdf).
% pdf or cdf is described by a matrix,
% whose size is N-by-2.
% Sampling points of pdf or cdf form the second row.
% Function value of pdf or cdf form the first row.
% coded by halleyhit on Aug. 15th, 2018

%df1(df1>1e6) = 1e6;

if numel(size1)==1
    n=1;m=size1(1);
elseif numel(size1)==2
    n=size1(1);m=size1(2);
else
    return
end
all=n*m;
if size(df1,1)~=2
    return
end
if sum(df1(1,:)<0)>0
    return
end
if size(df1,2)<2
    return
end
if strcmp(flag,'pdf')
    df1(1,:)=cumsum(df1(1,:),'omitnan')/sum(df1(1,:),'omitnan');
elseif strcmp(flag,'cdf')
    if sum(diff(df1(1,:))<0,'omitnan')>0
        return
    end
    df1(1,:)=df1(1,:)/df1(1,end);
else
    return
end
df1(1,:)=df1(1,:)+[1:size(df1,2)]*eps;
temp=rand(1,all);

dt1 = df1(1,:);
dt2 = df1(2,:);

[~,~,ind1] = unique(dt1,'stable');
[~,~,ind2] = unique(dt2,'stable');

%[~,~,ind] = sort(&unique(dt2));
%temp=interp1(df1(1,:),df1(2,:),temp,'linear','extrap');
temp=interp1(dt1(ind1==ind2),dt2(ind1==ind2),temp,'linear','extrap');
y=reshape(temp,n,m);

end



function [nphi,phib_bins,phic_bins] = nphi_biv_agg(a_ba,b_ba,b_cb)

phib_bins = linspace(0.05,1.0,200);
phic_bins = linspace(0.05,1.0,200);


nphi = zeros(length(phib_bins),length(phic_bins));


nphi_func = @(phib,phic,a_ba,b_ba,b_cb) ...
    (1./beta(a_ba,b_ba)).*(1./beta(a_ba+b_ba,b_cb)) .* ...
    phic.^(a_ba+b_ba-1) .* (phib-phic).^(b_cb-1) .* ...
    phib.^(-b_ba-b_cb) .* (1-phib).^(b_ba-1);

for i = 1 : length(phib_bins)
    for j = 1 : length(phic_bins)
        
       if phic_bins(j) <= phib_bins(i)
           
            nphi(i,j) = nphi_func(phib_bins(i),phic_bins(j),...
                                  a_ba,b_ba,b_cb);
           
       end
        
        
    end
    
end

nphi(isnan(nphi)) = 0;

end




function [x0,y0]=pinky(Xin,Yin,dist_in,varargin)
%check input
if length(size(dist_in))>2
    error('The input must be a N x M matrix.')
end
%check sizes
[sy,sx]=size(dist_in);
if or(length(Xin)~=sx,length(Yin)~=sy)
    error('Dimensions of input vectors and input matrix must match.')
end
%check values
if any(dist_in(:)<0)
    error('All input probability values must be positive.')
end
%get res
if nargin==4
    res=varargin{1};
    if res<=1
        error('The resolution factor (res) must be an integer greater than one.')
    end
elseif nargin~=3
    error('Incorrect number of input arguments.')
end
    
%create column distribution and pick random number
col_dist=sum(dist_in,1,'omitnan');
%pick column distribution type
if nargin==3
    %if no res parameter, simply update X/Yin2
    col_dist=col_dist/sum(col_dist,'omitnan');
    Xin2=Xin;
    Yin2=Yin;
else
    %generate new, higher res input vectors
    Xin2=linspace(min(Xin),max(Xin),round(res*length(Xin)));
    Yin2=linspace(min(Yin),max(Yin),round(res*length(Yin)));
    
    %generate interpolated column-sum distribution
    col_dist=interp1(Xin,col_dist,Xin2,'pchip');
    
    %check to make sure interpolated values are positive
    if any(col_dist<0)
        col_dist=abs(col_dist);
        warning('Interpolation generated negative probability values.')
    end
    col_dist=col_dist/sum(col_dist,'omitnan');
end
%generate random value index
ind1=gendist(col_dist,1,1);
%save first value
x0=Xin2(ind1);
%find corresponding indices and weights in the other dimension
[val_temp,ind_temp]=sort((x0-Xin).^2);
if val_temp(1)<eps %if we land on an original value
    row_dist=dist_in(:,ind_temp(1));
else %if we land inbetween, perform linear interpolation
    low_val=min(ind_temp(1:2));
    high_val=max(ind_temp(1:2));
    
    Xlow=Xin(low_val);
    Xhigh=Xin(high_val);
    
    w1=1-(x0-Xlow)/(Xhigh-Xlow);
    w2=1-(Xhigh-x0)/(Xhigh-Xlow);
    
    row_dist=w1*dist_in(:,low_val) + w2*dist_in(:,high_val);
end
%pick column distribution type
if nargin==3
    row_dist=row_dist/sum(row_dist,'omitnan');
else
    row_dist=interp1(Yin,row_dist,Yin2,'pchip');
    row_dist=row_dist/sum(row_dist,'omitnan');
end
%generate random value index
ind2=gendist(row_dist,1,1);
%save first value
y0=Yin2(ind2);
function T = gendist(P,N,M,varargin)
%
%GENDIST - generate random numbers according to a discrete probability
%distribution.
%Tristan Ursell, (c) 2012
%
%T = gendist(P,N,M)
%T = gendist(P,N,M,'plot')
%
%The function gendist(P,N,M) takes in a positive vector P whose values
%form a discrete probability distribution for the indices of P. The
%function outputs an N x M matrix of integers corresponding to the indices
%of P chosen at random from the given underlying distribution.
%
%P will be normalized, if it is not normalized already. Both N and M must
%be greater than or equal to 1.  The optional parameter 'plot' creates a
%plot displaying the input distribution in red and the generated points as
%a blue histogram.
%
%Conceptual EXAMPLE:
%
%If P = [0.2 0.4 0.4] (note sum(P)=1), then T can only take on values of 1,
%2 or 3, corresponding to the possible indices of P.  If one calls 
%gendist(P,1,10), then on average the output T should contain two 1's, four
%2's and four 3's, in accordance with the values of P, and a possible 
%output might look like:
%
%T = gendist(P,1,10)
%T = 2 2 2 3 3 3 1 3 1 3
%
%If, for example, P is a probability distribution for position, with
%positions X = [5 10 15] (does not have to be linearly spaced), then the
%set of generated positions is X(T).
%
%EXAMPLE 1:
%
%P = rand(1,50);
%T = gendist(P,100,1000,'plot');
%
%EXAMPLE 2:
%
%X = -3:0.1:3;
%P = 1+sin(X);
%T = gendist(P,100,1000,'plot');
%Xrand = X(T);
%
%Note:
%size(T) = 100 1000
%size(Xrand) = 100 1000
%
%Thanks to Derek O'Connor for tips on speeding up the code.
%check for input errors
if and(nargin~=3,nargin~=4)
    error('Error:  Invalid number of input arguments.')
end
if min(P)<0
    error('Error:  All elements of first argument, P, must be positive.')
end
if size(P,1)>1
    P=P';
end
if or(N<1,M<1)
    error('Error:  Output matrix dimensions must be greater than or equal to one.')
end
%normalize P
Pnorm=[0 P]/sum(P,'omitnan');
%create cumlative distribution
Pcum=cumsum(Pnorm,'omitnan');
%create random matrix
N=round(N);
M=round(M);
R=rand(1,N*M);
%calculate T output matrix
V=1:length(P);
[~,inds] = histc(R,Pcum); 
T = V(inds);
%shape into output matrix
T=reshape(T,N,M);
end
end
