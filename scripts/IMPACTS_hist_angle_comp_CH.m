% histogram_IMPACTS_angle_comp.m

paths = get_project_paths();

if ~exist('m','var')
load(paths.ellipse_file,'-mat')
end

DataDir = paths.data;

bins = -90:5:90;

Tmin = -8;
Tmax = -3;

ARmin = 0.;
ARmax = 0.4;

Dmin = 0.8;
Dmax = 1.6;

AreaRatio_min = 0.6;
AreaRatio_max = 0.8;

dbin = bins(2)-bins(1);

%m = load(fullfile(DataDir,'IMPACTS_EllipseFits_2020_2023.mat'),'-mat');

%m = load('C:\\Users\\edwin.dunnavan\\Documents\\IMPACTS\\Cases\\IMPACTS_2020_2023_ellipse_data.mat');

% load CH data 4k
 %m_CH = load('C:\\Users\\edwin.dunnavan\\Documents\\IMPACTS\\Cases\\CH_2DS_simulations_4k.mat','-mat','m_CH');
  %m_CH = load('C:\\Users\\edwin.dunnavan\\Documents\\IMPACTS\\Cases\\CH_2DS_simulations_4k_newcoords.mat','-mat','m_CH');
 m_CH = load(fullfile(DataDir,'CH_2DS_simulations_4k_newcoords.mat'),'-mat');

 m_CH = m_CH.m_CH;

% OLD data 1k
%m_CH = load('C:\\Users\\edwin.dunnavan\\Documents\\IMPACTS\\Cases\\CH_2DS_simulations.mat','-mat');
%m_CH = m_CH.m_CF;

cen_2020 = [542.1149,526.0741,114.2066];
cen_2023 = [543.8514,525.6625,111.3101];

y_H_2020 = m_CH.H.IMPACTS_2020.y;
y_H_2023 = m_CH.H.IMPACTS_2023.y;

z_V_2020 = m_CH.V.IMPACTS_2020.z;
z_V_2023 = m_CH.V.IMPACTS_2023.z;

%% Read data
% 2DS 2020 dates
 dates_2020 = {'20200118','20200125','20200201','20200205','20200207','20200213'...
         '20200218','20200220'};

% 2DS 2022 dates
dates_2022 ={'20220208','20220213','20220217','20220219','20220225'};


% 2023 dates
dates_2023 = {'20230113','20230115','20230119','20230123','20230125','20230129',...
              '20230205','20230209','20230212','20230214','20230216','20230223','20230228'};


dates = [dates_2020, dates_2022, dates_2023];

%norm = 'pdf';

norm = 'probability';

%%
columns_2020_H = zeros(1,length(bins)-1);
columns_2020_V = zeros(1,length(bins)-1);

columns_2023_H = zeros(1,length(bins)-1);
columns_2023_V = zeros(1,length(bins)-1);

for ff = 1 : length(dates_2020)

    fdate_temp = strcat("f",dates_2020{ff});

    D_H_cond =  (m.(fdate_temp).H.Dmajor>=Dmin)&(m.(fdate_temp).H.Dmajor<=Dmax);
    D_V_cond =  (m.(fdate_temp).V.Dmajor>=Dmin)&(m.(fdate_temp).V.Dmajor<=Dmax);

    AR_H_cond = (m.(fdate_temp).H.AR>=ARmin)&(m.(fdate_temp).H.AR<=ARmax);
    AR_V_cond = (m.(fdate_temp).V.AR>=ARmin)&(m.(fdate_temp).V.AR<=ARmax);

    ARatio_H_cond =  ((m.(fdate_temp).H.area_ratio>=AreaRatio_min)&((m.(fdate_temp).H.area_ratio<=AreaRatio_max)));
    ARatio_V_cond =  ((m.(fdate_temp).V.area_ratio>=0.6)&((m.(fdate_temp).V.area_ratio<=0.8)));

    habit_H_cond = (m.(fdate_temp).H.habit=='l');
    habit_V_cond = (m.(fdate_temp).V.habit=='l');

    temp_H_cond = ((m.(fdate_temp).H.Temp>Tmin) & (m.(fdate_temp).H.Temp<=Tmax));
    temp_V_cond = ((m.(fdate_temp).V.Temp>Tmin) & (m.(fdate_temp).V.Temp<=Tmax));

    total_H_cond = AR_H_cond&temp_H_cond&ARatio_H_cond&D_H_cond;
    total_V_cond = AR_V_cond&temp_V_cond&ARatio_V_cond&D_V_cond;

    columns_2020_H = columns_2020_H + histcounts(m.(fdate_temp).H.EllipAng(total_H_cond),bins);
    columns_2020_V = columns_2020_V + histcounts(m.(fdate_temp).V.EllipAng(total_V_cond),bins);

