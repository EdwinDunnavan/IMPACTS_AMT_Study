% Ellipse_CGAL_test_random.m

function results = Ellipse_CGAL_test_random(N_tests, show_plots)
    if nargin < 1, N_tests = 50; end
    if nargin < 2, show_plots = true; end

    % Define grid size based on classic OAP buffer strip dimensions
    m = 1700;
    n = 128;
    [Xt, Yt] = meshgrid(1:m, 1:n);

    % Define how many particles to composite into the example figure
    N_vis = min(6, N_tests); 
    composite_mask = false(n, m);

    % Pre-allocate results table
    results = zeros(N_tests, 10); 
    % Columns: [True_L, True_W, True_Ang, True_X, True_Y, CGAL_L, CGAL_W, CGAL_Ang, CGAL_X, CGAL_Y]

    fprintf('Generating and testing %d random ellipses...\n', N_tests);
    
    tic;
    for i = 1:N_tests
        % 1. Randomize Ellipse Parameters
        major_start = 20 + rand() * 80;           % Length: 20 to 100
        minor_start = 10 + rand() * (major_start - 10); % Width: 10 to major_start
        ang_start_orig = -90 + rand() * 180;       % Angle: -90 to 90 degrees
        y0 = 64;                                   % Lock Y to center of the 128 strip
        
        % Evenly space the visual examples to prevent overlap; randomize the rest
        if i <= N_vis
            x0 = (m / (N_vis + 1)) * i;
        else
            x0 = 150 + rand() * (m - 300);
        end
        
        ra = major_start / 2;
        rb = minor_start / 2;
        ang_start = -ang_start_orig;

        % 2. Analytical Ellipse Math
        a = ra.^2.*sind(ang_start).^2 + rb.^2.*cosd(ang_start).^2;
        b = 2.*(ra.^2 - rb.^2).*sind(ang_start).*cosd(ang_start);
        c = ra.^2.*cosd(ang_start).^2 + rb.^2 .* sind(ang_start).^2;
        d = -2.*a.*x0 - b.*y0;
        f = -b.*x0 - 2.*c.*y0;
        g = a.*x0.^2 + b.*x0.*y0 + c.*y0.^2 - ra.^2 .* rb.^2;

        % 3. Create Binary Mask 
        mask = (a.*(Xt).^2 + c.*(Yt).^2 + b.*(Xt).*(Yt) + d.*(Xt) + f.*(Yt) + g) <= 1;
        
        % Add to composite strip if it's one of our display particles
        if i <= N_vis
            composite_mask = composite_mask | mask;
        end
        
        % Convert to character array of '1's (background) and '0's (object)
        mask_new = char('1' - mask); 

        % 4. Call CGAL
        try
            [L_cgal, W_cgal, Ang_cgal_raw, xct, yct] = CGAL_EllipseSize_UIOPS(mask_new');
            
            % APPLY TRANSPOSE CORRECTION
            if Ang_cgal_raw >= 0
                Ang_cgal = pi/2 - Ang_cgal_raw;
            else
                Ang_cgal = -(pi/2 - abs(Ang_cgal_raw));
            end
            
            Ang_cgal = rad2deg(Ang_cgal);
            
        catch
            L_cgal = NaN; W_cgal = NaN; Ang_cgal = NaN; xct = NaN; yct = NaN;
        end

        % 5. Store Results
        results(i, :) = [major_start, minor_start, ang_start_orig, x0, y0, ...
                         L_cgal, W_cgal, Ang_cgal, xct, yct];
    end
    toc;
    
    fprintf('Testing complete.\n');

    % 6. Plotting
    if show_plots
        % --- FIGURE 1: Composite Buffer Strip ---
        fig_strip = figure('units','normalized','position',[0.1656 0.6361 0.7260 0.1296]);
        
        % Plot accumulated binary shadows
        pcolor(Xt, Yt, double(~composite_mask));
        colormap(gray); shading flat; hold on;
        
        % Loop through and draw outlines for the first N_vis particles
        for k = 1:N_vis
            % Overlay Analytical (Red Outline)
            plot_ellipse_outline(gca, results(k,1)/2, results(k,2)/2, results(k,4), results(k,5), results(k,3), 'r');
            % Overlay CGAL (Green Outline)
            plot_ellipse_outline(gca, results(k,6)/2, results(k,7)/2, results(k,9), results(k,10), results(k,8), 'g');
        end
        
        axis equal; xlim([0 m]); ylim([0 n]);
        title(sprintf('Example Buffer Strip (%d Particles | Red: Analytical, Green: CGAL)', N_vis), 'Interpreter', 'latex', 'FontSize', 16);
        xlabel('Pixels', 'Interpreter', 'latex');
        set(gca, 'TickLabelInterpreter', 'latex');
        drawnow;
        
        % --- FIGURE 2: Scatter Performance ---
        fig_perf = figure('units','normalized','position',[0.1 0.1 0.8 0.4]);
        
        % Major Axis
        subplot(1,3,1); hold on; box on; grid on;
        scatter(results(:,1), results(:,6), 40, 'b', 'filled', 'MarkerEdgeColor', 'k');
        plot([0, 150], [0, 150], 'r--', 'LineWidth', 2);
        xlabel('Analytical Major Axis'); ylabel('CGAL Major Axis');
        title('Major Axis ($L$)', 'Interpreter', 'latex');
        axis equal; xlim([0 150]); ylim([0 150]);
        
        % Minor Axis
        subplot(1,3,2); hold on; box on; grid on;
        scatter(results(:,2), results(:,7), 40, 'g', 'filled', 'MarkerEdgeColor', 'k');
        plot([0, 150], [0, 150], 'r--', 'LineWidth', 2);
        xlabel('Analytical Minor Axis'); ylabel('CGAL Minor Axis');
        title('Minor Axis ($W$)', 'Interpreter', 'latex');
        axis equal; xlim([0 150]); ylim([0 150]);
        
        % Angle
        subplot(1,3,3); hold on; box on; grid on;
        scatter(results(:,3), results(:,8), 40, 'm', 'filled', 'MarkerEdgeColor', 'k');
        plot([-90, 90], [-90, 90], 'r--', 'LineWidth', 2);
        xlabel('Analytical Angle (deg)'); ylabel('CGAL Angle (deg)');
        title('Orientation Angle ($\theta$)', 'Interpreter', 'latex');
        axis equal; xlim([-90 90]); ylim([-90 90]);
        
        sgtitle('CGAL Ellipse Fitting Performance (Monte Carlo)', 'Interpreter', 'latex', 'FontSize', 16);
    end
end

%% Helper Functions
function plot_ellipse_outline(ax, a, b, cx, cy, angle, color)
    % Draws a clean un-filled outline to overlay on the binary pcolor grid
    r = linspace(0, 360, 100);
    p = [(a.*cosd(r))' (b.*sind(r))'];
    alpha = [cosd(angle) -sind(angle); sind(angle) cosd(angle)]';
    p1 = p*alpha;
    plot(ax, cx+p1(:,1), cy+p1(:,2), 'Color', color, 'LineWidth', 2.5);
end