function plot_habit_fraction_timeseries(mtot,varargin)

save_fig = false;
visible = 'on';
outdir = pwd;

for nn = 1 : length(varargin)

switch varargin{nn}

    case 'save_fig'

        save_fig = varargin{nn+1};

    case 'outdir'

        outdir = varargin{nn+1};


    case 'show_fig'

        show_fig = varargin{nn+1};

        if ~show_fig

            visible = 'off';

        end


end

end

fig = figure('units','normalized','position',[0.0615    0.0056    0.5766    0.8713],'visible',visible); 

ax = tight_subplot(6,5,[0.07 0.04],[0.055 0.03],[0.06 0.005]);

fnames = fieldnames(mtot);

%fracnames = {'irregularFrac','dendriteFrac','hexagonalFrac',...
%             'aggregateFrac','graupelFrac','linearFrac',...
%             'orientedFrac','sphereFrac','tinyFrac','CFrac','MFrac'};

fracnames = {'irregularFrac','dendriteFrac','hexagonalFrac',...
             'aggregateFrac','graupelFrac','linearFrac',...
             'orientedFrac','sphereFrac'};

%fracnames = {'irregularFrac','dendriteFrac','hexagonalFrac',...
%             'linearFrac','graupelFrac','aggregateFrac',...
%             'orientedFrac','sphereFrac'};


%new_names = erase(fracnames,'Frac');

new_names = replace(fracnames,'Frac','$\hspace{5mm}\vspace{4mm}$');

%new_names{end+1} = '';

cmap= [0 0 0; 0.3 0.5 0.9; 0.1 0.8 0.8; 0.4 1.0 0.4;...
       0.5 0 0; 1 0.6 0.2; 0.9 0.2 0; 0.5 0 0]';

hcolors = turbo(length(fracnames));

hcolors(1,:) = [0 0 0];

part_ex = cell(1,length(fnames));
habit_ex = cell(1,length(fnames));
label_ex = cell(1,length(fnames));
height_ex = cell(1,length(fnames));

%20200118
part_ex{1} = [datetime(2020,1,18,18,55,10),datetime(2020,1,18,21,53,25)];
habit_ex{1} = [2,6];
label_ex{1} = ["1.","2."];
height_ex{1} = [0.4,0.1];

%20200125
part_ex{2} = [datetime(2020,1,25,20,38,0),datetime(2020,1,25,21,13,5,0)];
habit_ex{2} = [6,6];
label_ex{2} = ["3.","4."];
height_ex{2} = [0.4,0.35];

%20200201
part_ex{3} = [datetime(2020,2,1,12,43,5,10),datetime(2020,2,1,13,38,5)];
habit_ex{3} = [6,8];
label_ex{3} = ["5.","6."];
height_ex{3} = [0.35,0.1];

% 20200205
part_ex{4} = [datetime(2020,2,5,22,0,45,0),datetime(2020,2,6,0,32,10)];
habit_ex{4} = [6,1];
label_ex{4} = ["7.","8."];
height_ex{4} = [0.45,0.4];

% 20200207
part_ex{5} = [datetime(2020,2,7,15,10,30,0),datetime(2020,2,7,16,14,5),datetime(2020,2,7,17,29,35)];
habit_ex{5} = [1,6,2];
label_ex{5} = ["9.","10.","11."];
height_ex{5} = [0.35,0.3,0.3];

%20200213
part_ex{6} = [datetime(2020,2,13,7,11,15),datetime(2020,2,13,8,56,50)];
habit_ex{6} = [1,6];
label_ex{6} = ["12.","13."];
height_ex{6} = [0.35,0.3];

%20200218
part_ex{7} = [datetime(2020,2,18,18,43,15),datetime(2020,2,18,20,0,20)];
habit_ex{7} = [1,1];
label_ex{7} = ["14.","15."];
height_ex{7} = [0.35,0.3];

