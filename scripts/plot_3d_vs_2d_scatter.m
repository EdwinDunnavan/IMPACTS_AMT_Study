

% plot_3d_vs_2d_scatter_3row.m
% Compares 3D ground truth geometries to 2D projected properties (3x2 Grid)

paths = init_project();
simDir = paths.simulations;

% Included folders
folders = {'Irregular_1k_fuse_TEST3/','Rosettes_10k/','Linear_MA94_10k/','CappedColumns_10k/', 'Simulation_Dendrite/', 'Simulation_Plates/'};
test_folders = {'Irregular_2020_1e6/','Irregular_2020_1e5/','Linear_2022_2023_neg80deg_1e6/','Random_1e5/', 'IMPACTS_2020_N2e5_habit/', 'IMPACTS_2020_N2e5_habit/'};
legend_labels = {'Irregular','Bullet Rosettes','Linear','Capped Columns', 'Dendrite', 'Plates'};

% Categories for plotting logic
single_stls = {'Simulation_Dendrite/'};
constant_rho_stls = {'Linear_MA94_10k/', 'Simulation_Plates/'};

% Colors matching schema
colors = [
    0.5, 0.5, 0.5;          % Irregular
    0.2, 0.2, 0.2;          % Bullet Rosettes
    0.6, 0.3, 0;            % Linear
    0, 0.4470, 0.7410;      % Capped Columns
    0.9290, 0.6940, 0.1250; % Dendrite
    0.4940, 0.1840, 0.5560; % Plates
];
% 
% % Included folders
% folders = {'Rosettes_10k_TEST/','Linear_MA94_10k/','Simulation_CappedColumns/', 'Simulation_Dendrite/', 'Simulation_Plates/', 'Simulation_BR03/', 'Simulation_BR04/', 'Simulation_BR08/'};
% test_folders = {'Irregular_2020_1e5/','Linear_2022_2023_neg80deg_1e6/','IMPACTS_2020_N2e5_habit/', 'IMPACTS_2020_N2e5_habit/', 'IMPACTS_2020_N2e5_habit/', 'IMPACTS_2020_N2e5_habit/', 'IMPACTS_2020_N2e5_habit/', 'IMPACTS_2020_N2e5_habit/'};
% legend_labels = {'Bullet Rosettes','Linear','Capped Columns', 'Dendrite', 'Plates', 'BR03', 'BR04', 'BR08'};
% 
% % Categories for plotting logic
% single_stls = {'Simulation_CappedColumns/', 'Simulation_Dendrite/', 'Simulation_BR03/', 'Simulation_BR04/', 'Simulation_BR08/'};
% constant_rho_stls = {'Linear_MA94_10k/', 'Simulation_Plates/'};
% 
% % Colors matching schema
% colors = [
%     0.2, 0.2, 0.2;          % Irregular
%     0.6, 0.3, 0;            % Linear
%     0, 0.4470, 0.7410;      % Capped Columns
%     0.9290, 0.6940, 0.1250; % Dendrite
%     0.4940, 0.1840, 0.5560; % Plates
%     0.4660, 0.6740, 0.1880; % BR03
%     0.3010, 0.7450, 0.9330; % BR04
%     0.6350, 0.0780, 0.1840; % BR08
% ];

% Initialize Figure and 3x2 Grid (Taller for 3 rows)
fig = figure('units','normalized','position',[0.0693    0.0583    0.50    0.85]); 
% Increased vertical spacing to fit X-labels on all rows
ax = tight_subplot(3, 2, [0.10 0.06], [0.12 0.06], [0.08 0.04]);

for a = 1:6
    hold(ax(a), 'on');
    grid(ax(a), 'on');
    box(ax(a), 'on');
end

% Dummy handles for clean legend generation
h_leg = zeros(1, length(folders));

