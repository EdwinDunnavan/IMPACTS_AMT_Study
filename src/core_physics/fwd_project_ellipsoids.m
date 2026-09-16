function m = fwd_project_ellipsoids(varargin)
% SIMULATE_ELLIPSOID_PROJECTIONS Consolidated forward simulator for joint
% distributions of projected ellipse characteristics. 

    abamax = 20;

    %% 0. Instrument default parameters
    use_instrument_filter = true;
    W_array       = 1.28;  % 2D-S Array width in mm (Entire-in cutoff)
    Dthresh       = 0.35;   % Major axis threshold (mm)
    ar_thresh     = 0.1;   % Aspect ratio threshold
    area_thresh   = 0.2;   % Area ratio threshold
    NPixel_thresh = 800;   % Minimum pixels (1 pixel = 10um x 10um = 1e-4 mm^2)
    pixel_area    = 1e-4;  % mm^2

    %% ORIG!!
    %k_D = 20;
    %k_ar = 50;
    %k_AR = 30;
    %k_N  = 0.015;

    %% NEW !!
    k_D = 50;
    k_ar = 50;
    k_AR = 30;
    k_N  = 0.1; 

    %% 1. Default Parameters (Based on PAPER IRREGULAR 2020)
    default_pop.pop_frac = 1.0; 
    default_pop.nu = 0.2; 
    default_pop.Dmean = 2.0;
    default_pop.ar_min = 0.1;
    default_pop.AR_scale = 0.6;
    default_pop.AR_min  = 0.2;
    default_pop.AR_exponent = -0.27; 
    default_pop.AR_asymp = [];
    default_pop.AR_amp = [];
    default_pop.k_decay = [];
    default_pop.pba = 0.75;
    default_pop.pba_exponent = [];
    default_pop.pcb = 0.75;
    default_pop.pcb_exponent = [];
    default_pop.abatog = 0.6; 
    default_pop.rhovar_frac = 0.02;
    %default_pop.use_3D_density_scaling = false; % NEW: Toggle for rho^(2/3) postulate
    default_pop.ang_xz = -40; 
    default_pop.ang_xy = 45; 
    default_pop.kappa = 4;
    default_pop.psimean = 0; 
    default_pop.varpsi = 0.001;


   %  pops(1).pop_frac = 1.0; 
   %  pops(1).nu = 0.2; 
   %  pops(1).Dmean = 2.0;
   %  %pops(1).ar_scale = 0.68; 
   %  %pops(1).ar_exponent = []; 
   %  pops(1).ar_min = 0.1;
   %  pops(1).AR_scale = 0.6;
   %  pops(1).AR_min  = 0.2;
   %  pops(1).AR_exponent = -0.27; 
   %  pops(1).AR_asymp = [];
   %  pops(1).AR_amp = [];
   %  pops(1).k_decay = [];
   %  pops(1).pba = 0.75;
   %  pops(1).pba_exponent = [];
   %  pops(1).pcb = 0.75;
   %  pops(1).pcb_exponent = [];
   %  pops(1).abatog = 0.6; 
   %  pops(1).rhovar_frac = 0.02;
   %  pops(1).use_density_scaling = false;
   %  pops(1).ang_xz = -40; 
   %  pops(1).ang_xy = 45; 
   %  pops(1).kappa = 4;
   %  pops(1).psimean = 0; 
   %  pops(1).varpsi = 0.001;
   %  %pops(1).a0 = [];
   %  %pops(1).ds = [];
   %  %pops(1).ac = [];
   %  %pops(1).bc = [];
   % % pops(1).pbmean = [];

   user_pops = default_pop;

    for nn = 1 : 2 : length(varargin)
        switch varargin{nn}
            case 'N', N = varargin{nn+1};
            case 'use_instrument_filter', use_instrument_filter = varargin{nn+1};
            case 'pops', user_pops = varargin{nn+1};    
            %case 'pops', pops = varargin{nn+1};

        end
    end

    %% 1b. Merge User Populations with Defaults
    num_pops = length(user_pops);
    
    % Preallocate the final pops array using the complete default structure
    pops = repmat(default_pop, 1, num_pops);
    
    % Loop through each user-provided population and overwrite the default fields
    for i = 1:num_pops
        user_fields = fieldnames(user_pops);
        for j = 1:length(user_fields)
            field = user_fields{j};
            val = user_pops(i).(field);
            
            % If the user value is empty BUT the default is not empty, 
            % this is MATLAB padding the struct array. Skip overwriting!
            if isempty(val) && ~isempty(default_pop.(field))
                continue;
            end
            
            pops(i).(field) = val;
        end
    end


    %% 2. Pre-Calculations for all N-Populations
    num_pops = length(pops);
    pd = cell(1, num_pops);
    phimean = cell(1, num_pops);
    thetamean = cell(1, num_pops);
    
    % Preallocate Beta parameters
    a_ba = zeros(1, num_pops);
    b_ba = zeros(1, num_pops);
    b_cb = zeros(1, num_pops);

    for i = 1:num_pops
        pd{i} = truncate(makedist('Gamma','a',pops(i).nu,'b',pops(i).Dmean/pops(i).nu),0.3,5);
        [phimean{i}, thetamean{i}, ~, ~] = ret_angle_3D_proj(pops(i).ang_xz, pops(i).ang_xy);

        % Calculate static Bivariate Beta Parameters per population
        p_ba = pops(i).pba;
        p_cb = pops(i).pcb;
        abg  = pops(i).abatog;
        
       if isempty(pops(i).pba_exponent) && isempty(pops(i).pcb_exponent)

            pbmin = p_ba / (1 - p_ba);
            pcmin = p_ba * p_cb / (1 - p_cb);
            abamin = max(pbmin, pcmin);

            a_ba(i) = abg * abamax + (1 - abg) * abamin;
            b_ba(i) = ((1 / p_ba) - 1) * a_ba(i);
            b_cb(i) = ((1 / p_cb) - 1) * a_ba(i) / p_ba;

        end

    end

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
        
        %% 4a. Dynamic Population Masking
        rand_vals = rand(1, N);
        cum_fracs = cumsum([pops.pop_frac]);
        cum_fracs = cum_fracs ./ cum_fracs(end); % Safety normalization
        
        pop_idx = ones(1, N);
        for i = 2:num_pops
            pop_idx(rand_vals > cum_fracs(i-1)) = i;
        end

        % Preallocate physical arrays
        a          = zeros(1, N);
        b          = zeros(1, N);
        c          = zeros(1, N);
        rho_mu     = zeros(1, N);
        rhovar_dyn = zeros(1, N);
        ar_min_dyn = zeros(1,N);
        RandVMF    = zeros(N, 3);
        psi_p      = zeros(1, N);
        %use_3D_mask = false(1, N);

        %% 4b. Assign Independent Physics per Population
        for i = 1:num_pops
            mask = (pop_idx == i);
            n_mask = sum(mask);
            if n_mask == 0, continue; end
            
            % 1. Size
            a_temp = pd{i}.random([1, n_mask]) ./ 2;
            a(mask) = a_temp;

            % 2. 3D Shape (Aspect Ratios) NEW APPROACH
            if isempty(pops(i).pba_exponent) && isempty(pops(i).pcb_exponent)
            
                % --- IRREGULAR MODE (Static Interval-Mapped Symmetry) ---
                % 1. Normalize target means
                norm_mu_ba = (pops(i).pba - pops(i).ar_min) / (1.0 - pops(i).ar_min);
                norm_mu_cb = (pops(i).pcb - pops(i).ar_min) / (1.0 - pops(i).ar_min);
                
                % Clamp for safety
                norm_mu_ba = max(0.01, min(0.99, norm_mu_ba));
                norm_mu_cb = max(0.01, min(0.99, norm_mu_cb));
                
                % 2. Calculate symmetric Beta parameters (using abatog for variance scaling)
                nu_ar = abamax * pops(i).abatog;
                alpha_ba = norm_mu_ba * nu_ar; beta_ba = (1 - norm_mu_ba) * nu_ar;
                alpha_cb = norm_mu_cb * nu_ar; beta_cb = (1 - norm_mu_cb) * nu_ar;
                
                % 3. Sample on [0, 1] and map to [ar_min, 1.0]
                phiba_samp = pops(i).ar_min + betarnd(alpha_ba, beta_ba, [1, n_mask]) .* (1.0 - pops(i).ar_min);
                phicb_samp = pops(i).ar_min + betarnd(alpha_cb, beta_cb, [1, n_mask]) .* (1.0 - pops(i).ar_min);
                
                % 4. Combine for c/a
                phica_samp = phiba_samp .* phicb_samp;
                
            else
                
                % --- DYNAMIC POWER-LAW MODE (Interval-Mapped Symmetry) ---
                D_maj = 2 .* a_temp;
                
                % Compute b/a dynamic targets
                if ~isempty(pops(i).pba_exponent)
                    pba_dyn = pops(i).pba .* D_maj .^ pops(i).pba_exponent;
                else
                    pba_dyn = repmat(pops(i).pba, 1, n_mask);
                end
                pba_dyn(pba_dyn > 0.99) = 0.99; 
                pba_dyn(pba_dyn < pops(i).ar_min) = pops(i).ar_min;
                
                % Compute c/b dynamic targets
                if ~isempty(pops(i).pcb_exponent)
                    pcb_dyn = pops(i).pcb .* D_maj .^ pops(i).pcb_exponent;
                else
                    pcb_dyn = repmat(pops(i).pcb, 1, n_mask);
                end
                pcb_dyn(pcb_dyn > 0.99) = 0.99; 
                pcb_dyn(pcb_dyn < pops(i).ar_min) = pops(i).ar_min;
                
                % 1. Normalize the dynamic target means to [ar_min, 1.0]
                norm_mu_ba = (pba_dyn - pops(i).ar_min) ./ (1.0 - pops(i).ar_min);
                norm_mu_cb = (pcb_dyn - pops(i).ar_min) ./ (1.0 - pops(i).ar_min);
                
                % Clamp for safety
                norm_mu_ba(norm_mu_ba > 0.99) = 0.99; norm_mu_ba(norm_mu_ba < 0.01) = 0.01;
                norm_mu_cb(norm_mu_cb > 0.99) = 0.99; norm_mu_cb(norm_mu_cb < 0.01) = 0.01;
                
                % 2. Calculate symmetric Beta parameters
                nu_ar = abamax * pops(i).abatog; 
                
                alpha_ba = norm_mu_ba .* nu_ar;
                beta_ba  = (1 - norm_mu_ba) .* nu_ar;
                
                alpha_cb = norm_mu_cb .* nu_ar;
                beta_cb  = (1 - norm_mu_cb) .* nu_ar;
                
                % 3. Sample on [0, 1] and map back to physical interval
                phiba_samp = pops(i).ar_min + betarnd(alpha_ba, beta_ba) .* (1.0 - pops(i).ar_min);
                phicb_samp = pops(i).ar_min + betarnd(alpha_cb, beta_cb) .* (1.0 - pops(i).ar_min);
                
                % 4. Derive c/a (which guarantees c <= b <= a)
                phica_samp = phiba_samp .* phicb_samp;
                
            end





            % % 2. 3D Shape (Aspect Ratios)
            % if isempty(pops(i).pba_exponent) && isempty(pops(i).pcb_exponent)
            % 
            %     % --- IRREGULAR MODE ---
            %     phiba_samp = betarnd(a_ba(i), b_ba(i), [1, n_mask]);
            %     phica_samp = phiba_samp .* betarnd(a_ba(i) + b_ba(i), b_cb(i), [1, n_mask]);
            % 
            % else
            % 
            %     % --- DYNAMIC POWER-LAW MODE (Columns / Plates) ---
            %     D_maj = 2 .* a_temp;
            % 
            %     % Compute b/a
            %     if ~isempty(pops(i).pba_exponent)
            %         pba_dyn = pops(i).pba .* D_maj .^ pops(i).pba_exponent;
            %     else
            %         pba_dyn = repmat(pops(i).pba, 1, n_mask);
            %     end
            %     pba_dyn(pba_dyn > 0.99) = 0.99; 
            %     pba_dyn(pba_dyn < pops(i).ar_min) = pops(i).ar_min;
            % 
            %     % Compute c/b
            %     if ~isempty(pops(i).pcb_exponent)
            %         pcb_dyn = pops(i).pcb .* D_maj .^ pops(i).pcb_exponent;
            %     else
            %         pcb_dyn = repmat(pops(i).pcb, 1, n_mask);
            %     end
            %     pcb_dyn(pcb_dyn > 0.99) = 0.99; 
            %     pcb_dyn(pcb_dyn < pops(i).ar_min) = pops(i).ar_min;
            % 
            %     % Calculate dynamic Beta parameters (Vectorized)
            %     pbmin = pba_dyn ./ (1 - pba_dyn);
            %     pcmin = pba_dyn .* pcb_dyn ./ (1 - pcb_dyn);
            %     abamin = max(pbmin, pcmin);
            % 
            %     a_ba_dyn = pops(i).abatog .* abamax + (1 - pops(i).abatog) .* abamin;
            %     b_ba_dyn = ((1 ./ pba_dyn) - 1) .* a_ba_dyn;
            %     b_cb_dyn = ((1 ./ pcb_dyn) - 1) .* a_ba_dyn ./ pba_dyn;
            % 
            %     % Sample
            %     phiba_samp = betarnd(a_ba_dyn, b_ba_dyn);
            %     phica_samp = phiba_samp .* betarnd(a_ba_dyn + b_ba_dyn, b_cb_dyn);
            % 
            % end

            
            b(mask) = a_temp .* phiba_samp;
            c(mask) = a_temp .* phica_samp;

            % 3. Area Ratio Mean & Variance
            if ~isempty(pops(i).AR_exponent)
                rho_temp = pops(i).AR_scale .* (2 .* a_temp) .^ pops(i).AR_exponent;
            elseif ~isempty(pops(i).AR_asymp)
                rho_temp = pops(i).AR_asymp + pops(i).AR_amp .* exp(-pops(i).k_decay .* (a_temp));
            else
                % Use repmat to ensure the scalar perfectly matches the mask size
                rho_temp = repmat(pops(i).AR_scale, 1, n_mask);
            end
            
            % Clamp Area Ratios for this specific population
            rho_temp(rho_temp > 0.99) = 0.99;
            rho_temp(rho_temp < pops(i).AR_min) = pops(i).AR_min;

            % % NEW: Translate 2D Area Ratio targets back to 3D Density targets if flagged
            % if isfield(pops(i), 'use_3D_density_scaling') && pops(i).use_3D_density_scaling
            %     use_3D_mask(mask) = true;
            %     rho_temp = rho_temp .^ (3/2);             % Map 2D mean to 3D mean
            %     ar_min_dyn(mask) = pops(i).AR_min .^ (3/2); % Map 2D floor to 3D floor
            % else
            %     ar_min_dyn(mask) = pops(i).AR_min;
            % end


            %if isfield(pops(i), 'use_3D_density_scaling') && pops(i).use_3D_density_scaling
            %    use_3D_mask(mask) = true;
            %end
            
            % Assign back to the global array
            rho_mu(mask) = rho_temp;
            rhovar_dyn(mask) = pops(i).rhovar_frac;
           % ar_min_dyn(mask) = pops(i).AR_min; 



            % 5. 3D Orientation (vMF + Roll)
            x = sind(thetamean{i}) .* cosd(phimean{i});
            y = sind(thetamean{i}) .* sind(phimean{i});
            z = cosd(thetamean{i});
            mu_vmf = [x, y, z] ./ norm([x, y, z]);
            
            RandVMF(mask, :) = randVMF(n_mask, mu_vmf, pops(i).kappa);
            
            p_val = (randraw('vonmises',[2.*deg2rad(pops(i).psimean), pops(i).varpsi], [1, n_mask])) ./ 2;
            p_val(p_val > pi) = p_val(p_val > pi) - pi;
            p_val(p_val < 0) = p_val(p_val < 0) + pi;
            psi_p(mask) = p_val;
        end

        %% 4c. Global Symmetry & Shape Generation
        %pba_dyn(pba_dyn > 0.99) = 0.99;
       % pba_dyn(pba_dyn < ar_min) = pops.ar_min;
        
        %pcb_dyn = pba_dyn; % Universal symmetry enforced for all populations
        
        % pbmin = pba ./ (1 - pba);
        % pcmin = pba .* pcb ./ (1 - pcb);
        % abamin = max(pbmin, pcmin);
        % abamax = 20;

        % pbmin = pba_dyn ./ (1 - pba_dyn);
        % pcmin = pba_dyn .* pcb ./ (1 - pcb);
        % abamin = max(pbmin, pcmin);
        % abamax = 20;

        % a_ba = abatog .* abamax + (1-abatog) .* abamin;
        % b_ba = ((1./pba)-1) .* a_ba;
        % b_cb = ((1./pcb)-1) .* a_ba ./ pba;

        % DYNAMIC
        %a_ba = abatog_dyn .* abamax + (1 - abatog_dyn) .* abamin;
        %b_ba = ((1./pba_dyn)-1) .* a_ba;
        %b_cb = ((1./pcb_dyn)-1) .* a_ba ./ pba_dyn;

        % phiba_samp = betarnd(a_ba, b_ba, [1 N]);
        % phica_samp = phiba_samp .* betarnd(a_ba+b_ba, b_cb, [1 N]);
        % 
        % b = a .* phiba_samp;
        % c = a .* phica_samp;
        
        xrand = RandVMF(:,1)'; yrand = RandVMF(:,2)'; zrand = RandVMF(:,3)';
        theta_p = acos(zrand ./ sqrt(xrand.^2 + yrand.^2 + zrand.^2));
        phi_p = atan2(yrand, xrand);
        phi_p(phi_p < 0) = phi_p(phi_p < 0) + 2.*pi;

        %% 4c. Calculate Ellipse Projections
        [ra_xz_t, rb_xz_t, EllipAng_xz_t] = project_ellipsoid(a, b, c, phi_p, theta_p, psi_p, 2); % H
        [ra_xy_t, rb_xy_t, EllipAng_xy_t] = project_ellipsoid(a, b, c, phi_p, theta_p, psi_p, 3); % V
         
        L_xy_t = 2 .* ra_xy_t;
        ar_xy_t = rb_xy_t ./ ra_xy_t;
         
        L_xz_t = 2 .* ra_xz_t;
        ar_xz_t = rb_xz_t ./ ra_xz_t;


        %% 4d. Calculate Area Ratios using Interval Mapping for Symmetry
        % TESTING!!!!
        % Normalize the target mean to the interval [ar_min_dyn, 1.0]
        norm_mu = (rho_mu - ar_min_dyn) ./ (1.0 - ar_min_dyn);
        
        % Safety clamp to prevent alpha/beta from blowing up to infinity
        norm_mu(norm_mu > 0.99) = 0.99;
        norm_mu(norm_mu < 0.01) = 0.01;

        % Calculate symmetric Beta parameters on the normalized interval
        nu_rho = max((1 ./ rhovar_dyn) - 1, 2); 
        alpha_rho = norm_mu .* nu_rho; 
        beta_rho  = (1 - norm_mu) .* nu_rho;
        
        % Sample from the (now symmetric) Beta distribution
        AR_xy_norm = betarnd(alpha_rho, beta_rho);
        AR_xz_norm = betarnd(alpha_rho, beta_rho);

        % Map the values back to the physical [AR_min, 1.0] interval directly
        AR_xy_t = ar_min_dyn + AR_xy_norm .* (1.0 - ar_min_dyn);
        AR_xz_t = ar_min_dyn + AR_xz_norm .* (1.0 - ar_min_dyn);


        % %% 4d. Calculate Area Ratios using Interval Mapping for Symmetry
        % % Normalize the target mean to the interval [ar_min_dyn, 1.0]
        % norm_mu = (rho_mu - ar_min_dyn) ./ (1.0 - ar_min_dyn);
        % 
        % % Safety clamp to prevent alpha/beta from blowing up to infinity
        % norm_mu(norm_mu > 0.99) = 0.99;
        % norm_mu(norm_mu < 0.01) = 0.01;
        % 
        % % Calculate symmetric Beta parameters on the normalized interval
        % nu_rho = max((1 ./ rhovar_dyn) - 1, 2); 
        % alpha_rho = norm_mu .* nu_rho; 
        % beta_rho  = (1 - norm_mu) .* nu_rho;
        % 
        % % Sample from the (now symmetric) Beta distribution
        % AR_xy_norm = betarnd(alpha_rho, beta_rho);
        % AR_xz_norm = betarnd(alpha_rho, beta_rho);
        % 
        % % Map the values back to the physical [AR_min, 1.0] interval
        % AR_xy_t = ar_min_dyn + AR_xy_norm .* (1.0 - ar_min_dyn);
        % AR_xz_t = ar_min_dyn + AR_xz_norm .* (1.0 - ar_min_dyn);
        % 
        % % Apply the dimensional scaling postulate if flagged
        % if any(use_3D_mask)
        %     AR_xy_t(use_3D_mask) = AR_xy_t(use_3D_mask) .^ (2/3);
        %     AR_xz_t(use_3D_mask) = AR_xz_t(use_3D_mask) .^ (2/3);
        % end
        % 


        % ORIGINAL APPROACH
        % %% 4d. Calculate Area Ratios internally to evaluate NPixel filter
        % nu_rho = max((1 ./ rhovar_dyn) - 1, 2); 
        % alpha_rho = rho_mu .* nu_rho; 
        % beta_rho  = (1 - rho_mu) .* nu_rho;
        % 
        % AR_xy_t = betarnd(alpha_rho, beta_rho);
        % AR_xz_t = betarnd(alpha_rho, beta_rho);
        % 
        % % 2. Apply the dimensional scaling postulate (AR = rho^(2/3)) to flagged populations
        % if any(use_3D_mask)
        %     AR_xy_t(use_3D_mask) = AR_xy_t(use_3D_mask) .^ (2/3);
        %     AR_xz_t(use_3D_mask) = AR_xz_t(use_3D_mask) .^ (2/3);
        % end


        % ORIGINAL!!!
        % rho_mu(rho_mu > 0.99) = 0.99; 
        % rho_mu(rho_mu < AR_min) = AR_min;
        % 
        % nu_rho = max((1 ./ rhovar_dyn) - 1, 2); 
        % alpha_rho = rho_mu .* nu_rho; 
        % beta_rho  = (1 - rho_mu) .* nu_rho;
        % 
        % AR_xy_t = betarnd(alpha_rho, beta_rho);
        % AR_xz_t = betarnd(alpha_rho, beta_rho);

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
            P_D_xy    = 1 ./ (1 + exp(-k_D .* (L_xy_t - Dthresh)));
            P_ar_xy   = 1 ./ (1 + exp(-k_ar .* (ar_xy_t - ar_thresh)));
            P_AR_xy   = 1 ./ (1 + exp(-k_AR .* (AR_xy_t - area_thresh)));
            P_NPix_xy = 1 ./ (1 + exp(-k_N .* (NPix_xy - NPixel_thresh)));

            P_D_xz    = 1 ./ (1 + exp(-k_D .* (L_xz_t - Dthresh)));
            P_ar_xz   = 1 ./ (1 + exp(-k_ar .* (ar_xz_t - ar_thresh)));
            P_AR_xz   = 1 ./ (1 + exp(-k_AR .* (AR_xz_t - area_thresh)));
            P_NPix_xz = 1 ./ (1 + exp(-k_N .* (NPix_xz - NPixel_thresh)));

            % Total Probability (Stereo: must pass on both cameras)
            P_keep = P_in_xy .* P_in_xz .* P_D_xy .* P_D_xz .* P_ar_xy .* P_ar_xz .* ...
                     P_AR_xy .* P_AR_xz .* P_NPix_xy .* P_NPix_xz;
            
            L_check = rand(1, N) < P_keep;
        else
            L_check = (L_xy_t >= Dthresh) & (L_xz_t >= Dthresh); 
        end
        
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

    %% 5. Compile Output Structure
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