%20200220
part_ex{8} = [datetime(2020,2,20,20,23,5),datetime(2020,2,20,21,48,30)];
habit_ex{8} = [1,3];
label_ex{8} = ["16.","17."];
height_ex{8} = [0.35,0.3];

%20220208
part_ex{9} = [datetime(2022,2,8,14,23,20),datetime(2022,2,8,15,37,10)];
habit_ex{9} = [6,2];
label_ex{9} = ["18.","19."];
height_ex{9} = [0.3,0.3];

%20220213
part_ex{10} = [datetime(2022,2,13,14,26,45)];
habit_ex{10} = [4];
label_ex{10} = ["20."];
height_ex{10} = [0.3];

%20220217
part_ex{11} = [datetime(2022,2,17,17,26,30),datetime(2022,2,17,19,54,30)];
habit_ex{11} = [1,3];
label_ex{11} = ["21.","22."];
height_ex{11} = [0.3,0.3];

%20220219
part_ex{12} = [datetime(2022,2,19,13,53,50),datetime(2022,2,19,17,53,50)];
habit_ex{12} = [1,5];
label_ex{12} = ["23.","24."];
height_ex{12} = [0.3,0.3];

%20220225
part_ex{13} = [datetime(2022,2,25,15,40,25),datetime(2022,2,25,16,48,20)];
habit_ex{13} = [6,5];
label_ex{13} = ["25.","26."];
height_ex{13} = [0.3,0.3];

%20230113
part_ex{14} = [datetime(2023,1,13,6,11,10),datetime(2023,1,13,8,26,10)];
habit_ex{14} = [1,6];
label_ex{14} = ["27.","28."];
height_ex{14} = [0.3,0.3];

%20230115
part_ex{15} = [datetime(2023,1,15,16,9,25),datetime(2023,1,15,16,57,30),datetime(2023,1,15,17,58,50)];
habit_ex{15} = [1,3,6];
label_ex{15} = ["29.","30.","31."];
height_ex{15} = [0.35,0.3,0.35];

%20230119
part_ex{16} = [datetime(2023,1,19,22,10,30),datetime(2023,1,19,23,46,20),datetime(2023,1,20,2,38,30)];
habit_ex{16} = [2,6,2];
label_ex{16} = ["32.","33.","34."];
height_ex{16} = [0.3,0.3,0.3];

%20230123
part_ex{17} = [datetime(2023,1,23,14,1,50),datetime(2023,1,23,15,29,50),datetime(2023,1,23,17,9,40)];
habit_ex{17} = [2,6,6];
label_ex{17} = ["35.","36.","37."];
height_ex{17} = [0.3,0.3,0.3];

%20230125
part_ex{18} = [datetime(2023,1,25,21,38,35),datetime(2023,1,25,22,4,15)];
habit_ex{18} = [2,6];
label_ex{18} = ["38.","39."];
height_ex{18} = [0.3,0.15];

%20230129
part_ex{19} = [datetime(2023,1,29,14,12,30),datetime(2023,1,29,16,34,10)];
habit_ex{19} = [1,1];
label_ex{19} = ["40.","41."];
height_ex{19} = [0.3,0.3];

%20230205
part_ex{20} = [datetime(2023,2,5,14,36,25),datetime(2023,2,5,17,9,10),datetime(2023,2,5,19,9,10)];
habit_ex{20} = [1,1,1];
label_ex{20} = ["42.","43.","44."];
height_ex{20} = [0.3,0.3,0.3];

%20230209
part_ex{21} = [datetime(2023,2,9,19,41,45),datetime(2023,2,9,20,29,5)];
habit_ex{21} = [3,6];
label_ex{21} = ["45.","46."];
height_ex{21} = [0.3,0.3];

%20230212
part_ex{22} = [datetime(2023,2,12,14,46,5),datetime(2023,2,12,17,11,10)];
habit_ex{22} = [6,6];
label_ex{22} = ["47.","48."];
height_ex{22} = [0.35,0.3];

