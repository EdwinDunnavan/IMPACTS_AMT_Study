function [ra,rb,EllipAng]=ellipproj_axes(a,b,c,phi,theta,psi,proj)

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

%ap = rb./ra;

EllipAng = zeros(size(ra));

indxy = (cxy~=0);

EllipAng(indxy) = atand(cxy(indxy)./(cyy(indxy)-cxx(indxy)-sqrt((cxx(indxy)-cyy(indxy)).^2+cxy(indxy).^2)));

EllipAng(cxy==0&cxx<cyy) = 90;


% 
% A1 = [A11; A12; A13];
% A2 = [A21; A22; A23];
% A3 = [A31; A32; A33];
% 
% F = [1./phica; 1./phiba; ones(size(phiba))].^2;
% 
% A = [A11 A12 A13; A21 A22 A23; A31 A32 A33];
% 
% F = [1./c 1./b 1./a].^2;
% 
% D11 = sum(A(1,:).^2.*F);
% D22=sum(A(2,:).^2.*F);
% D33=sum(A(3,:).^2.*F);
% D12= sum(A(1,:).*A(2,:).*F);
% D21 = D12;
% D13 = sum(A(1,:).*A(3,:).*F);
% D31=D13;
% D23=sum(A(2,:).*A(3,:).*F);
% D32=D23;
% 
% D = [D11 D12 D13;D21 D22 D23;D31 D32 D33];
% 
% if proj==3
% % x-y
% cxx = D(2,2)-D(2,3).^2./D(3,3);
% cyy = D(1,1)-D(1,3).^2./D(3,3);
% cxy = 2.*(D(1,2)-D(1,3).*D(2,3)./D(3,3));
% 
% elseif proj==2
% 
% % x-z
% cxx = D(3,3)-D(2,3).^2./D(2,2);
% cyy = D(1,1)-D(1,2).^2./D(2,2);
% cxy = 2.*(D(1,3)-D(1,2).*D(2,3)./D(2,2));
% 
% elseif proj==1
% 
%  cxx = D(3,3)-D(1,3).^2./D(1,1);
%  cyy = D(2,2)-D(1,2).^2./D(1,1);
%  cxy = 2.*(D(2,3)-D(1,2).*D(1,3)./D(1,1));
% 
% end
% 
% % cxx = sin^2(theta_proj) + ar_proj^2 * cos^2(theta_proj)
% % cyy = ar_proj^2 * sin^2(theta_proj) + cos^2(theta_proj)
% % cxy = - 2*(1-ar_proj^2)*sin(2*theta_proj)
% %
% % cxx+cyy = ar_proj^2
% %
% % cxy^2 - 4*cxx*cyy = 4*(1-ar_proj^2)^2*sin^2(2*theta_proj) -
% % 4*(sin^2(theta_proj)+ar_proj^2*cos^2(theta_proj))*(ar_proj^2*sin^2(theta_proj)+cos^2(theta_proj))<0
% %(1-ar_proj^2)^2*sin^2(2*theta_proj) -
% %(sin^2(theta_proj)+ar_proj^2*cos^2(theta_proj))*(ar_proj^2*sin^2(theta_proj)+cos^2(theta_proj))<0
% %
% 
% ra = sqrt(2.*(cxx+cyy+sqrt((cyy-cxx).^2+cxy.^2))./(4.*cxx.*cyy-cxy.^2));
% rb = sqrt(2.*(cxx+cyy-sqrt((cyy-cxx).^2+cxy.^2))./(4.*cxx.*cyy-cxy.^2));
% 
% EllipAng = zeros(size(ra));
% 
% if cxy~=0
% EllipAng = atand(cxy./(cyy-cxx-sqrt((cxx-cyy).^2+cxy.^2)));
% 
% elseif cxy==0 && cxx>cyy
% 
%     EllipAng = 0;
% 
% elseif cxy==0 && cxx<cyy
% 
%     EllipAng = 90;
% 
% 
% end
%toc

%fprintf('EllipAng2 =%f\n',EllipAng)

end