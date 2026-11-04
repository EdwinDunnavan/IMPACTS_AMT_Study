%% plot_mmd_bootstrapped_boxplots.m
% Generates a 6x3 Trellis grid of grouped boxplots showing the bootstrapped 
% MMD distributions for 8 individual 2020 flights + 1 combined dataset.
% Evaluates 3 Models: Ellipsoids, STL (Irregular), and STL (All).

%clear; clc;

N_sim = 1e6;
fyear = {'2020'};
use_instrument_filter = true;

%% 1. Initialization and Paths
paths = init_project();
outdir_comp = paths.figures;

STL_folder = 'Irregular_1k_fuse_TEST3';
STL_sim    = 'Irregular_2020_1e6/';
STL_full_files = fullfile(paths.simulations, STL_folder, STL_sim);

if ~exist('m','var')
    load(paths.ellipse_file,'-mat')
end

% Extract only 2020 flights from the struct fields
all_fields = fieldnames(m);
flight_fields = all_fields(startsWith(all_fields, 'f2020'));
N_flights = length(flight_fields);
N_cases = N_flights + 1;

% Pre-allocate labels (Formats 'f20200118' -> '20200118')
legend_labels = cell(1, N_cases);
for c = 1:N_flights
    legend_labels{c} = strrep(flight_fields{c}, 'f', ''); 
end
legend_labels{N_cases} = 'ALL 2020';

% Define LaTeX single-line metric variables
dist_labels_tex = {
    '$D_{\mathrm{major}}$ -- $\varphi_{\mathrm{proj}}$', ...
    '$D_{\mathrm{major}}$ -- $\mathrm{AR}$', ...
    '$\theta_{\mathrm{proj}}$ -- $\varphi_{\mathrm{proj}}$', ...
    '$\theta_{\mathrm{proj}}$ -- $\mathrm{AR}$', ...
    '$\theta_{\mathrm{proj}}$ -- $D_{\mathrm{major}}$', ...
    '$\mathrm{AR}$ -- $\varphi_{\mathrm{proj}}$'
    };
N_metrics = length(dist_labels_tex);

% Define shared axis formatting (Hidden Figures)
shared_args = {
    'stack_all', true, ...
    'align_ticks', true, ...
    'show_cbar', false, ...
    'show_fig', false, ... % CRITICAL: Keep false to prevent massive popups
    'save_fig', false, ...
    'outdir', outdir_comp, ...
    'ang_ticks', -90:30:90, ...
    'AspectRatio_ticks', 0.:0.2:1, ...
    'AreaRatio_ticks', 0.2:0.2:1
};

% Simulation parameters
pops = struct();
pops(1).pop_frac = 1.0; pops(1).nu = 1.0; pops(1).Dmean = 2.0;
pops(1).AR_scale = 0.59; pops(1).AR_min = 0.1; pops(1).pba = 0.75; 
pops(1).pcb = 0.75; pops(1).abatog = 0.6; pops(1).rhovar_frac = 0.02;
pops(1).ang_xz = -40; pops(1).ang_xy = 45; pops(1).kappa = 3.5; 
pops(1).psimean = 0; pops(1).varpsi = 0.001;
pops(2).pop_frac = 0; 
sim_args_pop = {'N', N_sim, 'use_instrument_filter', use_instrument_filter, 'pops', pops};

%% 2. Generate Simulated Distributions (Once)
fprintf('Generating Ellipsoid Sim Background...\n');
ellip_sim_data = fwd_project_ellipsoids(sim_args_pop{:});
[fig_sim, ax_sim] = plot_universal_joint(ellip_sim_data, 'sim_ellipsoid', 'habit', 'all', shared_args{:});

fprintf('Generating STL Sim Background (Loading Data)...\n');
s_STL = read_stl_data(STL_full_files);

fprintf('Generating STL (Irregular Filtered) Background...\n');
[fig_stl_i, ax_stl_i] = plot_universal_joint(s_STL, 'sim', 'habit', 'i', shared_args{:});

