
%{
 generate_ellipsoid_sim_projections.m
 
 Generates Figure 16

%}

%% Set up paths based on Github Parent location
paths = get_project_paths();

DataDir = paths.data;

% scriptPath = mfilename('fullpath');
% scriptDir  = fileparts(scriptPath);
% projectDir = fileparts(scriptDir);
% srcDir     = fullfile(projectDir,'src/');
% utilsDir   = fullfile(srcDir,'utils');
% FiguresDir = fullfile(projectDir,'Figures','Joint_Distributions','IMPACTS_Observations/');
% DataDir    = fullfile(projectDir,'Data','processed/');
% 
% addpath(utilsDir)
% addpath(srcDir)

load(paths.ellipse_file,'-mat')


%% Generate bivariate beta distribution contour plots


%% Generate histogram lines
fig = figure; 

histogram(m_IMPACTS.f20200118.H.AR(m_IMPACTS.f20200118.H.habit=='i'),'normalization','pdf','displaystyle','stairs','EdgeColor',[0.5 0.5 0.5])