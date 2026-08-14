function mout = calc_ellipse_stats(m,varargin)

% Default options

habit = 'all';
Tc_max = 0;
Tc_min = -99999;

for nn = 1 : length(varargin)

switch varargin{nn}

    case 'habit'

        habit = varargin{nn+1};

    case 'Temp_max'

        Tc_max = varargin{nn+1};

    case 'Temp_min'

        Tc_min = varargin{nn+1};

end

end



fnames = fieldnames(m);

mout= struct();

phimean = NaN(1,length(fnames));
thetamean = NaN(1,length(fnames));
mean_ang_H = NaN(1,length(fnames));
mean_ang_V = NaN(1,length(fnames));

for ff = 1 : length(fnames)

    mtemp = m.(fnames{ff});

if ~strcmp(habit,'all')

indH_habit = (mtemp.H.habit==habit);     
indV_habit = (mtemp.V.habit==habit);

else

indH_habit = true(size(mtemp.H.AR));    
indV_habit = true(size(mtemp.V.AR));  

end

indH_temp = (mtemp.H.Temp<Tc_max)&(mtemp.H.Temp>=Tc_min);
indV_temp = (mtemp.V.Temp<Tc_max)&(mtemp.V.Temp>=Tc_min);

indH = (indH_habit&indH_temp);
indV = (indV_habit&indV_temp);

[phimean(ff),thetamean(ff),mean_ang_H(ff),mean_ang_V(ff)] = ret_angle_3D_proj(mtemp.H.EllipAng(indH),mtemp.V.EllipAng(indV));

end

mout.fdates = fnames;
mout.phimean = phimean;
mout.thetamean = thetamean;
mout.mean_ang_H = mean_ang_H;
mout.mean_ang_V = mean_ang_V;

end