fprintf('Generating STL (All Particles) Background...\n');
[fig_stl_all, ax_stl_all] = plot_universal_joint(s_STL, 'sim', 'habit', 'all', shared_args{:});

% Extract Simulation Pairs
sim_H_pairs = cell(1, 6); sim_V_pairs = cell(1, 6);
stl_i_H_pairs = cell(1, 6); stl_i_V_pairs = cell(1, 6);
stl_all_H_pairs = cell(1, 6); stl_all_V_pairs = cell(1, 6);

for i = 1:6
    idx_H = (i - 1) * 2 + 1; idx_V = idx_H + 1;
    
    % Ellipsoids
    h_sim_H = findobj(ax_sim(idx_H), 'Type', 'Histogram2');
    h_sim_V = findobj(ax_sim(idx_V), 'Type', 'Histogram2');
    sim_H_pairs{i} = [h_sim_H.Data(:,1), h_sim_H.Data(:,2)];
    sim_V_pairs{i} = [h_sim_V.Data(:,1), h_sim_V.Data(:,2)];
    
    % STL (Irregular)
    h_stl_i_H = findobj(ax_stl_i(idx_H), 'Type', 'Histogram2');
    h_stl_i_V = findobj(ax_stl_i(idx_V), 'Type', 'Histogram2');
    stl_i_H_pairs{i} = [h_stl_i_H.Data(:,1), h_stl_i_H.Data(:,2)];
    stl_i_V_pairs{i} = [h_stl_i_V.Data(:,1), h_stl_i_V.Data(:,2)];

    % STL (All)
    h_stl_all_H = findobj(ax_stl_all(idx_H), 'Type', 'Histogram2');
    h_stl_all_V = findobj(ax_stl_all(idx_V), 'Type', 'Histogram2');
    stl_all_H_pairs{i} = [h_stl_all_H.Data(:,1), h_stl_all_H.Data(:,2)];
    stl_all_V_pairs{i} = [h_stl_all_V.Data(:,1), h_stl_all_V.Data(:,2)];
end

close(fig_sim); close(fig_stl_i); close(fig_stl_all);

%% 3. Pre-allocate Cell Arrays for Boxplots
cell_H_ellip = cell(1, N_cases); cell_V_ellip = cell(1, N_cases);
cell_H_stl_i = cell(1, N_cases); cell_V_stl_i = cell(1, N_cases);
cell_H_stl_all = cell(1, N_cases); cell_V_stl_all = cell(1, N_cases);

rng(42); % Lock global seed for bootstrapping
N_sample = 10000;
n_bootstraps = 30;

