
function plot_habit_fractions(m,varargin)

save_fig = false;
visible = 'on';
outdir = pwd;

%temp_ranges = [-80, -18, -12, -8, -3, 0, 40];

htype = zeros(size(m.P3.Static_Air_Temp));

htype(m.P3.Static_Air_Temp<=-18.) = 1; % Irregular
htype((m.P3.Static_Air_Temp>-18) & (m.P3.Static_Air_Temp<=-12)) = 2; % Dendrites
htype((m.P3.Static_Air_Temp>-12) & (m.P3.Static_Air_Temp<=-8)) = 3; % Hexagonal
htype((m.P3.Static_Air_Temp>-8) & (m.P3.Static_Air_Temp<=-3)) = 6; % Linear
htype((m.P3.Static_Air_Temp>-3) & (m.P3.Static_Air_Temp<=0)) = 4; % Aggregate
htype(m.P3.Static_Air_Temp>0) = 8; % Sphere


Htrans = find(ischange(htype)==1)';

Htrans = unique([1 Htrans length(m.P3.Static_Air_Temp)]);



%temp_switch = false;


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

fracnames = {'irregularFrac','dendriteFrac','hexagonalFrac',...
             'aggregateFrac','graupelFrac','linearFrac',...
             'orientedFrac','sphereFrac','tinyFrac','CFrac','MFrac'};

hcolors = turbo(length(fracnames));

fig = figure('units','normalized','position',[0.0599    0.3167    0.8776    0.5231],'visible',visible); 

ax = tight_subplot(1,2,[0.07 0.08],[0.16 0.1],[0.05 0.065]);

%ax1 = subplot(1,2,1);

ax1 = ax(1);
ax2 = ax(2);

hold(ax1,'on');
for ff = 1:length(fracnames)
plot(ax1,m.H.time_bins,m.H.(fracnames{ff}),'linewidth',2);
end

set(ax1,'ticklabelinterpreter','latex','fontsize',18,'layer','top','linewidth',1.4)
ylabel(ax1,'Habit Fraction','interpreter','latex','fontsize',32)
title(ax1,'Horizontal','Interpreter','latex','fontsize',32)
%legend(erase(fracnames,'Frac'),'location','best','Interpreter','latex','fontsize',14)
%set(gca,'position',[0.05    0.1255    0.44    0.7500])
grid(ax1,'on')
colororder(ax1,turbo(length(fracnames)))
ylim(ax1,[0 1])


%ax2=subplot(1,2,2);
%hold on;
hold(ax2,'on')
for ff = 1:length(fracnames)
plot(ax2,m.V.time_bins,m.V.(fracnames{ff}),'linewidth',2);
end
set(ax2,'ticklabelinterpreter','latex','fontsize',18,'layer','top','linewidth',1.4)
%ylabel(ax2,'Habit Fraction','interpreter','latex','fontsize',22)
title(ax2,'Vertical','Interpreter','latex','fontsize',32)
%set(gca,'position', [0.55    0.1255    0.44    0.7500])
grid(ax2,'on')
colororder(ax2,turbo(length(fracnames)))

ylim(ax2,[0 1])

xlim(ax1,[min(m.H.time_bins(1),m.V.time_bins(1)),max(m.H.time_bins(end),m.V.time_bins(end))])
xlim(ax2,[min(m.H.time_bins(1),m.V.time_bins(1)),max(m.H.time_bins(end),m.V.time_bins(end))])


set(ax1,'ytick',0:0.1:1.0,'yticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})
set(ax2,'ytick',0:0.1:1.0,'yticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})

set(ax1,'box','on')
set(ax2,'box','on')



%colororder(ax2,turbo(length(fracnames)))
pause(0.01) % Needed for another bug fix.
% Plot temperature timeseries
 yyaxis(ax1,'right');
 plot(ax1,m.P3.Time,m.P3.Static_Air_Temp,'k:','linewidth',2)
 yyaxis(ax2,'right');
 plot(ax2,m.P3.Time,m.P3.Static_Air_Temp,'k:','linewidth',2)

 ylim(ax1,[-30 10])
 ylim(ax2,[-30 10])

 set(ax1,'ytick',-30:5:10,'yticklabel',{'$-30^{\circ}$','$-25^{\circ}$','$-20^{\circ}$', ...
     '$-15^{\circ}$','$-10^{\circ}$','$-5^{\circ}$','$0^{\circ}$','$5^{\circ}$',...
     '$10^{\circ}$'},'ycolor','k')

  set(ax2,'ytick',-30:5:10,'yticklabel',{'$-30^{\circ}$','$-25^{\circ}$','$-20^{\circ}$', ...
     '$-15^{\circ}$','$-10^{\circ}$','$-5^{\circ}$','$0^{\circ}$','$5^{\circ}$',...
     '$10^{\circ}$'},'ycolor','k')


 colororder(ax1,[turbo(length(fracnames));[0,0,0]])
 colororder(ax2,[turbo(length(fracnames));[0,0,0]])

new_names = erase(fracnames,'Frac');

new_names{end+1} = '';

leg = legend(ax1,new_names,'location','best','orientation','horizontal','Interpreter','latex','fontsize',18,'Color','none','EdgeColor','none');

ylabel(ax2,'Temperature (Celsius)','interpreter','latex','fontsize',32,'rotation',270,'verticalalignment','bottom')

set(leg,'units','normalized','position',[0.11 -0.007 0.75 0.06])

leg.AutoUpdate = false;

%% Make filled time periods of habit type
yyaxis(ax1,'left')
yyaxis(ax2,'left')

for tt = 1 : length(Htrans)-1

    ind_temp = htype(Htrans(tt));
    if ind_temp==0
        continue
    end

    color_ind = hcolors(htype(Htrans(tt)),:);

    area(ax1,[m.P3.Time(Htrans(tt)) m.P3.Time(Htrans(tt+1))],[1 1],'FaceColor',color_ind,'FaceAlpha',0.25,'linestyle','none');
    area(ax2,[m.P3.Time(Htrans(tt)) m.P3.Time(Htrans(tt+1))],[1 1],'FaceColor',color_ind,'FaceAlpha',0.25,'linestyle','none');


end


%% If saving figure
if save_fig
pdf_print(strcat(outdir,'IMPACTS_2DS_',string(m.H.time(1),'yMMdd'),'_habit_fraction'),'-dpdf')
close(fig)
end



end







