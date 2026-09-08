%% generate_hexagonal.m

%folder = '/localdata/edunnavan/Simulations/OAP_ellipsoid/Hexagon_column_mu4_Dm1_newparam_test3/';

%folder = '/localdata/edunnavan/Simulations/OAP_ellipsoid/Hexagonal_column_MA94/';

folder = '/localdata/edunnavan/Simulations/OAP_ellipsoid/Hexagonal_columns_AV70/';

%folder = '/localdata/edunnavan/Simulations/OAP_ellipsoid/Simulation_Column_AR4/';

if ~isfolder(folder)

mkdir(folder)

end

%% Set up size distribution or specify size
N_generate = 1e4;
part_type = 'columns';

nu = 4;
mu = nu-1;
Dbar = 0.5;
Dm = (mu+4)./(mu+1).*Dbar; 
%Dm = 1.;
Dlow = 0.35;
Dhigh = 3.0;

Dn = Dm./(mu+4);
nu = mu+1;

nD = truncate(makedist('gamma','a',nu,'b',Dn),Dlow,Dhigh);

D_samp = nD.random(1,N_generate);

switch part_type

    case 'plates'

       %W_samp = 0.001.*1.07.*(D_samp.*1000).^0.778; % Solid thick plate
       %D74, Davis 1974 (from Um et al. 2015)
       %W_samp = 0.001.*0.402.*(D_samp.*1000).^1.018; % Solid thick plate AV70
       W_samp = 0.001.*2.506.*(D_samp.*1000).^0.398; % Spectrum of plates AV70, Fig 1
       aspect_ratio = W_samp./D_samp; 

    case 'columns'

        W_samp = 0.001.*11.3.*(D_samp.*1000).^0.414; % Columns AV70
        %W_samp = 0.001.*6.96.*(D_samp.*1000).^0.5; % Columns MA94

        aspect_ratio = D_samp./W_samp;

        %% My parameterization
        %ARmin=0.15;
        %ARmax=0.5;
        %bet = (log(Dhigh./Dlow)).^(-1).*log(ARmin./ARmax);
        %alph = ARmax.*Dlow.^(-bet);
        %aspect_ratio = 1./(alph.*D_samp.^(bet));

end

Npart = length(aspect_ratio);

for ii = 1 : Npart
sobj = gen_stl_hexagonal(aspect_ratio(ii));

sobj = resize_stl_particle(sobj,D_samp(ii));

stlwrite(sobj.particle.TR,strcat(folder,sprintf('particle_%i_orig.stl',ii)));

end

%% Write particle_params.nc file
write_hexagon_params(strcat(folder,sprintf('particle_params.nc')),D_samp,aspect_ratio,mu,Dm,Dlow,Dhigh);
