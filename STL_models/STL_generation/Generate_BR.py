# -*- coding: utf-8 -*-
"""
Bullet Rosette Generator 
Adapted from SHPSG_IMPACTS pipeline using Manifold3D and Joblib
"""

import numpy as np
import os
import trimesh
from pathlib import Path
from joblib import Parallel, delayed

from funcs import WritePartNetcdf

def get_project_paths():
    """ Dynamically resolve project directories relative to this script. """
    project_root = Path(__file__).resolve().parent.parent.parent
    paths = {
        'root': project_root,
        'simulations': project_root / 'Simulations',
        'stl_models': project_root / 'STL_models'
    }
    return paths

# def generate_rosette(i, npar, bullet_path, data_folder):
#     """ Worker function to generate a single bullet rosette. """
    
#     stlpath = os.path.join(data_folder, f'particle_{i+1}_orig.stl')
    
#     # Randomize rosette complexity (e.g., 3 to 6 bullet branches)
#     num_branches = np.random.randint(3, 7)
#     print(f'Generating Rosette {i+1} out of {npar} | {num_branches} Branches')
    
#     success = False
#     max_attempts = 15
#     attempt = 0
    
#     while not success and attempt < max_attempts:
#         branch_meshes = []
#         branch_dirs = []
#         branch_failed = False
        
#         for b in range(num_branches):
            
#             # Load the base bullet template
#             try:
#                 mesh = trimesh.load(bullet_path)
#             except Exception as e:
#                 print(f"Error loading {bullet_path}: {e}")
#                 return
            
#             # Pre-flight cleanup
#             mesh.merge_vertices()
#             mesh.update_faces(mesh.nondegenerate_faces())
#             trimesh.repair.fill_holes(mesh)
            
#             # 1. BASAL PIVOT SHIFT
#             # Center the bullet first
#             mesh.vertices -= mesh.center_mass
            
#             # Find the bottom of the bullet (assumes bullet length is along Z-axis)
#             # If your bullet model points downwards, change np.min to np.max
#             z_base = np.min(mesh.vertices[:, 2])
            
#             # Shift the mesh UP so the flat base sits exactly at (0, 0, 0)
#             mesh.vertices[:, 2] -= z_base
            
#             if mesh.volume < 0:
#                 mesh.faces = np.fliplr(mesh.faces)
#             mesh.fix_normals()
            
#             if not mesh.is_watertight:
#                 branch_failed = True
#                 break
            
#             # 2. RADIAL SPLAYING
#             if b == 0:
#                 # Primary anchor stays roughly upright with micro-jitter
#                 mesh.apply_translation(np.random.uniform(-0.01, 0.01, 3))
#                 mesh.fix_normals()
#                 branch_dirs.append(np.array([0, 0, 1])) # Base points up Z-axis
#             else:
#                 # Randomize secondary branch size (80% to 120% of original)
#                 scale_factor = np.random.uniform(0.80, 1.20)
#                 mesh.apply_scale(scale_factor)
                
#                 # FORCE WIDE ANGLES: Reject vectors closer than 60 degrees to existing branches
#                 min_angle = np.radians(60) 
#                 valid_dir = False
#                 attempts = 0
                
#                 while not valid_dir and attempts < 100:
#                     vec = np.random.randn(3)
#                     vec /= np.linalg.norm(vec)
                    
#                     # Check angle against all previous branches
#                     dots = [np.dot(vec, d) for d in branch_dirs]
#                     angles = [np.arccos(np.clip(dot, -1.0, 1.0)) for dot in dots]
                    
#                     if all(angle > min_angle for angle in angles):
#                         valid_dir = True
#                     attempts += 1
                
#                 branch_dirs.append(vec)
                
#                 # Align the bullet's Z-axis to the new widespread vector
#                 rot_matrix = trimesh.geometry.align_vectors(np.array([0, 0, 1]), vec)
#                 mesh.apply_transform(rot_matrix)
                
#                 # Apply a random roll around its own axis for natural texture
#                 roll_angle = np.random.uniform(0, 2 * np.pi)
#                 roll_matrix = trimesh.transformations.rotation_matrix(roll_angle, vec)
#                 mesh.apply_transform(roll_matrix)
                
#                 # Sink the branch backward through the origin slightly to create a solid central core
#                 # -vec pushes the flat base past (0,0,0) so the branches physically intersect
#                 mesh.apply_translation(-vec * 0.05)
                
#                 mesh.fix_normals()

#             branch_meshes.append(mesh)

#         if branch_failed or len(branch_meshes) < num_branches:
#             attempt += 1
#             continue

#         # 3. MANIFOLD UNION (CSG FUSION)
#         aggregate_mesh = branch_meshes[0]
#         union_success = True
        
#         for secondary_idx, secondary in enumerate(branch_meshes[1:], start=1):
#             prev_faces = len(aggregate_mesh.faces)
            
