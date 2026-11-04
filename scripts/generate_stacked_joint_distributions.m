%% make_comparison_figure.m
% Generates the three 6-row PDF columns for the Obs vs Sim comparison.

N_sim = 1e6;
fyear = {'2020'};
%fyear = {'2022','2023'};
habit_type = 'irregular';
%habit_type = 'linear';
use_instrument_filter = true;
calc_MMD = true;
stl_comp = true;
stl_habit = false;

%% Irregular 2020 STL simulation
STL_folder = 'Irregular_1k_fuse_TEST3';
STL_sim    = 'Irregular_2020_1e6/';

paths = init_project();

STL_full_files = fullfile(paths.simulations,STL_folder,STL_sim);

if ~exist('m','var')
load(paths.ellipse_file,'-mat')
end

% Re-initialize pops struct.
pops = struct();

% Define output directory specifically for this figure's panels
outdir_comp = paths.figures;

switch habit_type

    case 'irregular'
    
        % Schima-identified "Irregular" habit
        habit = 'i';
        % PCGL temperature level
        Temp_min = -99;
        Temp_max = -18;
        
    case 'linear'

        % Schima-identified "Linear" habit
        habit = 'l';
        % NGL temperature level
        Temp_min = -8;
        Temp_max = -3;

end


switch true

    case (any(strcmp(fyear,'2020')) && (habit=='i'))

    % --- 2020: POPULATION 1: Irregular ---
        %pops(1).pop_frac    = 0.95;
        pops(1).pop_frac    = 1.0;
        pops(1).nu          = 1.0;
        pops(1).Dmean       = 2.0;
        pops(1).AR_scale    = 0.59;
        pops(1).AR_exponent = [];
        pops(1).AR_min      = 0.1;
        pops(1).pba         = 0.75;
        pops(1).pba_exponent= [];
        pops(1).pcb         = 0.75;
        %pops(1).pba         = 0.6;
        %pops(1).pcb         = 0.95;
        pops(1).pcb_exponent= [];
        pops(1).abatog      = 0.6;
        %pops(1).abatog      = 0.85;
        pops(1).rhovar_frac = 0.02;
        %pops(1).rhovar_frac = 0.0175;
        %pops(1).rhovar_frac = 0.015;
        %pops(1).ang_xz      = -48;
        pops(1).ang_xz       = -40;
        %pops(1).ang_xz      = -55;
        pops(1).ang_xy      = 45;
        %pops(1).kappa       = 5.0;
        %pops(1).kappa       = 4.5;
        pops(1).kappa       = 3.5;
        pops(1).psimean     = 0;
        pops(1).varpsi      = 0.001;

        % --- POPULATION 2: Columns (The Bump/Elbow) ---
        pops(2).pop_frac    = 1-pops(1).pop_frac;
        pops(2).nu          = 4.0;
        pops(2).Dmean       = 0.4; 
        pops(2).AR_scale    = 0.75; % Dense/Solid
        pops(2).AR_exponent = -0.15;  
        pops(2).AR_min      = 0.2;
        pops(2).pba         = 0.65;
        pops(2).pba_exponent= [];
        pops(2).pcb         = 0.65;
        pops(2).pcb_exponent= [];
        %pops(2).abatog      = 0.85;
        pops(2).abatog      = 0.95;
        %pops(2).rhovar_frac = 0.02;
        pops(2).rhovar_frac = 0.015;
        %pops(2).ang_xz      = -50;
        pops(2).ang_xz      = -75;
        %pops(2).ang_xy      = -80;
        pops(2).ang_xy      = 80;
        pops(2).kappa       = 10;
        pops(2).psimean     = 0;
        pops(2).varpsi      = 0.001;

    case (any(strcmp(fyear,{'2022','2023'})) && (habit=='i'))

