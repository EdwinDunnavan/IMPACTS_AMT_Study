
%{
 generate_ellipsoid_sim_projections.m
 
 Generates Figure 16 which shows a myraid of marginal distribution aspect ratio tests
 for different ellipsoid and orientation assumptions along with the 3D aspect ratios.

%}


%% generate_ellipsoid_sim_projections.m
% Generates 3x3 grid comparing orientation assumptions against 2020 observations.

%% 1. Set up paths and Load Data
paths = get_project_paths();

if ~exist('m','var')
    load(paths.ellipse_file,'-mat');
end

outdir_comp = paths.figures;

cmap = 0.95.*flipud(pink);

%% 2. Extract 2020 Irregular Observations
%fprintf('Extracting 2020 Irregular Observations...\n');
%fnames = fieldnames(m);
%f2020_names = fnames(startsWith(fnames, 'f2020'));

%fyear = '2020';

fyear = {'2022','2023'};



if strcmp(fyear,'2020')

    yr_str = '2020';

else

    yr_str = '2022-2023';

end

fprintf(sprintf('Extracting %s Irregular Observations...\n',yr_str));
fnames = fieldnames(m);
f_names = fnames(startsWith(fnames, strcat('f',fyear)));

obs_H_AR = [];
obs_V_AR = [];

for k = 1:length(f_names)
    flight = m.(f_names{k});
    
    % Filter for irregular ('i') habit
    indH = (flight.H.habit == 'i');
    indV = (flight.V.habit == 'i');
    
    obs_H_AR = [obs_H_AR, flight.H.AR(indH)];
    obs_V_AR = [obs_V_AR, flight.V.AR(indV)];
end

%% 3. Figure Initialization
fig = figure('units','normalized','position',[0.1 0.1 0.6 0.8]);
%ax = tight_subplot(3, 3, [0.05 0.05], [0.1 0.08], [0.08 0.05]);
ax = tight_subplot(3, 3, [0.05 0.05], [0.15 0.04], [0.05 0.08]);

% Row Parameters [Row 1, Row 2, Row 3]
% ORIGINAL
%pba_vals = [0.95, 0.75, 0.65];
%pcb_vals = [0.60, 0.75, 0.95];

% NEW
pba_vals = [0.95, 0.77, 0.65];
pcb_vals = [0.60, 0.76, 0.95];

% Plotting Colors
c_obs  = [0.75 0.75 0.75]; % Shaded Grey
c_base = [0 0.4470 0.7410]; % Blue (Irregular 2020)
c_par  = [0.8500 0.3250 0.0980]; % Orange (Parallel)
c_skew = [0.4940 0.1840 0.5560]; % Purple (Skewed)
c_orth = [0.4660 0.6740 0.1880]; % Green (Orthogonal)

% Shared Simulation Parameters
N_sim = 1e6; % Reduced slightly for speed, bump to 1e6 for final
bins_1d = 0.3:0.005:1.0;
bins_2d = 0.2:0.01:1.0;

use_instrument_filter = false; % NOTE: The marginal distributions are nearly identical if use_instrument_filter=false!

switch true

    % Irregular Defaults 2020 NEW
    case any(strcmp(fyear,'2020'))

        pops(1).pop_frac = 1.0; 
        pops(1).nu = 0.2; 
        pops(1).Dmean = 2.0;
        pops(1).ar_min = 0.2;
        pops(1).AR_scale = 0.6;
        pops(1).AR_min  = 0.2;
        pops(1).AR_exponent = -0.27; 
        pops(1).AR_asymp = [];
        pops(1).AR_amp = [];
        pops(1).k_decay = [];
        pops(1).pba_exponent = [];
        pops(1).pcb_exponent = [];
        pops(1).abatog = 0.6; 
        pops(1).rhovar_frac = 0.02;
        pops(1).ang_xz = -40; 
        pops(1).ang_xy = 45; 
        pops(1).kappa = 3.5;
        
    case any(strcmp(fyear,{'2022','2023'}))
        
        % Irregular Defaults 2022-2023 NEW
        % --- 2022-2023: POPULATION 1: Irregular ---
        pops(1).pop_frac    = 0.70;
        pops(1).nu          = 0.2;
        pops(1).Dmean       = 0.5;
        pops(1).AR_scale    = 0.59;
        pops(1).AR_exponent = -0.27;
        pops(1).AR_min      = 0.2;
        pops(1).pba         = 0.78;
        pops(1).pba_exponent= [];
        pops(1).pcb         = 0.78;
        pops(1).pcb_exponent= [];
        pops(1).abatog      = 0.6;
        pops(1).rhovar_frac = 0.015;
        pops(1).ang_xz      = -40;
        pops(1).ang_xy      = -10;
        pops(1).kappa       = 3;
        pops(1).psimean     = 0;
        pops(1).varpsi      = 0.001;

