function [phi_p,theta_p,psi_p] = getEulerAngles(N,phimean,thetamean,kappa,psimean,varpsi)

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

phi_p = rad2deg(phi_p);
theta_p = rad2deg(theta_p);
psi_p = rad2deg(psi_p);

end