%% Loop through datasets and plot
for hh = 1:length(folders)

    % Read data
    stemp = read_stl_data(fullfile(simDir, folders{hh}, test_folders{hh}));

    % Calculate 2D parameters (Ellipse)
    ARH = stemp.rb_xz_cgal ./ stemp.ra_xz_cgal;
    ARV = stemp.rb_xy_cgal ./ stemp.ra_xy_cgal;
    AreaH_ellip = stemp.area_ratio_xz_cgal;
    AreaV_ellip = stemp.area_ratio_xy_cgal;

    % Calculate 2D parameters (Circle)
    AreaH_circ = stemp.particle_area_xz ./ ((pi/4) .* stemp.Dmax_xz_cgal.^2);
    AreaV_circ = stemp.particle_area_xy ./ ((pi/4) .* stemp.Dmax_xy_cgal.^2);

    % Calculate 3D parameters
    phi_ca = stemp.c ./ stemp.a; 
    rho_eff_ellip = stemp.effective_density;
    
    % 3D Sphere Density Calculation (using abs() to fix self-intersecting mesh negative volumes)
    V_3D = abs(stemp.moments(1,:)'); 
    Dmax_3D = stemp.max_dim(:);
    rho_eff_sphere = V_3D ./ ((pi/6) .* Dmax_3D.^3);

    % Limit size for KDEs and general processing
    N_total = length(phi_ca);
    if N_total > 5000
        idx = randperm(N_total, 5000);
    else
        idx = 1:N_total;
    end

    % Check categories
    is_single_stl = ismember(folders{hh}, single_stls);
    is_constant_rho = ismember(folders{hh}, constant_rho_stls);

    % --- ROW 1: 3D Axis Ratio vs 2D Aspect Ratio (Ellipse) ---
    if is_single_stl
        x_phi = mean(phi_ca, 'omitnan'); 
        draw_custom_boxplot(ax(1), x_phi, ARH, colors(hh,:));
        draw_custom_boxplot(ax(2), x_phi, ARV, colors(hh,:));
    else
        draw_kde_contours(ax(1), phi_ca(idx), ARH(idx), colors(hh,:));
        draw_kde_contours(ax(2), phi_ca(idx), ARV(idx), colors(hh,:));
    end

    % --- ROW 2: 3D Effective Density (Ellipsoid) vs 2D Area Ratio (Ellipse) ---
    if is_single_stl || is_constant_rho
        x_rho_ellip = mean(rho_eff_ellip, 'omitnan'); 
        draw_custom_boxplot(ax(3), x_rho_ellip, AreaH_ellip, colors(hh,:));
        draw_custom_boxplot(ax(4), x_rho_ellip, AreaV_ellip, colors(hh,:));
    else
        draw_kde_contours(ax(3), rho_eff_ellip(idx), AreaH_ellip(idx), colors(hh,:));
        draw_kde_contours(ax(4), rho_eff_ellip(idx), AreaV_ellip(idx), colors(hh,:));
    end

    % --- ROW 3: 3D Effective Density (Sphere) vs 2D Area Ratio (Circle) ---
    if is_single_stl || is_constant_rho
        x_rho_sphere = mean(rho_eff_sphere, 'omitnan'); 
        draw_custom_boxplot(ax(5), x_rho_sphere, AreaH_circ, colors(hh,:));
        draw_custom_boxplot(ax(6), x_rho_sphere, AreaV_circ, colors(hh,:));
    else
        draw_kde_contours(ax(5), rho_eff_sphere(idx), AreaH_circ(idx), colors(hh,:));
        draw_kde_contours(ax(6), rho_eff_sphere(idx), AreaV_circ(idx), colors(hh,:));
    end
    
    % Store solid square for clear legend icons
    h_leg(hh) = plot(ax(1), NaN, NaN, 's', 'MarkerEdgeColor', colors(hh,:), 'MarkerFaceColor', colors(hh,:), 'MarkerSize', 8);
end

% Add Theoretical Scaling Line for Area Ratios (AR = rho_eff^(1/3))
x_theory = linspace(0, 1, 100);
y_theory = x_theory.^(1/3);

% Ellipsoid / Ellipse Row
plot(ax(3), x_theory, y_theory, '-', 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5);
plot(ax(4), x_theory, y_theory, '-', 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5);

% Sphere / Circle Row
h_theory = plot(ax(5), x_theory, y_theory, '-', 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5);
plot(ax(6), x_theory, y_theory, '-', 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5);

% Add line for perfect 1:1 correlation on Aspect Ratio plots
plot(ax(1), [0 1], [0 1], 'k--', 'LineWidth', 2);
plot(ax(2), [0 1], [0 1], 'k--', 'LineWidth', 2);

%% Formatting and Aesthetics
tick_vals = 0:0.2:1.0;
tick_labels = {'0','0.2','0.4','0.6','0.8','1.0'};

for a = 1:6
    % Shift X-axis left slightly (-0.05) to expose any data resting at exactly 0
    xlim(ax(a), [0 1.0]);
    ylim(ax(a), [0 1]);
    set(ax(a), 'XTick', tick_vals, 'YTick', tick_vals, ...
               'TickLabelInterpreter', 'latex', 'FontSize', 16, 'LineWidth', 1.4, ...
               'ticklength', [0.02, 0.04]);
end

% Restore X-labels on ALL rows because the X-axis variable changes per row
set(ax(1), 'XTickLabel', tick_labels, 'YTickLabel', tick_labels);
set(ax(2), 'XTickLabel', tick_labels, 'YTickLabel', '');
set(ax(3), 'XTickLabel', tick_labels, 'YTickLabel', tick_labels);
set(ax(4), 'XTickLabel', tick_labels, 'YTickLabel', '');
set(ax(5), 'XTickLabel', tick_labels, 'YTickLabel', tick_labels);
set(ax(6), 'XTickLabel', tick_labels, 'YTickLabel', '');

% Titles (Top Row Only)
title(ax(1), 'Horizontal', 'Interpreter', 'latex', 'FontSize', 22);
title(ax(2), 'Vertical', 'Interpreter', 'latex', 'FontSize', 22);

% Y-Labels
ylabel(ax(1), '2D Aspect Ratio (Ellipse)', 'Interpreter', 'latex', 'FontSize', 18);
ylabel(ax(3), '2D Area Ratio (Ellipse)', 'Interpreter', 'latex', 'FontSize', 18);
ylabel(ax(5), '2D Area Ratio (Circle)', 'Interpreter', 'latex', 'FontSize', 18);

% X-Labels
xlabel(ax(1), '3D Axis Ratio ($c/a$)', 'Interpreter', 'latex', 'FontSize', 18);
xlabel(ax(2), '3D Axis Ratio ($c/a$)', 'Interpreter', 'latex', 'FontSize', 18);
xlabel(ax(3), '3D Eff. Density (Ellipsoid)', 'Interpreter', 'latex', 'FontSize', 18);
xlabel(ax(4), '3D Eff. Density (Ellipsoid)', 'Interpreter', 'latex', 'FontSize', 18);
xlabel(ax(5), '3D Eff. Density (Sphere)', 'Interpreter', 'latex', 'FontSize', 18);
xlabel(ax(6), '3D Eff. Density (Sphere)', 'Interpreter', 'latex', 'FontSize', 18);

% Combine original handles/labels with the theoretical line for the legend
all_handles = [h_leg, h_theory];
all_labels = [legend_labels, {'$x^{1/3}$'}];

% Horizontal Legend placed at bottom center
leg = legend(ax(5), all_handles, all_labels, 'Interpreter', 'latex', 'FontSize', 16, ...
       'Orientation', 'horizontal', 'NumColumns', 5, 'Box', 'on');
leg.Position(1) = 0.5 - leg.Position(3)/2; % Center horizontally
leg.Position(2) = 0.02; % Drop down into the expanded bottom margin


%% LOCAL FUNCTION 1: True Adjacent Value Boxplot (NaN safe)
function draw_custom_boxplot(ax_h, x_val, y_data, c)
    % Force into 1D array to prevent dimension mismatch
    y_data = y_data(:);
    
    % Skip plotting if the 3D property (X-axis) is fully NaN
    if isnan(x_val)
        return;
    end

    % Calculate quartiles and mean safely
    q1 = prctile(y_data, 25);
    med = median(y_data, 'omitnan');
    q3 = prctile(y_data, 75);
    avg = mean(y_data, 'omitnan');
    iqr_val = q3 - q1;
    
    % True adjacent values safely
    adj_low = min(y_data(y_data >= q1 - 1.5 * iqr_val), [], 'omitnan');
    if isempty(adj_low), adj_low = min(y_data, [], 'omitnan'); end
    
    adj_high = max(y_data(y_data <= q3 + 1.5 * iqr_val), [], 'omitnan');
    if isempty(adj_high), adj_high = max(y_data, [], 'omitnan'); end
    
    % Identify outliers strictly outside the adjacent values
    outliers = y_data(y_data < adj_low | y_data > adj_high);

    hw = 0.015; % Half-width for the horizontal slashes
    
    % 1. Vertical line from lower whisker to upper whisker
    plot(ax_h, [x_val x_val], [adj_low adj_high], '-', 'Color', c, 'LineWidth', 1.5);
    
    % 2. Horizontal whisker caps
    plot(ax_h, [x_val-hw/2 x_val+hw/2], [adj_low adj_low], '-', 'Color', c, 'LineWidth', 1.5);
    plot(ax_h, [x_val-hw/2 x_val+hw/2], [adj_high adj_high], '-', 'Color', c, 'LineWidth', 1.5);

    % 3. Horizontal slashes for Q1 (25th) and Q3 (75th)
    plot(ax_h, [x_val-hw x_val+hw], [q1 q1], '-', 'Color', c, 'LineWidth', 1.5);
    plot(ax_h, [x_val-hw x_val+hw], [q3 q3], '-', 'Color', c, 'LineWidth', 1.5);
    
    % 4. Median marker (Bold Horizontal slash)
    plot(ax_h, [x_val-hw x_val+hw], [med med], '-', 'Color', c, 'LineWidth', 3.0);
    
    % 5. Arithmetic Mean (Circle)
    plot(ax_h, x_val, avg, 'o', 'MarkerEdgeColor', c, 'MarkerFaceColor', 'w', 'MarkerSize', 5, 'LineWidth', 1.5);
    
    % 6. Outliers (+)
    if ~isempty(outliers)
        plot(ax_h, repmat(x_val, length(outliers), 1), outliers, '+', ...
                'Color', c, 'MarkerSize', 4, 'LineWidth', 0.8);
    end
end

%% LOCAL FUNCTION 2: Heavily Smoothed 2D KDE Contours
function draw_kde_contours(ax_h, x, y, c)
    % Force into 1D column vectors to prevent implicit expansion bugs
    x = x(:); 
    y = y(:);
    
    valid = ~isnan(x) & ~isnan(y);
    x = x(valid); y = y(valid);
    if length(x) < 10, return; end

    % Define fixed, expanded bins to prevent edge truncation
    Nbins = 80;
    xb = linspace(-0.1, 1.1, Nbins);
    yb = linspace(-0.1, 1.1, Nbins);
    
    % 2D Histogram
    [N, Xedges, Yedges] = histcounts2(x, y, xb, yb);
    
    % Heavy smoothing using a 9x9 Gaussian kernel
    [Xg, Yg] = meshgrid(-4:4, -4:4);
    sigma = 2.0;
    kernel = exp(-(Xg.^2 + Yg.^2)/(2*sigma^2));
    kernel = kernel / sum(kernel(:));
    
    Ns = conv2(N, kernel, 'same');
    
    % Get bin centers
    xc = Xedges(1:end-1) + diff(Xedges)/2;
    yc = Yedges(1:end-1) + diff(Yedges)/2;
    
    % Draw 4 unfilled contour levels
    max_val = max(Ns(:));
    if max_val > 0
        levels = linspace(max_val*0.15, max_val*0.9, 4);
        contour(ax_h, xc, yc, Ns', levels, 'Color', c, 'LineWidth', 1.5);
    end
end