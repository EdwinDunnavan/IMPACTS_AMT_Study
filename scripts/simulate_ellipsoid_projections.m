
%{ 
 simulate_ellipsoid_projections.m

 Description: Use ellipsoid distributions to estimate joint distributions 
 of projected ellipse characteristics.
%}

%% Set up ellipsoid distributions

folder = '/home/edwin.dunnavan/Documents/UIOPS/EllipsoidProjection/Simulations/';
%subfolder = 'Irregular_2020_rejction_sampling_new';

subfolder = 'Columns_2020_rejection_sampling_new';

outdir = strcat(folder,subfolder);

% IRREGULAR 2020
%N = 1e6;
%nu = 8;
%Dmean = 0.6;
%pba = 0.8;
%pcb = 0.8;
%abatog = 0.5;
%ang_xz = -35;
%ang_xy = 45;
%kappa = 4;
%psimean = 0;
%varpsi = 0.001;
%rhomean = 0.75;
%rhovar_frac = 0.1;

% PAPER IRREGULAR 2020
% Lmin = 0.35;
% N = 1e6;
% nu = 8;
% Dmean = 0.6;
% pba = 0.75;
% pcb = 0.75;
% abatog = 0.6;
% ang_xz = -35;
% ang_xy = 45;
% kappa = 5;
% psimean = 0;
% varpsi = 0.001;
% rhomean = 0.8;
% rhovar_frac = 0.12;
% ar_scale = 2.0;
% AR_scale = 4/3;
% ar_min = 0.5;
% AR_min = 0.35;

% PAPER IRREGULAR 2022-2023
% Lmin = 0.35;
% N = 1e6;
% nu = 8;
% Dmean = 0.6;
% pba = 0.8;
% pcb = 0.8;
% abatog = 0.5;
% ang_xz = -10;
% ang_xy = 60;
% kappa = 4;
% psimean = 45;
% varpsi = 100;
% rhomean = 0.8;
% rhovar_frac = 0.12;
% ar_scale = 2.0;
% AR_scale = 4/3;
% ar_min = 0.5;
% AR_min = 0.35;

% PAPER LINEAR 2020
Lmin = 0.35;
N = 1e6;
nu = 4;
a0 = 5.0e-4;
ds = 1.3;
Dmean = 0.7;
pbmean = 1.0;
ang_xz = -70;
ang_xy = 80;
kappa = 3;
psimean = 45;
varpsi = 0.001;
rhomean = 0.75;
rhovar_frac = 0.05;
ar_scale = 0.01;
AR_scale = 4;
ar_min = 0.1;
AR_min = 0.8;

[phimean,thetamean,mean_ang_xz,mean_ang_xy] = ret_angle_3D_proj(ang_xz,ang_xy);


% phimean = 45;
% thetamean = 116;
% kappa = 4;
% psimean = 315;
% varpsi = 5;


%% 2022-2023 Testing Horizontal is good; vertical is too circular
%phimean = 60;
%thetamean = 135;
%kappa = 4;
%psimean = 0;
%varpsi = 1;


% 2022-2023 TESTING
%phimean = 45;
%thetamean = 70;
% kappa = 4;
% psimean = 45;
% varphi = 100;

%[L_xy,ar_xy,EllipAng_xy,AR_xy,L_xz,ar_xz,EllipAng_xz,AR_xz]= EllipProj_fwd_sim(N,nu,Dmean,pba,pcb,abatog,phimean,thetamean,kappa,psimean,varpsi,rhomean,rhovar_frac);

%[L_xy,ar_xy,EllipAng_xy,AR_xy,L_xz,ar_xz,EllipAng_xz,AR_xz,phiba,phica]= EllipProj_fwd_sim_rejection(N,nu,Dmean,Lmin,pba,pcb,abatog,phimean,thetamean,kappa,psimean,varpsi,rhomean,rhovar_frac,ar_scale,AR_scale,ar_min,AR_min);