%% 4. Loop Through Individual Flights + Combined Case
for c = 1:N_cases
    fprintf('Processing %s (%d/%d)...\n', legend_labels{c}, c, N_cases);
    
    % Select target flight field or '2020' for combined
    if c <= N_flights
        target = flight_fields(c);
    else
        target = {'2020'}; 
    end
    
    % Generate hidden Obs Figure and extract pairs
    [fig_obs, ax_obs] = plot_universal_joint(m, 'obs_multi', 'target_fields', target, 'habit', 'i', shared_args{:});
    obs_H_pairs = cell(1, 6); obs_V_pairs = cell(1, 6);
    
    for i = 1:6
        idx_H = (i - 1) * 2 + 1; idx_V = idx_H + 1;
        h_obs_H = findobj(ax_obs(idx_H), 'Type', 'Histogram2');
        h_obs_V = findobj(ax_obs(idx_V), 'Type', 'Histogram2');
        obs_H_pairs{i} = [h_obs_H.Data(:,1), h_obs_H.Data(:,2)];
        obs_V_pairs{i} = [h_obs_V.Data(:,1), h_obs_V.Data(:,2)];
    end
    close(fig_obs);
    
    % Bootstrapped MMD Storage Matrices
    mat_H_ellip = zeros(n_bootstraps, N_metrics);
    mat_V_ellip = zeros(n_bootstraps, N_metrics);
    mat_H_stl_i = zeros(n_bootstraps, N_metrics);
    mat_V_stl_i = zeros(n_bootstraps, N_metrics);
    mat_H_stl_all = zeros(n_bootstraps, N_metrics);
    mat_V_stl_all = zeros(n_bootstraps, N_metrics);
    
    % Calculate MMD across all distributions
    for i = 1:N_metrics
        for b = 1:n_bootstraps
            % 1. Ellipsoid MMD
            mat_H_ellip(b, i) = process_mmd(obs_H_pairs{i}, sim_H_pairs{i}, N_sample);
            mat_V_ellip(b, i) = process_mmd(obs_V_pairs{i}, sim_V_pairs{i}, N_sample);
            
            % 2. STL (Irregular Filtered) MMD
            mat_H_stl_i(b, i) = process_mmd(obs_H_pairs{i}, stl_i_H_pairs{i}, N_sample);
            mat_V_stl_i(b, i) = process_mmd(obs_V_pairs{i}, stl_i_V_pairs{i}, N_sample);

            % 3. STL (All Particles) MMD
            mat_H_stl_all(b, i) = process_mmd(obs_H_pairs{i}, stl_all_H_pairs{i}, N_sample);
            mat_V_stl_all(b, i) = process_mmd(obs_V_pairs{i}, stl_all_V_pairs{i}, N_sample);
        end
    end
    
    % Store in grouped cell arrays
    cell_H_ellip{c} = mat_H_ellip; cell_V_ellip{c} = mat_V_ellip;
    cell_H_stl_i{c} = mat_H_stl_i; cell_V_stl_i{c} = mat_V_stl_i;
    cell_H_stl_all{c} = mat_H_stl_all; cell_V_stl_all{c} = mat_V_stl_all;
end

%% 5. Global Limits & Plotting Setup
theoretical_max_mmd = sqrt(2 - 2*exp(-4)); % Approx 1.401

% Find absolute minimum Similarity Score to set dynamic Y-limits
global_min_sim = 100;
for i = 1:N_metrics
    max_mmd_temp = max([ ...
        max(cellfun(@(x) max(x(:, i), [], 'all'), cell_H_ellip)), ...
        max(cellfun(@(x) max(x(:, i), [], 'all'), cell_H_stl_i)), ...
        max(cellfun(@(x) max(x(:, i), [], 'all'), cell_H_stl_all)), ...
        max(cellfun(@(x) max(x(:, i), [], 'all'), cell_V_ellip)), ...
        max(cellfun(@(x) max(x(:, i), [], 'all'), cell_V_stl_i)), ...
        max(cellfun(@(x) max(x(:, i), [], 'all'), cell_V_stl_all)) ...
    ]);
    min_sim_temp = (1 - (max_mmd_temp / theoretical_max_mmd)) * 100;
    global_min_sim = min(global_min_sim, min_sim_temp);
end

% Snap bottom Y-limit to the nearest multiple of 5
y_lim_bottom = floor((global_min_sim - 2) / 5) * 5; 
global_y_lim = [y_lim_bottom, 100]; 
y_ticks_array = y_lim_bottom : 5 : 100;

colors = [0, 0.4470, 0.7410; 0.8500, 0.3250, 0.0980; 0.4660, 0.6740, 0.1880];

% 3x2 Mapping matching Figure 10 layout
% Subplot Index -> Original Metric Index
metric_map = [1, 3, 2, 4, 6, 5]; 

fig_master = figure('units','normalized','position',[0.05 0.05 0.5 0.9]);
ax = tight_subplot(3, 2, [0.08 0.03], [0.18 0.05], [0.12 0.02]); 

% Pull the pre-allocated legend labels (which contain 'All' and the flight dates)
x_tick_labels = legend_labels; 
x_centers = 0 : (N_cases - 1);

