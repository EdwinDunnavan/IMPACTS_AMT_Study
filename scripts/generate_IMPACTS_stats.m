
% generate_IMPACTS_figures.m

habit_fraction = false;
joint_dist = true;

load_data = true;

%outdir = '/localdata/edunnavan/P3_probe_data/IMPACTS/Figures/Joint_Distributions/AreaRatio_AspectRatio/Below_0C/';

outdir = '/localdata/edunnavan/P3_probe_data/IMPACTS/Figures/Histograms/';

%outdir_joint = {'AspectRatio_EllipseAngle/'};

outdir_ranges = {'Below_neg_10C/','Below_neg_5C/','Below_0C/','Between_neg_5C_neg_10C/','Between_0C_neg_5C/'};

dates_2020 = {'20200118','20200125','20200201','20200205','20200207','20200213'...
         '20200218','20200220'};
dates_2022 ={'20220208','20220213','20220217','20220219','20220225'};
dates_2023 = {'20230113','20230115','20230119','20230123','20230125','20230129',...
              '20230205','20230209','20230212','20230214','20230216','20230223','20230228'};

dates = [dates_2020,dates_2022,dates_2023];

Tc_max = [-10 -5 0 -5 0];
Tc_min = [-9999 -9999 -9999 -10 -5];

habit = {'all','i','d','h','g','l','a','o','s'};
habit_names = {'All','Irregular','Dendrite','Hexagonal','Graupel','Linear','Aggregate','Oriented','Sphere'};

probe_type = '2DS';

if load_data

m = struct;

for ff = 1 : length(dates)

    fprintf('Processing case %i out of %i\n',ff,length(dates))

    m.(strcat('f',dates{ff})) =  read_impacts_ellipse(dates{ff},probe_type,'entire_in');



end

end

%% Plot/Save Figures
fnames = fieldnames(m);

tic

for tt = 1 : length(Tc_max)

for hh = 1 : length(habit_names)

fprintf('Joint Distribution = %s |T range = %s | Plotting Distributions for habit %s\n',outdir_joint{dd},outdir_ranges{tt},habit_names{hh})

for ff = 1 : length(dates)


    fprintf('Saving figure for date %s | %i out of %i\n',dates{ff},ff,length(dates))

    out_temp = strcat(outdir,outdir_joint{dd},outdir_ranges{tt},habit_names{hh},'/');


%plot_ellipse_joint(m.(fnames{ff}),'save_fig',true,'outdir','/localdata/edunnavan/P3_probe_data/IMPACTS/Figures/Joint_Distributions/Between_0C_neg_5C/','habit',habit,'Temp_max',Tc_max,'Temp_min',Tc_min,'show_fig',false);

out_temp = strcat(outdir,outdir_joint{dd},outdir_ranges{tt},habit_names{hh},'/');


plot_ellipse_stats(m.(fnames{ff}),'save_fig',true,'outdir',out_temp,'habit',habit{hh},'Temp_max',Tc_max(tt),'Temp_min',Tc_min(tt),'show_fig',false);






end

end

end

toc