[L_xy,ar_xy,EllipAng_xy,AR_xy,L_xz,ar_xz,EllipAng_xz,AR_xz]= EllipProj_fwd_sim_rejection_plaw(N,nu,a0,Dmean,Lmin,ds,pbmean,phimean,thetamean,kappa,psimean,varpsi,rhomean,rhovar_frac,AR_scale,AR_min);

m = struct();

m.L_xy = L_xy;
m.ar_xy = ar_xy;
m.EllipAng_xy = EllipAng_xy;
m.AR_xy = AR_xy;

m.L_xz = L_xz;
m.ar_xz = ar_xz;
m.EllipAng_xz = EllipAng_xz;
m.AR_xz = AR_xz;


 [fig,ax] = plot_ellipse_joint_sim(m,subfolder,'show_fig',true,'save_fig',false,'outdir',outdir);


function [L_xy,ar_xy,EllipAng_xy,AR_xy,L_xz,ar_xz,EllipAng_xz,AR_xz]= EllipProj_fwd_sim(N,nu,Dmean,pba,pcb,abatog,phimean,thetamean,kappa,psimean,varpsi,rhomean,rhovar_tog,ar_scale,AR_scale)

%% Put in new method that samples the individual beta distributions and performs the trig transformation: u =sin^2(theta_p) 
% Note: Definitely a better approach. Much more accurate.

%% Sample from truncated gamma distribution
pd = truncate(makedist('Gamma','a',nu,'b',Dmean/nu),0.4,3);
a = pd.random([1 N])./2;

%% NEW: Sample phiba and phicb which are independent beta distributions
pbmin = pba./(1-pba);
pcmin = pba.*pcb./(1-pcb);
abamin = max(pbmin,pcmin);
abamax = 20;

a_ba = abatog.*abamax+(1-abatog).*abamin;
b_ba = ((1./pba)-1).*a_ba;
b_cb =((1./pcb)-1).*a_ba./pba;

phiba_samp1 = betarnd(a_ba,b_ba,[1 N]);

%fba_frac = truncate(makedist('Exponential','mu',a.*2))

%f_ba = (2.*a).^(-2);

f_ba = exp(-a./ar_scale);

f_ba(f_ba>1) = 1;
f_ba(f_ba<0.5) = 0.5;

f_ba = 1.0;

phiba_samp = f_ba.*phiba_samp1;

%f_ca = (2.*a).^(-3);
f_ca = exp(-a./3);

f_ca(f_ca>1) = 1;
f_ca(f_ca<0.5) = 0.5;

phica_samp = phiba_samp.*betarnd(a_ba+b_ba,b_cb,[1 N]);


%% Sample from von Mises Fisher distribution
x = sind(thetamean).*cosd(phimean);
y = sind(thetamean).*sind(phimean);
z = cosd(thetamean);

mu_tot = [x,y,z];

mu = mu_tot./norm(mu_tot);

RandVMF= randVMF(N, mu, kappa);

xrand = RandVMF(:,1)';
yrand = RandVMF(:,2)';
zrand = RandVMF(:,3)';

theta_p = acos(zrand./sqrt(xrand.^2+yrand.^2+zrand.^2));

phi_p = atan2(yrand,xrand);

phi_p(phi_p<0) = phi_p(phi_p<0)+2.*pi;

psi_p =  (randraw('vonmises',[2.*deg2rad(psimean),varpsi],[1 N]))./2;

psi_p(psi_p>pi) = psi_p(psi_p>pi)-pi;
psi_p(psi_p<0) = psi_p(psi_p<0)+pi;


%% Sample from beta distribution for effective density

rhovar_max = (rhomean^2-rhomean^3)/(rhomean+1);

rhovar = min(rhovar_tog.*rhovar_max,20);

alpha_rho = rhomean*((rhomean*(1-rhomean)/rhovar)-1);
beta_rho = (1-rhomean)*((rhomean*(1-rhomean)/rhovar)-1);

fAR = exp(-a./AR_scale);

fAR(fAR>1) = 1;
fAR(fAR<0.35) = 0.35;

AR_xy= fAR.*betarnd(alpha_rho,beta_rho,[1 N]);
AR_xz = fAR.*betarnd(alpha_rho,beta_rho,[1 N]);

