function [fig,ax] = plot_ellipse_joint(m,varargin)

normalization = 'pdf';

ang_edges = -90:2.5:90;
xedges = 0.:0.05:1.0;
area_edges = 0:0.05:1.0;
Dmajor_edges = 0.3:0.05:3.0;


% Default options

habit = 'all';
save_fig = false;
visible = 'on';
outdir = pwd;
Tc_max = 0;
Tc_min = -99999;

Dmajor_switch = false;
AspectRatio_switch = true;
EllipAng_switch = true;
AreaRatio_switch = false;

for nn = 1 : length(varargin)

switch varargin{nn}

    case 'habit'

        habit = varargin{nn+1};

    case 'Temp_max'

        Tc_max = varargin{nn+1};

    case 'Temp_min'

        Tc_min = varargin{nn+1};

    case 'save_fig'

        save_fig = varargin{nn+1};

    case 'outdir'

        outdir = varargin{nn+1};

        if ~exist(outdir,'dir')
            mkdir(outdir)
        end


    case 'show_fig'

        show_fig = varargin{nn+1};

        if ~show_fig

            visible = 'off';

        end

    case 'Dmajor'

        Dmajor_switch = varargin{nn+1};

    case 'AspectRatio'

        AspectRatio_switch = varargin{nn+1};

    case 'EllipseAngle'

        EllipAng_switch = varargin{nn+1};

    case 'AreaRatio'

        AreaRatio_switch = varargin{nn+1};


end

end


if ~strcmp(habit,'all')

indH_habit = (m.H.habit==habit);     
indV_habit = (m.V.habit==habit);

else

indH_habit = true(size(m.H.AR));    
indV_habit = true(size(m.V.AR));  

end

indH_temp = (m.H.Temp<Tc_max)&(m.H.Temp>=Tc_min);
indV_temp = (m.V.Temp<Tc_max)&(m.V.Temp>=Tc_min);

indH = (indH_habit&indH_temp);
indV = (indV_habit&indV_temp);

if AspectRatio_switch
ARH = m.H.AR(indH);
ARV = m.V.AR(indV);
end

if EllipAng_switch
EllipAngH = m.H.EllipAng(indH);
EllipAngV = m.V.EllipAng(indV);
end

if Dmajor_switch
DmajorH = m.H.Dmajor(indH);
DmajorV = m.V.Dmajor(indV);
end

if AreaRatio_switch
AreaH = m.H.area_ratio(indH);
AreaV = m.V.area_ratio(indV);
end


%% (1) Aspect Ratio / Ellipse Angle

if (AspectRatio_switch && EllipAng_switch)

colorscale = 'log';

switch colorscale

    case 'lin'

        color_lims = [0. 0.05];


    case 'log'

        color_lims = [0.00001 0.5];


end

fig = figure('units','normalized','position',[0.0417    0.2880    0.9005    0.5750],'visible',visible);

ax = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);

ax1 = ax(1);
ax2 = ax(2);

%nbins = ceil((max(max(length(ARH),length(ARV)),1))^(1/3));

