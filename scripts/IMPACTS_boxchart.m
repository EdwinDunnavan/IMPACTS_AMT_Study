
%% IMPACTS_boxchart.m

%% Set up paths based on Github Parent location
paths = init_project();

%% Load Ellipse fit IMPACTS data
if ~exist('m','var')
load(paths.ellipse_file,'-mat')
end

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


%% plot boxchart
T1 = [0.];
T2 = [-70.];

fnames = fieldnames(m);

%Hlabels = [];
%Vlabels = [];

AR = cell(1,length(dates));
EllipAng = cell(1,length(dates));
AreaRatio = cell(1,length(dates));

ARH = cell(1,length(dates));
EllipAngH =  cell(1,length(dates));
AreaRatioH =  cell(1,length(dates));

ARV =  cell(1,length(dates));
EllipAngV =  cell(1,length(dates));
AreaRatioV =  cell(1,length(dates));

habit_names = categorical(cellstr({'s','o','l','a','g','h','i','d'}));

habit_cats = categorical(cellstr({'sphere','oriented','linear','aggregate','graupel','hexagonal','irregular','dendrite'}));

habitH = zeros(length(T1),length(habit_names),length(dates));
habitV = zeros(length(T1),length(habit_names),length(dates));

for tt = 1 : length(T1)

    maxH = 0;
    maxV = 0;
    maxHV = 0 ;

    TindH = cell(1,length(fnames)); 
    TindV = cell(1,length(fnames)); 

for ff = 1 : length(fnames)

    tempH = m.(fnames{ff}).H.Temp;
    tempV = m.(fnames{ff}).V.Temp;

    TindH{ff} = ((tempH>T2(tt))&(tempH<=T1(tt)));
    TindV{ff} = ((tempV>T2(tt))&(tempV<=T1(tt)));

    maxH = max(maxH,sum(TindH{ff}));
    maxV = max(maxV,sum(TindV{ff}));

    maxHV = max(maxHV,max(maxH,maxV));

    habitH(tt,:,ff) = histcounts(m.(fnames{ff}).H.habit(TindH{ff}),habit_names);
    habitV(tt,:,ff) = histcounts(m.(fnames{ff}).V.habit(TindV{ff}),habit_names);
end

for ff = 1 : length(fnames)

ARH_arr = NaN(1,maxHV);
EllipAngH_arr = NaN(1,maxHV);
AreaRatioH_arr = NaN(1,maxHV);

ARV_arr = NaN(1,maxHV);
EllipAngV_arr = NaN(1,maxHV);
AreaRatioV_arr = NaN(1,maxHV);

ARH_temp = m.(fnames{ff}).H.AR(TindH{ff});
EllipAngH_temp = m.(fnames{ff}).H.EllipAng(TindH{ff});
AreaRatioH_temp = m.(fnames{ff}).H.area_ratio(TindH{ff});

ARV_temp = m.(fnames{ff}).V.AR(TindV{ff});
EllipAngV_temp = m.(fnames{ff}).V.EllipAng(TindV{ff});
AreaRatioV_temp = m.(fnames{ff}).V.area_ratio(TindV{ff});

ARH_arr(1:length(ARH_temp)) = ARH_temp;
EllipAngH_arr(1:length(EllipAngH_temp)) = EllipAngH_temp;
AreaRatioH_arr(1:length(AreaRatioH_temp)) = AreaRatioH_temp;

ARV_arr(1:length(ARV_temp)) = ARV_temp;
EllipAngV_arr(1:length(EllipAngV_temp)) = EllipAngV_temp;
AreaRatioV_arr(1:length(AreaRatioV_temp)) = AreaRatioV_temp;

ARH{ff} = ARH_arr';
EllipAngH{ff} = EllipAngH_arr';
AreaRatioH{ff} = AreaRatioH_arr';

ARV{ff} = ARV_arr';
EllipAngV{ff} = EllipAngV_arr';
AreaRatioV{ff} = AreaRatioV_arr';

AR{ff} = [ARH_arr;ARV_arr]';
EllipAng{ff} = [EllipAngH_arr;EllipAngV_arr]';
AreaRatio{ff} = [AreaRatioH_arr;AreaRatioV_arr]';


end


end

%% Plot boxplots

dates_cat = repmat(categorical(reshape([dates;dates],size(dates,1),[])),[maxHV,1]);

AR_arr = cell2mat(AR);
EllipAng_arr = cell2mat(EllipAng);
AreaRatio_arr = cell2mat(AreaRatio);

gnum = ones(size(AR_arr));
gnum(:,1:2:52) = 0;

fs = 18;
fs_title = 26;

%fig = figure('units','normalized','position',[0.0870    0.0250    0.7391    0.8361]); 

fig = figure('units','normalized','position',[0.0734    0.0324    0.7370    0.8556]); 

%ax = tight_subplot(1,3,0.02,[0.025,0.05],[0.07 0.01]);

ax = tight_subplot(1,3,0.02,[0.0325,0.05],[0.08 0.01]);

%ax1 = subplot(1,3,1);
ax1 = ax(1);
ax2 = ax(2);
ax3 = ax(3);

b1 = groupedBoxchart(dates_cat(:),gnum(:),AR_arr(:),'ax',ax1,'Distance',2,'Orientation','horizontal','BoxWidth',1,'MarkerStyle','none');
set(ax1,'ydir','reverse','TickLabelInterpreter','latex','fontsize',fs,'linewidth',1.4)
set(ax1,'xtick',0:0.2:1)
title(ax1,'Ellipse Aspect Ratio','interpreter','latex','fontsize',fs_title)
xlim(ax1,[0,1.05])

%ax2 = subplot(1,3,2);
b2 = groupedBoxchart(dates_cat(:),gnum(:),EllipAng_arr(:),'ax',ax2,'Distance',2,'Orientation','horizontal','BoxWidth',1,'MarkerStyle','none');
set(ax2,'ydir','reverse','TickLabelInterpreter','latex','fontsize',fs,'linewidth',1.4)
set(ax2,'xtick',-90:30:90,'xticklabel',{'-90$^{\circ}$','-60$^{\circ}$','-30$^{\circ}$','0$^{\circ}$', ...
                                         '30$^{\circ}$','60$^{\circ}$','90$^{\circ}$'},'yticklabel','')
xlim(ax2,[-100 100])
title(ax2,'Ellipse Orientation','interpreter','latex','fontsize',fs_title)

%ax3 = subplot(1,3,3);
b3 = groupedBoxchart(dates_cat(:),gnum(:),AreaRatio_arr(:),'ax',ax3,'Distance',2,'Orientation','horizontal','BoxWidth',1,'MarkerStyle','none');
set(ax3,'ydir','reverse','TickLabelInterpreter','latex','fontsize',fs,'linewidth',1.4)
set(ax3,'xtick',0:0.2:1,'yticklabel','')
xlim(ax3,[0,1.05])
title(ax3,'Ellipse Area Ratio','interpreter','latex','fontsize',fs_title)

leg = legend(ax3,'String',{'H','V'},'location','northwest','linewidth',1.4,...
                 'Interpreter','latex','fontsize',36);