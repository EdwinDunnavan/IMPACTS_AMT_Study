function [ra,rb,EllipAng]=project_ellipsoid(a,b,c,phi,theta,psi,proj)

% first index: x,y,z index
% second index: yproj, xproj

A11 = cos(phi).*cos(theta).*cos(psi)-sin(phi).*sin(psi);
A12 = -cos(psi).*sin(phi)-cos(phi).*cos(theta).*sin(psi);
A13=cos(phi).*sin(theta);
A21=cos(phi).*sin(psi)+cos(theta).*cos(psi).*sin(phi);
A22=cos(phi).*cos(psi)-cos(theta).*sin(phi).*sin(psi);
A23=sin(phi).*sin(theta);
A31=-cos(psi).*sin(theta);
A32=sin(theta).*sin(psi);
A33=cos(theta);

A1 = [A11; A12; A13];
A2 = [A21; A22; A23];
A3 = [A31; A32; A33];

F = [1./c; 1./b; 1./a].^2;

D11 = sum(A1.^2.*F);
D22=sum(A2.^2.*F);
D33=sum(A3.^2.*F);
D12= sum(A1.*A2.*F);
D13 = sum(A1.*A3.*F);
D23=sum(A2.*A3.*F);

if proj==3
% x-y plane
cxx = D22-D23.^2./D33;
cyy = D11-D13.^2./D33;
cxy = 2.*(D12-D13.*D23./D33);

elseif proj==2
% x-z plane
cxx = D33-D23.^2./D22;
cyy = D11-D12.^2./D22;
cxy = 2.*(D13-D12.*D23./D22);

elseif proj == 1
% y-z plane
cxx = D33-D13.^2./D11;
cyy = D22-D12.^2./D11;
cxy = 2.*(D23-D12.*D13./D11);

end

ra = sqrt(2.*(cxx+cyy+sqrt((cyy-cxx).^2+cxy.^2))./(4.*cxx.*cyy-cxy.^2));
rb = sqrt(2.*(cxx+cyy-sqrt((cyy-cxx).^2+cxy.^2))./(4.*cxx.*cyy-cxy.^2));

EllipAng = zeros(size(ra));

indxy = (cxy~=0);

EllipAng(indxy) = atand(cxy(indxy)./(cyy(indxy)-cxx(indxy)-sqrt((cxx(indxy)-cyy(indxy)).^2+cxy(indxy).^2)));

EllipAng(cxy==0&cxx<cyy) = 90;

end