%20230214
part_ex{23} = [datetime(2023,2,15,1,44,10)];
habit_ex{23} = [6];
label_ex{23} = ["49."];
height_ex{23} = [0.3];

%20230216
part_ex{24} = [datetime(2023,2,16,19,21,0),datetime(2023,2,16,21,38,5)];
habit_ex{24} = [6,1];
label_ex{24} = ["50.","51."];
height_ex{24} = [0.3,0.3];

%20230223
part_ex{25} = [datetime(2023,2,23,15,26,10),datetime(2023,2,23,16,31,35)];
habit_ex{25} = [2,3];
label_ex{25} = ["52.","53."];
height_ex{25} = [0.3,0.3];

part_ex{26} = [datetime(2023,2,28,10,24,35)];
habit_ex{26} = [1];
label_ex{26} = ["54."];
height_ex{26} = [0.3];

%hcolors= cmap;

for mm = 1 : 30

    ax2 = ax(mm);

    if mm>26

        delete(ax2)
        continue

    end


    m = mtot.(fnames{mm});

    hold(ax2,'on')


Nt = m.TwoDS.V.Nt;

Nt(Nt==0.)= NaN;

Nt = movmean(Nt,600,'omitnan');

ind_Nt = (Nt>1);

Time_Nt = m.TwoDS.V.Time(ind_Nt);

Time_min_Nt = min(Time_Nt);
Time_max_Nt = max(Time_Nt);


Air_Temp = movmean(fillmissing(m.P3.Static_Air_Temp,'nearest'),1200);


Height_P3 = filloutliers(m.P3.Alt_MSL,'nearest','movmedian',200);

ind = (Height_P3./1000>=0.5);

htype = zeros(size(Air_Temp));

htype(Air_Temp<=-18.) = 1; % Irregular
htype((Air_Temp>-18) & (Air_Temp<=-12)) = 2; % Dendrites
htype((Air_Temp>-12) & (Air_Temp<=-8)) = 3; % Hexagonal
htype((Air_Temp>-8) & (Air_Temp<=-3)) = 6; % Linear
htype((Air_Temp>-3) & (Air_Temp<=0)) = 4; % Aggregate
htype(Air_Temp>0) = 8; % Sphere

Htrans = find(ischange(htype)==1)';

Htrans = unique([1 Htrans length(Air_Temp)]);



for ff = 1:length(fracnames)
plot(ax2,m.V.time_bins,m.V.(fracnames{ff}),'linewidth',2);
end

%grid(ax2,'on')
%colororder(ax2,turbo(length(fracnames)))

colororder(ax2,hcolors)

Time_V_min = m.V.time_bins(1);
Time_V_max = m.V.time_bins(end);

Time_P3_min = min(m.P3.Time(ind));
Time_P3_max = max(m.P3.Time(ind));

Time_min = max(Time_min_Nt,Time_P3_min);
Time_max = min(Time_max_Nt,Time_P3_max);

set(ax2,'box','on')

Time_1 = dateshift(Time_min,'start','hours');
Time_2 = dateshift(Time_max,'end','hours');

xt = Time_1:hours(1):Time_2;

%pause(0.01) % Needed for another bug fix.
% Plot temperature timeseries
% yyaxis(ax2,'right');
% plot(ax2,m.P3.Time,m.P3.Static_Air_Temp,'k:','linewidth',2)

% ylim(ax2,[-30 10])



%colororder(ax2,[turbo(length(fracnames));[0,0,0]])


%colororder(ax2,[hcolors;[0,0,0]])

%colororder()


%ylabel(ax2,'Temperature (Celsius)','interpreter','latex','fontsize',32,'rotation',270,'verticalalignment','bottom')