end


for ff = 1 : length(dates_2023)

    fdate_temp = strcat("f",dates_2023{ff});

    D_H_cond =  (m.(fdate_temp).H.Dmajor>=Dmin)&(m.(fdate_temp).H.Dmajor<=Dmax);
    D_V_cond =  (m.(fdate_temp).V.Dmajor>=Dmin)&(m.(fdate_temp).V.Dmajor<=Dmax);

    AR_H_cond = (m.(fdate_temp).H.AR>=ARmin)&(m.(fdate_temp).H.AR<=ARmax);
    AR_V_cond = (m.(fdate_temp).V.AR>=ARmin)&(m.(fdate_temp).V.AR<=ARmax);

    ARatio_H_cond =  ((m.(fdate_temp).H.area_ratio>=AreaRatio_min)&((m.(fdate_temp).H.area_ratio<=AreaRatio_max)));
    ARatio_V_cond =  ((m.(fdate_temp).V.area_ratio>=AreaRatio_min)&((m.(fdate_temp).V.area_ratio<=AreaRatio_max)));

    habit_H_cond = (m.(fdate_temp).H.habit=='l');
    habit_V_cond = (m.(fdate_temp).V.habit=='l');

    temp_H_cond = ((m.(fdate_temp).H.Temp>Tmin) & (m.(fdate_temp).H.Temp<=Tmax));
    temp_V_cond = ((m.(fdate_temp).V.Temp>Tmin) & (m.(fdate_temp).V.Temp<=Tmax));

    total_H_cond = AR_H_cond&temp_H_cond&ARatio_H_cond&D_H_cond;
    total_V_cond = AR_V_cond&temp_V_cond&ARatio_V_cond&D_V_cond;

    columns_2023_H = columns_2023_H + histcounts(m.(fdate_temp).H.EllipAng(total_H_cond),bins);
    columns_2023_V = columns_2023_V + histcounts(m.(fdate_temp).V.EllipAng(total_V_cond),bins);

end

% columns_2020_H = columns_2020_H./(dbin.*sum(columns_2020_H,'omitnan'));
% columns_2020_V = columns_2020_V./(dbin.*sum(columns_2020_V,'omitnan'));
% 
% columns_2023_H = columns_2023_H./(dbin.*sum(columns_2023_H,'omitnan'));
% columns_2023_V = columns_2023_V./(dbin.*sum(columns_2023_V,'omitnan'));

columns_2020_H = columns_2020_H./(sum(columns_2020_H,'omitnan'));
columns_2020_V = columns_2020_V./(sum(columns_2020_V,'omitnan'));

columns_2023_H = columns_2023_H./(sum(columns_2023_H,'omitnan'));
columns_2023_V = columns_2023_V./(sum(columns_2023_V,'omitnan'));


%%
%fig = figure('units','normalized','position',[  0.2000   -0.0017    0.6375    0.9067]);

fig = figure('units','normalized','position',[0.1094    0.0433    0.7401    0.8633]);

% left = H | right = V
% top = 2020 | middle = 2023

ax = tight_subplot(3,2,0.05,[0.08 0.05],[0.07 0.06]);

max_depth = 100;

theta_H_2020 = m_CH.H.IMPACTS_2020.theta;
theta_V_2020 = m_CH.V.IMPACTS_2020.theta;
theta_H_2023 = m_CH.H.IMPACTS_2023.theta;
theta_V_2023 = m_CH.V.IMPACTS_2023.theta;

Y_H_2020 = mean(sind(2.*theta_H_2020));
X_H_2020 =  mean(cosd(2.*theta_H_2020));
R_H_2020 = sqrt(X_H_2020.^2+Y_H_2020.^2);

Y_V_2020 = mean(sind(2.*theta_V_2020));
X_V_2020 =  mean(cosd(2.*theta_V_2020));
R_V_2020 = sqrt(X_V_2020.^2+Y_V_2020.^2);

Y_H_2023 = mean(sind(2.*theta_H_2023));
X_H_2023 =  mean(cosd(2.*theta_H_2023));
R_H_2023 = sqrt(X_H_2023.^2+Y_H_2023.^2);

Y_V_2023 = mean(sind(2.*theta_V_2023));
X_V_2023 =  mean(cosd(2.*theta_V_2023));
R_V_2023 = sqrt(X_V_2023.^2+Y_V_2023.^2);

H_cond_2020 = (y_H_2020<=max_depth)&(y_H_2020>=-max_depth);
H_cond_2023 = (y_H_2023<=max_depth)&(y_H_2023>=-max_depth);