% --- 2022-2023: POPULATION 1: Irregular ---

        % BASE!!
        % pops(1).pop_frac    = 0.8;
        % pops(1).nu          = 1.0;
        % pops(1).Dmean       = 0.5;
        % pops(1).AR_scale    = 0.59;
        % pops(1).AR_exponent = [];
        % pops(1).AR_min      = 0.1;
        % pops(1).pba         = 0.78;
        % pops(1).pba_exponent= [];
        % pops(1).pcb         = 0.78;
        % pops(1).pcb_exponent= [];
        % pops(1).abatog      = 0.6;
        % pops(1).rhovar_frac = 0.02;
        % pops(1).ang_xz      = -40;
        % pops(1).ang_xy      = -10;
        % pops(1).kappa       = 4.5;
        % pops(1).psimean     = 0;
        % pops(1).varpsi      = 0.001;

        pops(1).pop_frac    = 0.75;
        pops(1).nu          = 1.0;
        pops(1).Dmean       = 0.5;
        pops(1).AR_scale    = 0.59;
        pops(1).AR_exponent = [];
        pops(1).AR_min      = 0.1;
        pops(1).pba         = 0.78;
        pops(1).pba_exponent= [];
        pops(1).pcb         = 0.78;
        pops(1).pcb_exponent= [];
        pops(1).abatog      = 0.6;
        pops(1).rhovar_frac = 0.02;
        pops(1).ang_xz      = -40;
        pops(1).ang_xy      = -10;
        pops(1).kappa       = 3.5;
        pops(1).psimean     = 0;
        pops(1).varpsi      = 0.001;  


        % --- POPULATION 2: Columns (The Bump/Elbow) ---

        % BASE!
        pops(2).pop_frac    = 1-pops(1).pop_frac;
        pops(2).nu          = 4.0;
        pops(2).Dmean       = 0.8;
        %pops(2).Dmean       = 0.5;
        pops(2).AR_scale    = 0.68;
        pops(2).AR_exponent = [];
        pops(2).AR_min      = 0.1;
        pops(2).pba         = 0.65;
        %pops(2).pba_exponent = -0.2;
        pops(2).pba_exponent= [];
        pops(2).pcb         = 0.95;
        pops(2).pcb_exponent= [];
        pops(2).abatog      = 1.0;
        pops(2).rhovar_frac = 0.02;
        pops(2).ang_xz      = -70;
        pops(2).ang_xy      = -75;
        pops(2).kappa       = 10;
        %pops(2).kappa       = 50;
        pops(2).psimean     = 0;
        pops(2).varpsi      = 0.001;

        % % IF USING 2022-2023 COLUMNS!
        % pops(1).pop_frac    = 1.0;
        % pops(1).nu          = 3;
        % %pops(1).Dmean       = 0.75;
        % pops(1).Dmean       = 0.35;
        % pops(1).AR_scale    = 0.65;
        % %pops(1).AR_exponent = -0.2;
        % pops(1).AR_exponent = [];
        % %pops(1).AR_min      = 0.2;
        % pops(1).AR_min      = 0.1;
        % pops(1).pba         = 0.2201;
        % pops(1).pba_exponent = -0.5;
        % pops(1).pcb         = 0.95;
        % pops(1).pcb_exponent = [];
        % pops(1).abatog      = 0.5;
        % pops(1).rhovar_frac = 0.03;
        % pops(1).ang_xz      = -80;
        % pops(1).ang_xy      = -80;
        % pops(1).kappa       = 8.0;
        % pops(1).psimean     = 0;
        % pops(1).varpsi      = 0.001;
        % pops(1).ar_min      = 0.1;

        % pops(2).pop_frac    = 1.0;
        % pops(2).nu          = 3;
        % pops(2).Dmean       = 0.75;
        % pops(2).AR_scale    = 0.65;
        % pops(2).AR_exponent = -0.2;
        % pops(2).AR_exponent = [];
        % pops(2).AR_min      = 0.2;
        % pops(2).pba         = 0.2201;
        % pops(2).pba_exponent = -0.5;
        % pops(2).pcb         = 0.95;
        % pops(2).pcb_exponent = [];
        % pops(2).abatog      = 0.5;
        % pops(2).rhovar_frac = 0.03;
        % pops(2).ang_xz      = -80;
        % pops(2).ang_xy      = -70;
        % pops(2).kappa       = 8.0;
        % pops(2).psimean     = 0;
        % pops(2).varpsi      = 0.001;
        % pops(2).ar_min      = 0.1;


    case (any(strcmp(fyear,'2020')) && (habit=='l'))

    % --- 2020: POPULATION 1: Columns ---
        pops(1).pop_frac    = 1.0;
        pops(1).nu          = 3;
        pops(1).Dmean       = 0.75;
        pops(1).AR_scale    = 0.65;
        %pops(1).AR_exponent = -0.2;
        pops(1).AR_exponent = [];
        pops(1).AR_min      = 0.1;
        pops(1).pba         = 0.2201;
        pops(1).pba_exponent = -0.5;
        pops(1).pcb         = 0.95;
        pops(1).pcb_exponent = [];
        pops(1).abatog      = 0.5;
        pops(1).rhovar_frac = 0.03;
        pops(1).ang_xz      = -70;
        pops(1).ang_xy      = 80;
        pops(1).kappa       = 8.0;
        pops(1).psimean     = 0;
        pops(1).varpsi      = 0.001;
        pops(1).ar_min      = 0.1;

    case (any(strcmp(fyear,{'2022','2023'})) && (habit=='l'))

    % --- 2022-2023: POPULATION 1: Columns ---
    % BASE!!
        % pops(1).pop_frac    = 1.0;
        % pops(1).nu          = 3;
        % pops(1).Dmean       = 0.75;
        % pops(1).AR_scale    = 0.65;
        % pops(1).AR_exponent = -0.2;
        % pops(1).AR_min      = 0.2;
        % pops(1).pba         = 0.2201;
        % pops(1).pba_exponent = -0.5;
        % pops(1).pcb         = 0.95;
        % pops(1).pcb_exponent = [];
        % pops(1).abatog      = 0.5;
        % pops(1).rhovar_frac = 0.03;
        % pops(1).ang_xz      = -80;
        % pops(1).ang_xy      = -70;
        % pops(1).kappa       = 8.0;
        % pops(1).psimean     = 0;
        % pops(1).varpsi      = 0.001;
        % pops(1).ar_min      = 0.1;

        pops(1).pop_frac    = 1.0;
        pops(1).nu          = 3;
        pops(1).Dmean       = 0.75;
        pops(1).AR_scale    = 0.65;
        %pops(1).AR_exponent = -0.2;
        pops(1).AR_exponent = [];
        %pops(1).AR_min      = 0.2;
        pops(1).AR_min      = 0.1;
        pops(1).pba         = 0.2201;
        pops(1).pba_exponent = -0.5;
        pops(1).pcb         = 0.95;
        pops(1).pcb_exponent = [];
        pops(1).abatog      = 0.5;
        pops(1).rhovar_frac = 0.03;
        pops(1).ang_xz      = -80;
        pops(1).ang_xy      = -80;
        pops(1).kappa       = 8.0;
        pops(1).psimean     = 0;
        pops(1).varpsi      = 0.001;
        pops(1).ar_min      = 0.1;

