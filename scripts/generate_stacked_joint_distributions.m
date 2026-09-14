%% make_comparison_figure.m
% Generates the three 6-row PDF columns for the Obs vs Sim comparison.

N_sim = 1e6;
fyear = {'2020'};
%fyear = {'2022','2023'};
habit_type = 'irregular';
%habit_type = 'linear';
use_instrument_filter = true;

paths = get_project_paths();

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

        %nu = 0.2;
        nu = 1;
        Dmean = 2.0;

        % ang_xz = -40;
        % ang_xy = 45;
        % kappa = 4; % NEW
        % psimean = 0;
        % varpsi = 0.001;
        % 
        % pop_frac = 1.0; % Fraction of particles in the PRIMARY state (1.0 = standard single mode)
        % ang_xz_2 = -40;
        % ang_xy_2 = -80;
        % kappa_2 = 5;

    % --- 2020: POPULATION 1: Irregular ---
        %pops(1).pop_frac    = 0.95;
        pops(1).pop_frac    = 1.0;
        pops(1).nu          = 0.2;
        pops(1).Dmean       = 2.0;
        %pops(1).AR_scale    = 0.59;
       % pops(1).AR_exponent = -0.27;
        pops(1).AR_scale = 0.59;
        pops(1).AR_exponent = [];
       % pops(1).AR_min      = 0.2;
        pops(1).AR_min      = 0.1;
        %pops(1).pba         = 0.75;
        pops(1).pba         = 0.75;
        pops(1).pba_exponent= [];
        %pops(1).pcb         = 0.75;
        pops(1).pcb         = 0.75;
        pops(1).pcb_exponent= [];
        pops(1).abatog      = 0.6;
        %pops(1).abatog      = 0.85;
        pops(1).rhovar_frac = 0.02;
        %pops(1).rhovar_frac = 0.0175;
        %pops(1).rhovar_frac = 0.015;
        pops(1).ang_xz      = -48;
        pops(1).ang_xy      = 45;
        pops(1).kappa       = 4.5;
        %pops(1).kappa       = 5.0;
        pops(1).psimean     = 0;
        pops(1).varpsi      = 0.001;
        pops(1).use_3D_density_scaling = true;

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
        pops(1).pop_frac    = 0.70;
        pops(1).nu          = 0.2;
        pops(1).Dmean       = 0.5;
        %pops(1).AR_scale    = 0.62;
        pops(1).AR_scale    = 0.59;
        pops(1).AR_exponent = -0.27;
        pops(1).AR_min      = 0.2;
        pops(1).pba         = 0.78;
        pops(1).pba_exponent= [];
        pops(1).pcb         = 0.78;
        pops(1).pcb_exponent= [];
        pops(1).abatog      = 0.6;
        pops(1).rhovar_frac = 0.015;
        %pops(1).rhovar_frac = 0.05;
        pops(1).ang_xz      = -40;
        %pops(1).ang_xy      = -5;
        pops(1).ang_xy      = -10;

        %pops(1).ang_xy      = -85;
        %pops(1).kappa       = 4;
        pops(1).kappa       = 3;
        pops(1).psimean     = 0;
        pops(1).varpsi      = 0.001;


        % --- POPULATION 2: Columns (The Bump/Elbow) ---
        pops(2).pop_frac    = 1-pops(1).pop_frac;
        pops(2).nu          = 4.0;

        pops(2).Dmean       = 0.4;
        %pops(2).Dmean       = 0.35; 
        %pops(2).AR_scale    = 0.68; % Dense/Solid
        %pops(2).AR_scale    = 0.72;

        % ORIG
        %pops(2).AR_scale    = 0.65;
        %pops(2).AR_exponent = -0.15;  

        % NEW
        pops(2).AR_scale    = 0.65;
        pops(2).AR_exponent = -0.05;


        pops(2).AR_min      = 0.2;
        %pops(2).pba         = 0.8; % Not bad
        %pops(2).pcb         = 0.7; % Not bad
        %pops(2).pba         = 0.75;
        pops(2).pba         = 0.70;
        pops(2).pba_exponent= [];
        %pops(2).pcb         = 0.75;
        pops(2).pcb         = 0.70;
        pops(2).pcb_exponent= [];
        pops(2).abatog      = 1.0;
        
        % NEW
        pops(2).rhovar_frac = 0.05;

        %pops(2).rhovar_frac = 0.075;

        %pops(2).ang_xz      = -50;
        pops(2).ang_xz      = -75;
        %pops(2).ang_xy      = -45;
        pops(2).ang_xy      = -75;

        pops(2).kappa       = 50;
        pops(2).psimean     = 0;
        pops(2).varpsi      = 0.001;


    case (any(strcmp(fyear,'2020')) && (habit=='l'))

    % --- 2020: POPULATION 1: Columns ---
        pops(1).pop_frac    = 1.0;
        pops(1).nu          = 3;
        pops(1).Dmean       = 0.75;
        pops(1).AR_scale    = 0.65;
        pops(1).AR_exponent = -0.2;
        pops(1).AR_min      = 0.2;
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
        pops(1).pop_frac    = 1.0;
        pops(1).nu          = 3;
        pops(1).Dmean       = 0.75;
        pops(1).AR_scale    = 0.65;
        pops(1).AR_exponent = -0.2;
        pops(1).AR_min      = 0.2;
        pops(1).pba         = 0.2201;
        pops(1).pba_exponent = -0.5;
        pops(1).pcb         = 0.95;
        pops(1).pcb_exponent = [];
        pops(1).abatog      = 0.5;
        pops(1).rhovar_frac = 0.03;
        pops(1).ang_xz      = -80;
        pops(1).ang_xy      = -70;
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
    %'ang_ticks', -80:20:80, ...
   % 'ang_ticklabels', {'$-80^{\circ}$', '$-60^{\circ}$', '$-40^{\circ}$', '$-20^{\circ}$', '$0^{\circ}$', '$20^{\circ}$', '$40^{\circ}$', '$60^{\circ}$', '$80^{\circ}$'}, ...
    %'dmajor_ticks', log10([0.5 1 2 4]), ...
    %'dmajor_ticklabels', {'0.5', '1.0', '2.0', '4.0'}%, ...
   % 'ratio_ticks', 0:0.2:1, ...
    %'ratio_ticklabels', {'0', '0.2', '0.4', '0.6', '0.8', '1.0'}
};

