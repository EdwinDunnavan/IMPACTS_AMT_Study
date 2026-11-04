function [fig, ax] = plot_universal_joint(data, dataType, varargin)
% PLOT_UNIVERSAL_JOINT Plots joint distributions for obs and sim data.

    %% 1. Default Options & Edges
    normalization = 'pdf';
    ang_edges = -90:2.5:90;
    xedges = 0.1:0.05:1.0;
    area_edges = 0.2:0.05:1.0;
    Dmajor_edges = 0.3:0.05:4.0; % Extended to 4.0 for uniform log scaling

    % Standard Axis Setup Variables
    ang_ticks = -90:30:90;
    ang_ticklabels = {'$-90^{\circ}$', '$-60^{\circ}$', '$-30^{\circ}$', '$0^{\circ}$', '$30^{\circ}$', '$60^{\circ}$', '$90^{\circ}$'};
    dmajor_ticks = log10([0.5 1 2 4]);
    dmajor_ticklabels = {'0.5', '1.0', '2.0', '4.0'};
    AspectRatio_ticks = 0.:0.2:1;
    AspectRatio_ticklabels = {'0','0.2', '0.4', '0.6', '0.8', '1.0'};
    AreaRatio_ticks = 0.2:0.2:1;
    AreaRatio_ticklabels = {'0.2', '0.4', '0.6', '0.8', '1.0'};

    habit = 'all';
    save_fig = false;
    visible = 'on';
    outdir = pwd;
    Tc_max = 0;
    Tc_min = -99999;
    target_fields = {};

    combine_all = false; 
    stack_all = false;
    align_ticks = false;
    show_cbar   = true;

    Dmajor_switch = false;
    AspectRatio_switch = true;
    EllipAng_switch = true;
    AreaRatio_switch = false;
    file_prefix = 'JointDist_'; 

    %% 2. Parse varargin
    for nn = 1 : 2 : length(varargin)
        switch varargin{nn}
            case {'habit', 'Habit'}
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
                if ~varargin{nn+1}
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
            case 'target_fields'
                target_fields = varargin{nn+1};
            case 'combine_all'
                combine_all = varargin{nn+1};
            case 'stack_all'
                stack_all = varargin{nn+1};
            case 'align_ticks'
                align_ticks = varargin{nn+1};
            case 'show_cbar'
                show_cbar = varargin{nn+1};
            case 'ang_ticks'
                ang_ticks = varargin{nn+1};
            case 'ang_ticklabels'
                ang_ticklabels = varargin{nn+1};
            case 'dmajor_ticks'
                dmajor_ticks = varargin{nn+1};
            case 'dmajor_ticklabels'
                dmajor_ticklabels = varargin{nn+1};
            case 'ratio_ticks'
                AreaRatio_ticks = varargin{nn+1};
            case 'ratio_ticklabels'
                AreaRatio_ticklabels = varargin{nn+1};               

        end
    end

    if combine_all || stack_all
        Dmajor_switch = true;
        AspectRatio_switch = true;
        EllipAng_switch = true;
        AreaRatio_switch = true;
    end

    %% 3. Adapter Block: Standardize Data
    stdData = struct('H', struct(), 'V', struct());

    switch dataType

        case 'sim'
            stdData.H.AR       = data.rb_xz_cgal ./ data.ra_xz_cgal;
            stdData.V.AR       = data.rb_xy_cgal ./ data.ra_xy_cgal;
            stdData.H.EllipAng = data.EllipAng_xz_cgal;
            stdData.V.EllipAng = data.EllipAng_xy_cgal;
            stdData.H.Dmajor   = 2 .* data.ra_xz_cgal;
            stdData.V.Dmajor   = 2 .* data.ra_xy_cgal;
            stdData.H.area_ratio = data.area_ratio_xz_cgal;
            stdData.V.area_ratio = data.area_ratio_xy_cgal;

            % Create a dummy habit that perfectly matches the requested filter
            % dummy_habit = habit;
            % if strcmp(dummy_habit, 'all')
            %     dummy_habit = 'e'; % Arbitrary char since 'all' bypasses the check
            % end
            % 
            % stdData.H.habit      = repmat(dummy_habit, size(stdData.H.AR)); 
            % stdData.V.habit      = repmat(dummy_habit, size(stdData.V.AR));

            stdData.H.habit    = char(data.habit_xz)'; 
            stdData.V.habit    = char(data.habit_xy)';

            % Use a safe dummy temperature that always passes the Temp filter
            safe_temp = Tc_max - 1; 
            stdData.H.Temp     = repmat(safe_temp, size(stdData.H.AR));
            stdData.V.Temp     = repmat(safe_temp, size(stdData.V.AR));
            
            file_prefix = 'Simulation_2DS_';

        case 'sim_ellipsoid'
            % Map theoretical ellipsoid simulation structure
            stdData.H.AR         = data.ar_xz;
            stdData.V.AR         = data.ar_xy;
            stdData.H.EllipAng   = data.EllipAng_xz;
            stdData.V.EllipAng   = data.EllipAng_xy;
            stdData.H.Dmajor     = data.L_xz;
            stdData.V.Dmajor     = data.L_xy;
            stdData.H.area_ratio = data.AR_xz;
            stdData.V.area_ratio = data.AR_xy;
            
            % Create a dummy habit that perfectly matches the requested filter
            dummy_habit = habit;
            if strcmp(dummy_habit, 'all')
                dummy_habit = 'e'; % Arbitrary char since 'all' bypasses the check
            end
            
            stdData.H.habit      = repmat(dummy_habit, size(stdData.H.AR)); 
            stdData.V.habit      = repmat(dummy_habit, size(stdData.V.AR));
            
            % Use a safe dummy temperature that always passes the Temp filter
            safe_temp = Tc_max - 1; 
            stdData.H.Temp       = repmat(safe_temp, size(stdData.H.AR));
            stdData.V.Temp       = repmat(safe_temp, size(stdData.V.AR));
            
            file_prefix = 'Simulation_Ellipsoid_';
        case 'obs_single'
            stdData = data;
            if isfield(stdData.H, 'time')
                file_prefix = strcat('IMPACTS_2DS_', string(stdData.H.time(1),'yMMdd'), '_');
            else
                file_prefix = 'IMPACTS_2DS_';
            end

        case 'obs_multi'
            all_fnames = fieldnames(data);
            
            if isempty(target_fields)
                fnames = all_fnames;
            else
                % 1. Preallocate formatted targets
                tgts = target_fields;
                for k = 1:length(tgts)
                    if ~startsWith(tgts{k}, 'f')
                        tgts{k} = ['f', tgts{k}];
                    end
                end
                
                % 2. Vectorized matching (no loop needed for fnames!)
                % startsWith natively checks if all_fnames starts with ANY of the tgts
                fnames = all_fnames(startsWith(all_fnames, tgts));
                
                % Safety Check
                if isempty(fnames)
                    warning('No matching flights found for the specified target_fields. Exiting.');
                    fig = []; ax = []; return;
                end
            end
           
            stdData.H.AR = []; stdData.V.AR = [];
            stdData.H.EllipAng = []; stdData.V.EllipAng = [];
            stdData.H.Dmajor = []; stdData.V.Dmajor = [];
            stdData.H.area_ratio = []; stdData.V.area_ratio = [];
            stdData.H.habit = []; stdData.V.habit = [];
            stdData.H.Temp = []; stdData.V.Temp = [];

            for mm = 1 : length(fnames)
                mtemp = data.(fnames{mm});
                stdData.H.AR = [stdData.H.AR mtemp.H.AR];
                stdData.V.AR = [stdData.V.AR mtemp.V.AR];
                stdData.H.EllipAng = [stdData.H.EllipAng mtemp.H.EllipAng];
                stdData.V.EllipAng = [stdData.V.EllipAng mtemp.V.EllipAng];
                stdData.H.Dmajor = [stdData.H.Dmajor mtemp.H.Dmajor];
                stdData.V.Dmajor = [stdData.V.Dmajor mtemp.V.Dmajor];
                stdData.H.area_ratio = [stdData.H.area_ratio mtemp.H.area_ratio];
                stdData.V.area_ratio = [stdData.V.area_ratio mtemp.V.area_ratio];
                stdData.H.habit = [stdData.H.habit char(mtemp.H.habit)']; 
                stdData.V.habit = [stdData.V.habit char(mtemp.V.habit)'];
                stdData.H.Temp = [stdData.H.Temp mtemp.H.Temp];
                stdData.V.Temp = [stdData.V.Temp mtemp.V.Temp];
            end
            if isempty(target_fields)
                file_prefix = 'IMPACTS_2DS_MultiFlight_All_';
            else
                file_prefix = strcat('IMPACTS_2DS_MultiFlight_', strjoin(target_fields, '_'), '_');
            end
    end

    % Append temperature bounds to filename if custom filters are applied
    if Tc_max ~= 0 || Tc_min ~= -99999
        file_prefix = strcat(file_prefix, sprintf('Temp_%dto%d_', round(Tc_min), round(Tc_max)));
    end

    %% 4. Unified Filtering Block
    if strcmp(habit, 'all')
        indH_habit = true(size(stdData.H.AR));    
        indV_habit = true(size(stdData.V.AR));  
    else
        indH_habit = (stdData.H.habit == habit);     
        indV_habit = (stdData.V.habit == habit);
    end

    indH_temp = (stdData.H.Temp < Tc_max) & (stdData.H.Temp >= Tc_min);
    indV_temp = (stdData.V.Temp < Tc_max) & (stdData.V.Temp >= Tc_min);

    indH_valid = ~isnan(stdData.H.AR);
    indV_valid = ~isnan(stdData.V.AR);

    indH = indH_habit & indH_temp & indH_valid;
    indV = indV_habit & indV_temp & indV_valid;

    if AspectRatio_switch
        ARH = stdData.H.AR(indH); ARV = stdData.V.AR(indV);
    end
    if EllipAng_switch
        EllipAngH = stdData.H.EllipAng(indH); EllipAngV = stdData.V.EllipAng(indV);
    end
    if Dmajor_switch
        DmajorH = stdData.H.Dmajor(indH); DmajorV = stdData.V.Dmajor(indV);
    end
    if AreaRatio_switch
        AreaH = stdData.H.area_ratio(indH); AreaV = stdData.V.area_ratio(indV);
    end

    %% 5. Master Figure Initialization
    if combine_all
        fs_title = 20; fs_label = 18; fs_tick = 18; fs_cbar = 18;

        fig = figure('units','normalized','position',[0.0089 0 0.8698 0.8833],'visible',visible);

        left_gap = 0.0425;
        right_gap = 0.08;
        gutter = 0.63;
        lower = 0.085;
        upper = 0.04;

        % TIGHT SUBPLOT ORDER: Nh, Nw, gap, [lower upper], [left right]
        % Left Pair: 0.02 left margin, 0.58 right margin (Width = 0.40)
        %ax_L = tight_subplot(3, 2, [0.08 0.025], [0.08 0.04], [0.04 0.58]); 
        ax_L = tight_subplot(3, 2, [0.1 0.025], [lower upper], [left_gap (gutter-left_gap)]); 

        % Right Pair: 0.54 left margin (creates 0.12 gutter), 0.06 right margin (Width = 0.40)
        %ax_R = tight_subplot(3, 2, [0.08 0.025], [0.08 0.04], [0.54 0.08]);
        ax_R = tight_subplot(3, 2, [0.1 0.025], [lower upper], [(gutter-right_gap) right_gap]);

        if align_ticks
            % Custom Y-positions for a "2+1" Block Layout
            H = 0.245;           % Slightly shorter to fit the middle gap
            gap_tight = 0.015;   % Squeeze Row 1 and Row 2
            gap_label = 0.085;   % Standard gap for Row 2's X-labels
            
            y3 = 0.08;                           % Row 3 (Bottom)
            y2 = y3 + H + gap_label;             % Row 2 (Middle)
            y1 = y2 + H + gap_tight;             % Row 1 (Top)
            
            y_pos = [y1, y2, y3];
            
            for row = 1:3
                for col = 1:2
                    idx = (row-1)*2 + col;
                    % Apply to Left Column
                    pL = get(ax_L(idx), 'Position');
                    set(ax_L(idx), 'Position', [pL(1), y_pos(row), pL(3), H]);
                    % Apply to Right Column
                    pR = get(ax_R(idx), 'Position');
                    set(ax_R(idx), 'Position', [pR(1), y_pos(row), pR(3), H]);
                end
            end
        end

    elseif stack_all
        % 1. Reduce font sizes to prevent text overlap
        fs_title = 14; fs_label = 13; fs_tick = 12; fs_cbar = 10;

        if show_cbar
            fig_width = 0.2375;
            right_margin = 0.18;
        else
            fig_width = 0.239; % Thinner figure
            right_margin = 0.03; % Snug right margin
        end
        
        % Tall, skinny figure for a 6-row single column stack
        %fig = figure('units','normalized','position',[0.0974 0 0.2375 0.8898],'visible',visible);

        fig = figure('units','normalized','position',[0.0974 0 fig_width 0.8898],'visible',visible);


        if align_ticks
            % Build grid just to establish horizontal sizing
            
            %ax_stack = tight_subplot(6, 2, [0.0 0.04], [0.05 0.05], [0.125 0.18]);

            ax_stack = tight_subplot(6, 2, [0.0 0.05], [0.05 0.05], [0.11 right_margin]);

            % --- EXPLICIT Y-POSITION OVERRIDE ---
            % 3 Groups, 6 Panels Total.
            % Total vertical space = 1 - 0.05 (bottom) - 0.05 (top) = 0.90
            % Let panel height H = 0.12
            % Let tight intra-group gap = 0.005
            % Let large inter-group gap = 0.0825
            % Verification: 6(0.12) + 3(0.005) + 2(0.0825) = 0.72 + 0.015 + 0.165 = 0.90
            
            %H = 0.125;
            %y6 = 0.06; % Shifted up from 0.05
            %group_gap = 0.07;
            %panel_gap = 0.01;

            H = 0.124;
            y6 = 0.06; % Shifted up from 0.05
            group_gap = 0.07;
            panel_gap = 0.01;

            y5 = y6 + H + group_gap; % Gap above Group 3
            y4 = y5 + H + panel_gap;  % Gap inside Group 2
            y3 = y4 + H + panel_gap;  % Gap inside Group 2
            y2 = y3 + H + group_gap; % Gap above Group 2
            y1 = y2 + H + panel_gap;  % Gap inside Group 1

            %fprintf('total=%f',6*H+3*panel_gap+2*group_gap)
            
            y_pos = [y1, y2, y3, y4, y5, y6];
            
            for row = 1:6
                for col = 1:2
                    idx = (row-1)*2 + col;
                    p = get(ax_stack(idx), 'Position');
                    set(ax_stack(idx), 'Position', [p(1), y_pos(row), p(3), H]);
                end
            end
            
            % Route axes logic to group by X-axis
            % Group 1: X = Dmajor
            ax_p2 = ax_stack(1:2); % Top row
            ax_p5 = ax_stack(3:4); % Bottom row (gets labels)
            % Group 2: X = EllipAng
            ax_p1 = ax_stack(5:6); % Top row
            ax_p3 = ax_stack(7:8); % Mid row
            ax_p6 = ax_stack(9:10);% Bottom row (gets labels)
            % Group 3: X = AreaRatio
            ax_p4 = ax_stack(11:12);
        else
            ax_stack = tight_subplot(6, 2, [0.06 0.03], [0.04 0.04], [0.12 0.18]);
            ax_p1 = ax_stack(1:2); ax_p2 = ax_stack(3:4); ax_p3 = ax_stack(5:6); 
            ax_p4 = ax_stack(7:8); ax_p5 = ax_stack(9:10); ax_p6 = ax_stack(11:12);
        end

        ax = ax_stack;

    else
       % fs_title = 32; fs_label = 26; fs_tick = 22; fs_cbar = 22;

        fs_title = 42; fs_label = 32; fs_tick = 36; fs_cbar = 32;

    end

    % % Standard Axis Setup Variables
    % ang_ticks = -90:30:90;
    % ang_ticklabels = {'$-90^{\circ}$', '$-60^{\circ}$', '$-30^{\circ}$', '$0^{\circ}$', '$30^{\circ}$', '$60^{\circ}$', '$90^{\circ}$'};
    % dmajor_ticks = log10([0.5 1 2 4]);
    % dmajor_ticklabels = {'0.5', '1.0', '2.0', '4.0'};

    %% Plot 1: Aspect Ratio / Ellipse Angle (TOP RIGHT)
    if (AspectRatio_switch && EllipAng_switch)
        colorscale = 'log'; color_lims = [0.00001 0.5];

        if combine_all
            ax1 = ax_R(1); ax2 = ax_R(2);

        elseif stack_all
            ax1 = ax_p1(1); ax2 = ax_p1(2);            

        else
            %fig = figure('units','normalized','position',[0.0417 0.2880 0.9005 0.5750],'visible',visible);
            fig = figure('units','normalized','position',[0.0391    0.2046    0.9057    0.6472],'visible',visible);
            %ax_temp = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);
            ax_temp = tight_subplot(1,2,0.03,[0.22 0.1],[0.075 0.125]);
            ax1 = ax_temp(1); ax2 = ax_temp(2);
        end

        histogram2(ax1,EllipAngH,ARH,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        %xlim(ax1,[-90 90]); ylim(ax1,[0 1]);
        xlim(ax1,[min(ang_edges),max(ang_edges)]); ylim(ax1,[min(xedges) max(xedges)]);
        set(ax1,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax1,color_lims); set(ax1,'colorscale',colorscale);
        if stack_all
        ylabel(ax1,'Aspect Ratio','interpreter','latex','fontsize',fs_label);
        xl1 = xlabel(ax1,'Angle','interpreter','latex','fontsize',fs_label); 
        else
        ylabel(ax1,'Ellipse Aspect Ratio','interpreter','latex','fontsize',fs_label);
        xl1 = xlabel(ax1,'Ellipse Angle','interpreter','latex','fontsize',fs_label);
        end
        grid(ax1, 'on'); set(ax1,'xtick',ang_ticks,'xticklabel',ang_ticklabels); set(ax1,'ytick',AspectRatio_ticks,'yticklabel',AspectRatio_ticklabels);

        %if stack_all
        if combine_all || stack_all
            % Shift Ellipse Angle xlabel up
            set(xl1, 'Units', 'normalized'); p1 = get(xl1, 'Position'); 
            set(xl1, 'Position', [p1(1), p1(2)+0.06, p1(3)]);
        else
            % Shift Ellipse Angle xlabel up
            set(xl1, 'Units', 'normalized'); p1 = get(xl1, 'Position'); 
            set(xl1, 'Position', [p1(1), p1(2)+0.042, p1(3)]);
        end

        histogram2(ax2,EllipAngV,ARV,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        %xlim(ax2,[-90 90]); ylim(ax2,[0 1]);
        xlim(ax2,[min(ang_edges),max(ang_edges)]); ylim(ax2,[min(xedges) max(xedges)]);
        set(ax2,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax2,color_lims); set(ax2,'colorscale',colorscale);
        xl2 = xlabel(ax2,'Ellipse Angle','interpreter','latex','fontsize',fs_label);
        grid(ax2, 'on'); set(ax2,'xtick',ang_ticks,'xticklabel',ang_ticklabels); 
        set(ax2,'ytick',AspectRatio_ticks); set(ax2,'yticklabel',{''}); colormap(fig, manga);

       % if align_ticks && stack_all
        if align_ticks && (stack_all || combine_all)
            % Inner panel: Strip labels
            set(ax1, 'xticklabel', ''); set(ax2, 'xticklabel', '');
            xlabel(ax1,''); xlabel(ax2,'');
        else
            xl1 = xlabel(ax1,'Ellipse Angle','interpreter','latex','fontsize',fs_label);
            xl2 = xlabel(ax2,'Ellipse Angle','interpreter','latex','fontsize',fs_label);
            %if combine_all || stack_all
            if stack_all
                set(xl1, 'Units', 'normalized'); p1 = get(xl1, 'Position'); set(xl1, 'Position', [p1(1), p1(2)+0.06, p1(3)]);
                set(xl2, 'Units', 'normalized'); p2 = get(xl2, 'Position'); set(xl2, 'Position', [p2(1), p2(2)+0.06, p2(3)]);
            else
                if exist('yl1', 'var') && isgraphics(yl1)
                    set(yl1, 'Units', 'normalized'); p_yl = get(yl1, 'Position'); set(yl1, 'Position', [p_yl(1)-0.05, p_yl(2), p_yl(3)]);
                end
                %set(yl1, 'Units', 'normalized'); p_yl = get(yl1, 'Position'); set(yl1, 'Position', [p_yl(1)-0.05, p_yl(2), p_yl(3)]);
            end
        end

        if combine_all 

            % Shift Ellipse Angle xlabel up
            set(xl2, 'Units', 'normalized'); p2 = get(xl2, 'Position'); set(xl2, 'Position', [p2(1), p2(2)+0.06, p2(3)]);

            title(ax1,sprintf('Horizontal (N=%s)',addComma(length(ARH))),'Interpreter','latex','fontsize',fs_title);
            title(ax2,sprintf('Vertical (N=%s)',addComma(length(ARV))),'Interpreter','latex','fontsize',fs_title);

            if show_cbar
                pos = get(ax2, 'Position'); 
                cbar = colorbar(ax2);
                set(cbar,'TickLabelInterpreter','latex','FontSize',fs_cbar);
                ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
                set(ax2, 'Position', pos);
            end

        elseif stack_all

            % Shift Ellipse Angle xlabel up
            set(xl2, 'Units', 'normalized'); p2 = get(xl2, 'Position'); set(xl2, 'Position', [p2(1), p2(2)+0.06, p2(3)]);

            if show_cbar
                pos = get(ax2, 'Position'); 
                cbar = colorbar(ax2);
                set(cbar,'TickLabelInterpreter','latex','FontSize',fs_cbar);
                ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
                set(ax2, 'Position', pos);
            end

        else
            % Shift Ellipse Angle xlabel up
            set(xl2, 'Units', 'normalized'); p2 = get(xl2, 'Position'); set(xl2, 'Position', [p2(1), p2(2)+0.042, p2(3)]);

            title(ax1,sprintf('Horizontal (N=%s)',addComma(length(ARH))),'Interpreter','latex','fontsize',fs_title);
            title(ax2,sprintf('Vertical (N=%s)',addComma(length(ARV))),'Interpreter','latex','fontsize',fs_title);
            
            
            % cbar = colorbar(ax2);
            % %set(cbar,'position',[0.9 0.1997 0.0179 0.7005],'ticklabelinterpreter','latex','fontsize',fs_cbar,'linewidth',1.2,'ticklength',0.04);
            % set(cbar,'position',[0.895 0.22 0.0179 0.682],'ticklabelinterpreter','latex','fontsize',fs_cbar,'linewidth',1.2,'ticklength',0.04);
            % ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            % 
            if show_cbar
                cbar = colorbar(ax2);
                set(cbar,'position',[0.895 0.22 0.0179 0.682],'ticklabelinterpreter','latex','fontsize',fs_cbar,'linewidth',1.2,'ticklength',0.04);
                ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            end        
        
        end


        if show_cbar && strcmp(colorscale,'log')
            set(cbar,'ytick',[0.00001 0.0001 0.001 0.01 0.1 0.5],'yticklabel',{'$10^{-5}$','$10^{-4}$', '$10^{-3}$','$10^{-2}$','$10^{-1}$','$0.5$'});
        end

        if ~combine_all && ~stack_all && save_fig
            pdf_print(fullfile(outdir, strcat(file_prefix, 'AspectRatio_EllipAng')),'-dpdf');
            close(fig);
        end
    end

    %% Plot 2: Dmajor / Aspect Ratio (TOP LEFT)
    if (AspectRatio_switch && Dmajor_switch)
        colorscale = 'log'; color_lims = [0.01 50.0];

        if combine_all
            ax1 = ax_L(1); ax2 = ax_L(2);

        elseif stack_all
            ax1 = ax_p2(1); ax2 = ax_p2(2);

        else
            fig = figure('units','normalized','position',[0.0417 0.2880 0.9005 0.5750],'visible',visible);
            %ax_temp = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);
            ax_temp = tight_subplot(1,2,0.04,[0.25 0.1],[0.10 0.125]);
            ax1 = ax_temp(1); ax2 = ax_temp(2);
        end

        histogram2(ax1,log10(DmajorH),ARH,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        xlim(ax1,log10([min(Dmajor_edges) max(Dmajor_edges)])); ylim(ax1,[min(xedges) max(xedges)]);
        set(ax1,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax1,color_lims); set(ax1,'colorscale',colorscale);

        if stack_all
        ylabel(ax1,'Aspect Ratio','interpreter','latex','fontsize',fs_label);
        xlabel(ax1,'Major Axis (mm)','interpreter','latex','fontsize',fs_label);
        else
        ylabel(ax1,'Ellipse Aspect Ratio','interpreter','latex','fontsize',fs_label);
        xlabel(ax1,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',fs_label);
        end


        set(ax1,'xtick',dmajor_ticks,'xticklabel',dmajor_ticklabels);
        grid(ax1, 'on'); set(ax1,'ytick',AspectRatio_ticks,'yticklabels',AspectRatio_ticklabels);

        histogram2(ax2,log10(DmajorV),ARV,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        xlim(ax2,log10([min(Dmajor_edges) max(Dmajor_edges)]));  ylim(ax2,[min(xedges) max(xedges)]);
        set(ax2,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax2,color_lims); set(ax2,'colorscale',colorscale);
        grid(ax2, 'on'); 
        
        if stack_all
        xlabel(ax2,'Major Axis (mm)','interpreter','latex','fontsize',fs_label);
        else
        xlabel(ax2,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',fs_label);
        end

        set(ax2,'xtick',dmajor_ticks,'xticklabel',dmajor_ticklabels);
        set(ax2,'ytick',AspectRatio_ticks); set(ax2,'yticklabel',{''}); colormap(fig, manga);

       % if align_ticks && stack_all
        if align_ticks && (stack_all || combine_all)
            set(ax1, 'xticklabel', ''); set(ax2, 'xticklabel', '');
            xlabel(ax1,''); xlabel(ax2,'');
        else
            if stack_all
            xl1 = xlabel(ax1,'Major Axis (mm)','interpreter','latex','fontsize',fs_label);
            xl2 = xlabel(ax2,'Major Axis (mm)','interpreter','latex','fontsize',fs_label);
            else
            xl1 = xlabel(ax1,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',fs_label);
            xl2 = xlabel(ax2,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',fs_label);
            end
            %if combine_all || stack_all
            if stack_all
                set(xl1, 'Units', 'normalized'); p1 = get(xl1, 'Position'); set(xl1, 'Position', [p1(1), p1(2)+0.06, p1(3)]);
                set(xl2, 'Units', 'normalized'); p2 = get(xl2, 'Position'); set(xl2, 'Position', [p2(1), p2(2)+0.06, p2(3)]);
            else
                if exist('yl1', 'var') && isgraphics(yl1)
                    set(yl1, 'Units', 'normalized'); p_yl = get(yl1, 'Position'); set(yl1, 'Position', [p_yl(1)-0.05, p_yl(2), p_yl(3)]);
                end
                %set(yl1, 'Units', 'normalized'); p_yl = get(yl1, 'Position'); set(yl1, 'Position', [p_yl(1)-0.05, p_yl(2), p_yl(3)]);
            end
        end

        if combine_all
            title(ax1,sprintf('Horizontal (N=%s)',addComma(length(ARH))),'Interpreter','latex','fontsize',fs_title);
            title(ax2,sprintf('Vertical (N=%s)',addComma(length(ARV))),'Interpreter','latex','fontsize',fs_title);

            if show_cbar
            pos = get(ax2, 'Position'); 
            cbar = colorbar(ax2);
            set(cbar,'TickLabelInterpreter','latex','FontSize',fs_cbar);
            ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            set(ax2, 'Position', pos);
            end
        elseif stack_all
            title(ax1,sprintf('Horizontal (N=%s)',addComma(length(ARH))),'Interpreter','latex','fontsize',fs_title);
            title(ax2,sprintf('Vertical (N=%s)',addComma(length(ARV))),'Interpreter','latex','fontsize',fs_title);

            %title(ax1, {'Horizontal', sprintf('(N=%s)', addComma(length(ARH)))}, 'Interpreter', 'latex', 'fontsize', fs_title);
            %title(ax2, {'Vertical', sprintf('(N=%s)', addComma(length(ARV)))}, 'Interpreter', 'latex', 'fontsize', fs_title);


            if show_cbar
            pos = get(ax2, 'Position'); 
            cbar = colorbar(ax2);
            set(cbar,'TickLabelInterpreter','latex','FontSize',fs_cbar);
            ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            set(ax2, 'Position', pos);        
            end

        else
            title(ax1,sprintf('Horizontal (N=%s)',addComma(length(ARH))),'Interpreter','latex','fontsize',fs_title);
            title(ax2,sprintf('Vertical (N=%s)',addComma(length(ARV))),'Interpreter','latex','fontsize',fs_title);
            
            if show_cbar
            cbar = colorbar(ax2);
            set(cbar,'position',[0.9 0.1997 0.0179 0.7005],'ticklabelinterpreter','latex','fontsize',fs_cbar,'linewidth',1.2,'ticklength',0.04);
            ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            end

        end
        
        if show_cbar && strcmp(colorscale,'log')
            set(cbar,'ytick',[0.01 0.1 1.0 10 50],'yticklabel',{'$10^{-2}$','$10^{-1}$','$10^{0}$','$10^{1}$','$50$'});
        end

        if ~combine_all && ~stack_all && save_fig
            pdf_print(fullfile(outdir, strcat(file_prefix, 'Dmajor_AspectRatio')),'-dpdf');
            close(fig);
        end
    end

    %% Plot 3: Ellipse Angle / Dmajor (BOTTOM RIGHT)
    if (EllipAng_switch && Dmajor_switch)
        colorscale = 'log'; color_lims = [0.0001 0.1];

        if combine_all
            ax1 = ax_R(5); ax2 = ax_R(6);

        elseif stack_all
            ax1 = ax_p3(1); ax2 = ax_p3(2);

        else
            fig = figure('units','normalized','position',[0.0417 0.2880 0.9005 0.5750],'visible',visible);
            %ax_temp = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);
            ax_temp = tight_subplot(1,2,0.04,[0.25 0.1],[0.10 0.125]);
            ax1 = ax_temp(1); ax2 = ax_temp(2);
        end

        histogram2(ax1,EllipAngH,log10(DmajorH),'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        ylim(ax1,log10([min(Dmajor_edges) max(Dmajor_edges)])); xlim(ax1,[min(ang_edges) max(ang_edges)]);
        set(ax1,'ytick',dmajor_ticks,'yticklabel',dmajor_ticklabels);
        set(ax1,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax1,color_lims); set(ax1,'colorscale',colorscale);

        if stack_all
        ylabel(ax1,'Major Axis (mm)','interpreter','latex','fontsize',fs_label);
        xl1 = xlabel(ax1,'Angle','interpreter','latex','fontsize',fs_label);
        else
        ylabel(ax1,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',fs_label);
        xl1 = xlabel(ax1,'Ellipse Angle','interpreter','latex','fontsize',fs_label);            
        end

        grid(ax1, 'on'); set(ax1,'xtick',ang_ticks,'xticklabel',ang_ticklabels);

        if combine_all
            % Shift Ellipse Angle xlabel up
            set(xl1, 'Units', 'normalized'); p1 = get(xl1, 'Position'); 
            set(xl1, 'Position', [p1(1), p1(2)+0.06, p1(3)]);
        end

        histogram2(ax2,EllipAngV,log10(DmajorV),'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        ylim(ax2,log10([min(Dmajor_edges) max(Dmajor_edges)])); xlim(ax2,[min(ang_edges) max(ang_edges)]);
        set(ax2,'ytick',dmajor_ticks,'yticklabel',{''});
        set(ax2,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax2,color_lims); set(ax2,'colorscale',colorscale);
        grid(ax2, 'on'); xl2 = xlabel(ax2,'Ellipse Angle','interpreter','latex','fontsize',fs_label);
        set(ax2,'xtick',ang_ticks,'xticklabel',ang_ticklabels); colormap(fig, manga);

        if align_ticks && stack_all
       % if align_ticks && (stack_all || combine_all)
            set(ax1, 'xticklabel', ''); set(ax2, 'xticklabel', '');
            xlabel(ax1,''); xlabel(ax2,'');
        else
            if stack_all
            xl1 = xlabel(ax1,'Angle','interpreter','latex','fontsize',fs_label);
            xl2 = xlabel(ax2,'Angle','interpreter','latex','fontsize',fs_label);
            else
            xl1 = xlabel(ax1,'Ellipse Angle','interpreter','latex','fontsize',fs_label);
            xl2 = xlabel(ax2,'Ellipse Angle','interpreter','latex','fontsize',fs_label);                
            end

            %if combine_all || stack_all
            if stack_all
                set(xl1, 'Units', 'normalized'); p1 = get(xl1, 'Position'); set(xl1, 'Position', [p1(1), p1(2)+0.06, p1(3)]);
                set(xl2, 'Units', 'normalized'); p2 = get(xl2, 'Position'); set(xl2, 'Position', [p2(1), p2(2)+0.06, p2(3)]);
            else
                if exist('yl1', 'var') && isgraphics(yl1)
                    set(yl1, 'Units', 'normalized'); p_yl = get(yl1, 'Position'); set(yl1, 'Position', [p_yl(1)-0.05, p_yl(2), p_yl(3)]);
                end
               % set(yl1, 'Units', 'normalized'); p_yl = get(yl1, 'Position'); set(yl1, 'Position', [p_yl(1)-0.05, p_yl(2), p_yl(3)]);
            end
        end


        if combine_all || stack_all
            % Shift Ellipse Angle xlabel up
            set(xl2, 'Units', 'normalized'); p2 = get(xl2, 'Position'); set(xl2, 'Position', [p2(1), p2(2)+0.06, p2(3)]);
            
            title(ax1, ''); title(ax2, '');

            if show_cbar
            pos = get(ax2, 'Position'); 
            cbar = colorbar(ax2);
            set(cbar,'TickLabelInterpreter','latex','FontSize',fs_cbar);
            ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            set(ax2, 'Position', pos);
            end
            
        else
            title(ax1,sprintf('Horizontal (N=%s)',addComma(length(DmajorH))),'Interpreter','latex','fontsize',fs_title);
            title(ax2,sprintf('Vertical (N=%s)',addComma(length(DmajorV))),'Interpreter','latex','fontsize',fs_title);
            
            if show_cbar
            cbar = colorbar(ax2);
            set(cbar,'position',[0.9 0.1997 0.0179 0.7005],'ticklabelinterpreter','latex','fontsize',fs_cbar,'linewidth',1.2,'ticklength',0.04);
            ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            end
        end

        if show_cbar && strcmp(colorscale,'log')
            set(cbar,'ytick',[0.0001 0.001 0.01 0.1],'yticklabel',{'$10^{-4}$','$10^{-3}$','$10^{-2}$','$10^{-1}$'});
        end

        if ~combine_all && ~stack_all && save_fig
            pdf_print(fullfile(outdir, strcat(file_prefix, 'EllipAng_Dmajor')),'-dpdf');
            close(fig);
        end
    end

    %% Plot 4: Area Ratio / Aspect Ratio (BOTTOM LEFT)
    if (AspectRatio_switch && AreaRatio_switch)
        colorscale = 'log'; color_lims = [0.01 50];

        if combine_all
            ax1 = ax_L(5); ax2 = ax_L(6);

        elseif stack_all
            ax1 = ax_p4(1); ax2 = ax_p4(2);

        else
            fig = figure('units','normalized','position',[0.0417 0.2880 0.9005 0.5750],'visible',visible);
            %ax_temp = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);
            ax_temp = tight_subplot(1,2,0.04,[0.25 0.1],[0.10 0.125]);
            ax1 = ax_temp(1); ax2 = ax_temp(2);
        end

        histogram2(ax1,AreaH,ARH,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        ylim(ax1,[min(xedges) max(xedges)]); xlim(ax1,[min(area_edges) max(area_edges)]);
        set(ax1,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax1,color_lims); set(ax1,'colorscale',colorscale);

        if stack_all
        xlabel(ax1,'Area Ratio','interpreter','latex','fontsize',fs_label);
        ylabel(ax1,'Aspect Ratio','interpreter','latex','fontsize',fs_label);
        else
        xlabel(ax1,'Ellipse Area Ratio','interpreter','latex','fontsize',fs_label);
        ylabel(ax1,'Ellipse Aspect Ratio','interpreter','latex','fontsize',fs_label);            
        end

        grid(ax1, 'on'); set(ax1,'ytick',AspectRatio_ticks,'yticklabel',AspectRatio_ticklabels); set(ax1,'xtick',AreaRatio_ticks,'xticklabel',AreaRatio_ticklabels);

        histogram2(ax2,AreaV,ARV,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        ylim(ax2,[min(xedges) max(xedges)]); xlim(ax2,[min(area_edges) max(area_edges)]);
        set(ax2,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax2,color_lims); set(ax2,'colorscale',colorscale);
        grid(ax2, 'on'); 
        
        if stack_all
        xlabel(ax2,'Area Ratio','interpreter','latex','fontsize',fs_label);
        else
         xlabel(ax2,'Ellipse Area Ratio','interpreter','latex','fontsize',fs_label);           
        end
        
        %set(ax2,'ytick',AreaRatio_ticks); set(ax2,'yticklabel',{''}); set(ax2,'xtick',0:0.2:1); colormap(fig, manga);

        set(ax2,'ytick',AspectRatio_ticks); set(ax2,'yticklabel',{''}); 
        set(ax2,'xtick',AreaRatio_ticks,'xticklabel',AreaRatio_ticklabels); colormap(fig, manga);


        if combine_all || stack_all
            title(ax1, ''); title(ax2, '');

            if show_cbar
            pos = get(ax2, 'Position'); 
            cbar = colorbar(ax2);
            set(cbar,'TickLabelInterpreter','latex','FontSize',fs_cbar);
            ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            set(ax2, 'Position', pos);
            end
        else
            title(ax1,sprintf('Horizontal (N=%s)',addComma(length(AreaH))),'Interpreter','latex','fontsize',fs_title);
            title(ax2,sprintf('Vertical (N=%s)',addComma(length(AreaV))),'Interpreter','latex','fontsize',fs_title);
            
            if show_cbar
            cbar = colorbar(ax2);
            set(cbar,'position',[0.9 0.1997 0.0179 0.7005],'ticklabelinterpreter','latex','fontsize',fs_cbar,'linewidth',1.2,'ticklength',0.04);
            ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            end
        end
        if show_cbar && strcmp(colorscale,'log')
            set(cbar,'ytick',[0.01 0.1 1.0 10 50],'yticklabel',{'$10^{-2}$','$10^{-1}$','$10^{0}$','$10^{1}$','$50$'});
        end

        if ~combine_all && ~stack_all && save_fig
            pdf_print(fullfile(outdir, strcat(file_prefix, 'AreaRatio_AspectRatio')),'-dpdf');
            close(fig);
        end
    end

    %% Plot 5: Dmajor / Area Ratio (MIDDLE LEFT)
    if (Dmajor_switch && AreaRatio_switch)
        colorscale = 'log'; color_lims = [0.01 50];

        if combine_all
            ax1 = ax_L(3); ax2 = ax_L(4);

        elseif stack_all
            ax1 = ax_p5(1); ax2 = ax_p5(2);     

        else
            fig = figure('units','normalized','position',[0.0417 0.2880 0.9005 0.5750],'visible',visible);
            %ax_temp = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);
            ax_temp = tight_subplot(1,2,0.04,[0.25 0.1],[0.10 0.125]);
            ax1 = ax_temp(1); ax2 = ax_temp(2);
        end

        histogram2(ax1,log10(DmajorH),AreaH,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        xlim(ax1,log10([min(Dmajor_edges) max(Dmajor_edges)])); ylim(ax1,[min(area_edges) max(area_edges)]);
        set(ax1,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax1,color_lims); set(ax1,'colorscale',colorscale);

        if stack_all
        ylabel(ax1,'Area Ratio','interpreter','latex','fontsize',fs_label);
        xlabel(ax1,'Major Axis (mm)','interpreter','latex','fontsize',fs_label);
        else
        ylabel(ax1,'Ellipse Area Ratio','interpreter','latex','fontsize',fs_label);
        xlabel(ax1,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',fs_label);            
        end

        set(ax1,'xtick',dmajor_ticks,'xticklabel',dmajor_ticklabels);
        grid(ax1, 'on'); set(ax1,'ytick',AreaRatio_ticks,'yticklabels',AreaRatio_ticklabels);

        histogram2(ax2,log10(DmajorV),AreaV,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        xlim(ax2,log10([min(Dmajor_edges) max(Dmajor_edges)])); ylim(ax2,[min(area_edges) max(area_edges)]);
        set(ax2,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax2,color_lims); set(ax2,'colorscale',colorscale);
        grid(ax2, 'on'); set(ax2,'xtick',dmajor_ticks,'xticklabel',dmajor_ticklabels);

        if stack_all
        xlabel(ax2,'Major Axis (mm)','interpreter','latex','fontsize',fs_label);
        else
        xlabel(ax2,'Ellipse Major Axis (mm)','interpreter','latex','fontsize',fs_label);            
        end

        set(ax2,'ytick',AreaRatio_ticks); set(ax2,'yticklabel',{''}); colormap(fig, manga);

        if combine_all || stack_all
            title(ax1, ''); title(ax2, '');

            if show_cbar
            pos = get(ax2, 'Position'); 
            cbar = colorbar(ax2);
            set(cbar,'TickLabelInterpreter','latex','FontSize',fs_cbar);
            ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            set(ax2, 'Position', pos);
            end
        else
            title(ax1,sprintf('Horizontal (N=%s)',addComma(length(AreaH))),'Interpreter','latex','fontsize',fs_title);
            title(ax2,sprintf('Vertical (N=%s)',addComma(length(AreaV))),'Interpreter','latex','fontsize',fs_title);
            
            if show_cbar
            cbar = colorbar(ax2);
            set(cbar,'position',[0.9 0.1997 0.0179 0.7005],'ticklabelinterpreter','latex','fontsize',fs_cbar,'linewidth',1.2,'ticklength',0.04);
            ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            end
        end

        if show_cbar && strcmp(colorscale,'log')
            set(cbar,'ytick',[0.01 0.1 1.0 10 50],'yticklabel',{'$10^{-2}$','$10^{-1}$','$10^{0}$','$10^{1}$','$50$'});
        end

        if ~combine_all && ~stack_all && save_fig
            pdf_print(fullfile(outdir, strcat(file_prefix, 'Dmajor_AreaRatio')),'-dpdf');
            close(fig);
        end
    end

    %% Plot 6: Ellipse Angle / Area Ratio (MIDDLE RIGHT)
    if (EllipAng_switch && AreaRatio_switch)
        colorscale = 'log'; color_lims = [0.0001 0.5];

        if combine_all
            ax1 = ax_R(3); ax2 = ax_R(4);

        elseif stack_all
            ax1 = ax_p6(1); ax2 = ax_p6(2);

        else
            fig = figure('units','normalized','position',[0.0417 0.2880 0.9005 0.5750],'visible',visible);
           % ax_temp = tight_subplot(1,2,0.04,[0.2 0.1],[0.06 0.125]);
            ax_temp = tight_subplot(1,2,0.04,[0.25 0.1],[0.10 0.125]);
            ax1 = ax_temp(1); ax2 = ax_temp(2);
        end

        histogram2(ax1,EllipAngH,AreaH,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        xlim(ax1,[min(ang_edges) max(ang_edges)]); ylim(ax1,[min(area_edges) max(area_edges)]);
        set(ax1,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax1,color_lims); set(ax1,'colorscale',colorscale);

        if stack_all
        ylabel(ax1,'Area Ratio','interpreter','latex','fontsize',fs_label);
        xl1 = xlabel(ax1,'Angle','interpreter','latex','fontsize',fs_label);
        else
        ylabel(ax1,'Ellipse Area Ratio','interpreter','latex','fontsize',fs_label);
        xl1 = xlabel(ax1,'Ellipse Angle','interpreter','latex','fontsize',fs_label); 
        end

        grid(ax1, 'on'); set(ax1,'xtick',ang_ticks,'xticklabel',ang_ticklabels); set(ax1,'ytick',AreaRatio_ticks,'yticklabel',AreaRatio_ticklabels);

        if combine_all || stack_all
            % Shift Ellipse Angle xlabel up
            set(xl1, 'Units', 'normalized'); p1 = get(xl1, 'Position'); set(xl1, 'Position', [p1(1), p1(2)+0.06, p1(3)]);
        end

        histogram2(ax2,EllipAngV,AreaV,'displaystyle','tile','Normalization',normalization,'LineStyle','none');
        xlim(ax2,[min(ang_edges) max(ang_edges)]); ylim(ax2,[min(area_edges) max(area_edges)]);
        set(ax2,'ticklabelinterpreter','latex','fontsize',fs_tick,'layer','top','linewidth',1.4,'ticklength',[0.02 0.04]);
        clim(ax2,color_lims); set(ax2,'colorscale',colorscale);
        grid(ax2, 'on'); 
        
        if stack_all
        xl2 = xlabel(ax2,'Angle','interpreter','latex','fontsize',fs_label);
        else
        xl2 = xlabel(ax2,'Ellipse Angle','interpreter','latex','fontsize',fs_label); 
        end


        set(ax2,'xtick',ang_ticks,'xticklabel',ang_ticklabels); set(ax2,'ytick',AreaRatio_ticks); set(ax2,'yticklabel',{''}); colormap(fig, manga);

        % if align_ticks && combine_all
        %     set(ax1, 'xticklabel', ''); set(ax2, 'xticklabel', '');
        %     xlabel(ax1,''); xlabel(ax2,'');
        % end

        if combine_all || stack_all

            % Shift Ellipse Angle xlabel up
            %if stack_all
            set(xl2, 'Units', 'normalized'); p2 = get(xl2, 'Position'); 
            set(xl2, 'Position', [p2(1), p2(2)+0.06, p2(3)]);
            %end

            title(ax1, ''); title(ax2, '');

            if show_cbar
            pos = get(ax2, 'Position'); 
            cbar = colorbar(ax2);
            set(cbar,'TickLabelInterpreter','latex','FontSize',fs_cbar);
            ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            set(ax2, 'Position', pos);    
            end
        else
            title(ax1,sprintf('Horizontal (N=%s)',addComma(length(AreaH))),'Interpreter','latex','fontsize',fs_title);
            title(ax2,sprintf('Vertical (N=%s)',addComma(length(AreaV))),'Interpreter','latex','fontsize',fs_title);
            
            if show_cbar
            cbar = colorbar(ax2);
            set(cbar,'position',[0.9 0.1997 0.0179 0.7005],'ticklabelinterpreter','latex','fontsize',fs_cbar,'linewidth',1.2,'ticklength',0.04);
            ylabel(cbar,'Probability Density','interpreter','latex','fontsize',fs_cbar,'rotation',270,'verticalalignment','bottom');
            end
        end
        if show_cbar && strcmp(colorscale,'log')
            set(cbar,'ytick',[0.0001 0.001 0.01 0.1 0.5],'yticklabel',{'$10^{-4}$','$10^{-3}$','$10^{-2}$','$10^{-1}$','$0.5$'});
        end

        if ~combine_all && ~stack_all && save_fig
            pdf_print(fullfile(outdir, strcat(file_prefix, 'EllipAng_AreaRatio')),'-dpdf');
            close(fig);
        end
    end

    %% Save the Combined Master Figure
    if combine_all && save_fig
        pdf_print(fullfile(outdir, strcat(file_prefix, 'All_JointDists_3x2')),'-dpdf');
        close(fig);
    elseif stack_all && save_fig
        pdf_print(fullfile(outdir, strcat(file_prefix, 'All_JointDists_Stack')),'-dpdf');
        close(fig);
    end
end

%% Helper Function
function numOut = addComma(numIn)
   jf = java.text.DecimalFormat; 
   numOut = char(jf.format(numIn)); 
end