end

sim_args_pop = {'N', N_sim, 'use_instrument_filter', use_instrument_filter, 'pops', pops};

% Define shared axis formatting so everything perfectly aligns across the 3 PDFs
shared_args = {
    'stack_all', true, ...
    'align_ticks',true, ...
    'show_cbar',false, ...
    'show_fig', true, ...
    'save_fig', false, ...
    'outdir', outdir_comp, ...
    'ang_ticks', -90:30:90, ...
    'ang_ticklabels', {'$-90^{\circ}$', '$-60^{\circ}$','$-30^{\circ}$', '$0^{\circ}$', '$30^{\circ}$', '$60^{\circ}$', '$90^{\circ}$'}, ...
    'AspectRatio_ticks',0.:0.2:1,...
    'AspectRatio_ticklabels',0.:0.2:1,...
    'AreaRatio_ticks',0.2:0.2:1,...
    'AreaRatio_ticklabels',0.2:0.2:1,...
};

%% Column 1: Observations
fprintf('Generating Observation Column...\n');
[fig_obs,ax_obs] = plot_universal_joint(m, 'obs_multi', ...
    'target_fields', fyear, ...
    'Temp_min', Temp_min, 'Temp_max', Temp_max, ... % PCGL boundaries
    'habit',habit,...
    shared_args{:});

%% Column 2: Simulated Ellipsoids
fprintf('Generating Ellipsoid Sim Column...\n');

ellip_sim_data = fwd_project_ellipsoids(sim_args_pop{:});

[fig_sim,ax_sim] = plot_universal_joint(ellip_sim_data, 'sim_ellipsoid', ...
    'habit', 'all', ... 
    shared_args{:});

%% Column 3: STL Simulations
if stl_comp

    fprintf('Generating STL Sim Column...\n');

    s_STL = read_stl_data(STL_full_files);

    if stl_habit

        habit_stl = habit;

    else

        habit_stl = 'all';

    end

    [fig_STL, ax_STL] = plot_universal_joint(s_STL,'sim','habit',habit_stl,shared_args{:});

end


