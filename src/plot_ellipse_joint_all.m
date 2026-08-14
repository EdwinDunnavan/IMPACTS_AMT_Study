function m = plot_ellipse_joint_all(mtot,outdir)


% Default options

habit = 'all';

fexten = '2020_ROT_TEST1';

outdir_full = strcat(outdir,fexten);

if ~isfolder(outdir_full)

    mkdir(outdir_full)

end

%outdir = pwd;
Tc_max = -3;
Tc_min = -8;

m = struct();

fnames = fieldnames(mtot); 

m.H.Temp = [];
m.V.Temp = [];

m.H.habit = [];
m.V.habit = [];

m.H.AR = [];
m.V.AR = [];

m.H.EllipAng = [];
m.V.EllipAng = [];

m.H.area_ratio = [];
m.V.area_ratio = [];

m.H.Dmajor = [];
m.V.Dmajor = [];

%for mm = 1 : length(fnames)
for mm = 1 : 8 % 2020
% for mm = 9 : 13 % 2022
% for mm = 14 : length(fnames) % 2023
%for mm = 9 : length(fnames) % 2022-2023

mtemp = mtot.(fnames{mm});

m.H.habit = [m.H.habit mtemp.H.habit];
m.V.habit = [m.V.habit mtemp.V.habit];

m.H.Dmajor = [m.H.Dmajor mtemp.H.Dmajor];
m.V.Dmajor = [m.V.Dmajor mtemp.V.Dmajor];

m.H.Temp = [m.H.Temp mtemp.H.Temp];
m.V.Temp = [m.V.Temp mtemp.V.Temp];

m.H.AR = [m.H.AR mtemp.H.AR];
m.V.AR = [m.V.AR mtemp.V.AR];

m.H.EllipAng = [m.H.EllipAng mtemp.H.EllipAng];
m.V.EllipAng = [m.V.EllipAng mtemp.V.EllipAng];

m.H.area_ratio = [m.H.area_ratio mtemp.H.area_ratio];
m.V.area_ratio = [m.V.area_ratio mtemp.V.area_ratio];

end

%% Plot Aspect Ratio / Ellipse Angle
[fig,~] = plot_ellipse_joint(m,'save_fig',false,'Temp_max',Tc_max,'Temp_min',Tc_min,'habit',habit,...
            'Dmajor',false,'AspectRatio',true,'EllipseAngle',true,'AreaRatio',false);

pdf_print(strcat(outdir_full,'/IMPACTS_2DS_','AspectRatio_EllipseAngle_',fexten),'-dpdf')
close(fig)

return


%% Plot Dmajor / Aspect Ratio
[fig,~] = plot_ellipse_joint(m,'save_fig',false,'Temp_max',Tc_max,'Temp_min',Tc_min,'habit',habit,...
            'Dmajor',true,'AspectRatio',true,'EllipseAngle',false,'AreaRatio',false);

pdf_print(strcat(outdir_full,'/IMPACTS_2DS_','Dmajor_AspectRatio_',fexten),'-dpdf')
close(fig)

%% Plot Dmajor / Ellipse Angle
[fig,~] = plot_ellipse_joint(m,'save_fig',false,'Temp_max',Tc_max,'Temp_min',Tc_min,'habit',habit,...
            'Dmajor',true,'AspectRatio',false,'EllipseAngle',true,'AreaRatio',false);

pdf_print(strcat(outdir_full,'/IMPACTS_2DS_','Dmajor_EllipseAngle_',fexten),'-dpdf')
close(fig)

%% Plot Dmajor / Area Ratio
[fig,~] = plot_ellipse_joint(m,'save_fig',false,'Temp_max',Tc_max,'Temp_min',Tc_min,'habit',habit,...
            'Dmajor',true,'AspectRatio',false,'EllipseAngle',false,'AreaRatio',true);

pdf_print(strcat(outdir_full,'/IMPACTS_2DS_','Dmajor_AreaRatio_',fexten),'-dpdf')
close(fig)

%% Plot Area Ratio / Aspect Ratio
[fig,~] = plot_ellipse_joint(m,'save_fig',false,'Temp_max',Tc_max,'Temp_min',Tc_min,'habit',habit,...
            'Dmajor',false,'AspectRatio',true,'EllipseAngle',false,'AreaRatio',true);

pdf_print(strcat(outdir_full,'/IMPACTS_2DS_','AreaRatio_AspectRatio_',fexten),'-dpdf')
close(fig)

%% Plot Ellipse Angle / Area Ratio
[fig,~] = plot_ellipse_joint(m,'save_fig',false,'Temp_max',Tc_max,'Temp_min',Tc_min,'habit',habit,...
            'Dmajor',false,'AspectRatio',false,'EllipseAngle',true,'AreaRatio',true);

pdf_print(strcat(outdir_full,'/IMPACTS_2DS_','EllipseAngle_AreaRatio',fexten),'-dpdf')
close(fig)

end