%% Calculate ellipse projections
 [ra_xz,rb_xz,EllipAng_xz]=project_ellipsoid(a,a.*phiba_samp,a.*phica_samp,phi_p,theta_p,psi_p,2); % H Projection
 [ra_xy,rb_xy,EllipAng_xy]=project_ellipsoid(a,a.*phiba_samp,a.*phica_samp,phi_p,theta_p,psi_p,3); % V Projection

 ar_xz = rb_xz./ra_xz;
 ar_xy = rb_xy./ra_xy;

 L_xz = 2.*ra_xz;
 L_xy = 2.*ra_xy;


end


function [L_xy,ar_xy,EllipAng_xy,AR_xy,L_xz,ar_xz,EllipAng_xz,AR_xz,phiba_samp,phica_samp]= EllipProj_fwd_sim_rejection(N,nu,Dmean,Lmin,pba,pcb,abatog,phimean,thetamean,kappa,psimean,varpsi,rhomean,rhovar_tog,ar_scale,AR_scale,ar_min,AR_min)

%% Put in new method that samples the individual beta distributions and performs the trig transformation: u =sin^2(theta_p) 
% Note: Definitely a better approach. Much more accurate.

%% Sample from truncated gamma distribution
pd = truncate(makedist('Gamma','a',nu,'b',Dmean/nu),0.4,3);

a_tot = [];
b_tot = [];
V_tot = [];

L_xy = [];
ar_xy = [];
EllipAng_xy = [];

L_xz = [];
ar_xz = [];
EllipAng_xz = [];

n= 1;

while n<N

a = pd.random([1 N])./2;

%% NEW: Sample phiba and phicb which are independent beta distributions
pbmin = pba./(1-pba);
pcmin = pba.*pcb./(1-pcb);
abamin = max(pbmin,pcmin);
abamax = 20;

a_ba = abatog.*abamax+(1-abatog).*abamin;
b_ba = ((1./pba)-1).*a_ba;
b_cb =((1./pcb)-1).*a_ba./pba;

phiba_samp1 = betarnd(a_ba,b_ba,[1 N]);

f_ba = exp(-a./ar_scale);

f_ba(f_ba>1) = 1;
f_ba(f_ba<ar_min) = ar_min;

f_ba = 1;

phiba_samp = f_ba.*phiba_samp1;

%f_ca = (2.*a).^(-3);
%f_ca = exp(-a./3);

%f_ca(f_ca>1) = 1;
%f_ca(f_ca<0.5) = 0.5;

phica_samp = phiba_samp.*betarnd(a_ba+b_ba,b_cb,[1 N]);


%% Sample from von Mises Fisher distribution
x = sind(thetamean).*cosd(phimean);
y = sind(thetamean).*sind(phimean);
z = cosd(thetamean);

mu_tot = [x,y,z];

mu = mu_tot./norm(mu_tot);

RandVMF= randVMF(N, mu, kappa);

xrand = RandVMF(:,1)';
yrand = RandVMF(:,2)';
zrand = RandVMF(:,3)';

theta_p = acos(zrand./sqrt(xrand.^2+yrand.^2+zrand.^2));

phi_p = atan2(yrand,xrand);

phi_p(phi_p<0) = phi_p(phi_p<0)+2.*pi;

%%%% TESTING %%%%%
%psimean = theta_p;

psi_p =  (randraw('vonmises',[2.*deg2rad(psimean),varpsi],[1 N]))./2;

psi_p(psi_p>pi) = psi_p(psi_p>pi)-pi;
psi_p(psi_p<0) = psi_p(psi_p<0)+pi;