V_cond_2020 = (z_V_2020<=max_depth)&(z_V_2020>=-max_depth);
V_cond_2023 = (z_V_2023<=max_depth)&(z_V_2023>=-max_depth);

mode_theta_H_2020 = 0.5.*atan2d(mode(sind(2.*theta_H_2020)),mode(cosd(2.*theta_H_2020)));
mode_theta_H_2023 =  0.5.*atan2d(mode(sind(2.*theta_H_2023)),mode(cosd(2.*theta_H_2023)));
mode_theta_V_2020 = 0.5.*atan2d(mode(sind(2.*theta_V_2020)),mode(cosd(2.*theta_V_2020)));
mode_theta_V_2023 =  0.5.*atan2d(mode(sind(2.*theta_V_2023)),mode(cosd(2.*theta_V_2023)));

mean_theta_H_2020 = 0.5.*atan2d(mean(sind(2.*theta_H_2020)),mean(cosd(2.*theta_H_2020)));
mean_theta_H_2023 =  0.5.*atan2d(mean(sind(2.*theta_H_2023)),mean(cosd(2.*theta_H_2023)));
mean_theta_V_2020 = 0.5.*atan2d(mean(sind(2.*theta_V_2020)),mean(cosd(2.*theta_V_2020)));
mean_theta_V_2023 =  0.5.*atan2d(mean(sind(2.*theta_V_2023)),mean(cosd(2.*theta_V_2023)));

std_theta_H_2020 = rad2deg(0.5.*sqrt(-2.*log(R_H_2020))); % axial standard deviation in degrees
std_theta_H_2023 =   rad2deg(0.5.*sqrt(-2.*log(R_H_2023)));
std_theta_V_2020 =  rad2deg(0.5.*sqrt(-2.*log(R_V_2020)));
std_theta_V_2023 =   rad2deg(0.5.*sqrt(-2.*log(R_V_2023)));

% OLD
% y_H_2020 = m_CH.H.IMPACTS_2020.y-cen_2020(2);
% y_H_2023 = m_CH.H.IMPACTS_2023.y-cen_2023(2);
% 
% z_V_2020 = -1.*(m_CH.V.IMPACTS_2020.z-cen_2020(3));
% z_V_2023 = -1.*(m_CH.V.IMPACTS_2023.z-cen_2023(3));

corder = colororder();

%histogram(ax(1),m_CH.H.IMPACTS_2020.theta(H_cond_2020),bins,'normalization',norm);
histogram(ax(1),theta_H_2020(H_cond_2020),bins,'normalization',norm);
hold(ax(1),'on')
histogram(ax(1),'BinEdges',bins,'BinCounts',columns_2020_H,'displaystyle','stairs','EdgeColor','k','linewidth',2)
hold(ax(1),'off')

%histogram(ax(2),m_CH.V.IMPACTS_2020.theta(V_cond_2020),bins,'normalization',norm);
histogram(ax(2),theta_V_2020(V_cond_2020),bins,'normalization',norm);
hold(ax(2),'on')
histogram(ax(2),'BinEdges',bins,'BinCounts',columns_2020_V,'displaystyle','stairs','EdgeColor','k','linewidth',2)
histogram(ax(2),'BinEdges',bins,'BinCounts',fliplr(columns_2023_H),'displaystyle','stairs','EdgeColor','b','linewidth',2,'linestyle',':')
hold(ax(2),'off')

%histogram(ax(3),m_CH.H.IMPACTS_2023.theta(H_cond_2023),bins,'normalization',norm,'FaceColor',corder(2,:));
histogram(ax(3),theta_H_2023(H_cond_2023),bins,'normalization',norm,'FaceColor',corder(2,:));
hold(ax(3),'on')
histogram(ax(3),'BinEdges',bins,'BinCounts',columns_2023_H,'displaystyle','stairs','EdgeColor','k','linewidth',2)
histogram(ax(3),'BinEdges',bins,'BinCounts',fliplr(columns_2020_V),'displaystyle','stairs','EdgeColor','b','linewidth',2,'linestyle',':')
hold(ax(3),'off')

%histogram(ax(4),m_CH.V.IMPACTS_2023.theta(V_cond_2023),bins,'normalization',norm,'FaceColor',corder(2,:));
histogram(ax(4),theta_V_2023(V_cond_2023),bins,'normalization',norm,'FaceColor',corder(2,:));
hold(ax(4),'on')
histogram(ax(4),'BinEdges',bins,'BinCounts',columns_2023_V,'displaystyle','stairs','EdgeColor','k','linewidth',2)
hold(ax(4),'off')