#             # Symmetry breakers (Translation + Micro-Rotation)
#             secondary.apply_translation([0.00314, -0.00271, 0.00161])
#             jitter = trimesh.transformations.euler_matrix(0.001, -0.002, 0.0015)
#             secondary.apply_transform(jitter)
            
#             try:
#                 fused = trimesh.boolean.union([aggregate_mesh, secondary], engine='manifold')
#             except:
#                 union_success = False
#                 break
            
#             if fused.is_empty:
#                 union_success = False
#                 break
            
#             # Topological cleanup
#             fused.merge_vertices()
#             fused.update_faces(fused.unique_faces())
#             fused.update_faces(fused.nondegenerate_faces())
#             trimesh.repair.fix_normals(fused)
#             trimesh.repair.fix_inversion(fused)
#             trimesh.repair.fix_winding(fused)
#             trimesh.repair.fill_holes(fused)
            
#             # Component Isolation
#             components = fused.split(only_watertight=False)
#             if len(components) > 1:
#                 components = sorted(components, key=lambda c: c.volume, reverse=True)
#                 c1_faces = len(components[1].faces)
                
#                 if c1_faces < 200:
#                     fused = components[0]
#                     fused.merge_vertices()
#                     trimesh.repair.fill_holes(fused)
#                     fused.fix_normals()
#                 else:
#                     union_success = False
#                     break
            
#             if len(fused.faces) <= prev_faces + 10:
#                 union_success = False
#                 break
            
#             if not fused.is_watertight or fused.volume <= 0.005:
#                 union_success = False
#                 break
                
#             aggregate_mesh = fused

#         if union_success:
#             success = True
#         else:
#             attempt += 1
        
        
#     # # 4. MESH DECIMATION / FACET SIMPLIFICATION
#     #     # Reduce dense CSG boolean intersection facets down to ~1200 target faces
#     #     target_faces = 1200
#     #     if len(aggregate_mesh.faces) > target_faces:
#     #         try:
#     #             simplified = aggregate_mesh.simplify_quadratic_decimation(target_faces)
#     #             if simplified is not None and not simplified.is_empty:
#     #                 aggregate_mesh = simplified
#     #         except Exception as e:
#     #             print(f"Decimation skipped for Rosette {i+1}: {e}")

#     #     # Final topological cleanup
#     #     aggregate_mesh.merge_vertices()
#     #     trimesh.repair.fill_holes(aggregate_mesh)
#     #     aggregate_mesh.fix_normals()

#     # if not success:
#     #     print(f"Warning: Rosette {i+1} completely failed. Saving fallback.")
#     #     aggregate_mesh = branch_meshes[0]    
        
#     aggregate_mesh.export(stlpath)
#     return True