for p = 1:6
    % Map subplot index 'p' to the specific metric 'i'
    i = metric_map(p);
    
    axes(ax(p)); hold on; box on;
    
    Y_matrix_H = zeros(N_cases, 3);
    Y_matrix_V = zeros(N_cases, 3);
    
    for c = 1:N_cases
        % Extract worst-case MMDs
        max_H_e = max(cell_H_ellip{c}(:, i)); max_V_e = max(cell_V_ellip{c}(:, i));
        max_H_si = max(cell_H_stl_i{c}(:, i)); max_V_si = max(cell_V_stl_i{c}(:, i));
        max_H_sa = max(cell_H_stl_all{c}(:, i)); max_V_sa = max(cell_V_stl_all{c}(:, i));
        
        % Convert to Similarity Percentage
        Y_matrix_H(c, 1) = (1 - (max_H_e / theoretical_max_mmd)) * 100;
        Y_matrix_H(c, 2) = (1 - (max_H_si / theoretical_max_mmd)) * 100;
        Y_matrix_H(c, 3) = (1 - (max_H_sa / theoretical_max_mmd)) * 100;
        
        Y_matrix_V(c, 1) = (1 - (max_V_e / theoretical_max_mmd)) * 100;
        Y_matrix_V(c, 2) = (1 - (max_V_si / theoretical_max_mmd)) * 100;
        Y_matrix_V(c, 3) = (1 - (max_V_sa / theoretical_max_mmd)) * 100;
    end
    
    % Overlay Bars: H and V share same width (0.8) and no edges
    b_H = bar(ax(p), x_centers, Y_matrix_H, 0.8, 'grouped');
    for k = 1:3
        b_H(k).FaceColor = colors(k, :);
        b_H(k).EdgeColor = 'none';
        b_H(k).FaceAlpha = 0.8; % Mostly opaque
    end
    
    b_V = bar(ax(p), x_centers, Y_matrix_V, 0.8, 'grouped');
    for k = 1:3
        b_V(k).FaceColor = colors(k, :);
        b_V(k).EdgeColor = 'none';
        b_V(k).FaceAlpha = 0.4; % Highly transparent overlay
    end
    
    % Draw explicit Flight Dividers (Between groups)
    for div_x = 0.5 : 1 : 7.5
        xline(ax(p), div_x, '-', 'Color', [0.88 0.88 0.88], 'LineWidth', 1.2);
    end
    
    % Formatting limits and ticks
    ylim(ax(p), global_y_lim);
    xlim(ax(p), [-0.6, 8.6]); 
    
    % Apply LaTeX tick interpreter globally to all panels
    set(ax(p), 'TickLabelInterpreter', 'latex');
    
    % Y-Axis logic (Left column only)
    if mod(p, 2) ~= 0
        set(ax(p), 'YTick', y_ticks_array, 'YTickLabel', arrayfun(@num2str, y_ticks_array, 'UniformOutput', false));
    else
        set(ax(p), 'YTick', y_ticks_array, 'YTickLabel', '');
    end
    
    % X-Axis logic (Bottom row only: Panels 5 and 6)
    set(ax(p), 'XTick', x_centers);
    if p == 5 || p == 6
        set(ax(p), 'XTickLabel', x_tick_labels);
       % xlabel(ax(p), 'Flight Date', 'Interpreter', 'latex', 'FontSize', 16);
        xtickangle(ax(p), 45); % Restored 45-degree angle to fit individual dates 
    else
        set(ax(p), 'XTickLabel', '');
    end
    
    % Standardize all axis tick label font sizes to 14
    set(ax(p), 'FontSize', 14, 'Layer', 'bottom','ticklength',[0.025 0.05],'LineWidth',1.4);
    grid(ax(p), 'off');
    % Title: Joint Metric Variables (Standardized FontSize 18)
    title(ax(p), dist_labels_tex{i}, 'Interpreter', 'latex', 'FontSize', 22);

