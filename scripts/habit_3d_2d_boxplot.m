
% habit_3d_2d_boxplot.m
% Computes and plots the 3D/2D Correction Factor using grouped boxplots.
% Panel 1: Horizontal Projections | Panel 2: Vertical Projections
% X-Axis: 7 Parameterization Metrics
% Grouping: Ice Habit Colors

paths = init_project();
simDir = paths.simulations;

% Included folders and labels
folders = {'Irregular_1k_fuse_TEST3/', 'Rosettes_10k/', 'Linear_MA94_10k/','Linear_MA94_10k/', 'CappedColumns_10k/','CappedColumns_10k/', 'Simulation_Dendrite/', 'Plates_AV70_10k/'};
test_folders = {'Irregular_2020_1e6/', 'Irregular_2020_1e6/', 'Linear_2020_1e6/','Linear_2022_2023_neg80deg_1e6/', 'Linear_2020_1e6/', 'Linear_2022_2023_1e6/', 'Random_fixed_1mm_1e6/', 'Random_1e6/'};
legend_labels = {'Irregular 2020', 'Bullet Rosettes 2020', 'Linear 2020','Linear 2022-2023', 'Capped Columns 2020','Capped Columns 2022-2023', 'Dendrite', 'Plates'};


metric_labels = {'$\varphi_{ca}\ /\ \varphi_{\mathrm{proj}}$', ...
    '$D_{\mathrm{max}}\ /\ D_{\mathrm{circ}}$', ...
    '$D_{\mathrm{max}}\ /\ 2r_{a}$', ...
    '$a\ /\ r_{a}$', ...
    '$\rho_{\mathrm{ellip}}\ /\ \mathrm{AR}_{\mathrm{ellip}}$', ...
    '$\rho_{\mathrm{sph}}\ /\ \mathrm{AR}_{\mathrm{circ}}$', ...
    '$\Psi\ /\ C$'};

N_habits = length(folders);
N_metrics = length(metric_labels);
interGroupSpace = 2; % Matches the setting in boxplotGroup
groupStride = N_habits + interGroupSpace;

% Calculate centers
first_center = (1 + N_habits) / 2;
group_centers = first_center + (0:(N_metrics-1)) * groupStride;

% Calculate dynamic xlim (last box position + 1 for padding)
last_box_x = 1 + (N_metrics - 1) * groupStride + (N_habits - 1);
x_max = last_box_x + 1;

colors = [
    0.50, 0.50, 0.50;  % Irregular
    0.10, 0.10, 0.10;  % Bullet Rosettes
    0.84, 0.37, 0.00;  % Linear 2020
    0.55, 0.36, 0.20;  % Linear 2022-2023
    0.35, 0.70, 0.90;  % Capped Columns 2020
    0.00, 0.45, 0.70;  % Capped Columns 2022-2023
    0.00, 0.62, 0.45;  % Dendrite
    0.49, 0.18, 0.56;  % Plates
    ];

% Pre-allocate cell arrays for boxplotGroup 
% Format: cell_H{hh} = [N x 7 matrix] 
cell_H = cell(1, N_habits);
cell_V = cell(1, N_habits);