%% Calculate ellipse projections
 [ra_xz_temp,rb_xz_temp,EllipAng_xz_temp]=project_ellipsoid(a,a.*phiba_samp,a.*phica_samp,phi_p,theta_p,psi_p,2); % H Projection
 [ra_xy_temp,rb_xy_temp,EllipAng_xy_temp]=project_ellipsoid(a,a.*phiba_samp,a.*phica_samp,phi_p,theta_p,psi_p,3); % V Projection

 
 L_xy_temp = 2.*ra_xy_temp;
 ar_xy_temp = rb_xy_temp./ra_xy_temp;
 
 L_xz_temp = 2.*ra_xz_temp;
 ar_xz_temp = rb_xz_temp./ra_xz_temp;

 L_check = (L_xy_temp>=Lmin) & (L_xz_temp>=Lmin); 

 a_tot = horzcat(a_tot,a(L_check));
 b_tot = horzcat(b_tot,a(L_check).*phiba_samp(L_check));
 V_tot = horzcat(V_tot,a(L_check).^3.*phiba_samp(L_check).*phica_samp(L_check));

 L_xy = horzcat(L_xy,L_xy_temp(L_check));
 ar_xy = horzcat(ar_xy,ar_xy_temp(L_check));
 EllipAng_xy = horzcat(EllipAng_xy,EllipAng_xy_temp(L_check));

 L_xz = horzcat(L_xz,L_xz_temp(L_check));
 ar_xz = horzcat(ar_xz,ar_xz_temp(L_check));
 EllipAng_xz = horzcat(EllipAng_xz,EllipAng_xz_temp(L_check));

 n_temp = min(length(L_xy),length(L_xz));

 if n_temp >= N

     a_tot = a_tot(1:N);
     b_tot = b_tot(1:N);
     V_tot = V_tot(1:N);

     L_xy = L_xy(1:N);
     ar_xy = ar_xy(1:N);
     EllipAng_xy = EllipAng_xy(1:N);

     L_xz = L_xz(1:N);
     ar_xz = ar_xz(1:N);
     EllipAng_xz = EllipAng_xz(1:N);

     n = n_temp;

 end

end

%% Sample from beta distribution for effective density


rhovar_max = (rhomean^2-rhomean^3)/(rhomean+1);

rhovar = min(rhovar_tog.*rhovar_max,20);

alpha_rho = rhomean*((rhomean*(1-rhomean)/rhovar)-1);
beta_rho = (1-rhomean)*((rhomean*(1-rhomean)/rhovar)-1);

fAR = exp(-a_tot./AR_scale);

%fAR = exp(-V_tot.^(1./3)./AR_scale);

fAR(fAR>1) = 1;
fAR(fAR<AR_min) = AR_min;

AR_xy= fAR.*betarnd(alpha_rho,beta_rho,[1 N]);
AR_xz = fAR.*betarnd(alpha_rho,beta_rho,[1 N]);


end



function [L_xy,ar_xy,EllipAng_xy,AR_xy,L_xz,ar_xz,EllipAng_xz,AR_xz]= EllipProj_fwd_sim_rejection_plaw(N,nu,a0,Dmean,Lmin,ds,pbmean,phimean,thetamean,kappa,psimean,varpsi,rhomean,rhovar_tog,AR_scale,AR_min)

%% Put in new method that samples the individual beta distributions and performs the trig transformation: u =sin^2(theta_p) 
% Note: Definitely a better approach. Much more accurate.

astar = a0.^(1-ds);

%% Sample from truncated gamma distribution
pd = truncate(makedist('Gamma','a',nu,'b',Dmean/nu),0.4,3);

a_tot = [];
L_xy = [];
ar_xy = [];
EllipAng_xy = [];

L_xz = [];
ar_xz = [];
EllipAng_xz = [];

n= 1;

while n<N

a = pd.random([1 N])./2;

%% NEW: Sample phiba and phicb which are independent beta distributions
if pbmean<=0.99
    alph = pbmean./(1-pbmean);
    phib_samp1 = betarnd(alph,1,[1 1]);
else

    phib_samp1 = 1.0;

end

if ds<=1.0

    c = astar.*a.^ds;



    b = c.*phib_samp1 + (1-phib_samp1).*a;

else

    %c = (a./astar).^(1./ds);
    %c = 0.001.*8.*(a.*2000).^0.4; % Columns MA94

    c = 0.001.*6.96.*(a.*2000).^0.5; % Columns MA94

    b = c.*phib_samp1+(1-phib_samp1).*a;






end


%% Sample from von Mises Fisher distribution
x = sind(thetamean).*cosd(phimean);
y = sind(thetamean).*sind(phimean);
z = cosd(thetamean);

