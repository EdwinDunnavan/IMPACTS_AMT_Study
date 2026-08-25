
%{
 plot_simulation_marginal.m

 Description: Plots Figure 19.
 
%}

fdir = '/localdata/edunnavan/Simulations/OAP_ellipsoid/';
folders = {'Simulation_BR03/','Simulation_BR04/','Simulation_BR08/','Simulation_Dendrite_2/'};
test_folders = {'Random_1mm_N1e4_habit/','Random_1mm_N1e4_habit/','Gamma_Random_exp_N1e4/','Random_Fixed_1mm/'};

%test_folders = {'Gamma_Random_exp_N1e4/','Gamma_Random_exp_N1e4/','Gamma_Random_exp_N1e4/','Random_Fixed_1mm/'};


%test_folders = {'Gamma_IMPACTS_2020_exp_N1e4/','Gamma_IMPACTS_2020_exp_N1e4/','Gamma_IMPACTS_2020_exp_N1e4/'};


% Plot ellipse major dimension, aspect ratio, ellipse angle, and ellipse area ratio
fig = figure('units','normalized'); 

for hh = 1 : length(test_folders)

    % Read data
    stemp = read_stl_data(strcat(fdir,folders{hh},test_folders{hh}));

    ARH = stemp.rb_xz_cgal./stemp.ra_xz_cgal;
    ARV = stemp.rb_xy_cgal./stemp.ra_xy_cgal;

    EllipAngH = stemp.EllipAng_xz_cgal;
    EllipAngV = stemp.EllipAng_xy_cgal;

    DmajorH = 2.*stemp.ra_xz_cgal;
    DmajorV = 2.*stemp.ra_xy_cgal;

    DmaxH = stemp.Dmax_xz_cgal;
    DmaxV = stemp.Dmax_xy_cgal;

    AreaH = stemp.area_ratio_xz_cgal;
    AreaV = stemp.area_ratio_xy_cgal;

    complexityH = stemp.complexity_xz_cgal;
    complexityV = stemp.complexity_xy_cgal;

    circularityH = stemp.circularity_xz;
    circularityV = stemp.circularity_xy;

    ellipticityH = stemp.ellipticity_xz_cgal;
    ellipticityV = stemp.ellipticity_xy_cgal;

    AreaCircH = stemp.particle_area_xz./((pi/4).*stemp.Dmax_xz_cgal.^2);
    AreaCircV = stemp.particle_area_xy./((pi/4).*stemp.Dmax_xy_cgal.^2);


ax1 = subplot(4,2,1);
hold on; 
histogram(ax1,ARH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
%histogram(ax1,DmajorH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
%histogram(ax1,DmajorV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')

ax2 = subplot(4,2,2);
hold on; 
histogram(ax2,ARV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','-')

ax3 = subplot(4,2,3);
hold on; 
histogram(ax3,AreaH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
%histogram(ax3,EllipAngH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
%histogram(ax3,EllipAngV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')

ax4 = subplot(4,2,4);
hold on; 
histogram(ax4,AreaV,'normalization','pdf','DisplayStyle','stairs','linewidth',2)

%histogram(ax4,AreaV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')

ax5 = subplot(4,2,5);
hold on; 
%histogram(ax5,complexityH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)

%histogram(ax5,circularityH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)

histogram(ax5,AreaCircH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)


%histogram(ax5,complexityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')

ax6 = subplot(4,2,6);
hold on; 
%histogram(ax6,circularityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
histogram(ax6,AreaCircV,'normalization','pdf','DisplayStyle','stairs','linewidth',2)

%histogram(ax6,ellipticityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')

ax7 = subplot(4,2,7);
hold on; 
%histogram(ax5,complexityH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)

histogram(ax7,ellipticityH,'normalization','pdf','DisplayStyle','stairs','linewidth',2)

%histogram(ax5,complexityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')

ax8 = subplot(4,2,8);
hold on; 
histogram(ax8,ellipticityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2)
%histogram(ax6,ellipticityV,'normalization','pdf','DisplayStyle','stairs','linewidth',2,'linestyle','--')




end