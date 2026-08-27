
%{
 plot_simulation_marginal.m

 Description: Plots Figure 19.
 
%}

fdir = '/localdata/edunnavan/Simulations/OAP_ellipsoid/';

%paths = get_project_paths();

folders = {'Simulation_CappedColumns/','Simulation_Columns_AR10/','Simulation_Dendrite_2/','Hexagonal_plate_D74/','Simulation_BR03/','Simulation_BR04/','Simulation_BR08/'};
test_folders = {'IMPACTS_2020_N2e5_habit/','IMPACTS_2020_N2e5_habit/','IMPACTS_2020_N2e5_habit/','IMPACTS_2020_N2e5_habit/','IMPACTS_2020_N2e5_habit/','IMPACTS_2020_N2e5_habit/','IMPACTS_2020_N2e5_habit/'};

%test_folders = {'Gamma_Random_exp_N1e4/','Gamma_Random_exp_N1e4/','Gamma_Random_exp_N1e4/','Random_Fixed_1mm/'};


%test_folders = {'Gamma_IMPACTS_2020_exp_N1e4/','Gamma_IMPACTS_2020_exp_N1e4/','Gamma_IMPACTS_2020_exp_N1e4/'};


% Labels for the legend (matching the order of folders)
legend_labels = {'Capped Columns','Needles','Dendrite','Plates','BR03', 'BR04', 'BR08'};

% Custom colors to match the target figure's aesthetic 
% (Green, Light Blue, Dark Red, Yellow)
colors = [
    0, 0.4470, 0.7410;      % Capped Columns
    0.8500, 0.3250, 0.0980; % Needles
    0.9290  0.6940  0.1250  % Dendrite
    0.4940, 0.1840, 0.5560; % Plates
    0.4660  0.6740  0.1880; % BR03
    0.3010  0.7450  0.9330; % BR04
    0.6350  0.0780  0.1840; % BR08
];

% Initialize Figure and 2x2 Grid
fig = figure('units','normalized','position',[0.0693    0.0583    0.4026    0.6889]); 
ax = tight_subplot(2, 2, [0.12 0.04], [0.12 0.08], [0.08 0.04]);

for a = 1:4
    hold(ax(a), 'on');
    grid(ax(a), 'on');
end

%% Loop through datasets and plot
for hh = 1 : length(test_folders)

    % Read data
    stemp = read_stl_data(strcat(fdir,folders{hh},test_folders{hh}));

    % Calculate required parameters
    ARH = stemp.rb_xz_cgal ./ stemp.ra_xz_cgal;
    ARV = stemp.rb_xy_cgal ./ stemp.ra_xy_cgal;
    AreaH = stemp.area_ratio_xz_cgal;
    AreaV = stemp.area_ratio_xy_cgal;

    % Ax 1: Horizontal Aspect Ratio
    histogram(ax(1), ARH, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', ...
              'LineWidth', 2, 'EdgeColor', colors(hh,:));

    % Ax 2: Vertical Aspect Ratio
    histogram(ax(2), ARV, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', ...
              'LineWidth', 2, 'EdgeColor', colors(hh,:));

    % Ax 3: Horizontal Area Ratio
    histogram(ax(3), AreaH, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', ...
              'LineWidth', 2, 'EdgeColor', colors(hh,:));

    % Ax 4: Vertical Area Ratio
    histogram(ax(4), AreaV, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', ...
              'LineWidth', 2, 'EdgeColor', colors(hh,:));
end

% Global Axis Limits and Ticks
for a = 1:4
    xlim(ax(a), [0 1]);
    ylim(ax(a), [0 30]);
    set(ax(a), 'XTick', 0:0.2:1.0,'xticklabel',{'0','0.2','0.4','0.6','0.8','1.0'}, ...
               'YTick', 0:5:30,'yticklabel',0:5:30);
    set(ax(a), 'TickLabelInterpreter', 'latex', 'FontSize', 16, 'LineWidth', 1.4, ...
               'ticklength',[0.02,0.04],'box','on');


end

%% Formatting and Aesthetics
% Titles (Top row only)
title(ax(1), 'Horizontal', 'Interpreter', 'latex', 'FontSize', 26);
title(ax(2), 'Vertical', 'Interpreter', 'latex', 'FontSize', 26);

