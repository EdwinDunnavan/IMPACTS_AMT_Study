
%{
% generate_IMPACTS_figures.m

Description: This script generates figures 

%}

%% Set up paths based on Github Parent location
scriptPath = mfilename('fullpath');
scriptDir  = fileparts(scriptPath);
projectDir = fileparts(scriptDir);
srcDir     = fullfile(projectDir,'src/');
utilsDir   = fullfile(srcDir,'utils');
FiguresDir = fullfile(projectDir,'Figures','Joint_Distributions','IMPACTS_Observations/');
DataDir    = fullfile(projectDir,'Data','processed/');

addpath(utilsDir)
addpath(srcDir)

load(fullfile(DataDir,'IMPACTS_EllipseFits_2020_2023.mat'),'-mat')

habit_fraction = false;
joint_dist = true;

outdir = FiguresDir;

outdir_joint = {'AspectRatio_EllipseAngle/','Dmajor_AspectRatio/','EllipseAngle_Dmajor/','AreaRatio_AspectRatio/',...
                'Dmajor_AreaRatio/','EllipseAngle_AreaRatio/'};

dates_2020 = {'20200118','20200125','20200201','20200205','20200207','20200213'...
         '20200218','20200220'};
dates_2022 ={'20220208','20220213','20220217','20220219','20220225'};
dates_2023 = {'20230113','20230115','20230119','20230123','20230125','20230129',...
              '20230205','20230209','20230212','20230214','20230216','20230223','20230228'};

dates = [dates_2020,dates_2022,dates_2023];

%Tc_max = [-18,-12,-8,-3,0];
%Tc_min = [-9999,-18,-12,-8,-3];

Tc_max = -18;
Tc_min = -9999;

outdir_ranges = {'Below_neg_18C/'};

habit = {'all','i','d','h','g','l','a','o','s'};
habit_names = {'All','Irregular','Dendrite','Hexagonal','Graupel','Linear','Aggregate','Oriented','Sphere'};


%% Plot/Save Figures
fnames = fieldnames(m);

tic

for dd = 1 : length(outdir_joint)

for tt = 1 : length(Tc_max)

for hh = 1 : length(habit_names)

fprintf('Joint Distribution = %s |T range = %s | Plotting Distributions for habit %s\n',outdir_joint{dd},outdir_ranges{tt},habit_names{hh})

for ff = 1 : length(dates)


    fprintf('Saving figure for date %s | %i out of %i\n',dates{ff},ff,length(dates))

if joint_dist

out_temp = strcat(outdir,outdir_joint{dd},outdir_ranges{tt},habit_names{hh},'/');

switch outdir_joint{dd}


    case 'AspectRatio_EllipseAngle/'

        EllipseAngle = true;
        Dmajor = false;
        AspectRatio = true;
        AreaRatio = false;


    case 'Dmajor_AspectRatio/'

        EllipseAngle = false;
        Dmajor = true;
        AspectRatio = true;
        AreaRatio = false;

    case 'EllipseAngle_Dmajor/'

        EllipseAngle = true;
        Dmajor = true;
        AspectRatio = false;
        AreaRatio = false;


    case 'AreaRatio_AspectRatio/'

        EllipseAngle = false;
        Dmajor = false;
        AspectRatio = true;
        AreaRatio = true;        

    case 'Dmajor_AreaRatio/'

        EllipseAngle = false;
        Dmajor = true;
        AspectRatio = false;
        AreaRatio = true;

    case 'EllipseAngle_AreaRatio/'

        EllipseAngle = true;
        Dmajor = false;
        AspectRatio = false;
        AreaRatio = true;

end

plot_ellipse_joint(m.(fnames{ff}),'save_fig',true,'outdir',out_temp,'habit',habit{hh},'EllipseAngle',EllipseAngle,'Dmajor',Dmajor,'AspectRatio',AspectRatio,'AreaRatio',AreaRatio,'Temp_max',Tc_max(tt),'Temp_min',Tc_min(tt),'show_fig',false);

end

if habit_fraction

plot_habit_fractions(m.(fnames{ff}),'save_fig',true,'outdir','/localdata/edunnavan/P3_probe_data/IMPACTS/Figures/Habit_Fractions/','show_fig',false);
end


end

end

end

end

toc