%% Column 1: Observations
fprintf('Generating Observation Column...\n');
plot_universal_joint(m, 'obs_multi', ...
    'target_fields', fyear, ...
    'Temp_min', Temp_min, 'Temp_max', Temp_max, ... % PCGL boundaries
    'habit',habit,...
    shared_args{:});

% Rename the output file so it's clear
%movefile(fullfile(outdir_comp, 'IMPACTS_2DS_MultiFlight_2020_Temp_-99to-18_All_JointDists_Stack.pdf'), ...
%         fullfile(outdir_comp, 'Col1_OBS_PCGL.pdf'));

% %% Column 2: Simulated Ellipsoids
fprintf('Generating Ellipsoid Sim Column...\n');
% ORIG
ellip_sim_data = fwd_project_ellipsoids(sim_args_pop{:});


plot_universal_joint(ellip_sim_data, 'sim_ellipsoid', ...
    'habit', 'all', ... 
    shared_args{:});

% movefile(fullfile(outdir_comp, 'Simulation_2DS_All_JointDists_Stack.pdf'), ...
%          fullfile(outdir_comp, 'Col2_SIM_Ellipsoids.pdf'));



% %% Column 3: Simulated STL Models
% fprintf('Generating STL Sim Column...\n');
% plot_universal_joint(stl_sim_data, 'sim', ...
%     'habit', 'all', ... 
%     shared_args{:});
% 
% movefile(fullfile(outdir_comp, 'Simulation_2DS_All_JointDists_Stack.pdf'), ...
%          fullfile(outdir_comp, 'Col3_SIM_STL.pdf'));
% 
% fprintf('\nDone! Drop the 3 PDFs in %s into Illustrator side-by-side.\n', outdir_comp);