% Y-Labels (Left column only)
ylabel(ax(1), 'Probability Density', 'Interpreter', 'latex', 'FontSize', 20);
ylabel(ax(3), 'Probability Density', 'Interpreter', 'latex', 'FontSize', 20);

% X-Labels
xlabel(ax(1), 'Ellipse Aspect Ratio', 'Interpreter', 'latex', 'FontSize', 20);
xlabel(ax(2), 'Ellipse Aspect Ratio', 'Interpreter', 'latex', 'FontSize', 20);
xlabel(ax(3), 'Ellipse Area Ratio', 'Interpreter', 'latex', 'FontSize', 20);

% Remove Y-tick labels for the right column to prevent overlap
set(ax(2), 'YTickLabel', '');
set(ax(4), 'YTickLabel', '');

xlabel(ax(4), 'Ellipse Area Ratio', 'Interpreter', 'latex', 'FontSize', 22);

% Add Legend to the first panel
legend(ax(1), legend_labels, 'Interpreter', 'latex', 'FontSize', 14, ...
       'Location', 'northeast', 'Box', 'on');




% % Plot ellipse major dimension, aspect ratio, ellipse angle, and ellipse area ratio
% fig = figure('units','normalized'); 
% 
% for hh = 1 : length(test_folders)
% 
%     % Read data
%     stemp = read_stl_data(strcat(fdir,folders{hh},test_folders{hh}));
% 
%     ARH = stemp.rb_xz_cgal./stemp.ra_xz_cgal;
%     ARV = stemp.rb_xy_cgal./stemp.ra_xy_cgal;
% 
%     EllipAngH = stemp.EllipAng_xz_cgal;
%     EllipAngV = stemp.EllipAng_xy_cgal;
% 
%     DmajorH = 2.*stemp.ra_xz_cgal;
%     DmajorV = 2.*stemp.ra_xy_cgal;
% 
%     DmaxH = stemp.Dmax_xz_cgal;
%     DmaxV = stemp.Dmax_xy_cgal;
% 
%     AreaH = stemp.area_ratio_xz_cgal;
%     AreaV = stemp.area_ratio_xy_cgal;
% 
%     complexityH = stemp.complexity_xz_cgal;
%     complexityV = stemp.complexity_xy_cgal;
% 
%     circularityH = stemp.circularity_xz;
%     circularityV = stemp.circularity_xy;
% 
%     ellipticityH = stemp.ellipticity_xz_cgal;
%     ellipticityV = stemp.ellipticity_xy_cgal;
% 
%     AreaCircH = stemp.particle_area_xz./((pi/4).*stemp.Dmax_xz_cgal.^2);
%     AreaCircV = stemp.particle_area_xy./((pi/4).*stemp.Dmax_xy_cgal.^2);
% 
% 
% ax1 = subplot(4,2,1);
% hold on; 
% histogram(ax1,ARH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% %histogram(ax1,DmajorH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% %histogram(ax1,DmajorV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')
% 
% ax2 = subplot(4,2,2);
% hold on; 
% histogram(ax2,ARV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','-')
% 
% ax3 = subplot(4,2,3);
% hold on; 
% histogram(ax3,AreaH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% %histogram(ax3,EllipAngH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% %histogram(ax3,EllipAngV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')
% 
% ax4 = subplot(4,2,4);
% hold on; 
% histogram(ax4,AreaV,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% 
% %histogram(ax4,AreaV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')
% 
% ax5 = subplot(4,2,5);
% hold on; 
% %histogram(ax5,complexityH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% 
% %histogram(ax5,circularityH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% 
% histogram(ax5,AreaCircH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% 
% 
% %histogram(ax5,complexityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')
% 
% ax6 = subplot(4,2,6);
% hold on; 
% %histogram(ax6,circularityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% histogram(ax6,AreaCircV,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% 
% %histogram(ax6,ellipticityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')
% 
% ax7 = subplot(4,2,7);
% hold on; 
% %histogram(ax5,complexityH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% 
% histogram(ax7,ellipticityH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% 
% %histogram(ax5,complexityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')
% 
% ax8 = subplot(4,2,8);
% hold on; 
% histogram(ax8,ellipticityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
% %histogram(ax6,ellipticityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')
% 
% 
% 
% 
% end