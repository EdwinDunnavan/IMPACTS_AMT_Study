%% make_figure_14.m
% Generates the 5 temperature-binned joint distributions for Figure 14.

paths = init_project();

fyear = {'2020'};
%fyear = {'2022','2023'};

save_figs = false;
show_figs = true;

if ~exist('m','var')
load(paths.ellipse_file,'-mat')
end

% Define the temperature boundaries for the 5 rows (Top to Bottom)
T_max_bins = [-18, -12, -8, -3,  0];
T_min_bins = [-99, -18, -12, -8, -3]; % -99 acts as the floor for PCGL
row_labels = {'PCGL', 'DGL', 'PGL', 'NGL', 'AGG'};

% Define output directory specifically for this figure's panels
outdir_fig14 = paths.figures;

% Loop through the bins and generate the pairs
for ii = 1:length(T_max_bins)
    fprintf('Processing row %d: %s (%d to %d C)...\n', ...
        ii, row_labels{ii}, T_min_bins(ii), T_max_bins(ii));

    % Call the universal joint distribution plotter
    plot_universal_joint(m, 'obs_multi', ...
        'target_fields', fyear, ...
        'Temp_min', T_min_bins(ii), ...
        'Temp_max', T_max_bins(ii), ...
        'AspectRatio', true, ...
        'EllipseAngle', true, ...
        'Dmajor', false, ...
        'AreaRatio', false, ...
        'combine_all', false, ...  % Keeps them as individual 1x2 pairs
        'show_fig', show_figs, ...
        'save_fig', save_figs, ...
        'outdir', outdir_fig14,...
        'ang_ticks',-80:20:80,...
        'ang_ticklabels', {'$-80^{\circ}$', '$-60^{\circ}$', '$-40^{\circ}$', '$-20^{\circ}$','$0^{\circ}$','$20^{\circ}$','$40^{\circ}$','$60^{\circ}$', '$80^{\circ}$'})
       % 'ang_ticklabels', {'$-90^{\circ}$', '$-45^{\circ}$', '$0^{\circ}$', '$45^{\circ}$', '$90^{\circ}$'});
end

fprintf('\nDone! All 5 rows saved to %s\n', outdir_fig14);