mu_tot = [x,y,z];

mu = mu_tot./norm(mu_tot);

RandVMF= randVMF(N, mu, kappa);

xrand = RandVMF(:,1)';
yrand = RandVMF(:,2)';
zrand = RandVMF(:,3)';

theta_p = acos(zrand./sqrt(xrand.^2+yrand.^2+zrand.^2));

phi_p = atan2(yrand,xrand);

phi_p(phi_p<0) = phi_p(phi_p<0)+2.*pi;

psi_p =  (randraw('vonmises',[2.*deg2rad(psimean),varpsi],[1 N]))./2;

psi_p(psi_p>pi) = psi_p(psi_p>pi)-pi;
psi_p(psi_p<0) = psi_p(psi_p<0)+pi;


%% Calculate ellipse projections
 [ra_xz_temp,rb_xz_temp,EllipAng_xz_temp]=project_ellipsoid(a,b,c,phi_p,theta_p,psi_p,2); % H Projection
 [ra_xy_temp,rb_xy_temp,EllipAng_xy_temp]=project_ellipsoid(a,b,c,phi_p,theta_p,psi_p,3); % V Projection

 
 L_xy_temp = 2.*ra_xy_temp;
 ar_xy_temp = rb_xy_temp./ra_xy_temp;
 
 L_xz_temp = 2.*ra_xz_temp;
 ar_xz_temp = rb_xz_temp./ra_xz_temp;

 L_check = (L_xy_temp>=Lmin) & (L_xz_temp>=Lmin); 

 a_tot = horzcat(a_tot,a(L_check));

 L_xy = horzcat(L_xy,L_xy_temp(L_check));
 ar_xy = horzcat(ar_xy,ar_xy_temp(L_check));
 EllipAng_xy = horzcat(EllipAng_xy,EllipAng_xy_temp(L_check));

 L_xz = horzcat(L_xz,L_xz_temp(L_check));
 ar_xz = horzcat(ar_xz,ar_xz_temp(L_check));
 EllipAng_xz = horzcat(EllipAng_xz,EllipAng_xz_temp(L_check));

 n_temp = min(length(L_xy),length(L_xz));

 if n_temp >= N

     a_tot = a_tot(1:N);
     L_xy = L_xy(1:N);
     ar_xy = ar_xy(1:N);
     EllipAng_xy = EllipAng_xy(1:N);

     L_xz = L_xz(1:N);
     ar_xz = ar_xz(1:N);
     EllipAng_xz = EllipAng_xz(1:N);

     n = n_temp;

 end

end



%% Sample from beta distribution for effective density

rhovar_max = (rhomean^2-rhomean^3)/(rhomean+1);

rhovar = min(rhovar_tog.*rhovar_max,20);

alpha_rho = rhomean*((rhomean*(1-rhomean)/rhovar)-1);
beta_rho = (1-rhomean)*((rhomean*(1-rhomean)/rhovar)-1);

fAR = exp(-a_tot./AR_scale);

fAR(fAR>1) = 1;
fAR(fAR<AR_min) = AR_min;

AR_xy= fAR.*betarnd(alpha_rho,beta_rho,[1 N]);
AR_xz = fAR.*betarnd(alpha_rho,beta_rho,[1 N]);


end





function [phimean,thetamean,mean_ang_xz,mean_ang_xy] = ret_angle_3D_proj(ang_xz,ang_xy)

mean_ang_xz = 0.5.*atan2d(mean(sind(2.*ang_xz)),mean(cosd(2.*ang_xz)));

mean_ang_xy = 0.5.*atan2d(mean(sind(2.*ang_xy)),mean(cosd(2.*ang_xy)));


phimean = mean_ang_xy;
phimean(phimean<0) = 180 + phimean(phimean<0);

%phimean((phimean>90)&(phimean<=270)) = phimean((phimean>90)&(phimean<=270)) - 180;

thetamean = atan2d(secd(phimean),tand(mean_ang_xz));
thetamean(thetamean<0) = 180 + thetamean(thetamean<0);


end