function paths = init_project()
    % INIT_PROJECT Adds core utilities to the path and loads project paths.
    
    % Get the directory where THIS helper function lives (the /scripts/ folder)
    scripts_dir = fileparts(mfilename('fullpath'));
    
    % Step up one directory level to the project root
    project_root = fileparts(scripts_dir);
    
    % Add the utils directory so MATLAB can locate get_project_paths.m
    addpath(fullfile(project_root, 'src', 'utils'));
    
    % Load and return the rest of the project paths
    paths = get_project_paths();
end