% if (mm==5 || mm ==10 || mm==20 || mm==25 || mm==30)
% 
%    % set(ax2,'yticklabel',{'$-40^{\circ}$','$-20^{\circ}$','$0^{\circ}$','$20^{\circ}$'},'ticklabelinterpreter','latex','fontsize',12)
% 
%      set(ax2,'ytick',-30:5:10,'yticklabel',{'$-30^{\circ}$','$-25^{\circ}$','$-20^{\circ}$', ...
%      '$-15^{\circ}$','$-10^{\circ}$','$-5^{\circ}$','$0^{\circ}$','$5^{\circ}$',...
%      '$10^{\circ}$'},'ycolor','k')
% 
% 
% else
% 
%     set(ax2,'ytick',-30:5:10,'yticklabel','')
% 
% end

if (mm>21)

xlabel(ax2,'Time (UTC)','interpreter','latex','fontsize',12)

end

%% Make filled time periods of habit type

for tt = 1 : length(Htrans)-1

    ind_temp = htype(Htrans(tt));
    if ind_temp==0
        continue
    end

    color_ind = hcolors(htype(Htrans(tt)),:);

    area(ax2,[m.P3.Time(Htrans(tt)) m.P3.Time(Htrans(tt+1))],[2 2],'FaceColor',color_ind,'EdgeColor','none','FaceAlpha',0.35,'linestyle','none');


end


if length(xt)>6

    xt = Time_1:hours(2):Time_2;

end

set(ax2,'ticklabelinterpreter','latex','fontsize',14,'xtick',xt,'xticklabel',xt.Hour, ...
    'linewidth',1.4,'ticklength',[0.025 0.05])

xlim(ax2,[Time_1 Time_2]);

if (mm==1 || mm==6 || mm==11 || mm == 16 || mm==21 || mm ==26)

%set(ax2,'ytick',0:0.2:1.0,'yticklabel',{'0','0.2','0.4','0.6','0.8','1.0'})
set(ax2,'ytick',[0.01 0.05 0.25 1],'yticklabel',{'0.01','0.05','0.25','1.0'})

ylabel(ax2,'Habit Fraction','interpreter','latex','fontsize',12)

else

%set(ax2,'ytick',0:0.2:1.0,'yticklabel','')
set(ax2,'ytick',[0.01 0.05 0.25 1],'yticklabel','')

end

if (mm==26)

leg = legend(ax2,new_names,'location','none','orientation','horizontal','Interpreter','latex','fontsize',16,'Color','none','EdgeColor','none');

set(leg,'units','normalized','position',[0.26 0.07 0.75 0.06],'NumColumns',4,'fontsize',22)

set(findobj(leg,'type','text'),'HorizontalAlignment','center')

%set(leg,'units','normalized','ItemTokenSize',[30 30])


leg.AutoUpdate = false;


end

xlim(ax2,[Time_min Time_max])

set(ax2,'yscale','log','yminorgrid','off','xminortick','off','layer','top')

ylim(ax2,[0.01 2])

title(ax2,fnames{mm}(2:end),'interpreter','latex','fontsize',18)

for ff = 1 : length(part_ex{mm})

    part_temp = part_ex{mm};
    label_temp = label_ex{mm};
    habit_temp =  habit_ex{mm};
    height_temp = height_ex{mm};

    for tt = 1 : length(part_temp)
    text(ax2,part_temp(tt),height_temp(tt),label_temp(tt),'color',hcolors(habit_temp(tt),:),...
        'Margin',0.01,'fontsize',14,'interpreter','latex','horizontalalignment','center')
    
    %annotation('textbox',part_temp(tt),height_temp(tt),'String',label_temp(tt),'units','data','fitboxtotext','on')
    
    end

end

hold(ax2,'off')




end




%% If saving figure
if save_fig
pdf_print(strcat(outdir,'IMPACTS_2DS_',string(m.H.time(1),'yMMdd'),'_hfrac_temp'),'-dpdf')
close(fig)
end



end
