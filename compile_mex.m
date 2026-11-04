% compile_mex.m
% Place this script in your project root directory.
% To run, simply type `compile_mex` in the MATLAB Command Window.

fprintf('===================================================\n');
fprintf('⚙️ Starting Cross-Platform MEX Compilation Pipeline...\n');
fprintf('===================================================\n');

%% 1. Configure OS & Native Compiler Strings
source_dir = fullfile(pwd, 'src', 'mex_source');
output_dir = source_dir;

source_files = { ...
    fullfile(source_dir, 'CGAL_EllipseSize_UIOPS.cpp'), ...
    fullfile(source_dir, 'CGAL_minR.cpp') ...
};

% Identify system architectures
is_windows = ispc;
is_mac = ismac;
is_linux = isunix && ~ismac;

%% 2. Setup Include Paths and Library Links Dynamically Based on OS
mex_args = {'-v'};

if is_windows
    % --- WINDOWS (vcpkg setup) ---
    mingw_include = fullfile(pwd, 'vcpkg_installed', 'x64-mingw-dynamic', 'include');
    mingw_lib_dir = fullfile(pwd, 'vcpkg_installed', 'x64-mingw-dynamic', 'lib');
    msvc_include  = fullfile(pwd, 'vcpkg_installed', 'x64-windows', 'include');
    msvc_lib_dir  = fullfile(pwd, 'vcpkg_installed', 'x64-windows', 'lib');
    
    if isfolder(mingw_include)
        fprintf('[INFO] OS: Windows -> Linking vcpkg MinGW libraries.\n');
        mex_args = [mex_args, ['-I', mingw_include], 'CXXFLAGS=$CXXFLAGS -std=c++17', ...
                    find_library_file(mingw_lib_dir, 'gmp'), find_library_file(mingw_lib_dir, 'mpfr')];
    elseif isfolder(msvc_include)
        fprintf('[INFO] OS: Windows -> Linking vcpkg MSVC libraries.\n');
        mex_args = [mex_args, ['-I', msvc_include], ...
                    find_library_file(msvc_lib_dir, 'gmp'), find_library_file(msvc_lib_dir, 'mpfr')];
    else
        error('[ERROR] Missing vcpkg folder on Windows. Check README.');
    end
    
elseif is_mac
    % --- macOS (Homebrew setup) ---
    fprintf('[INFO] OS: macOS -> Scanning system package manager (Homebrew).\n');
    
    % Homebrew path mapping based on CPU architecture (Apple Silicon vs Intel)
    if isfolder('/opt/homebrew/include')
        brew_prefix = '/opt/homebrew'; % Apple Silicon (M1/M2/M3/M4)
    else
        brew_prefix = '/usr/local';    % Intel Mac legacy fallback
    end
    
    % Check for CGAL installation via brew
    cgal_check = fullfile(brew_prefix, 'include', 'CGAL');
    if ~isfolder(cgal_check)
        error('[ERROR] CGAL not found! Please run: "brew install cgal" inside your terminal.');
    end
    
    mex_args = [mex_args, ...
                ['-I', fullfile(brew_prefix, 'include')], ...
                ['-L', fullfile(brew_prefix, 'lib')], ...
                '-lgmp', '-lmpfr'];
            
elseif is_linux
    % --- LINUX (Apt/Yum setup) ---
    fprintf('[INFO] OS: Linux -> Utilizing native system directories.\n');
    
    % Linux registers include/lib dependencies directly to system environments natively
    if ~isfile('/usr/include/CGAL/basic.h') && ~isfile('/usr/local/include/CGAL/basic.h')
        error('[ERROR] CGAL not found! Please run: "sudo apt install libcgal-dev" in your terminal.');
    end
    
    mex_args = [mex_args, '-lgmp', '-lmpfr'];
end

%% 3. Apply Patch for Legacy Header Reference ("Miniball.h")
target_h_file   = fullfile(source_dir, 'Miniball.h');
if ~isfile(target_h_file)
    fprintf('[INFO] Patching backward-compatibility mapping header "Miniball.h"...\n');
    fid = fopen(target_h_file, 'w');
    if fid ~= -1
        fprintf(fid, '// Automated legacy forward mapper mapping header\n');
        fprintf(fid, '#include "Miniball.hpp"\n');
        fclose(fid);
    end
end

% Include source folder directory to intercept local patched targets
mex_args = [mex_args, ['-I', source_dir]];

%% 4. Execute the Global Compilation Loop
for f = 1:length(source_files)
    current_file = source_files{f};
    fprintf('[INFO] Compiling file (%d/%d): %s...\n', f, length(source_files), current_file);
    
    % Trigger active structural compile with customized systemic cell arguments
    mex(mex_args{:}, current_file, '-outdir', output_dir);
end

fprintf('\n===================================================\n');
fprintf('🎉 [SUCCESS] All MEX binaries successfully generated in source tree!\n');
fprintf('===================================================\n');

%% Helper Function to locate library files matching a pattern (Windows only)
function filepath = find_library_file(dirpath, libname)
    extensions = {'*.dll.a', ['*.', libname, '.a'], '*gmp*.a', '*mpfr*.a', '*.lib'};
    for i = 1:length(extensions)
        files = dir(fullfile(dirpath, [libname, extensions{i}]));
        if isempty(files)
            files = dir(fullfile(dirpath, ['*', libname, '*']));
        end
        if ~isempty(files)
            filepath = fullfile(dirpath, files(1).name);
            return;
        end
    end
    error('[ERROR] Could not locate library binary for "%s" inside folder:\n%s', libname, dirpath);
end
