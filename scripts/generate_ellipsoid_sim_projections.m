
%{
 generate_ellipsoid_sim_projections.m
 
 Generates Figure 16

%}

%% Set up paths based on Github Parent location
paths = get_project_paths();

load(paths.ellipse_file,'-mat')

%% Get Schima-identified irregular particles from 2020



%% Generate bivariate beta distribution contour plots


%% Generate histogram lines
fig = figure; 

histogram(m_IMPACTS.f20200118.H.AR(m_IMPACTS.f20200118.H.habit=='i'),'normalization','pdf','displaystyle','stairs','EdgeColor',[0.5 0.5 0.5])