%% Calculate Mean Maximum Difference calculations for each joint distribution
if calc_MMD 

    % 2. Extract [X, Y] Arrays directly from the generated Histogram2 objects
    obs_H_pairs = cell(1, 6); obs_V_pairs = cell(1, 6);
    sim_H_pairs = cell(1, 6); sim_V_pairs = cell(1, 6);
    
    if stl_comp
        stl_H_pairs = cell(1, 6); stl_V_pairs = cell(1, 6);
    end

    % reset rng for strict reproducibility
    rng(42);

    % Loop through the 6 rows of the stack_all axes layout 
    % (Odd axes = H channel, Even axes = V channel)
    for i = 1:6
        idx_H = (i - 1) * 2 + 1;
        idx_V = idx_H + 1;

        % Get Observation Data
        h_obs_H = findobj(ax_obs(idx_H), 'Type', 'Histogram2');
        h_obs_V = findobj(ax_obs(idx_V), 'Type', 'Histogram2');
        obs_H_pairs{i} = [h_obs_H.Data(:,1), h_obs_H.Data(:,2)];
        obs_V_pairs{i} = [h_obs_V.Data(:,1), h_obs_V.Data(:,2)];

        % Get Ellipsoid Simulation Data
        h_sim_H = findobj(ax_sim(idx_H), 'Type', 'Histogram2');
        h_sim_V = findobj(ax_sim(idx_V), 'Type', 'Histogram2');
        sim_H_pairs{i} = [h_sim_H.Data(:,1), h_sim_H.Data(:,2)];
        sim_V_pairs{i} = [h_sim_V.Data(:,1), h_sim_V.Data(:,2)];
        
        % Get STL Simulation Data
        if stl_comp
            h_stl_H = findobj(ax_STL(idx_H), 'Type', 'Histogram2');
            h_stl_V = findobj(ax_STL(idx_V), 'Type', 'Histogram2');
            stl_H_pairs{i} = [h_stl_H.Data(:,1), h_stl_H.Data(:,2)];
            stl_V_pairs{i} = [h_stl_V.Data(:,1), h_stl_V.Data(:,2)];
        end
    end

    % 3. Define the 6 Joint Distribution Pairs (Based on stack_all order)
    dist_names = {
        'D_max vs. Aspect Ratio', ...
        'D_max vs. Area Ratio', ...
        'Ellipse Angle vs. Aspect Ratio', ...
        'Ellipse Angle vs. Area Ratio', ...
        'Ellipse Angle vs. D_max', ...
        'Area Ratio vs. Aspect Ratio'
        };

    % 4. Print Output Table Header
    fprintf('\n====================================================================================================\n');
    fprintf('                       MAXIMUM MEAN DISCREPANCY (MMD) TEST: OBSERVED VS SIMULATED                   \n');
    fprintf('====================================================================================================\n');
    if stl_comp
        fprintf('%-35s %-12s %-25s %-25s\n', 'Joint Distribution', 'Channel', 'Ellipsoid MMD (Mean ± Std)', 'STL MMD (Mean ± Std)');
    else
        fprintf('%-35s %-12s %-25s\n', 'Joint Distribution', 'Channel', 'Ellipsoid MMD (Mean ± Std)');
    end
    fprintf('----------------------------------------------------------------------------------------------------\n');

    % 5. Bootstrapped Calculation
    N_sample = 10000; 
    n_bootstraps = 30; % 30 iterations is standard for statistical convergence

    for i = 1:length(dist_names)

        mmd_H_boot = zeros(n_bootstraps, 1);
        mmd_V_boot = zeros(n_bootstraps, 1);
        
        if stl_comp
            mmd_H_stl_boot = zeros(n_bootstraps, 1);
            mmd_V_stl_boot = zeros(n_bootstraps, 1);
        end

        for b = 1:n_bootstraps
            
            % =========================================================
            % A. ELLIPSOID SIMULATION MMD CALCULATION
            % =========================================================
            
            % --- Horizontal Channel ---
            X_H = obs_H_pairs{i};
            Y_H = sim_H_pairs{i};

            min_pts_H = min([size(X_H, 1), size(Y_H, 1), N_sample]);
            X_H = X_H(randsample(size(X_H,1), min_pts_H), :);
            Y_H = Y_H(randsample(size(Y_H,1), min_pts_H), :);

            % Pooled Normalization
            min_bounds_H = min([X_H; Y_H], [], 1);
            max_bounds_H = max([X_H; Y_H], [], 1);
            X_H_norm = (X_H - min_bounds_H) ./ (max_bounds_H - min_bounds_H);
            Y_H_norm = (Y_H - min_bounds_H) ./ (max_bounds_H - min_bounds_H);

            % --- Vertical Channel ---
            X_V = obs_V_pairs{i};
            Y_V = sim_V_pairs{i};

            min_pts_V = min([size(X_V, 1), size(Y_V, 1), N_sample]);
            X_V = X_V(randsample(size(X_V,1), min_pts_V), :);
            Y_V = Y_V(randsample(size(Y_V,1), min_pts_V), :);

            % Pooled Normalization
            min_bounds_V = min([X_V; Y_V], [], 1);
            max_bounds_V = max([X_V; Y_V], [], 1);
            X_V_norm = (X_V - min_bounds_V) ./ (max_bounds_V - min_bounds_V);
            Y_V_norm = (Y_V - min_bounds_V) ./ (max_bounds_V - min_bounds_V);

            % GPU Execution (Ellipsoids)
            try
                mmd_H_boot(b) = compute_mmd_gpu(X_H_norm, Y_H_norm, 0.5);
                mmd_V_boot(b) = compute_mmd_gpu(X_V_norm, Y_V_norm, 0.5);
            catch ME
                warning('GPU execution failed on Ellipsoid bootstrap %d. Error: %s', b, ME.message);
            end
            
            % =========================================================
            % B. STL SIMULATION MMD CALCULATION (If requested)
            % =========================================================
            if stl_comp
                % --- Horizontal Channel (STL) ---
                X_H_stl = obs_H_pairs{i};
                Y_H_stl = stl_H_pairs{i};

                min_pts_H_stl = min([size(X_H_stl, 1), size(Y_H_stl, 1), N_sample]);
                X_H_stl = X_H_stl(randsample(size(X_H_stl,1), min_pts_H_stl), :);
                Y_H_stl = Y_H_stl(randsample(size(Y_H_stl,1), min_pts_H_stl), :);

                % Pooled Normalization (STL)
                min_bounds_H_stl = min([X_H_stl; Y_H_stl], [], 1);
                max_bounds_H_stl = max([X_H_stl; Y_H_stl], [], 1);
                X_H_norm_stl = (X_H_stl - min_bounds_H_stl) ./ (max_bounds_H_stl - min_bounds_H_stl);
                Y_H_norm_stl = (Y_H_stl - min_bounds_H_stl) ./ (max_bounds_H_stl - min_bounds_H_stl);

                % --- Vertical Channel (STL) ---
                X_V_stl = obs_V_pairs{i};
                Y_V_stl = stl_V_pairs{i};

                min_pts_V_stl = min([size(X_V_stl, 1), size(Y_V_stl, 1), N_sample]);
                X_V_stl = X_V_stl(randsample(size(X_V_stl,1), min_pts_V_stl), :);
                Y_V_stl = Y_V_stl(randsample(size(Y_V_stl,1), min_pts_V_stl), :);

                % Pooled Normalization (STL)
                min_bounds_V_stl = min([X_V_stl; Y_V_stl], [], 1);
                max_bounds_V_stl = max([X_V_stl; Y_V_stl], [], 1);
                X_V_norm_stl = (X_V_stl - min_bounds_V_stl) ./ (max_bounds_V_stl - min_bounds_V_stl);
                Y_V_norm_stl = (Y_V_stl - min_bounds_V_stl) ./ (max_bounds_V_stl - min_bounds_V_stl);
                
                % GPU Execution (STL)
                try
                    mmd_H_stl_boot(b) = compute_mmd_gpu(X_H_norm_stl, Y_H_norm_stl, 0.5);
                    mmd_V_stl_boot(b) = compute_mmd_gpu(X_V_norm_stl, Y_V_norm_stl, 0.5);
                catch ME
                    warning('GPU execution failed on STL bootstrap %d. Error: %s', b, ME.message);
                end
            end
        end

        % Calculate Mean and Standard Deviation across all bootstraps
        mean_H = mean(mmd_H_boot); std_H = std(mmd_H_boot);
        mean_V = mean(mmd_V_boot); std_V = std(mmd_V_boot);
        
        str_H_ellip = sprintf('%5.4f ± %5.4f', mean_H, std_H);
        str_V_ellip = sprintf('%5.4f ± %5.4f', mean_V, std_V);

        if stl_comp
            mean_H_stl = mean(mmd_H_stl_boot); std_H_stl = std(mmd_H_stl_boot);
            mean_V_stl = mean(mmd_V_stl_boot); std_V_stl = std(mmd_V_stl_boot);
            
            str_H_stl = sprintf('%5.4f ± %5.4f', mean_H_stl, std_H_stl);
            str_V_stl = sprintf('%5.4f ± %5.4f', mean_V_stl, std_V_stl);
            
            fprintf('%-35s %-12s %-25s %-25s\n', dist_names{i}, 'Horizontal', str_H_ellip, str_H_stl);
            fprintf('%-35s %-12s %-25s %-25s\n', '', 'Vertical', str_V_ellip, str_V_stl);
        else
            fprintf('%-35s %-12s %-25s\n', dist_names{i}, 'Horizontal', str_H_ellip);
            fprintf('%-35s %-12s %-25s\n', '', 'Vertical', str_V_ellip);
        end

    end
    fprintf('====================================================================================================\n\n');
