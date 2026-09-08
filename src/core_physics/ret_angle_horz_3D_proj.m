function [phimean,thetamean,mean_ang_xz,mean_ang_yz] = ret_angle_horz_3D_proj(ang_xz,ang_xy)

mean_ang_xz = 0.5.*atan2d(mean(sind(2.*ang_xz)),mean(cosd(2.*ang_xz)));

mean_ang_yz = 0.5.*atan2d(mean(sind(2.*ang_xy)),mean(cosd(2.*ang_xy)));


phimean = atan2d(tand(mean_ang_xz),tand(mean_ang_yz));
phimean(phimean<0) = 180 + phimean(phimean<0);

thetamean = atan2d(secd(phimean),tand(mean_ang_xz));
thetamean(thetamean<0) = 180 + thetamean(thetamean<0);


end