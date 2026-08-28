function m = fwd_project_ellipsoids(varargin)
% SIMULATE_ELLIPSOID_PROJECTIONS Consolidated forward simulator for joint
% distributions of projected ellipse characteristics. 
%
% Mode automatically switches to 'powerlaw' if 'a0' and 'ds' are provided.
% Otherwise, defaults to 'irregular'.

    %% 0. Instrument default parameters
   % W_array = 1.28;        % 2D-S Array width in mm
   % Lmin_steepness = 35;   % Controls the gradual roll-off of small particles
  %  Lmin_steepness = 60;   % Controls the gradual roll-off of small particles
  %  use_instrument_filter = true; % Toggle physical instrument limitations

    % NEW: 2D-S Physical Instrument Post-Processing Thresholds
    use_instrument_filter = true;
    W_array       = 1.28;  % 2D-S Array width in mm (Entire-in cutoff)
    Dthresh       = 0.35;   % Major axis threshold (mm)
    ar_thresh     = 0.1;   % Aspect ratio threshold
    area_thresh   = 0.2;   % Area ratio threshold
    NPixel_thresh = 800;   % Minimum pixels (1 pixel = 10um x 10um = 1e-4 mm^2)
    pixel_area    = 1e-4;  % mm^2

    %% 1. Default Parameters (Based on PAPER IRREGULAR 2020)
    N = 1e6;
   % Lmin = 0.35;
    
    %nu = 8; % ORIG
    nu = 1;
    %Dmean = 0.6; % ORIG

    Dmean = 2.0;
    
    % Irregular Defaults
    pba = 0.75;
    pcb = 0.75; % ORIG
    %abatog = 0.6; % ORIG
    abatog = 0.85;
    
    %ar_scale = 2.0;% ORIG

   % ar_scale = 0.5; % ORIG
   % ar_scale = 0.65; 