end

% 
% %% Calculate Mean Maximum Difference calculations for each joint distribution
% if calc_MMD 
% 
%      dist_names = {
%          'D_max vs. Aspect Ratio', ...
%          'D_max vs. Area Ratio', ...
%          'Ellipse Angle vs. Aspect Ratio', ...
%          'Ellipse Angle vs. Area Ratio', ...
%          'Ellipse Angle vs. D_max', ...
%          'Area Ratio vs. Aspect Ratio'
%          };
% 
%     % 4. Print Output Table Header
%     fprintf('\n================================================================================\n');
%     fprintf('           MAXIMUM MEAN DISCREPANCY (MMD) TEST: OBSERVED VS SIMULATED           \n');
%     fprintf('================================================================================\n');
%     fprintf('%-35s %-12s %-20s\n', 'Joint Distribution', 'Channel', 'MMD Value (Mean ± Std)');
%     fprintf('--------------------------------------------------------------------------------\n');
% 
%     % 5. Bootstrapped Calculation
%     N_sample = 10000; 
%     n_bootstraps = 30; % 30 iterations is standard for statistical convergence
% 
%     for i = 1:length(dist_names)
% 
%         mmd_H_boot = zeros(n_bootstraps, 1);
%         mmd_V_boot = zeros(n_bootstraps, 1);
% 
%         for b = 1:n_bootstraps
%             % --- Horizontal Channel ---
%             X_H = obs_H_pairs{i};
%             Y_H = sim_H_pairs{i};
% 
%             min_pts_H = min([size(X_H, 1), size(Y_H, 1), N_sample]);
%             X_H = X_H(randsample(size(X_H,1), min_pts_H), :);
%             Y_H = Y_H(randsample(size(Y_H,1), min_pts_H), :);
% 
%             % Pooled Normalization
%             min_bounds_H = min([X_H; Y_H], [], 1);
%             max_bounds_H = max([X_H; Y_H], [], 1);
%             X_H_norm = (X_H - min_bounds_H) ./ (max_bounds_H - min_bounds_H);
%             Y_H_norm = (Y_H - min_bounds_H) ./ (max_bounds_H - min_bounds_H);
% 
%             % --- Vertical Channel ---
%             X_V = obs_V_pairs{i};
%             Y_V = sim_V_pairs{i};
% 
%             min_pts_V = min([size(X_V, 1), size(Y_V, 1), N_sample]);
%             X_V = X_V(randsample(size(X_V,1), min_pts_V), :);
%             Y_V = Y_V(randsample(size(Y_V,1), min_pts_V), :);
% 
%             % Pooled Normalization
%             min_bounds_V = min([X_V; Y_V], [], 1);
%             max_bounds_V = max([X_V; Y_V], [], 1);
%             X_V_norm = (X_V - min_bounds_V) ./ (max_bounds_V - min_bounds_V);
%             Y_V_norm = (Y_V - min_bounds_V) ./ (max_bounds_V - min_bounds_V);
% 
%             % GPU Execution
%             try
%                 % Compute H
%                 mmd_H_boot(b) = compute_mmd_gpu(X_H_norm, Y_H_norm, 0.5);
%                 % Compute V
%                 mmd_V_boot(b) = compute_mmd_gpu(X_V_norm, Y_V_norm, 0.5);
%             catch ME
%                 warning('GPU execution failed on bootstrap %d. Error: %s', b, ME.message);
%                 % Fallback or handle error
%             end
%         end
% 
%         % Calculate Mean and Standard Deviation across all bootstraps
%         mean_H = mean(mmd_H_boot); std_H = std(mmd_H_boot);
%         mean_V = mean(mmd_V_boot); std_V = std(mmd_V_boot);
% 
%         fprintf('%-35s %-12s %5.4f ± %5.4f\n', dist_names{i}, 'Horizontal', mean_H, std_H);
%         fprintf('%-35s %-12s %5.4f ± %5.4f\n', '', 'Vertical', mean_V, std_V);
% 
%     end
%     fprintf('================================================================================\n\n');
% 
%    %  % 2. Extract [X, Y] Arrays directly from the generated Histogram2 objects
%    %  obs_H_pairs = cell(1, 6); obs_V_pairs = cell(1, 6);
%    %  sim_H_pairs = cell(1, 6); sim_V_pairs = cell(1, 6);
%    % 
%    %  % Loop through the 6 rows of the stack_all axes layout 
%    %  % (Odd axes = H channel, Even axes = V channel)
%    % 
%    %  % reset rng
%    %  %rng(42);
%    %  %rng(100);
%    % 
%    %  for i = 1:6
%    %      idx_H = (i - 1) * 2 + 1;
%    %      idx_V = idx_H + 1;
%    % 
%    %      % Get Observation Data
%    %      h_obs_H = findobj(ax_obs(idx_H), 'Type', 'Histogram2');
%    %      h_obs_V = findobj(ax_obs(idx_V), 'Type', 'Histogram2');
%    %      obs_H_pairs{i} = [h_obs_H.Data(:,1), h_obs_H.Data(:,2)];
%    %      obs_V_pairs{i} = [h_obs_V.Data(:,1), h_obs_V.Data(:,2)];
%    % 
%    %      % Get Simulation Data
%    %      h_sim_H = findobj(ax_sim(idx_H), 'Type', 'Histogram2');
%    %      h_sim_V = findobj(ax_sim(idx_V), 'Type', 'Histogram2');
%    %      sim_H_pairs{i} = [h_sim_H.Data(:,1), h_sim_H.Data(:,2)];
%    %      sim_V_pairs{i} = [h_sim_V.Data(:,1), h_sim_V.Data(:,2)];
%    %  end
%    % 
%    %  %close(fig_obs); close(fig_sim);
%    % 
%    %  % 3. Define the 6 Joint Distribution Pairs (Based on stack_all order)
%    %  % Group 1: Dmajor(X) vs AspectRatio(Y)   | Dmajor(X) vs AreaRatio(Y)
%    %  % Group 2: EllipAng(X) vs AspectRatio(Y) | EllipAng(X) vs AreaRatio(Y) | EllipAng(X) vs Dmajor(Y)
%    %  % Group 3: AreaRatio(X) vs AspectRatio(Y)
%    %  dist_names = {
%    %      'D_max vs. Aspect Ratio', ...
%    %      'D_max vs. Area Ratio', ...
%    %      'Ellipse Angle vs. Aspect Ratio', ...
%    %      'Ellipse Angle vs. Area Ratio', ...
%    %      'Ellipse Angle vs. D_max', ...
%    %      'Area Ratio vs. Aspect Ratio'
%    %      };
%    % 
%    %  % 4. Print Output Table Header
%    % % fprintf('\n================================================================================\n');
%    % % fprintf('           MAXIMUM MEAN DISCREPANCY (MMD) TEST: OBSERVED VS SIMULATED           \n');
%    % % fprintf('================================================================================\n');
%    % % fprintf('%-35s %-12s %-15s %-15s\n', 'Joint Distribution', 'Channel', 'MMD Value', 'p-value');
%    % % fprintf('--------------------------------------------------------------------------------\n');
%    % 
%    %  fprintf('\n================================================================================\n');
%    %  fprintf('           MAXIMUM MEAN DISCREPANCY (MMD) TEST: OBSERVED VS SIMULATED           \n');
%    %  fprintf('================================================================================\n');
%    %  fprintf('%-35s %-12s %-15s\n', 'Joint Distribution', 'Channel', 'MMD Value');
%    %  fprintf('--------------------------------------------------------------------------------\n');
%    % 
%    %  % 5. Loop and Calculate
%    %  N_sample = 10000; % Subsample limit to prevent mmdtest memory exhaustion
%    % 
%    %  for i = 1:length(dist_names)
%    % 
%    %      % --- Horizontal Channel ---
%    %      X_H = obs_H_pairs{i};
%    %      Y_H = sim_H_pairs{i};
%    % 
%    %      % Enforce common sample size for stable MMD distance comparisons
%    %      min_pts_H = min([size(X_H, 1), size(Y_H, 1), N_sample]);
%    %      X_H = X_H(randsample(size(X_H,1), min_pts_H), :);
%    %      Y_H = Y_H(randsample(size(Y_H,1), min_pts_H), :);
%    % 
%    %      % Normalize to [0,1]
%    %      %X_H_norm = (X_H - min(X_H)) ./ (max(X_H) - min(X_H));
%    %      %Y_H_norm = (Y_H - min(Y_H)) ./ (max(Y_H) - min(Y_H));
%    % 
%    %      % --- Pooled Normalization (Horizontal) ---
%    %      min_bounds_H = min([X_H; Y_H], [], 1);
%    %      max_bounds_H = max([X_H; Y_H], [], 1);
%    % 
%    %      X_H_norm = (X_H - min_bounds_H) ./ (max_bounds_H - min_bounds_H);
%    %      Y_H_norm = (Y_H - min_bounds_H) ./ (max_bounds_H - min_bounds_H);
%    % 
%    %      % 1. PUSH TO GPU
%    %      try
%    %          X_gpu = gpuArray(X_H_norm);
%    %          Y_gpu = gpuArray(Y_H_norm);
%    % 
%    %          % 2. COMPUTE ON GPU
%    %          %[mmd_H_raw, p_H, h_H_raw] = mmdtest(X_gpu, Y_gpu);
%    % 
%    %          mmd_H = compute_mmd_gpu(X_gpu, Y_gpu, 0.5);
%    % 
%    %          % 3. PULL BACK TO CPU
%    %          %mmd_H = gather(mmd_H_raw);
%    %          %p_H = gather(p_H);
%    %         % h_H = gather(h_H_raw);
%    % 
%    %      catch ME
%    %          warning('GPU execution failed, falling back to CPU. Error: %s', ME.message);
%    %          %[mmd_H, p_H, h_H] = mmdtest(X_H_norm, Y_H_norm);
%    %          mmd_H = mmdtest(X_H_norm, Y_H_norm);
%    %      end
%    % 
%    %      %[mmd_H, p_H, h_H] = mmdtest(X_H_norm, Y_H_norm);
%    % 
%    %     % if p_H < 0.001; p_str_H = '< 0.001'; else; p_str_H = sprintf('%.4f', p_H); end
%    %      %fprintf('%-35s %-12s %-15.4f %-15s\n', dist_names{i}, 'Horizontal', mmd_H, p_str_H);
%    %      fprintf('%-35s %-12s %-15.4f\n', dist_names{i}, 'Horizontal', mmd_H);
%    % 
%    %      % --- Vertical Channel ---
%    %      X_V = obs_V_pairs{i};
%    %      Y_V = sim_V_pairs{i};
%    % 
%    %      min_pts_V = min([size(X_V, 1), size(Y_V, 1), N_sample]);
%    %      X_V = X_V(randsample(size(X_V,1), min_pts_V), :);
%    %      Y_V = Y_V(randsample(size(Y_V,1), min_pts_V), :);
%    % 
%    %      %X_V_norm = (X_V - min(X_V)) ./ (max(X_V) - min(X_V));
%    %      %Y_V_norm = (Y_V - min(Y_V)) ./ (max(Y_V) - min(Y_V));
%    % 
%    %      % --- Pooled Normalization (Horizontal) ---
%    %      min_bounds_V = min([X_V; Y_V], [], 1);
%    %      max_bounds_V = max([X_V; Y_V], [], 1);
%    % 
%    %      X_V_norm = (X_V - min_bounds_V) ./ (max_bounds_V - min_bounds_V);
%    %      Y_V_norm = (Y_V - min_bounds_V) ./ (max_bounds_V - min_bounds_V);
%    % 
%    %      % 1. PUSH TO GPU
%    %      try
%    %          X_gpu = gpuArray(X_V_norm);
%    %          Y_gpu = gpuArray(Y_V_norm);
%    % 
%    %          % 2. COMPUTE ON GPU
%    %         % [mmd_V_raw, p_V, h_V_raw] = mmdtest(X_gpu, Y_gpu);
%    % 
%    %          mmd_V = compute_mmd_gpu(X_gpu, Y_gpu, 0.5);
%    % 
%    %          % 3. PULL BACK TO CPU
%    %          %mmd_V = gather(mmd_V_raw);
%    %          %p_V = gather(p_V);
%    %          %h_V = gather(h_V_raw);
%    % 
%    %      catch ME
%    %          warning('GPU execution failed, falling back to CPU. Error: %s', ME.message);
%    %         % [mmd_V, p_V, h_V] = mmdtest(X_V_norm, Y_V_norm);
%    %          mmd_V = mmdtest(X_V_norm, Y_V_norm);
%    %      end
%    % 
%    %      %[mmd_V, p_V, h_V] = mmdtest(X_V_norm, Y_V_norm);
%    % 
%    %      %if p_V < 0.001; p_str_V = '< 0.001'; else; p_str_V = sprintf('%.4f', p_V); end
%    %      %fprintf('%-35s %-12s %-15.4f %-15s\n', '', 'Vertical', mmd_V, p_str_V);
%    %      fprintf('%-35s %-12s %-15.4f\n', '', 'Vertical', mmd_V);
%    % 
%    %  end
%    %  fprintf('================================================================================\n\n');
% 
% end