%scatter(ax(5),m_CH.H.IMPACTS_2020.theta,y_H_2020,'filled','markeredgecolor','k','linewidth',0.5);
scatter(ax(5),theta_H_2020,y_H_2020,'filled','markeredgecolor','k','linewidth',0.5);
hold(ax(5),'on')
%scatter(ax(5),m_CH.H.IMPACTS_2023.theta,y_H_2023,'filled','markeredgecolor','k','linewidth',0.5);
scatter(ax(5),theta_H_2023,y_H_2023,'filled','markeredgecolor','k','linewidth',0.5);
hold(ax(5),'off')

%scatter(ax(6),m_CH.V.IMPACTS_2020.theta,z_V_2020,'filled','markeredgecolor','k','linewidth',0.5);
scatter(ax(6),theta_V_2020,z_V_2020,'filled','markeredgecolor','k','linewidth',0.5);
hold(ax(6),'on')
%scatter(ax(6),m_CH.V.IMPACTS_2023.theta,z_V_2023,'filled','markeredgecolor','k','linewidth',0.5);
scatter(ax(6),theta_V_2023,z_V_2023,'filled','markeredgecolor','k','linewidth',0.5);
hold(ax(6),'off')

% scatter(ax(5),m_CH.H.IMPACTS_2020.theta,m_CH.H.IMPACTS_2020.y-cen_2020(2),'filled','markeredgecolor','k','linewidth',0.5);
% hold(ax(5),'on')
% scatter(ax(5),m_CH.H.IMPACTS_2023.theta,m_CH.H.IMPACTS_2023.y-cen_2023(2),'filled','markeredgecolor','k','linewidth',0.5);
% hold(ax(5),'off')
% 
% scatter(ax(6),m_CH.V.IMPACTS_2020.theta,-1.*(m_CH.V.IMPACTS_2020.z-cen_2020(3)),'filled','markeredgecolor','k','linewidth',0.5);
% hold(ax(6),'on')
% scatter(ax(6),m_CH.V.IMPACTS_2023.theta,-1.*(m_CH.V.IMPACTS_2023.z-cen_2023(3)),'filled','markeredgecolor','k','linewidth',0.5);
% hold(ax(6),'off')

ylim(ax(5),1.6.*[-1 1])
ylim(ax(6),1.6.*[-1 1])

for ii = 1 : length(ax)
    xlim(ax(ii),[-90 90]);
    grid(ax(ii),'on')
    if ii<=4
        %ylim(ax(ii),[0 0.12])
        ylim(ax(ii),[0 0.6])
        set(ax(ii),'xticklabel','')
        set(ax(ii),'ytick',0:0.1:0.6)

    else

        set(ax(ii),'xticklabel',{'$-90^{\circ}$','$-60^{\circ}$','$-30^{\circ}$','$0^{\circ}$','$30^{\circ}$','$60^{\circ}$','$90^{\circ}$'})
    end
    
    if (ii==2) || (ii==4)

        set(ax(ii),'yticklabel','')

            
    end

    set(ax(ii),'ticklabelinterpreter','latex','fontsize',16)
    set(ax(ii),'xtick',-90:30:90)
   % set(ax(ii),'xticklabel',{'$-90^{\circ}$','$-60^{\circ}$','$-30^{\circ}$','$0^{\circ}$','$30^{\circ}$','$60^{\circ}$','$90^{\circ}$'})
end

title(ax(1),'Horizontal','fontsize',26,'interpreter','latex')
title(ax(2),'Vertical','fontsize',26,'interpreter','latex')

%ylabel(ax(1),'Probability Density','interpreter','latex','FontSize',20)
%ylabel(ax(3),'Probability Density','interpreter','latex','FontSize',20)

ylabel(ax(1),'Frequency','interpreter','latex','FontSize',20)
ylabel(ax(3),'Frequency','interpreter','latex','FontSize',20)

ylabel(ax(5),'y pos. (in.)','interpreter','latex','fontsize',22)
ylabel(ax(6),'z pos. (in.)','interpreter','latex','fontsize',22,'verticalalignment','bottom','rotation',270)

xlabel(ax(5),'Ellipse Angle','Interpreter','latex','fontsize',22)
xlabel(ax(6),'Ellipse Angle','Interpreter','latex','fontsize',22)

set(ax(6),'YAxisLocation','right')

for ii = 1 : length(ax)

    set(ax(ii),'box','on','layer','top','ticklabelinterpreter','latex','fontsize',18,'linewidth',1.4,'ticklength',[0.025 0.05])

end

leg_hist = legend(ax(1),'CFD trajectories','IMPACTS ellipse fits','interpreter','latex','fontsize',18,'location','northeast');
leg_scatt = legend(ax(5),'2020','2023','Location','best','interpreter','latex','fontsize',20);