%    ar_scale = 0.92; 
    ar_scale = 0.75;
    %ar_min = 0.5; % ORIG
    ar_min = 0.2;

   % ar_exponent = -0.15; % NEW: Power-law exponent for Aspect Ratio (b/a)

    ar_exponent = [];
    %ar_exponent = -0.15;
  %  ar_exponent = -0.25; % NEW: Power-law exponent for Aspect Ratio (b/a)
   % ar_exponent = 0.35; % NEW: Power-law exponent for Aspect Ratio (b/a)
    
    % Powerlaw Defaults (Triggered if a0 and ds are assigned)
    a0 = [];
    ds = [];
    pbmean = 1.0;

    % Shared Orientation & Density Defaults
    ang_xz = -35;
    ang_xy = 45;
    kappa = 5;
    psimean = 0;
    varpsi = 0.001;
    rhomean = 0.8;
   % rhovar_frac = 0.12;
    rhovar_frac = 0.025;
    %AR_scale = 4/3; % ORIGINAL
    AR_scale = 0.61;
    %AR_min = 0.35;
    AR_min = 0.2;
    AR_exponent = -0.29; % NEW: Power-law exponent for Area Ratio

    %% 2. Parse varargin
    for nn = 1 : 2 : length(varargin)
        switch varargin{nn}
            case 'N',           N = varargin{nn+1};
            %case 'Lmin',        Lmin = varargin{nn+1};
            case 'nu',          nu = varargin{nn+1};
            case 'Dmean',       Dmean = varargin{nn+1};
            case 'pba',         pba = varargin{nn+1};
            case 'pcb',         pcb = varargin{nn+1};
            case 'abatog',      abatog = varargin{nn+1};
            case 'ar_scale',    ar_scale = varargin{nn+1};
            case 'ar_min',      ar_min = varargin{nn+1};
            case 'a0',          a0 = varargin{nn+1};
            case 'ds',          ds = varargin{nn+1};
            case 'pbmean',      pbmean = varargin{nn+1};
            case 'ang_xz',      ang_xz = varargin{nn+1};
            case 'ang_xy',      ang_xy = varargin{nn+1};
            case 'kappa',       kappa = varargin{nn+1};
            case 'psimean',     psimean = varargin{nn+1};
            case 'varpsi',      varpsi = varargin{nn+1};
            case 'rhomean',     rhomean = varargin{nn+1};
            case 'rhovar_frac', rhovar_frac = varargin{nn+1};
            case 'AR_scale',    AR_scale = varargin{nn+1};
            case 'AR_min',      AR_min = varargin{nn+1};
            case 'AR_exponent', AR_exponent = varargin{nn+1};
            case 'use_instrument_filter', use_instrument_filter = varargin{nn+1};
            case 'W_array',       W_array = varargin{nn+1};
            case 'Dthresh',       Dthresh = varargin{nn+1};
            case 'ar_thresh',     ar_thresh = varargin{nn+1};
            case 'area_thresh',   area_thresh = varargin{nn+1};
            case 'NPixel_thresh', NPixel_thresh = varargin{nn+1};
        end
    end

    % Determine Simulation Mode
    if ~isempty(a0) && ~isempty(ds)
        sim_mode = 'powerlaw';
        astar = a0.^(1-ds);
    else
        sim_mode = 'irregular';
    end

    %% 3. Pre-Calculations
    [phimean, thetamean, ~, ~] = ret_angle_3D_proj(ang_xz, ang_xy);
    %pd = truncate(makedist('Gamma','a',nu,'b',Dmean/nu),0.35,4);

    pd = truncate(makedist('Gamma','a',nu,'b',Dmean/nu),0.3,5);

    %% 4. Rejection Sampling Loop
    % Preallocate exact target sizes for speed
    a_tot       = zeros(1, N);
    L_xy        = zeros(1, N); 
    ar_xy       = zeros(1, N); 
    EllipAng_xy = zeros(1, N);
    AR_xy       = zeros(1, N);
    L_xz        = zeros(1, N); 
    ar_xz       = zeros(1, N); 
    EllipAng_xz = zeros(1, N);
    AR_xz       = zeros(1, N);

    n_valid = 0; % Index tracker for stored samples

    while n_valid < N
        
        a = pd.random([1 N]) ./ 2;

        %% 4a. Calculate Minor Axes (b, c) based on Mode
        if strcmp(sim_mode, 'irregular')

            % --- NEW: SIZE-DEPENDENT ASPECT RATIO ---
            if ~isempty(ar_exponent)
                pba_dyn = ar_scale .* (2 .* a) .^ ar_exponent;
                pba_dyn(pba_dyn > 0.99) = 0.99;
                pba_dyn(pba_dyn < ar_min) = ar_min;
            else
                % Fallback to constant scalar pba, vectorized to match 'a'
                pba_dyn = repmat(pba, 1, N);
            end

            %pcb_dyn = pba_dyn;


            pbmin = pba_dyn ./ (1 - pba_dyn);
            pcmin =  pba_dyn .* pcb ./ (1 - pcb); % ORIG

           % pcmin = pba_dyn .* pcb_dyn ./ (1 - pcb_dyn);

            % ORIG
            %pbmin = pba ./ (1-pba);
            %pcmin = pba .* pcb ./ (1-pcb);

            abamin = max(pbmin, pcmin);
            abamax = 20;

           % a_ba = abatog .* abamax + (1-abatog) .* abamin;
           % b_ba = ((1./pba_dyn)-1) .* a_ba;
           % b_cb = ((1./pcb_dyn)-1) .* a_ba ./ pba_dyn;

            %ORIG
            a_ba = abatog .* abamax + (1-abatog) .* abamin;
            b_ba = ((1./pba)-1) .* a_ba;
            b_cb = ((1./pcb)-1) .* a_ba ./ pba;

            phiba_samp1 = betarnd(a_ba, b_ba, [1 N]);

            % Irregular scales
            phiba_samp = 1.0 .* phiba_samp1; % Preserving f_ba = 1 logic
            phica_samp = phiba_samp .* betarnd(a_ba+b_ba, b_cb, [1 N]);

            b = a .* phiba_samp;
            c = a .* phica_samp;

        elseif strcmp(sim_mode, 'powerlaw')
            if pbmean <= 0.99
                alph = pbmean ./ (1-pbmean);
                phib_samp1 = betarnd(alph, 1, [1 1]);
            else
                phib_samp1 = 1.0;
            end

            if ds <= 1.0
                c_temp = astar .* a.^ds;
                b = c_temp .* phib_samp1 + (1-phib_samp1) .* a;
                c = c_temp;
            else
                c_temp = 0.001 .* 6.96 .* (a .* 2000).^0.5; % Columns MA94
                b = c_temp .* phib_samp1 + (1-phib_samp1) .* a;
                c = c_temp;
            end
        end

        %% 4b. Sample from von Mises Fisher distribution
        x = sind(thetamean) .* cosd(phimean);
        y = sind(thetamean) .* sind(phimean);
        z = cosd(thetamean);

        mu_tot = [x, y, z];
        mu = mu_tot ./ norm(mu_tot);

        RandVMF = randVMF(N, mu, kappa);
        xrand = RandVMF(:,1)';
        yrand = RandVMF(:,2)';
        zrand = RandVMF(:,3)';

        theta_p = acos(zrand ./ sqrt(xrand.^2 + yrand.^2 + zrand.^2));
        phi_p = atan2(yrand, xrand);
        phi_p(phi_p < 0) = phi_p(phi_p < 0) + 2.*pi;

        psi_p = (randraw('vonmises',[2.*deg2rad(psimean),varpsi],[1 N])) ./ 2;
        psi_p(psi_p > pi) = psi_p(psi_p > pi) - pi;
        psi_p(psi_p < 0) = psi_p(psi_p < 0) + pi;

        %% 4c. Calculate Ellipse Projections
        [ra_xz_t, rb_xz_t, EllipAng_xz_t] = project_ellipsoid(a, b, c, phi_p, theta_p, psi_p, 2); % H
        [ra_xy_t, rb_xy_t, EllipAng_xy_t] = project_ellipsoid(a, b, c, phi_p, theta_p, psi_p, 3); % V
         
        L_xy_t = 2 .* ra_xy_t;
        ar_xy_t = rb_xy_t ./ ra_xy_t;
         
        L_xz_t = 2 .* ra_xz_t;
        ar_xz_t = rb_xz_t ./ ra_xz_t;

        %% 4d. Calculate Area Ratios internally to evaluate NPixel filter
        if ~isempty(AR_exponent)
            rho_mu = AR_scale .* (2 .* a) .^ AR_exponent;
            rho_mu(rho_mu > 0.99) = 0.99; rho_mu(rho_mu < AR_min) = AR_min;
            nu_rho = max((1 / rhovar_frac) - 1, 2); 
            alpha_rho = rho_mu .* nu_rho; beta_rho  = (1 - rho_mu) .* nu_rho;
            AR_xy_t = betarnd(alpha_rho, beta_rho);
            AR_xz_t = betarnd(alpha_rho, beta_rho);
        else
            rhovar_max = (rhomean^2 - rhomean^3) / (rhomean+1);
            rhovar = min(rhovar_frac .* rhovar_max, 20);
            alpha_rho = rhomean * ((rhomean * (1-rhomean) / rhovar) - 1);
            beta_rho = (1-rhomean) * ((rhomean * (1-rhomean) / rhovar) - 1);
            fAR = exp(-a ./ AR_scale);
            fAR(fAR > 1) = 1; fAR(fAR < AR_min) = AR_min;
            AR_xy_t = fAR .* betarnd(alpha_rho, beta_rho, [1 N]);
            AR_xz_t = fAR .* betarnd(alpha_rho, beta_rho, [1 N]);
        end

        %% 4e. Apply Instrumental Filters
        if use_instrument_filter
            % Calculate Bounding Box Cross-Track Width
            W_cross_xy = 2 .* sqrt((ra_xy_t .* sind(EllipAng_xy_t)).^2 + (rb_xy_t .* cosd(EllipAng_xy_t)).^2);
            W_cross_xz = 2 .* sqrt((ra_xz_t .* sind(EllipAng_xz_t)).^2 + (rb_xz_t .* cosd(EllipAng_xz_t)).^2);
            
            % Probability of fitting entirely inside the 1.28mm Array
            P_in_xy = max(0, W_array - W_cross_xy) ./ W_array;
            P_in_xz = max(0, W_array - W_cross_xz) ./ W_array;
            
            % Calculate NPixels = (Ellipse Area * AreaRatio) / (10um x 10um)
            NPix_xy = (pi .* ra_xy_t .* rb_xy_t .* AR_xy_t) ./ pixel_area;
            NPix_xz = (pi .* ra_xz_t .* rb_xz_t .* AR_xz_t) ./ pixel_area;

            % Logistic Roll-offs for smooth detection degradation
            P_D_xy    = 1 ./ (1 + exp(-20 .* (L_xy_t - Dthresh)));
            P_ar_xy   = 1 ./ (1 + exp(-50 .* (ar_xy_t - ar_thresh)));
            P_AR_xy   = 1 ./ (1 + exp(-30 .* (AR_xy_t - area_thresh)));
            P_NPix_xy = 1 ./ (1 + exp(-0.015 .* (NPix_xy - NPixel_thresh)));

            P_D_xz    = 1 ./ (1 + exp(-20 .* (L_xz_t - Dthresh)));
            P_ar_xz   = 1 ./ (1 + exp(-50 .* (ar_xz_t - ar_thresh)));
            P_AR_xz   = 1 ./ (1 + exp(-30 .* (AR_xz_t - area_thresh)));
            P_NPix_xz = 1 ./ (1 + exp(-0.015 .* (NPix_xz - NPixel_thresh)));

            % Total Probability (Stereo: must pass on both cameras)
            P_keep = P_in_xy .* P_in_xz .* P_D_xy .* P_D_xz .* P_ar_xy .* P_ar_xz .* ...
                     P_AR_xy .* P_AR_xz .* P_NPix_xy .* P_NPix_xz;
            
            L_check = rand(1, N) < P_keep;
        else
            L_check = (L_xy_t >= Dthresh) & (L_xz_t >= Dthresh); 
        end

        % Apply Rejection Condition
       % L_check = (L_xy_t >= Lmin) & (L_xz_t >= Lmin); 

        % % Apply Rejection Conditions
        % if use_instrument_filter
        %     % 1. Cross-track width of the bounding box
        %     W_cross_xy = 2 .* sqrt((ra_xy_t .* sind(EllipAng_xy_t)).^2 + (rb_xy_t .* cosd(EllipAng_xy_t)).^2);
        %     W_cross_xz = 2 .* sqrt((ra_xz_t .* sind(EllipAng_xz_t)).^2 + (rb_xz_t .* cosd(EllipAng_xz_t)).^2);
        % 
        %     % 2. Probability of being entirely inside the 1.28 mm array
        %     P_in_xy = max(0, W_array - W_cross_xy) ./ W_array;
        %     P_in_xz = max(0, W_array - W_cross_xz) ./ W_array;
        % 
        %     % 3. Probability of detection at the small end (Logistic curve)
        %     P_det_xy = 1 ./ (1 + exp(-Lmin_steepness .* (L_xy_t - Lmin)));
        %     P_det_xz = 1 ./ (1 + exp(-Lmin_steepness .* (L_xz_t - Lmin)));
        % 
        %     % Total probability of retention (Stereo requirement: must pass both)
        %     P_keep = P_in_xy .* P_in_xz .* P_det_xy .* P_det_xz;
        % 
        %     % Roll the dice!
        %     L_check = rand(1, N) < P_keep;
        % else
        %     % Legacy hard-cutoff logic
        %     L_check = (L_xy_t >= Lmin) & (L_xz_t >= Lmin); 
        % end
        
        num_new = sum(L_check);

        % If valid samples exist, store them exactly where they belong
        if num_new > 0
            % Ensure we don't exceed N
            num_to_add = min(num_new, N - n_valid);
            
            % Grab exactly the indices we need to add
            valid_idx = find(L_check, num_to_add);
            
            % Define the injection window
            insert_range = (n_valid + 1) : (n_valid + num_to_add);
            
            % Insert directly into preallocated arrays
            a_tot(insert_range)       = a(valid_idx);
            L_xy(insert_range)        = L_xy_t(valid_idx);
            ar_xy(insert_range)       = ar_xy_t(valid_idx);
            EllipAng_xy(insert_range) = EllipAng_xy_t(valid_idx);
            AR_xy(insert_range)       = AR_xy_t(valid_idx);
            L_xz(insert_range)        = L_xz_t(valid_idx);
            ar_xz(insert_range)       = ar_xz_t(valid_idx);
            EllipAng_xz(insert_range) = EllipAng_xz_t(valid_idx);
            AR_xz(insert_range)       = AR_xz_t(valid_idx);
            
            % Advance the tracker
            n_valid = n_valid + num_to_add;
        end
    end

    %% 5. Sample Beta Distribution for Effective Density (Area Ratio)
    % if ~isempty(AR_exponent)
    %     % --- NEW: SIZE-DEPENDENT POWER-LAW BETA DISTRIBUTION ---
    %     % Calculate size-dependent mean: mu = alpha * D^beta
    %     % AR_scale acts as the coefficient, AR_exponent as the power
    %     D_major = 2 .* a_tot; 
    %     rho_mu = AR_scale .* (D_major) .^ AR_exponent;
    % 
    %     % Constrain mean to valid Beta bounds
    %     rho_mu(rho_mu > 0.99) = 0.99; 
    %     rho_mu(rho_mu < AR_min) = AR_min;
    % 
    %     % Calculate precision parameter (nu = alpha + beta) based on fractional variance. 
    %     % Because Var = mu*(1-mu)/(nu+1), setting nu constant keeps the spread 
    %     % mathematically symmetric and physically bounded across all sizes.
    %     nu_rho = max((1 / rhovar_frac) - 1, 2); 
    % 
    %     % Generate unique alpha and beta parameters for every single particle
    %     alpha_rho = rho_mu .* nu_rho;
    %     beta_rho  = (1 - rho_mu) .* nu_rho;
    % 
    %     AR_xy = betarnd(alpha_rho, beta_rho);
    %     AR_xz = betarnd(alpha_rho, beta_rho);
    % 
    % else
    %     % --- LEGACY: EXPONENTIAL SCALING APPROACH ---
    %     rhovar_max = (rhomean^2 - rhomean^3) / (rhomean+1);
    %     rhovar = min(rhovar_frac .* rhovar_max, 20);
    % 
    %     alpha_rho = rhomean * ((rhomean * (1-rhomean) / rhovar) - 1);
    %     beta_rho = (1-rhomean) * ((rhomean * (1-rhomean) / rhovar) - 1);
    % 
    %     fAR = exp(-a_tot ./ AR_scale);
    %     fAR(fAR > 1) = 1;
    %     fAR(fAR < AR_min) = AR_min;
    % 
    %     AR_xy = fAR .* betarnd(alpha_rho, beta_rho, [1 N]);
    %     AR_xz = fAR .* betarnd(alpha_rho, beta_rho, [1 N]);
    % end

    % %% 6. Sample Beta Distribution for Effective Density (Area Ratio)
    % rhovar_max = (rhomean^2 - rhomean^3) / (rhomean+1);
    % rhovar = min(rhovar_frac .* rhovar_max, 20);
    % 
    % alpha_rho = rhomean * ((rhomean * (1-rhomean) / rhovar) - 1);
    % beta_rho = (1-rhomean) * ((rhomean * (1-rhomean) / rhovar) - 1);
    % 
    % fAR = exp(-a_tot ./ AR_scale);
    % fAR(fAR > 1) = 1;
    % fAR(fAR < AR_min) = AR_min;
    % 
    % AR_xy = fAR .* betarnd(alpha_rho, beta_rho, [1 N]);
    % AR_xz = fAR .* betarnd(alpha_rho, beta_rho, [1 N]);

    %% 6. Compile Output Structure
    m = struct();
    m.L_xy = L_xy;
    m.ar_xy = ar_xy;
    m.EllipAng_xy = EllipAng_xy;
    m.AR_xy = AR_xy;

    m.L_xz = L_xz;
    m.ar_xz = ar_xz;
    m.EllipAng_xz = EllipAng_xz;
    m.AR_xz = AR_xz;

end