end

% Link Y-limits across all subplots
linkaxes(ax, 'y');

%% 6. Master Y-Label & Multi-Row Legend
% 1. Create invisible axes for the Master Y-Label
ax_master_ylab = axes(fig_master, 'Position', [0 0 1 1], 'Visible', 'off');
text(ax_master_ylab, 0.025, 0.53, 'Similarity (\%)', 'Interpreter', 'latex', ...
    'FontSize', 32, 'Rotation', 90, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

% 2. Create invisible axes for Legend Row 1 (The 3 Models)
ax_leg1 = axes(fig_master, 'Position', [0 0 1 1], 'Visible', 'off');
hold(ax_leg1, 'on'); 
h_leg1 = gobjects(1, 3);
for c = 1:3
    h_leg1(c) = patch(ax_leg1, NaN, NaN, colors(c,:), 'EdgeColor', 'none', 'FaceAlpha', 0.8);
end
leg1_labels = {'Ellipsoids', 'STL (Irregular Filtered)', 'STL (All)'};
leg1 = legend(ax_leg1, h_leg1, leg1_labels, 'Interpreter', 'latex', ...
    'FontSize', 15, 'Orientation', 'horizontal', 'Box', 'off');
leg1.Position = [0.15 0.04 0.8 0.03]; % Positioned higher

% 3. Create invisible axes for Legend Row 2 (H vs V Channel Transparency)
ax_leg2 = axes(fig_master, 'Position', [0 0 1 1], 'Visible', 'off');
hold(ax_leg2, 'on'); 
h_leg2 = gobjects(1, 2);
h_leg2(1) = patch(ax_leg2, NaN, NaN, [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.8);
h_leg2(2) = patch(ax_leg2, NaN, NaN, [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
leg2_labels = {'Horizontal Channel (Opaque)', 'Vertical Channel (Transparent)'};
leg2 = legend(ax_leg2, h_leg2, leg2_labels, 'Interpreter', 'latex', ...
    'FontSize', 15, 'Orientation', 'horizontal', 'Box', 'off');
leg2.Position = [0.22 0.005 0.56 0.03]; % Positioned directly below Row 1


%% ========================================================================
%  HELPER FUNCTIONS
%  ========================================================================

function mmd_val = process_mmd(X, Y, N_sample)
    min_pts = min([size(X, 1), size(Y, 1), N_sample]);
    X = X(randsample(size(X,1), min_pts), :);
    Y = Y(randsample(size(Y,1), min_pts), :);
    
    min_bounds = min([X; Y], [], 1);
    max_bounds = max([X; Y], [], 1);
    
    X_norm = (X - min_bounds) ./ (max_bounds - min_bounds);
    Y_norm = (Y - min_bounds) ./ (max_bounds - min_bounds);
    
    try
        mmd_val = compute_mmd_gpu(X_norm, Y_norm, 0.5);
    catch
        mmd_val = NaN;
    end
end

function mmd_val = compute_mmd_gpu(X, Y, sigma)
    X = gpuArray(X); Y = gpuArray(Y);
    n = size(X, 1); m = size(Y, 1);
    
    X_sq = sum(X.^2, 2); Y_sq = sum(Y.^2, 2);
    XX = max(X_sq - 2 * (X * X') + X_sq', 0);
    YY = max(Y_sq - 2 * (Y * Y') + Y_sq', 0);
    XY = max(X_sq - 2 * (X * Y') + Y_sq', 0);
    
    gamma = 1 / (2 * sigma^2);
    K_XX = exp(-gamma * XX); K_YY = exp(-gamma * YY); K_XY = exp(-gamma * XY);
    
    mmd2 = (1 / n^2) * sum(K_XX, 'all') + (1 / m^2) * sum(K_YY, 'all') - (2 / (n * m)) * sum(K_XY, 'all');
    mmd_val = gather(sqrt(max(mmd2, 0)));
end