function mmd_val = compute_mmd_gpu(X, Y, sigma)
% COMPUTE_MMD_GPU calculates the Maximum Mean Discrepancy using an RBF kernel.
% X and Y: N x D matrices
% sigma: Kernel bandwidth (0.5 to 1.0 is standard for [0,1] normalized data)

% 1. Push to GPU
X = gpuArray(X);
Y = gpuArray(Y);

n = size(X, 1);
m = size(Y, 1);

% 2. Vectorized Pairwise Squared Euclidean Distances 
% (X-Y)^2 = X^2 - 2XY + Y^2
X_sq = sum(X.^2, 2);
Y_sq = sum(Y.^2, 2);

XX = X_sq - 2 * (X * X') + X_sq';
YY = Y_sq - 2 * (Y * Y') + Y_sq';
XY = X_sq - 2 * (X * Y') + Y_sq';

% Prevent floating point errors from pushing distances slightly below zero
XX = max(XX, 0); YY = max(YY, 0); XY = max(XY, 0);

% 3. Apply Gaussian RBF Kernel
gamma = 1 / (2 * sigma^2);
K_XX = exp(-gamma * XX);
K_YY = exp(-gamma * YY);
K_XY = exp(-gamma * XY);

% 4. Compute Biased MMD^2 Statistic
mmd2 = (1 / n^2) * sum(K_XX, 'all') + ...
    (1 / m^2) * sum(K_YY, 'all') - ...
    (2 / (n * m)) * sum(K_XY, 'all');

% 5. Return MMD to CPU (ensure non-negative before sqrt)
mmd_val = gather(sqrt(max(mmd2, 0)));
end