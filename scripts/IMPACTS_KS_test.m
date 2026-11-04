%% IMPACTS_KS_test.m
% Calculates two-sample Kolmogorov-Smirnov statistics comparing individual
% flight cases to their respective campaign ensembles, stratified by temperature.
% H and V channels are evaluated independently. Includes a toggleable habit filter
% and outputs summary statistics (Median, Std, 90th percentile) for the abstract.

%% 1. Set paths and load data
paths = init_project(); 

fprintf('Loading ellipse fit data...\n');
load(paths.ellipse_file, '-mat');
fnames = fieldnames(m);

%% 2. Define Flight Dates and Campaigns
dates_2020 = {'20200118','20200125','20200201','20200205','20200207','20200213','20200218','20200220'};
dates_2022 = {'20220208','20220213','20220217','20220219','20220225'};
dates_2023 = {'20230113','20230115','20230119','20230123','20230125','20230129','20230205','20230209','20230212','20230214','20230216','20230223','20230228'};

dates = [dates_2020, dates_2022, dates_2023];

% Index arrays for campaign pooling
idx_2020 = 1:8;
idx_2223 = 9:26; 

%% 3. Define Temperature Layers, Parameters, and Habit Filters
T1_layers = [-18, -12, -8, -3, 0];
T2_layers = [-70, -18, -12, -8, -3];
layer_names = {'PCGL', 'DGL', 'PGL', 'NGL', 'AGG'};

param_names = {'Ellipse Aspect Ratio', 'Ellipse Orientation', 'Ellipse Area Ratio'};
param_fields = {'AR', 'EllipAng', 'area_ratio'};

% =========================================================================
% TOGGLEABLE HABIT FILTER
% =========================================================================
use_habit_filter = true; 

% Mapped explicitly to layer_names order: PCGL, DGL, PGL, NGL, AGG
layer_target_habits = {'i', 'd', 'h', 'l', 'a'}; 
layer_target_habit_names = {'Irregular', 'Dendrite', 'Hexagonal', 'Linear', 'Aggregate'};
% =========================================================================

%% 4. Temperature-Stratified KS-Test Analysis 
fprintf('\n================================================================================================\n');
fprintf('                CAMPAIGN ENSEMBLE KS-TEST (TEMPERATURE STRATIFIED UNIVERSALITY)                   \n');
fprintf('================================================================================================\n');

