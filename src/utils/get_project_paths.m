function paths = get_project_paths()
% GET_PROJECT_PATHS Sets up MATLAB paths and returns directory locations.
%
% Outputs:
%   paths - A structure containing absolute paths to key project directories.

    % Find the root directory dynamically based on this file's location
    scriptPath = mfilename('fullpath');
    utilsDir   = fileparts(scriptPath); % Now in /src/utils
    %scriptDir  = fileparts(scriptPath);
    srcDir     = fileparts(utilsDir);
    %projectDir = fileparts(scriptDir); % Moves up one level to the parent
    projectDir = fileparts(srcDir);
    
    % Define the directory structure
    paths.root    = projectDir;
    paths.src     = fullfile(projectDir, 'src');
    paths.utils   = fullfile(projectDir, 'src', 'utils');
    paths.data    = fullfile(projectDir, 'Data', 'processed');
    paths.sample  = fullfile(projectDir, 'Data', 'sample_raw');
    paths.figures = fullfile(projectDir, 'Figures');
    paths.simulations = fullfile(projectDir,'Simulations');
    paths.stl_models = fullfile(projectDir,'STL_models');
    paths.scripts = fullfile(projectDir,'scripts');

    paths.ellipse_file = fullfile(paths.data,'IMPACTS_EllipseFits_2020_2023.mat');
    
    % Add source code folders to MATLAB search path
    % (Using genpath adds the folder and all its subfolders automatically)
    addpath(genpath(paths.src));
    %addpath(genpath(paths.utils));
    
    % This prevents the script from crashing if a reviewer clones your 
    % repo and the empty /Figures directory wasn't tracked by Git.
    if ~exist(paths.figures, 'dir')
        mkdir(paths.figures);
    end
end