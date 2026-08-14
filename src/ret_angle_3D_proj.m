function [phimean,thetamean,mean_ang_xz,mean_ang_xy] = ret_angle_3D_proj(ang_xz,ang_xy)

mean_ang_xz = 0.5.*atan2d(mean(sind(2.*ang_xz)),mean(cosd(2.*ang_xz)));

mean_ang_xy = 0.5.*atan2d(mean(sind(2.*ang_xy)),mean(cosd(2.*ang_xy)));


phimean = mean_ang_xy;
phimean(phimean<0) = 180 + phimean(phimean<0);

%phimean((phimean>90)&(phimean<=270)) = phimean((phimean>90)&(phimean<=270)) - 180;




thetamean = atan2d(secd(phimean),tand(mean_ang_xz));
thetamean(thetamean<0) = 180 + thetamean(thetamean<0);


end