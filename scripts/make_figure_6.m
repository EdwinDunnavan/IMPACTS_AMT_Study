%% make_figure_6.m
% Generates timeseries of 

paths = get_project_paths();

if ~exist('m','var')
load(paths.ellipse_file,'-mat')
end

% Define output directory specifically for this figure's panels
outdir_comp = paths.figures;

outfile = 'IMPACTS_timeseries_frac_plot_fig_6.pdf';

%outdir = fullfile()

opts = {'save_fig',false,...
            'show_fig',true,...
            'outdir',outdir_comp};

plot_habit_fraction_timeseries(m,opts{:})