def generate_rosette(i, npar, bullet_path, data_folder):
    """ Worker function to generate a single bullet rosette. """
    
    stlpath = os.path.join(data_folder, f'particle_{i+1}_orig.stl')
    num_branches = np.random.randint(3, 9)
    print(f'Generating Rosette {i+1} out of {npar} | {num_branches} Branches')
    
    success = False
    max_attempts = 15
    attempt = 0
    
    angle_map = {3: 75, 4: 70, 5: 60, 6: 50, 7: 45, 8: 40}
    base_angle_deg = angle_map.get(num_branches, 40)
    base_angle = np.radians(base_angle_deg)
    max_darts = 200
    
    # 1. OPTIMIZATION: Load and clean the bullet template ONCE per rosette
    try:
        bullet_template = trimesh.load(bullet_path)
        bullet_template.merge_vertices()
        bullet_template.update_faces(bullet_template.nondegenerate_faces())
        trimesh.repair.fill_holes(bullet_template)
    except Exception as e:
        print(f"Error loading {bullet_path}: {e}")
        return
    
    while not success and attempt < max_attempts:
        branch_meshes = []
        branch_dirs = []
        branch_failed = False
        
        for b in range(num_branches):
            
            # Use a fast memory copy instead of hitting the disk
            mesh = bullet_template.copy()
            
            # BASAL PIVOT SHIFT
            mesh.vertices -= mesh.center_mass
            z_base = np.min(mesh.vertices[:, 2])
            mesh.vertices[:, 2] -= z_base
            
            if mesh.volume < 0:
                mesh.faces = np.fliplr(mesh.faces)
            mesh.fix_normals()
            
            # RADIAL SPLAYING
            if b == 0:
                mesh.apply_translation(np.random.uniform(-0.01, 0.01, 3))
                mesh.fix_normals()
                branch_dirs.append(np.array([0, 0, 1])) 
            else:
                scale_factor = np.random.uniform(0.80, 1.20)
                mesh.apply_scale(scale_factor)
                
                #min_angle = np.radians(60) 
                valid_dir = False
                attempts = 0
                
                while not valid_dir and attempts < max_darts:
                    vec = np.random.randn(3)
                    vec /= np.linalg.norm(vec)
                    
                    # Relax the angle by 15% if it struggles to find a gap
                    if attempts > 50:
                        current_min = base_angle * 0.85
                    else:
                        current_min = base_angle
                    
                    dots = [np.dot(vec, d) for d in branch_dirs]
                    angles = [np.arccos(np.clip(dot, -1.0, 1.0)) for dot in dots]
                    
                    if all(angle > current_min for angle in angles):
                        valid_dir = True
                    attempts += 1
                
                branch_dirs.append(vec)
                rot_matrix = trimesh.geometry.align_vectors(np.array([0, 0, 1]), vec)
                mesh.apply_transform(rot_matrix)
                
                roll_angle = np.random.uniform(0, 2 * np.pi)
                roll_matrix = trimesh.transformations.rotation_matrix(roll_angle, vec)
                mesh.apply_transform(roll_matrix)
                
                mesh.apply_translation(-vec * 0.15)
                mesh.fix_normals()

            branch_meshes.append(mesh)

        if branch_failed or len(branch_meshes) < num_branches:
            attempt += 1
            continue

        # MANIFOLD UNION (CSG FUSION)
        aggregate_mesh = branch_meshes[0]
        union_success = True
        
        for secondary_idx, secondary in enumerate(branch_meshes[1:], start=1):
            
            secondary.apply_translation([0.00314, -0.00271, 0.00161])
            jitter = trimesh.transformations.euler_matrix(0.001, -0.002, 0.0015)
            secondary.apply_transform(jitter)
            
            try:
                # 2. OPTIMIZATION: Explicitly demand the fast C++ Manifold3D engine
                fused = trimesh.boolean.union([aggregate_mesh, secondary], engine='manifold')
            except:
                union_success = False
                break
            
            if fused.is_empty or fused.volume <= 0.005:
                union_success = False
                break
            
            components = fused.split(only_watertight=False)
            if len(components) > 1:
                components = sorted(components, key=lambda c: len(c.faces), reverse=True)
                fused = components[0]
            
            # 3. OPTIMIZATION: Skip heavy fill_holes() during intermediate steps
            fused.merge_vertices()
            aggregate_mesh = fused

        if union_success:
            success = True
        else:
            attempt += 1

    # MESH DECIMATION / FACET SIMPLIFICATION
    target_faces = 1200
    if success and len(aggregate_mesh.faces) > target_faces:
        try:
            simplified = aggregate_mesh.simplify_quadratic_decimation(target_faces)
            if simplified is not None and not simplified.is_empty:
                aggregate_mesh = simplified
        except Exception:
            pass

    # Apply the heavy topological cleanup just once at the very end
    aggregate_mesh.merge_vertices()
    trimesh.repair.fill_holes(aggregate_mesh)
    aggregate_mesh.fix_normals()

    if not success:
        print(f"Warning: Rosette {i+1} completely failed. Saving fallback.")
        aggregate_mesh = branch_meshes[0]
        
    aggregate_mesh.export(stlpath)
    return True

if __name__ == '__main__':
    
    # Initialize the paths
    paths = get_project_paths()
    
    #output_folder = 'Rosettes_100_TEST'
    #npar = 100
    
    output_folder = 'Rosettes_10k'
    npar = 10000
    
    # Dynamically construct the output folder path
    data_folder_path = paths['simulations'] / output_folder
    data_folder_path.mkdir(parents=True, exist_ok=True)
    data_folder = str(data_folder_path) + os.sep
    
    # Define the template path
    bullet_template_path = str(paths['stl_models'] / 'Bullet.stl')
    
    if not os.path.exists(bullet_template_path):
        raise FileNotFoundError(f"Could not find template at {bullet_template_path}")
    
    # Initialize NetCDF parameter arrays for MATLAB compatibility
    D = np.ones((1, npar))[0]
    Ei = np.full(npar, 0.5)
    Fi = np.full(npar, 0.5)
    D2_8 = np.zeros(npar)
    D9_15 = np.zeros(npar)
    
    rand_j = []
    rand_m = []
    rand_p = []
    
    for i in range(npar):
        rand_j_temp = [np.random.rand(n+1, 3) for n in range(1, 16)]
        rand_m_temp = [np.random.rand(n, 3) for n in range(1, 16)]
        rand_j.append(rand_j_temp)
        rand_m.append(rand_m_temp)
        rand_p.append(np.random.rand(1, 3))
    
    print(f"Executing parallel generation of {npar} rosettes across 12 workers...")
    
    # Run the worker function in parallel
    Parallel(n_jobs=12, backend='loky')(
        delayed(generate_rosette)(
            i, npar, bullet_template_path, data_folder
        ) for i in range(npar)
    )

    print("Generation complete.")
    # Save particle parameters
    WritePartNetcdf(data_folder+'particle_params.nc',D,Ei,Fi,D2_8,D9_15,rand_j,rand_m,rand_p)