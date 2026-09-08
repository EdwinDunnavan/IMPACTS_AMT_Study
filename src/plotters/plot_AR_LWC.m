
function plot_AR_LWC(m,varargin)

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


fig = figure('units','normalized','position',[0.0599    0.3167    0.8776    0.6],'visible',visible); 

ax = tight_subplot(1,2,[0.07 0.08],[0.3 0.08],[0.053 0.072]);

ax1 = ax(1);
ax2 = ax(2);

hold(ax1,'on');
histogram2(ax1,datenum(m.H.time),m.H.AR,'displaystyle','tile','normalization','pdf','linestyle','none'); 
colormap(manga); 
set(ax1,'colorscale','log');
clim(ax1,[0.01 100])
datetick(ax1,'x')

cbar = colorbar(ax1,'south','orientation','horizontal','tickdirection','out','ticklabelinterpreter','latex','fontsize',18);


set(cbar,'units','normalized','position',[0.049,0.15,0.88,0.05],'ticklength',0.01,'linewidth',1.4)

set(cbar,'xtick',[0.01 0.1 1 10 100],'xticklabel',{'0.01','0.1','1.0','10','100'})
xlabel(cbar,'Probability Density','Interpreter','latex','fontsize',32)

set(ax1,'ticklabelinterpreter','latex','fontsize',18,'layer','top','linewidth',1.4)
ylabel(ax1,'Ellipse Aspect Ratio','interpreter','latex','fontsize',32)
title(ax1,'Horizontal','Interpreter','latex','fontsize',32)
grid(ax1,'on')

ylim(ax1,[0 1])


hold(ax2,'on')
histogram2(ax2,datenum(m.V.time),m.V.AR,'displaystyle','tile','normalization','pdf','linestyle','none'); 
colormap(manga); 
set(ax2,'colorscale','log');
clim(ax2,[0.01 100])
datetick(ax2,'x')

set(ax2,'ticklabelinterpreter','latex','fontsize',18,'layer','top','linewidth',1.4)
title(ax2,'Vertical','Interpreter','latex','fontsize',32)
grid(ax2,'on')


set(ax1,'ytick',0:0.1:1.0,'yticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})
set(ax2,'ytick',0:0.1:1.0,'yticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})

set(ax1,'box','on')
set(ax2,'box','on')

ylim(ax1,[0 1])
ylim(ax2,[0 1])

pause(0.01) % Needed for another bug fix.
% Plot temperature timeseries
 yyaxis(ax1,'right');
 plot(ax1,datenum(m.FCDP.Time),movmean(m.FCDP.LWC,300,'omitnan'),'color',[0.5 0.5 0.5],'linewidth',3)
 yyaxis(ax2,'right');
 plot(ax2,datenum(m.FCDP.Time),movmean(m.FCDP.LWC,300,'omitnan'),'color',[0.5 0.5 0.5],'linewidth',3)
 ylim(ax1,[0.001 10])
 ylim(ax2,[0.001 10])

 set(ax1,'yscale','log')
 set(ax2,'yscale','log')

 set(ax1,'ytick',[0.001 0.01 0.1 1 10],'yticklabel',{'0.001','0.01','0.1','1.0','10'})
 set(ax2,'ytick',[0.001 0.01 0.1 1 10],'yticklabel',{'0.001','0.01','0.1','1.0','10'})

 set(ax1,'Ycolor',[0.5 0.5 0.5])
 set(ax2,'Ycolor',[0.5 0.5 0.5])

ylabel(ax2,'LWC (g/m$^{3}$)','interpreter','latex','fontsize',36,'rotation',270,'verticalalignment','bottom')


yyaxis(ax1,'left')
yyaxis(ax2,'left')

xlim(ax1,[min(datenum(m.H.time)) max(datenum(m.H.time))])
xlim(ax2,[min(datenum(m.V.time)) max(datenum(m.V.time))])

% If saving figure
if save_fig
pdf_print(strcat(outdir,'IMPACTS_2DS_',string(m.H.time(1),'yMMdd'),'_AR_LWC'),'-dpng')
close(fig)
end



end