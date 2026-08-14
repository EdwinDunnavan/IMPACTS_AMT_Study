% process_impacts.m

%%

Temp_thresh = -18;
count_thresh = 20000;

% 2DS 2020 dates
 dates_2020 = {'20200118','20200125','20200201','20200205','20200207','20200213'...
         '20200218','20200220'};

% HVPS3 A/B 2020 dates
%dates_2020 = {'20200207','20200213','20200218','20200220','20200225'};

% 2DS 2022 dates
dates_2022 ={'20220208','20220213','20220217','20220219','20220225'};

% HVPS3 A/B 2022 dates
%dates_2022 = {'20220114','20220129','20220204','20220208','20220213','20220217','20220219','20220225'};

% 2020 dates
%dates_2020 = {'20200118','20200125','20200201','20200205','20200207','20200213'...
%         '20200218','20200220','20200225'};

% 2022 dates
%dates_2022 = {'20220114','20220129','20220204','20220208','20220213','20220217',...
%              '20220219','20220225'};

%dates = {'20200207','20200213','20200218','20200220','20200225'};

% 2023 dates
dates_2023 = {'20230113','20230115','20230119','20230123','20230125','20230129',...
              '20230205','20230209','20230212','20230214','20230216','20230223','20230228'};


% 2DS irregular
dates_irreg = {'20200218','20200205','20200207','20200213','20200218',...
               '20200220','20220208','20220213','20220217','20220219','20220219',...
               '20230113','20230125','20230129','20230205','20230212','20230214','20230216'};

%dates = {'20230115'};

%dates = [dates_2020 dates_2022 dates_2023]; 



%dates = dates_irreg;

%dates = [dates_2020,dates_2022,dates_2023];

%dates = [dates_2022,dates_2023];

dates = [dates_2020, dates_2022, dates_2023];

probe_type = '2DS';

m = struct;

for ff = 1 : length(dates)

    fprintf('Processing case %i out of %i\n',ff,length(dates))

    m.(strcat('f',dates{ff})) =  read_impacts_ellipse(dates{ff},probe_type,'entire_in');

end


%% Make a plot

count_tot = 0;

fig1 = figure; 

[ha,pos] = tight_subplot(2,2,0.05,0.05,0.05);

hold(ha(1),'on')
hold(ha(2),'on')
hold(ha(3),'on')
hold(ha(4),'on')


habit_H_tot = {};
habit_V_tot = {};

dates_H_good = {};
dates_V_good = {};

for ff = 1 : length(dates)

    mtemp = m.(strcat('f',dates{ff}));

    temp_H = mtemp.H.Temp;
    H_cond = (temp_H<=Temp_thresh)&(mtemp.H.habit=='i');
    Time_H = mtemp.H.Time(H_cond);
    EllipAng_H = mtemp.H.EllipAng(H_cond);
    AR_H = mtemp.H.AR(H_cond);
if length(Time_H)<count_thresh

    continue

end

fprintf('Total # H Particles for %s = %i\n',dates{ff},length(Time_H))

count_tot = count_tot+1;

habit_H_tot{count_tot} = mtemp.H.habit(H_cond);
dates_H_good{count_tot} = dates{ff};

%m.(strcat('f',dates{ff})).H.R1 = (cosd(EllipAng_H).^2+AR_H.^2.*sind(EllipAng_H).^2)./(sind(EllipAng_H).^2+AR_H.^2.*cosd(EllipAng_H).^2);
%m.(strcat('f',dates{ff})).H.R2 = sind(2.*EllipAng_H).*((AR_H.^2-1)./(1+AR_H.^2));



%ax1 = subplot(2,2,1);
%hold on;
histogram(ha(1),AR_H,'normalization','pdf','displaystyle','bar');


%ax2 = subplot(2,2,2);
%hold on;
histogram(ha(2),EllipAng_H,'normalization','pdf','displaystyle','stairs');

%subplot(2,2,3);
%hold on;
%histogram(m.(strcat('f',dates{ff})).H.R1,'normalization','pdf','displaystyle','stairs');
%xlim([0 5])

%subplot(2,2,4);
%hold on;
%histogram(m.(strcat('f',dates{ff})).H.R2,'normalization','pdf','displaystyle','stairs');

end

colororder(turbo(count_tot))

count_tot = 0;

%figure; 
for ff = 1 : length(dates)

    mtemp = m.(strcat('f',dates{ff}));

    temp_V = mtemp.V.Temp;
    V_cond = (temp_V<=Temp_thresh)&(mtemp.V.habit=='i');
    Time_V = mtemp.V.Time(V_cond);
    EllipAng_V = mtemp.V.EllipAng(V_cond);
    AR_V = mtemp.V.AR(V_cond);


[m.(strcat('f',dates{ff})).phimean,m.(strcat('f',dates{ff})).thetamean,m.(strcat('f',dates{ff})).H.mean_angle,m.(strcat('f',dates{ff})).V.mean_angle] = ret_angle_3D_proj(EllipAng_H,EllipAng_V);


if length(Time_V)<count_thresh

    continue

end

fprintf('Total # V Particles for %s = %i\n',dates{ff},length(Time_V))

count_tot = count_tot+1;

habit_V_tot{count_tot} = mtemp.V.habit(V_cond);
dates_V_good{count_tot} = dates{ff};

%m.(strcat('f',dates{ff})).V.R1 = (cosd(EllipAng_V).^2+AR_V.^2.*sind(EllipAng_V).^2)./(sind(EllipAng_V).^2+AR_V.^2.*cosd(EllipAng_V).^2);
%m.(strcat('f',dates{ff})).V.R2 = sind(2.*EllipAng_V).*((AR_V.^2-1)./(1+AR_V.^2));

%ax3 = subplot(2,2,3);
%hold on;
histogram(ha(3),AR_V,'normalization','pdf','displaystyle','stairs');

%ax4 = subplot(2,2,4);
%hold on;
histogram(ha(4),EllipAng_V,'normalization','pdf','displaystyle','stairs');

%subplot(2,2,3);
%hold on;
%histogram(m.(strcat('f',dates{ff})).V.R1,'normalization','pdf','displaystyle','stairs');
%xlim([0 5])

%subplot(2,2,4);
%hold on;
%histogram(m.(strcat('f',dates{ff})).V.R2,'normalization','pdf','displaystyle','stairs');

end

%colororder(turbo(count_tot))
legend(ha(1),dates,'location','NorthWest')

% FOR Some reason there is a bug in Matlab2024a where the legend doesn't
% show stair colors. Here is a roundabout fix in the meantime.

for hh = 1 : length(ha(1).Children)

    ha(1).Children(hh).DisplayStyle='stairs';

end


%% Plot Habits

% figure;
% subplot(1,2,1);
% for ff = 1 : length(dates_H_good)
% 
% hold on;
%     histogram(habit_H_tot{ff},'normalization','probability','DisplayStyle','bar');
% 
% end
% colororder(turbo(count_tot))
% 
% subplot(1,2,2);
% hold on;
% for ff = 1 : length(dates_V_good)
% 
% histogram(habit_V_tot{ff},'normalization','probability','DisplayStyle','bar');
% 
% end