end

% Irregular Defaults NEW
% use_instrument_filter = false;
% %pba = 0.78;
% %pcb = 0.78;
% %abatog = 0.85;
% ar_scale = 0.75;
% ar_min = 0.2;
% ar_exponent = [];
% a0 = [];
% ds = [];
% pbmean = 1.0;
% ang_xz = -40;
% ang_xy = 45;
% kappa = 4; % NEW
% %psimean = 0;
% %varpsi = 0.001;
% rhovar_frac = 0.02;
% AR_min = 0.2;
% AR_scale = 0.6; 
% AR_exponent = -0.27;

% sim_args = {'N', N_sim,...
%                    'use_instrument_filter', use_instrument_filter,...
%                    'ar_scale',ar_scale,...
%                    'ar_min',ar_min,...
%                    'ar_exponent',ar_exponent,...
%                    'a0',a0,...
%                    'ds',ds,...
%                    'pbmean',pbmean,...
%                    'ang_xz',ang_xz,...
%                    'ang_xy',ang_xy,...
%                    'kappa',kappa,...
%                    'rhovar_frac',rhovar_frac,...
%                    'AR_min',AR_min,...
%                    'AR_scale',AR_scale,...
%                    'AR_exponent',AR_exponent};

%% 4. Master Loop over Rows
for row = 1:3
    fprintf('Simulating Row %d...\n', row);
    
    pba_target = pba_vals(row);
    pcb_target = pcb_vals(row);
    
    % Axis indices for this row
    ax_H = ax((row-1)*3 + 1);
    ax_V = ax((row-1)*3 + 2);
    ax_B = ax((row-1)*3 + 3);
    
    %% --- COLUMN 3: Bivariate Beta Distribution ---
    % Generate beta distributions analytically
    abatog = 0.6; % ORIG
  %  abatog = 0.85; % NEW
    pbmin = pba_target / (1 - pba_target);
    pcmin = pba_target * pcb_target / (1 - pcb_target);
    abamin = max(pbmin, pcmin);
    abamax = 20;

    a_ba = abatog * abamax + (1 - abatog) * abamin;
    b_ba = ((1 / pba_target) - 1) * a_ba;
    b_cb = ((1 / pcb_target) - 1) * a_ba / pba_target;

    phiba_samp = betarnd(a_ba, b_ba, [1, N_sim]);
    phica_samp = phiba_samp .* betarnd(a_ba + b_ba, b_cb, [1, N_sim]);
    
    histogram2(ax_B, phiba_samp, phica_samp, bins_2d, bins_2d, ...
        'DisplayStyle', 'tile', 'LineStyle', 'none', 'Normalization', 'pdf');
    colormap(ax_B, cmap); % Matches your heat map color profile
    hold(ax_B, 'on');
    plot(ax_B, [0.2 1.0], [0.2 1.0], 'k-', 'LineWidth', 2); % 1:1 Line
    hold(ax_B, 'off');
    
    set(ax_B, 'xtick', 0.2:0.1:1.0, 'ytick', 0.2:0.1:1.0, 'TickLabelInterpreter', 'latex', 'FontSize', 14);
    xlim(ax_B, [0.2 1.0]); ylim(ax_B, [0.2 1.0]);
    grid(ax_B, 'on');
    
    % Text boxes
    text(ax_B, 0.25, 0.9, sprintf('$\\bar{\\varphi}_{ba} = %.2f$', pba_target), 'Interpreter', 'latex', 'FontSize', 16);
    text(ax_B, 0.25, 0.8, sprintf('$\\bar{\\varphi}_{cb} = %.2f$', pcb_target), 'Interpreter', 'latex', 'FontSize', 16);
    
    set(ax_B,'YAxisLocation','right')

    %% --- COLUMNS 1 & 2: 2D Ellipse Simulations ---
    % Base arguments to feed into simulator
   % sim_args = {'N', N_sim, 'pba', pba_target, 'pcb', pcb_target, 'use_instrument_filter', false, 'abatog', abatog};
    
    pops(1).pba = pba_target;
    pops(1).pcb = pcb_target;
    pops(1).abatog = abatog;

    % Run the 4 Orientations
    % 1. Base (No rolling variance)
    pops(1).psimean = 0; 
    pops(1).varpsi = 0.001;
    sim_base = fwd_project_ellipsoids('N', N_sim, 'use_instrument_filter', use_instrument_filter, 'pops', pops);
    
    % 2. Parallel Roll
    pops(1).psimean = 0; 
    pops(1).varpsi = 10;
    sim_par = fwd_project_ellipsoids('N', N_sim, 'use_instrument_filter', use_instrument_filter, 'pops', pops);
    
    % 3. Skewed Roll
    pops(1).psimean = 45; 
    pops(1).varpsi = 10;
    sim_skew = fwd_project_ellipsoids('N', N_sim, 'use_instrument_filter', use_instrument_filter, 'pops', pops);
    
    % 4. Orthogonal Roll
    pops(1).psimean = 90; 
    pops(1).varpsi = 10;
    sim_orth = fwd_project_ellipsoids('N', N_sim, 'use_instrument_filter', use_instrument_filter, 'pops', pops);

    
    %% ORIGINAL

    % sim_base   = fwd_project_ellipsoids(sim_args{:},  'pba', pba_target, 'pcb', pcb_target, 'abatog', abatog,...
    %                                                                                'psimean', 0,  'varpsi', 0.001);
    % 
    % sim_par    = fwd_project_ellipsoids(sim_args{:}, 'pba', pba_target, 'pcb', pcb_target, 'abatog', abatog,...
    %                                                                              'psimean', 0,  'varpsi', 10);
    % 
    % sim_skew   = fwd_project_ellipsoids(sim_args{:},  'pba', pba_target, 'pcb', pcb_target, 'abatog', abatog,...
    %                                                                               'psimean', 45, 'varpsi', 10);
    % 
    % sim_orth   = fwd_project_ellipsoids(sim_args{:}, 'pba', pba_target, 'pcb', pcb_target, 'abatog', abatog,...
    %                                                                              'psimean', 90, 'varpsi', 10);

    %% Plotting
    % Plot Horizontal (Col 1)
    hold(ax_H, 'on');
    histogram(ax_H, obs_H_AR, bins_1d, 'Normalization', 'pdf', 'DisplayStyle', 'bar', 'EdgeColor', 'none', 'FaceColor', c_obs);
    histogram(ax_H, sim_base.ar_xz, bins_1d, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', c_base, 'LineWidth', 2);
    histogram(ax_H, sim_par.ar_xz, bins_1d, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', c_par, 'LineWidth', 2);
    histogram(ax_H, sim_skew.ar_xz, bins_1d, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', c_skew, 'LineWidth', 2);
    histogram(ax_H, sim_orth.ar_xz, bins_1d, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', c_orth, 'LineWidth', 2);
    hold(ax_H, 'off');
    
    % Plot Vertical (Col 2)
    hold(ax_V, 'on');
    histogram(ax_V, obs_V_AR, bins_1d, 'Normalization', 'pdf', 'DisplayStyle', 'bar', 'EdgeColor', 'none', 'FaceColor', c_obs);
    histogram(ax_V, sim_base.ar_xy, bins_1d, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', c_base, 'LineWidth', 2);
    histogram(ax_V, sim_par.ar_xy, bins_1d, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', c_par, 'LineWidth', 2);
    histogram(ax_V, sim_skew.ar_xy, bins_1d, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', c_skew, 'LineWidth', 2);
    histogram(ax_V, sim_orth.ar_xy, bins_1d, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', c_orth, 'LineWidth', 2);
    hold(ax_V, 'off');
    
    % Formatting for H and V
    for a = [ax_H, ax_V]
        xlim(a, [0.3 1.0]); ylim(a, [0 5]);
        set(a, 'xtick', 0.3:0.1:1.0,'xticklabel', {'0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'},...
                  'ytick', 0:1:5,'yticklabel',0:1:5 ,'TickLabelInterpreter', 'latex', 'FontSize', 14);
        grid(a, 'on');
    end
    
    % Titles (Row 1 Only)
    if row == 1
        title(ax_H, 'Horizontal', 'Interpreter', 'latex', 'FontSize', 18);
        title(ax_V, 'Vertical', 'Interpreter', 'latex', 'FontSize', 18);
        title(ax_B, '3D Ellipsoid Aspect Ratios', 'Interpreter', 'latex', 'FontSize', 18);
    end
    
    % Y-Labels (Col 1 & 3 Only)
    ylabel(ax_H, 'Probability Density', 'Interpreter', 'latex', 'FontSize', 16);
    ylabel(ax_B, '$\varphi_{ca}$', 'rotation',270,'verticalalignment','bottom', 'Interpreter', 'latex', 'FontSize', 26);
    set(ax_V, 'YTickLabel', ''); % Hide middle panel Y-labels
    
    set(ax_B,'Layer','top','yticklabel',{'0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1.0'})

    % X-Labels (Row 3 Only)
    if row == 3
        xlabel(ax_H, '2D Ellipse Aspect Ratio', 'Interpreter', 'latex', 'FontSize', 16);
        xlabel(ax_V, '2D Ellipse Aspect Ratio', 'Interpreter', 'latex', 'FontSize', 16);
        x_pba = xlabel(ax_B, '$\varphi_{ba}$', 'Interpreter', 'latex', 'FontSize', 26);
        set(x_pba,'units','normalized');
        x_pba_pos = get(x_pba,'position');
        x_pba.Position(2) = x_pba_pos(2) + 0.07; % Shift up a bit.

    else
        set(ax_H, 'XTickLabel', '');
        set(ax_V, 'XTickLabel', '');
        set(ax_B, 'XTickLabel', '');
    end
end

for aa = ax

    set(aa,'linewidth',1.4,'ticklength',[0.025,0.05])

end


%% 5. Add Custom Legend
% Create dummy plots to safely assign the legend without breaking tight_subplot
leg_ax = axes(fig, 'Position', [0 0 1 1], 'Visible', 'off');
hold(leg_ax, 'on');
p1 = plot(leg_ax, nan, nan, 's', 'MarkerFaceColor', c_obs, 'MarkerEdgeColor', 'none', 'MarkerSize', 12);
p2 = plot(leg_ax, nan, nan, '-', 'Color', c_base, 'LineWidth', 2);
p3 = plot(leg_ax, nan, nan, '-', 'Color', c_par, 'LineWidth', 2);
p4 = plot(leg_ax, nan, nan, '-', 'Color', c_skew, 'LineWidth', 2);
p5 = plot(leg_ax, nan, nan, '-', 'Color', c_orth, 'LineWidth', 2);
hold(leg_ax, 'off');

lgd = legend(leg_ax, [p1, p2, p3, p4, p5], ...
    {'IMPACTS 2020', 'Irregular 2020', 'Parallel $\bar{\psi}_p$', 'Skewed $\bar{\psi}_p$', 'Orthogonal $\bar{\psi}_p$'}, ...
    'Interpreter', 'latex', 'FontSize', 14, 'Orientation', 'horizontal', 'NumColumns', 5);

% Position legend at the very bottom center
%lgd.Position = [0.5 - lgd.Position(3)/2, 0.02, lgd.Position(3), lgd.Position(4)];

set(lgd,'linewidth',2)

lgd.Position = [0.108716563298676,0.0121875,0.774999233046528,0.034427083333333];