for p = 1:length(param_names)
    fprintf('\n================================================================================================\n');
    fprintf('                              ANALYZING: %s\n', upper(param_names{p}));
    fprintf('================================================================================================\n');
    
    for tt = 1:length(layer_names)
        
        if use_habit_filter
            fprintf('\n--- Layer: %s (%.0f C to %.0f C) | Habit Filter: %s ---\n', ...
                layer_names{tt}, T2_layers(tt), T1_layers(tt), upper(layer_target_habit_names{tt}));
        else
            fprintf('\n--- Layer: %s (%.0f C to %.0f C) | Habit Filter: OFF (All Particles) ---\n', ...
                layer_names{tt}, T2_layers(tt), T1_layers(tt));
        end
        
        fprintf('%-15s %-12s %-12s %-10s %-12s %-10s\n', 'Flight Date', 'Campaign', 'KS Stat (H)', 'N (H)', 'KS Stat (V)', 'N (V)');
        fprintf('------------------------------------------------------------------------------------------------\n');
        
        % Extract and Filter Data by Temperature Layer
        layer_data_H = cell(1, length(fnames));
        layer_data_V = cell(1, length(fnames));
        
        for ff = 1:length(fnames)
            tempH = m.(fnames{ff}).H.Temp;
            tempV = m.(fnames{ff}).V.Temp;
            
            valid_TindH = (tempH > T2_layers(tt)) & (tempH <= T1_layers(tt));
            valid_TindV = (tempV > T2_layers(tt)) & (tempV <= T1_layers(tt));
            
            if use_habit_filter
                target_cat = categorical(cellstr(layer_target_habits{tt}));
                valid_TindH = valid_TindH & (m.(fnames{ff}).H.habit == target_cat);
                valid_TindV = valid_TindV & (m.(fnames{ff}).V.habit == target_cat);
            end
            
            rawH = m.(fnames{ff}).H.(param_fields{p})(valid_TindH);
            rawV = m.(fnames{ff}).V.(param_fields{p})(valid_TindV);
            
            % Force column vectors to prevent vertcat dimension errors
            layer_data_H{ff} = rawH(~isnan(rawH)); layer_data_H{ff} = layer_data_H{ff}(:);
            layer_data_V{ff} = rawV(~isnan(rawV)); layer_data_V{ff} = layer_data_V{ff}(:);
        end
        
        % Pool Master Distributions (By Campaign and Channel)
        pool_2020_H = []; pool_2020_V = [];
        for i = idx_2020
            pool_2020_H = [pool_2020_H; layer_data_H{i}];
            pool_2020_V = [pool_2020_V; layer_data_V{i}];
        end
        
        pool_2223_H = []; pool_2223_V = [];
        for i = idx_2223
            pool_2223_H = [pool_2223_H; layer_data_H{i}];
            pool_2223_V = [pool_2223_V; layer_data_V{i}];
        end
        
        % Arrays to collect valid KS stats for summary calculation
        ks_arr_H = [];
        ks_arr_V = [];
        
        % Run KS Tests against respective pools
        for i = 1:length(dates)
            flight_H = layer_data_H{i};
            flight_V = layer_data_V{i};
            
            if isempty(flight_H) && isempty(flight_V)
                continue;
            end
            
            if ismember(i, idx_2020)
                camp_label = '2020';
                pool_H = pool_2020_H;
                pool_V = pool_2020_V;
            else
                camp_label = '2022-2023';
                pool_H = pool_2223_H;
                pool_V = pool_2223_V;
            end
            
            ks_H = NaN; ks_V = NaN;
            if ~isempty(flight_H) && ~isempty(pool_H)
                [~, ~, ks_H] = kstest2(flight_H, pool_H);
                ks_arr_H = [ks_arr_H; ks_H];
            end
            if ~isempty(flight_V) && ~isempty(pool_V)
                [~, ~, ks_V] = kstest2(flight_V, pool_V);
                ks_arr_V = [ks_arr_V; ks_V];
            end
            
            % Flag statistical outliers in the console output (KS > 0.05 in either channel)
            flag = '';
            if ks_H > 0.05 || ks_V > 0.05
                flag = '<-- Outlier'; 
            end
            
            fprintf('%-15s %-12s %-12.4f %-10d %-12.4f %-10d %s\n', dates{i}, camp_label, ks_H, length(flight_H), ks_V, length(flight_V), flag);
        end
        
        % Print Summary Statistics
        fprintf('------------------------------------------------------------------------------------------------\n');
        fprintf('SUMMARY STATISTICS:\n');
        fprintf('%-20s %-12s %-12s\n', 'Metric', 'H-Channel', 'V-Channel');
        if ~isempty(ks_arr_H) && ~isempty(ks_arr_V)
            fprintf('%-20s %-12.4f %-12.4f\n', 'Median KS Stat', median(ks_arr_H), median(ks_arr_V));
            fprintf('%-20s %-12.4f %-12.4f\n', 'Std Dev KS Stat', std(ks_arr_H), std(ks_arr_V));
            fprintf('%-20s %-12.4f %-12.4f\n', '90th Percentile', prctile(ks_arr_H, 90), prctile(ks_arr_V, 90));
            fprintf('%-20s %-12.4f %-12.4f\n', 'Maximum KS Stat', max(ks_arr_H), max(ks_arr_V));
        else
            fprintf('Insufficient data for summary statistics.\n');
        end
        
    end
end
fprintf('\n================================================================================================\n');