%% 1. Loop through datasets and calculate Correction Factors (3D / 2D)
for hh = 1:N_habits

    % Read data
    stemp = read_stl_data(fullfile(simDir, folders{hh}, test_folders{hh}));

    % ---------------------------------------------------------
    % 2D Parameters (Force column vectors)
    % ---------------------------------------------------------
    ARH = stemp.rb_xz_cgal(:) ./ stemp.ra_xz_cgal(:);
    ARV = stemp.rb_xy_cgal(:) ./ stemp.ra_xy_cgal(:);

    AreaH_ellip = stemp.area_ratio_xz_cgal(:);
    AreaV_ellip = stemp.area_ratio_xy_cgal(:);

    AreaH_circ = stemp.particle_area_xz(:) ./ ((pi/4) .* stemp.Dmax_xz_cgal(:).^2);
    AreaV_circ = stemp.particle_area_xy(:) ./ ((pi/4) .* stemp.Dmax_xy_cgal(:).^2);

    % Clamp dilation artifacts for extremely thin particles
    AreaH_circ(AreaH_circ > 1.0) = 1.0;
    AreaV_circ(AreaV_circ > 1.0) = 1.0;

    % Circularity: 4*pi*Area / Perimeter^2
    CircH = (4 * pi * stemp.particle_area_xz(:)) ./ (stemp.particle_perimeter_xz(:).^2);
    CircV = (4 * pi * stemp.particle_area_xy(:)) ./ (stemp.particle_perimeter_xy(:).^2);

    % ---------------------------------------------------------
    % 3D Parameters (Force column vectors)
    % ---------------------------------------------------------
    phi_ca = stemp.c(:) ./ stemp.a(:); 
    rho_eff_ellip = stemp.effective_density(:);

    V_3D = abs(stemp.moments(1,:)'); 
    rho_eff_sphere = V_3D ./ ((pi/6) .* stemp.max_dim(:).^3);

    % True 3D Sphericity: (pi^(1/3) * (6V)^(2/3)) / SurfaceArea
    SA_3D = stemp.surface_area(:);
    Sphericity_3D = (pi^(1/3) * (6 .* V_3D).^(2/3)) ./ SA_3D;

    % ---------------------------------------------------------
    % CALCULATE CORRECTION FACTORS (3D / 2D)
    % ---------------------------------------------------------
    % 1. Aspect Ratio
    RatH_AR = phi_ca ./ ARH;
    RatV_AR = phi_ca ./ ARV;

    % 2. Maximum Dimension (True Max Dim / 2D CGAL Circle Diameter)
    RatH_SizeCirc = stemp.max_dim(:) ./ stemp.Dmax_xz_cgal(:);
    RatV_SizeCirc = stemp.max_dim(:) ./ stemp.Dmax_xy_cgal(:);

    % 3. Maximum Dimension (True Max Dim / 2D CGAL Ellipse Major Axis)
    RatH_SizeEllip = stemp.max_dim(:) ./ (2 .* stemp.ra_xz_cgal(:));
    RatV_SizeEllip = stemp.max_dim(:) ./ (2 .* stemp.ra_xy_cgal(:));

    % 4. Major Axis (True 3D Ellipsoid 2a / 2D Ellipse 2ra)
    RatH_Major = stemp.a(:) ./ stemp.ra_xz_cgal(:);
    RatV_Major = stemp.a(:) ./ stemp.ra_xy_cgal(:);

    % 5. Ellipsoid Area-Density
    RatH_ellip = rho_eff_ellip ./ AreaH_ellip;
    RatV_ellip = rho_eff_ellip ./ AreaV_ellip;

    % 6. Sphere Area-Density
    RatH_circ = rho_eff_sphere ./ AreaH_circ;
    RatV_circ = rho_eff_sphere ./ AreaV_circ;

    % 7. Complexity (3D Sphericity / 2D Circularity)
    RatH_Comp = Sphericity_3D ./ CircH;
    RatV_Comp = Sphericity_3D ./ CircV;

    % Clean data: Remove NaNs, Infs, and <=0 before appending
    valid_H = isfinite(RatH_AR) & isfinite(RatH_SizeCirc) & isfinite(RatH_SizeEllip) & isfinite(RatH_Major) & ...
              isfinite(RatH_ellip) & isfinite(RatH_circ) & isfinite(RatH_Comp) & RatH_circ > 0;

    valid_V = isfinite(RatV_AR) & isfinite(RatV_SizeCirc) & isfinite(RatV_SizeEllip) & isfinite(RatV_Major) & ...
              isfinite(RatV_ellip) & isfinite(RatV_circ) & isfinite(RatV_Comp) & RatV_circ > 0;

    % Store as N x 7 matrices
    cell_H{hh} = [RatH_AR(valid_H), RatH_SizeCirc(valid_H), RatH_SizeEllip(valid_H), RatH_Major(valid_H), RatH_ellip(valid_H), RatH_circ(valid_H), RatH_Comp(valid_H)];
    cell_V{hh} = [RatV_AR(valid_V), RatV_SizeCirc(valid_V), RatV_SizeEllip(valid_V), RatV_Major(valid_V), RatV_ellip(valid_V), RatV_circ(valid_V), RatV_Comp(valid_V)];

end

%% 2. Plotting Setup
% 2 Rows, 1 Column grid
%fig_pos = [0.0638    0.0510    0.5879    0.8885];
fig_pos = [0.0638    0.0510    0.7370    0.8885];
fig = figure('units','normalized','position',[0.0182    0.0323    0.8789    0.8885]); 
ax = tight_subplot(2, 1, [0.2 0.05], [0.10 0.12], [0.05 0.05]);

%% Panel 1: Horizontal Channel (H)
axes(ax(1)); hold on; grid on; box on;
boxplotGroup(ax(1), cell_H, 'Colors', colors, ...
    'GroupType', 'betweenGroups', 'groupLines', true, 'Symbol', '', ...
    'interGroupSpace', 2);

%% Panel 2: Vertical Channel (V)
axes(ax(2)); hold on; grid on; box on;
boxplotGroup(ax(2), cell_V, 'Colors', colors, ...
    'GroupType', 'betweenGroups', 'groupLines', true, 'Symbol', '', ...
    'interGroupSpace', 2);

%% 3. Formatting, Filling Boxplots, and Global Aesthetics
for a = 1:2

    % CRITICAL FIX 1: Delete hidden outlier objects!
    % This removes millions of invisible Line objects, freeing memory 
    % and preventing uistack from freezing the script.
    delete(findobj(ax(a), 'Tag', 'Outliers'));

    % --- SOPHISTICATED BOXPLOT FILL INJECTION ---
    hBoxes = findobj(ax(a), 'Tag', 'box');
    p_all = gobjects(length(hBoxes), 1); % Pre-allocate graphics array

    for j = 1:length(hBoxes)
        c = hBoxes(j).Color;
        p_all(j) = patch(ax(a), hBoxes(j).XData, hBoxes(j).YData, c, ...
            'FaceAlpha', 0.35, 'EdgeColor', c, 'LineWidth', 1.5);
    end

    % CRITICAL FIX 2: Vectorize uistack 
    % Push all patches to the back in a single operation rather than looping
    %uistack(p_all, 'bottom'); 

    % CRITICAL FIX: Remove empty graphics objects before stacking
    p_valid = p_all(isgraphics(p_all));

    if ~isempty(p_valid)
        uistack(p_valid, 'bottom'); 
    end

    set(findobj(ax(a), 'Tag', 'Median'), 'LineWidth', 2.0);
    set(findobj(ax(a), 'Tag', 'Whisker'), 'LineWidth', 1.2);
    set(findobj(ax(a), 'Tag', 'Upper Adjacent Value'), 'LineWidth', 1.2);
    set(findobj(ax(a), 'Tag', 'Lower Adjacent Value'), 'LineWidth', 1.2);

    % Draw Reference line for a "Perfect" Instrument (Correction Factor = 1.0)
    yline(ax(a), 1.0, 'k--', 'LineWidth', 2.0);

    % Linear Y-limits and custom Ticks
    ylim(ax(a), [0.001 3.0]); 
    set(ax(a), 'YTick', 0:0.5:3.0, 'YTickLabel', {'0', '0.5', '1.0', '1.5', '2.0', '2.5','3.0'});

    set(ax(a), 'XTick', group_centers);
    ax(a).XTickLabel = metric_labels;

    xlim(ax(a), [0, x_max]); % Dynamically extended XLim

    % Erase default Text objects created by boxplot
    set(findobj(ax(a), 'Type', 'text'), 'String', '');

    set(ax(a), 'TickLabelInterpreter', 'latex', 'FontSize', 16, 'LineWidth', 1.4);
end

ylabel(ax(1), {'Correction Factor', '(3D / 2D)'}, 'Interpreter', 'latex', 'FontSize', 20);
ylabel(ax(2), {'Correction Factor', '(3D / 2D)'}, 'Interpreter', 'latex', 'FontSize', 20);

title(ax(1), 'Horizontal Channel', 'Interpreter', 'latex', 'FontSize', 32);
title(ax(2), 'Vertical Channel', 'Interpreter', 'latex', 'FontSize', 32);

%% 4. Top-Center Master Legend
h_leg = zeros(1, N_habits);
for hh = 1:N_habits
    h_leg(hh) = plot(ax(1), NaN, NaN, 's', 'MarkerFaceColor', colors(hh,:), 'MarkerEdgeColor', colors(hh,:), 'MarkerSize', 12);
end

leg = legend(ax(1), h_leg, legend_labels, ...
    'Interpreter', 'latex', 'FontSize', 26, 'Orientation', 'vertical', 'Box', 'off','NumColumns',3);

% Manually position legend
leg.Position = [-0.0119    0.4519    1.0046    0.1021];
leg.ItemTokenSize = [50; 20];

% Apply custom bounding box coordinates
set(ax(1),'units','normalized','position',[ 0.1160    0.6296    0.8798    0.3101])
set(ax(2),'units','normalized','position',[0.1160    0.0458    0.8798    0.3101])

%% 5. Print Statistical Summary Tables to Console
fprintf('\n================================================================================\n');
fprintf('                3D/2D CORRECTION FACTOR STATISTICS (MANUSCRIPT DATA)              \n');
fprintf('================================================================================\n');

table_metric_names = {'Aspect Ratio (3D/2D)', 'Max Dim / D_circ', 'Max Dim / 2ra', ...
    'Major Axis (a/ra)', 'Ellipsoid Area-Density', ...
    'Sphere Area-Density', 'Morphological Complexity'};

fp_str ='%-22s %-4s %5.4f ± %-6.4f %-10.4f %-10.4f %-10.4f\n';

for mm = 1:length(table_metric_names)
    fprintf('\n--- Metric %d: %s ---\n', mm, table_metric_names{mm});
    fprintf('%-22s %-4s %-15s %-10s %-10s %-10s\n', 'Habit', 'Ch', 'Mean ± Std', '25th', 'Median', '75th');
    fprintf('--------------------------------------------------------------------------------\n');

    for hh = 1:N_habits
        % H Channel Stats
        data_H = cell_H{hh}(:, mm);
        mean_H = mean(data_H, 'omitnan'); 
        std_H  = std(data_H, 'omitnan');
        pct_H  = prctile(data_H, [25 50 75]);

        fprintf(fp_str, ...
            legend_labels{hh}, 'H', mean_H, std_H, pct_H(1), pct_H(2), pct_H(3));

        % V Channel Stats
        data_V = cell_V{hh}(:, mm);
        mean_V = mean(data_V, 'omitnan'); 
        std_V  = std(data_V, 'omitnan');
        pct_V  = prctile(data_V, [25 50 75]);

        fprintf(fp_str, ...
            '', 'V', mean_V, std_V, pct_V(1), pct_V(2), pct_V(3));
    end
    fprintf('\n');
end

%% 6. Calculate H vs V Similarity Metrics (For Abstract/Manuscript)
fprintf('\n================================================================================\n');
fprintf('                 H vs V CHANNEL SIMILARITY & DIVERGENCE METRICS                   \n');
fprintf('================================================================================\n');
fprintf('%-22s %-25s %-15s %-15s\n', 'Habit', 'Metric', 'Median Diff (%)', 'KS Stat (Max Dev)');
fprintf('--------------------------------------------------------------------------------\n');

max_med_diff = 0;
max_ks_stat = 0;

for hh = 1:N_habits
    for mm = 1:length(table_metric_names)

        data_H = cell_H{hh}(:, mm);
        data_V = cell_V{hh}(:, mm);

        % Drop NaNs for valid comparisons
        data_H = data_H(~isnan(data_H));
        data_V = data_V(~isnan(data_V));

        if isempty(data_H) || isempty(data_V)
            continue;
        end

        % 1. Relative Median Difference (%)
        med_H = median(data_H);
        med_V = median(data_V);
        med_diff_pct = (abs(med_H - med_V) / mean([med_H, med_V])) * 100;

        % 2. Kolmogorov-Smirnov (KS) Statistic
        % Represents the maximum distance between the two cumulative distribution functions
        [~, ~, ks_stat] = kstest2(data_H, data_V);

        % Track overall maximums for the abstract
        if med_diff_pct > max_med_diff; max_med_diff = med_diff_pct; end
        if ks_stat > max_ks_stat; max_ks_stat = ks_stat; end

        fprintf('%-22s %-25s %-15.2f %-15.4f\n', ...
            legend_labels{hh}, table_metric_names{mm}, med_diff_pct, ks_stat);
    end
end

fprintf('--------------------------------------------------------------------------------\n');
fprintf('ABSTRACT SUMMARY NUMBERS:\n');
fprintf('Maximum Median Difference across ALL tests: %.2f%%\n', max_med_diff);
fprintf('Maximum KS Statistic (ECDF Deviation) across ALL tests: %.2f%%\n', max_ks_stat * 100);
fprintf('================================================================================\n\n');