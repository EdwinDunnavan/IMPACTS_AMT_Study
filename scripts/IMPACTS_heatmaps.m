
%% IMPACTS_boxchart.m

%% Set up paths based on Github Parent location
paths = get_project_paths();

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

% For heatmaps
T1 = [-18,-12,-8,-3,0];
T2 = [-70,-18,-12,-8,-3];

fnames = fieldnames(m);

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

%% Plot habit heatmap
layers = {'PCGL','DGL','PGL','NGL','AGG'};

%habitV_new = habitV;

habitV_new = squeeze(sum(habitV,3,'omitnan')); % Add up for all cases

habitV_new(habitV_new==0) = NaN;

habitV_total = sum(habitV_new,1,'omitnan'); % Add up for all temp levels

habitH_new = squeeze(sum(habitH,3,'omitnan'));

habitH_new(habitH_new==0) = NaN;

habitH_total = sum(habitH_new,1,'omitnan');

fig_hm = figure('units','normalized','position',[0.0344    0.2417    0.7240    0.5657]); 

cat_grid = 1:8;
layer_grid = 1:5;

cat_grid_box = 0.5:1:8.5;
layer_grid_box = 0.5:1:5.5;

%ngrid = ndgrid(1:5,1:8);

im2 = imagesc(habitV_new./sum(habitV_new,1,'omitnan')); % Sum all temperature regions.
cbar = colorbar; 
colormap(flipud(pink(12)))

set(cbar,'ticklabelinterpreter','latex','linewidth',1.4)
ylabel(cbar,'Fraction of Habit Category','interpreter','latex','fontsize',22,'rotation',270,'verticalalignment','bottom')

clear gca

set(gca,'xtick',1:1:8,'xticklabel',string(habit_cats))
set(gca,'ytick',1:1:5,'yticklabel',layers);

set(gca,'TickLength',[0 0])
set(gca,'ticklabelinterpreter','latex','fontsize',20)

clim(gca,[0 0.6])


% Add horizontal grid boxe lines
for ii = 1 : length(layer_grid_box)

    hold on; 
    plot([cat_grid_box(1) cat_grid_box(end)],[layer_grid_box(ii) layer_grid_box(ii)],'k');

end

% Add vertical grid box lines
for jj = 1 : length(cat_grid_box)
hold on;
plot([cat_grid_box(jj) cat_grid_box(jj)],[layer_grid_box(1) layer_grid_box(end)],'k');


end



for ii = 1 : 5
    for jj = 1 : 8

        ctemp = im2.CData(ii,jj);

        if ctemp<0.5

            ctog = 0;

        else
            ctog = 1;

        end

        text(gca,cat_grid(jj),layer_grid(ii),string(addComma(int32(habitV_new(ii,jj)))),...
            'VerticalAlignment','middle','HorizontalAlignment','center',...
            'Interpreter','latex','fontsize',20,'Color',ctog.*[1 1 1])


    end
end


title(gca,'Vertical','interpreter','latex','fontsize',42)


set(gca,'XAxisLocation','top');

    for jj = 1 : 8

        text(gca,cat_grid(jj),5.8,string(addComma(int32(habitV_total(jj)))),...
            'VerticalAlignment','middle','HorizontalAlignment','center',...
            'Interpreter','latex','fontsize',20,'Color','k')


    end


%% Horizontal habit heatmap

fig_hm = figure('units','normalized','position',[0.0344    0.2417    0.7240    0.5657]); 

cat_grid = 1:8;
layer_grid = 1:5;

cat_grid_box = 0.5:1:8.5;
layer_grid_box = 0.5:1:5.5;

im2 = imagesc(habitH_new./sum(habitH_new,1,'omitnan'));
cbar = colorbar; 
colormap(flipud(pink(12)))


set(cbar,'ticklabelinterpreter','latex','linewidth',1.4)
ylabel(cbar,'Fraction of Habit Category','interpreter','latex','fontsize',22,'rotation',270,'verticalalignment','bottom')


clear gca

set(gca,'xtick',1:1:8,'xticklabel',string(habit_cats))
set(gca,'ytick',1:1:5,'yticklabel',layers);

set(gca,'TickLength',[0 0])

set(gca,'ticklabelinterpreter','latex','fontsize',20)

% Add horizontal grid boxe lines
for ii = 1 : length(layer_grid_box)

    hold on; 
    plot([cat_grid_box(1) cat_grid_box(end)],[layer_grid_box(ii) layer_grid_box(ii)],'k');

end

% Add vertical grid box lines
for jj = 1 : length(cat_grid_box)
hold on;
plot([cat_grid_box(jj) cat_grid_box(jj)],[layer_grid_box(1) layer_grid_box(end)],'k');


end

clim(gca,[0 0.6])

for ii = 1 : 5
    for jj = 1 : 8

        ctemp = im2.CData(ii,jj);

        if ctemp<0.5

            ctog = 0;

        else
            ctog = 1;

        end

        text(gca,cat_grid(jj),layer_grid(ii),string(addComma(int32(habitH_new(ii,jj)))),...
            'VerticalAlignment','middle','HorizontalAlignment','center',...
            'Interpreter','latex','fontsize',20,'Color',ctog.*[1 1 1])


    end
end


title(gca,'Horizontal','interpreter','latex','fontsize',42)

set(gca,'XAxisLocation','top');

    for jj = 1 : 8

        text(gca,cat_grid(jj),5.8,string(addComma(int32(habitH_total(jj)))),...
            'VerticalAlignment','middle','HorizontalAlignment','center',...
            'Interpreter','latex','fontsize',20,'Color','k')


    end