histogram2(ax1,EllipAngH,ARH,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
xlim(ax1,[-90 90])
ylim(ax1,[0 1])
set(ax1,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax1,sprintf('Horizontal (N=%s)',addComma(length(ARH))),'Interpreter','latex','fontsize',32)
clim(ax1,color_lims)
set(ax1,'colorscale',colorscale)
xlabel(ax1,'Ellipse Angle','interpreter','latex','fontsize',26)
ylabel(ax1,'Ellipse Aspect Ratio','interpreter','latex','fontsize',26)

grid on

set(ax1,'xtick',-90:10:90,...
     'xticklabel',{'$-90^{\circ}$' '$-80^{\circ}$' '$-70^{\circ}$' '$-60^{\circ}$' '$-50^{\circ}$',...
                        '$-40^{\circ}$' '$-30^{\circ}$' '$-20^{\circ}$' '$-10^{\circ}$' '$0^{\circ}$',...
                        '$10^{\circ}$' '$20^{\circ}$' '$30^{\circ}$' '$40^{\circ}$' '$50^{\circ}$', ...
                        '$60^{\circ}$' '$70^{\circ}$' '$80^{\circ}$' '$90^{\circ}$'})
set(ax1,'ytick',0:0.1:1,'yticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})

histogram2(ax2,EllipAngV,ARV,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
xlim(ax2,[-90 90])
ylim(ax2,[0 1])

set(ax2,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax2,sprintf('Vertical (N=%s)',addComma(length(ARV))),'Interpreter','latex','fontsize',32)
clim(ax2,color_lims)
set(ax2,'colorscale',colorscale)
grid on
xlabel(ax2,'Ellipse Angle','interpreter','latex','fontsize',26)
%ylabel(ax2,'Ellipse Aspect Ratio','interpreter','latex','fontsize',26)

set(ax2,'xtick',-90:10:90,...
     'xticklabel',{'$-90^{\circ}$' '$-80^{\circ}$' '$-70^{\circ}$' '$-60^{\circ}$' '$-50^{\circ}$',...
                        '$-40^{\circ}$' '$-30^{\circ}$' '$-20^{\circ}$' '$-10^{\circ}$' '$0^{\circ}$',...
                        '$10^{\circ}$' '$20^{\circ}$' '$30^{\circ}$' '$40^{\circ}$' '$50^{\circ}$', ...
                        '$60^{\circ}$' '$70^{\circ}$' '$80^{\circ}$' '$90^{\circ}$'})
set(ax2,'ytick',0:0.1:1,'yticklabel',{''})
colormap(gcf,manga)

cbar = colorbar();

set(cbar,'position',[0.9    0.1997    0.0179    0.7005],'ticklabelinterpreter','latex','fontsize',18,'linewidth',1.2,'ticklength',0.04)
ylabel(cbar,'Probability Density','interpreter','latex','fontsize',32,'rotation',270,'verticalalignment','bottom')

if strcmp(colorscale,'log')
set(cbar,'ytick',[0.00001 0.0001 0.001 0.01 0.1 1.0],'yticklabel',{'0.00001','0.0001', '0.001','0.01','0.1','1.0'})
end

% If saving figure
if save_fig
pdf_print(strcat(outdir,'IMPACTS_2DS_',string(m.H.time(1),'yMMdd'),'_AspectRatio_EllipAng'),'-dpdf')
close(fig)

end

end



%% (2) Dmajor / Aspect Ratio

if (AspectRatio_switch && Dmajor_switch)

colorscale = 'log';

switch colorscale

    case 'lin'

        color_lims = [0. 10];


    case 'log'

        color_lims = [0.01 50.0];


end

fig = figure('units','normalized','position',[0.0417    0.2880    0.9005    0.5750],'visible',visible);

ax = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);

ax1 = ax(1);
ax2 = ax(2);

%nbins = ceil((max(max(length(ARH),length(ARV)),1))^(1/3));

histogram2(ax1,log10(DmajorH),ARH,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
xlim(ax1,log10([min(Dmajor_edges) max(Dmajor_edges)]))
ylim(ax1,[min(xedges) max(xedges)])
set(ax1,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax1,sprintf('Horizontal (N=%s)',addComma(length(ARH))),'Interpreter','latex','fontsize',32)
clim(ax1,color_lims)
set(ax1,'colorscale',colorscale)
xlabel(ax1,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',26)
ylabel(ax1,'Ellipse Aspect Ratio','interpreter','latex','fontsize',26)

%set(ax1,'xscale','log')

set(ax1,'xtick',log10([0.5 1 1.5 2. 2.5 3]),'xticklabel',{'0.5','1.0','1.5','2.0','2.5','3.0'})

grid on

%set(ax1,'xtick',-90:10:90,...
%     'xticklabel',{'$-90^{\circ}$' '$-80^{\circ}$' '$-70^{\circ}$' '$-60^{\circ}$' '$-50^{\circ}$',...
%                        '$-40^{\circ}$' '$-30^{\circ}$' '$-20^{\circ}$' '$-10^{\circ}$' '$0^{\circ}$',...
%                        '$10^{\circ}$' '$20^{\circ}$' '$30^{\circ}$' '$40^{\circ}$' '$50^{\circ}$', ...
%                        '$60^{\circ}$' '$70^{\circ}$' '$80^{\circ}$' '$90^{\circ}$'})

set(ax1,'ytick',0:0.1:1,'yticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})

histogram2(ax2,log10(DmajorV),ARV,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
xlim(ax2,log10([min(Dmajor_edges) max(Dmajor_edges)]))
ylim(ax2,[0 1])

set(ax2,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax2,sprintf('Vertical (N=%s)',addComma(length(ARV))),'Interpreter','latex','fontsize',32)
clim(ax2,color_lims)
set(ax2,'colorscale',colorscale)
grid on
xlabel(ax2,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',26)

%set(ax2,'xscale','log')

set(ax2,'xtick',log10([0.5 1 1.5 2. 2.5 3]),'xticklabel',{'0.5','1.0','1.5','2.0','2.5','3.0'})

%ylabel(ax2,'Ellipse Aspect Ratio','interpreter','latex','fontsize',26)

% set(ax2,'xtick',-90:10:90,...
%      'xticklabel',{'$-90^{\circ}$' '$-80^{\circ}$' '$-70^{\circ}$' '$-60^{\circ}$' '$-50^{\circ}$',...
%                         '$-40^{\circ}$' '$-30^{\circ}$' '$-20^{\circ}$' '$-10^{\circ}$' '$0^{\circ}$',...
%                         '$10^{\circ}$' '$20^{\circ}$' '$30^{\circ}$' '$40^{\circ}$' '$50^{\circ}$', ...
%                         '$60^{\circ}$' '$70^{\circ}$' '$80^{\circ}$' '$90^{\circ}$'})

set(ax2,'ytick',0:0.1:1,'yticklabel',{''})
colormap(gcf,manga)

cbar = colorbar();

set(cbar,'position',[0.9    0.1997    0.0179    0.7005],'ticklabelinterpreter','latex','fontsize',18,'linewidth',1.2,'ticklength',0.04)
ylabel(cbar,'Probability Density','interpreter','latex','fontsize',32,'rotation',270,'verticalalignment','bottom')

if strcmp(colorscale,'log')
set(cbar,'ytick',[0.0001 0.001 0.01 0.1 1.0 10],'yticklabel',{'0.0001', '0.001','0.01','0.1','1.0','10.0'})
end

% If saving figure
if save_fig
pdf_print(strcat(outdir,'IMPACTS_2DS_',string(m.H.time(1),'yMMdd'),'_Dmajor_AspectRatio'),'-dpdf')
close(fig)

end

end

%% (3) Dmajor / Ellipse Angle

if (EllipAng_switch && Dmajor_switch)

colorscale = 'log';

switch colorscale

    case 'lin'

        color_lims = [0. 10];


    case 'log'

        color_lims = [0.0001 0.1];


end

fig = figure('units','normalized','position',[0.0417    0.2880    0.9005    0.5750],'visible',visible);

ax = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);

ax1 = ax(1);
ax2 = ax(2);

%nbins = ceil((max(max(length(DmajorH),length(DmajorV)),1))^(1/3));

histogram2(ax1,EllipAngH,log10(DmajorH),'displaystyle','tile','Normalization',normalization,'LineStyle','none');
ylim(ax1,log10([min(Dmajor_edges) max(Dmajor_edges)]))
xlim(ax1,[min(ang_edges) max(ang_edges)])


set(ax1,'ytick',log10([0.5 1 1.5 2. 2.5 3]),'yticklabel',{'0.5','1.0','1.5','2.0','2.5','3.0'})
%set(gca,'yscale','log')

set(ax1,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax1,sprintf('Horizontal (N=%s)',addComma(length(DmajorH))),'Interpreter','latex','fontsize',32)
clim(ax1,color_lims)
set(ax1,'colorscale',colorscale)
ylabel(ax1,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',26)
xlabel(ax1,'Ellipse Angle','interpreter','latex','fontsize',26)

grid on

set(ax1,'xtick',-90:10:90,...
    'xticklabel',{'$-90^{\circ}$' '$-80^{\circ}$' '$-70^{\circ}$' '$-60^{\circ}$' '$-50^{\circ}$',...
                       '$-40^{\circ}$' '$-30^{\circ}$' '$-20^{\circ}$' '$-10^{\circ}$' '$0^{\circ}$',...
                       '$10^{\circ}$' '$20^{\circ}$' '$30^{\circ}$' '$40^{\circ}$' '$50^{\circ}$', ...
                       '$60^{\circ}$' '$70^{\circ}$' '$80^{\circ}$' '$90^{\circ}$'})

%set(ax1,'yscale','log')

%set(ax1,'ytick',0:0.1:1,'yticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})

histogram2(ax2,EllipAngV,log10(DmajorV),'displaystyle','tile','Normalization',normalization,'LineStyle','none');
ylim(ax2,log10([min(Dmajor_edges) max(Dmajor_edges)]))
xlim(ax2,[min(ang_edges) max(ang_edges)])

set(ax2,'ytick',log10([0.5 1 1.5 2. 2.5 3]),'yticklabel',{''})
%set(ax2,'yscale','log')

set(ax2,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax2,sprintf('Vertical (N=%s)',addComma(length(DmajorV))),'Interpreter','latex','fontsize',32)
clim(ax2,color_lims)
set(ax2,'colorscale',colorscale)
grid on
%ylabel(ax2,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',26)


%ylabel(ax2,'Ellipse Aspect Ratio','interpreter','latex','fontsize',26)

xlabel(ax2,'Ellipse Angle','interpreter','latex','fontsize',26)

set(ax2,'xtick',-90:10:90,...
     'xticklabel',{'$-90^{\circ}$' '$-80^{\circ}$' '$-70^{\circ}$' '$-60^{\circ}$' '$-50^{\circ}$',...
                        '$-40^{\circ}$' '$-30^{\circ}$' '$-20^{\circ}$' '$-10^{\circ}$' '$0^{\circ}$',...
                        '$10^{\circ}$' '$20^{\circ}$' '$30^{\circ}$' '$40^{\circ}$' '$50^{\circ}$', ...
                        '$60^{\circ}$' '$70^{\circ}$' '$80^{\circ}$' '$90^{\circ}$'})

%set(ax2,'ytick',0:0.1:1,'yticklabel',{''})

set(ax2,'yticklabel',{''})

colormap(gcf,manga)

cbar = colorbar();

set(cbar,'position',[0.9    0.1997    0.0179    0.7005],'ticklabelinterpreter','latex','fontsize',18,'linewidth',1.2,'ticklength',0.04)
ylabel(cbar,'Probability Density','interpreter','latex','fontsize',32,'rotation',270,'verticalalignment','bottom')

if strcmp(colorscale,'log')
set(cbar,'ytick',[0.00001 0.0001 0.001 0.01 0.1 1.0],'yticklabel',{'0.00001','0.0001', '0.001','0.01','0.1','1.0'})
end

% If saving figure
if save_fig
pdf_print(strcat(outdir,'IMPACTS_2DS_',string(m.H.time(1),'yMMdd'),'_EllipseAngle_Dmajor'),'-dpdf')
close(fig)

end

end


%% (4) Aspect Ratio / Area Ratio

if (AspectRatio_switch && AreaRatio_switch)

colorscale = 'log';

switch colorscale

    case 'lin'

        color_lims = [0. 10];


    case 'log'

        color_lims = [0.01 50];


end

fig = figure('units','normalized','position',[0.0417    0.2880    0.9005    0.5750],'visible',visible);

ax = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);

ax1 = ax(1);
ax2 = ax(2);

%nbins = ceil((max(max(length(ARH),length(ARV)),1))^(1/3));

histogram2(ax1,AreaH,ARH,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
ylim(ax1,[min(xedges) max(xedges)])
xlim(ax1,[min(area_edges) max(area_edges)])

set(ax1,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax1,sprintf('Horizontal (N=%s)',addComma(length(AreaH))),'Interpreter','latex','fontsize',32)
clim(ax1,color_lims)
set(ax1,'colorscale',colorscale)
xlabel(ax1,'Ellipse Area Ratio','interpreter','latex','fontsize',26)
ylabel(ax1,'Ellipse Aspect Ratio','interpreter','latex','fontsize',26)

grid on

set(ax1,'ytick',0:0.1:1,'yticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})
set(ax1,'xtick',0:0.1:1,'xticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})

histogram2(ax2,AreaV,ARV,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
ylim(ax2,[min(xedges) max(xedges)])
xlim(ax2,[min(area_edges) max(area_edges)])

set(ax2,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax2,sprintf('Vertical (N=%s)',addComma(length(AreaV))),'Interpreter','latex','fontsize',32)
clim(ax2,color_lims)
set(ax2,'colorscale',colorscale)
grid on

%ylabel(ax2,'Ellipse Aspect Ratio','interpreter','latex','fontsize',26)
xlabel(ax2,'Ellipse Area Ratio','interpreter','latex','fontsize',26)

set(ax2,'ytick',0:0.1:1,'yticklabel',{''})
set(ax2,'xtick',0:0.1:1,'xticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})

colormap(gcf,manga)

cbar = colorbar();

set(cbar,'position',[0.9    0.1997    0.0179    0.7005],'ticklabelinterpreter','latex','fontsize',18,'linewidth',1.2,'ticklength',0.04)
ylabel(cbar,'Probability Density','interpreter','latex','fontsize',32,'rotation',270,'verticalalignment','bottom')

if strcmp(colorscale,'log')
set(cbar,'ytick',[0.001 0.01 0.1 1.0 10],'yticklabel',{'0.001','0.01','0.1','1.0', '10'})
end

% If saving figure
if save_fig
pdf_print(strcat(outdir,'IMPACTS_2DS_',string(m.H.time(1),'yMMdd'),'_AreaRatio_AspectRatio'),'-dpdf')
close(fig)

end

end


%% (5) Dmajor / Area Ratio

if (Dmajor_switch && AreaRatio_switch)

colorscale = 'log';

switch colorscale

    case 'lin'

        color_lims = [0. 10];


    case 'log'

        color_lims = [0.01 50];


end

fig = figure('units','normalized','position',[0.0417    0.2880    0.9005    0.5750],'visible',visible);

ax = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);

ax1 = ax(1);
ax2 = ax(2);

%nbins = ceil((max(max(length(AreaH),length(AreaV)),1))^(1/3));

histogram2(ax1,log10(DmajorH),AreaH,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
xlim(ax1,log10([min(Dmajor_edges) max(Dmajor_edges)]))
ylim(ax1,[min(area_edges) max(area_edges)])

set(ax1,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax1,sprintf('Horizontal (N=%s)',addComma(length(AreaH))),'Interpreter','latex','fontsize',32)
clim(ax1,color_lims)
set(ax1,'colorscale',colorscale)

ylabel(ax1,'Ellipse Area Ratio','interpreter','latex','fontsize',26)
xlabel(ax1,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',26)

set(ax1,'xtick',log10([0.5 1 1.5 2. 2.5 3]),'xticklabel',{'0.5','1.0','1.5','2.0','2.5','3.0'})
%set(ax1,'xscale','log')

grid on

set(ax1,'ytick',0:0.1:1,'yticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})


histogram2(ax2,log10(DmajorV),AreaV,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
xlim(ax2,log10([min(Dmajor_edges) max(Dmajor_edges)]))
ylim(ax2,[min(area_edges) max(area_edges)])

set(ax2,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax2,sprintf('Vertical (N=%s)',addComma(length(AreaV))),'Interpreter','latex','fontsize',32)
clim(ax2,color_lims)
set(ax2,'colorscale',colorscale)
grid on

set(ax2,'xtick',log10([0.5 1 1.5 2. 2.5 3]),'xticklabel',{'0.5','1.0','1.5','2.0','2.5','3.0'})
%set(ax2,'xscale','log')

xlabel(ax2,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',26)

set(ax2,'ytick',0:0.1:1,'yticklabel',{''})

colormap(gcf,manga)

cbar = colorbar();

set(cbar,'position',[0.9    0.1997    0.0179    0.7005],'ticklabelinterpreter','latex','fontsize',18,'linewidth',1.2,'ticklength',0.04)
ylabel(cbar,'Probability Density','interpreter','latex','fontsize',32,'rotation',270,'verticalalignment','bottom')

if strcmp(colorscale,'log')
set(cbar,'ytick',[0.001 0.01 0.1 1.0 10],'yticklabel',{'0.001','0.01','0.1','1.0', '10'})
end

% If saving figure
if save_fig
pdf_print(strcat(outdir,'IMPACTS_2DS_',string(m.H.time(1),'yMMdd'),'_Dmajor_AreaRatio'),'-dpdf')
close(fig)

end

end

%% (6) Ellipse Angle / Area Ratio

if (EllipAng_switch && AreaRatio_switch)

colorscale = 'log';

switch colorscale

    case 'lin'

        color_lims = [0. 10];


    case 'log'

        color_lims = [0.0001 0.5];


end

fig = figure('units','normalized','position',[0.0417    0.2880    0.9005    0.5750],'visible',visible);

ax = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);

ax1 = ax(1);
ax2 = ax(2);

%nbins = ceil((max(max(length(AreaH),length(AreaV)),1))^(1/3));

histogram2(ax1,EllipAngH,AreaH,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
xlim(ax1,[min(ang_edges) max(ang_edges)])
ylim(ax1,[min(area_edges) max(area_edges)])

xlabel(ax1,'Ellipse Angle','interpreter','latex','fontsize',26)

set(ax1,'xtick',-90:10:90,...
     'xticklabel',{'$-90^{\circ}$' '$-80^{\circ}$' '$-70^{\circ}$' '$-60^{\circ}$' '$-50^{\circ}$',...
                        '$-40^{\circ}$' '$-30^{\circ}$' '$-20^{\circ}$' '$-10^{\circ}$' '$0^{\circ}$',...
                        '$10^{\circ}$' '$20^{\circ}$' '$30^{\circ}$' '$40^{\circ}$' '$50^{\circ}$', ...
                        '$60^{\circ}$' '$70^{\circ}$' '$80^{\circ}$' '$90^{\circ}$'})

set(ax1,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax1,sprintf('Horizontal (N=%s)',addComma(length(AreaH))),'Interpreter','latex','fontsize',32)
clim(ax1,color_lims)
set(ax1,'colorscale',colorscale)

ylabel(ax1,'Ellipse Area Ratio','interpreter','latex','fontsize',26)

xlabel(ax1,'Ellipse Angle','interpreter','latex','fontsize',26)

grid on

set(ax1,'ytick',0:0.1:1,'yticklabel',{'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})

histogram2(ax2,EllipAngV,AreaV,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
xlim(ax2,[min(ang_edges) max(ang_edges)])
ylim(ax2,[min(area_edges) max(area_edges)])

set(ax2,'ticklabelinterpreter','latex','fontsize',22,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04])
title(ax2,sprintf('Vertical (N=%s)',addComma(length(AreaV))),'Interpreter','latex','fontsize',32)
clim(ax2,color_lims)
set(ax2,'colorscale',colorscale)
grid on

xlabel(ax2,'Ellipse Angle','interpreter','latex','fontsize',26)

set(ax2,'xtick',-90:10:90,...
     'xticklabel',{'$-90^{\circ}$' '$-80^{\circ}$' '$-70^{\circ}$' '$-60^{\circ}$' '$-50^{\circ}$',...
                        '$-40^{\circ}$' '$-30^{\circ}$' '$-20^{\circ}$' '$-10^{\circ}$' '$0^{\circ}$',...
                        '$10^{\circ}$' '$20^{\circ}$' '$30^{\circ}$' '$40^{\circ}$' '$50^{\circ}$', ...
                        '$60^{\circ}$' '$70^{\circ}$' '$80^{\circ}$' '$90^{\circ}$'})




set(ax2,'ytick',0:0.1:1,'yticklabel',{''})

colormap(gcf,manga)

cbar = colorbar();

set(cbar,'position',[0.9    0.1997    0.0179    0.7005],'ticklabelinterpreter','latex','fontsize',18,'linewidth',1.2,'ticklength',0.04)
ylabel(cbar,'Probability Density','interpreter','latex','fontsize',32,'rotation',270,'verticalalignment','bottom')

if strcmp(colorscale,'log')
set(cbar,'ytick',[0.0001 0.001 0.01 0.1],'yticklabel',{'0.0001','0.001','0.01','0.1'})
end

% If saving figure
if save_fig
pdf_print(strcat(outdir,'IMPACTS_2DS_',string(m.H.time(1),'yMMdd'),'_EllipseAngle_AreaRatio'),'-dpdf')
close(fig)

end

end



end


function numOut = addComma(numIn)
   jf=java.text.DecimalFormat; % comma for thousands, three decimal places
   numOut= jf.format(numIn); % omit "char" if you want a string out
end