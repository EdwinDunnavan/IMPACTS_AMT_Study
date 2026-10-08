# -*- coding: utf-8 -*-
"""
Modified from SHPSG (https://github.com/budizhao/SHPSG)
Original code copyright (c) [2020] Budi Zhao
Licensed under the MIT License
Modifications made by Edwin Lee Dunnavan (CIWRO) for "Universality of ice particle shapes
and orientations as revealed by the 2D-S in situ optical array probe" in 
Atmospheric Measurement Technique"", 2026
"""

import numpy as np

from funcs import icosahedron, subdivsurf, cleanmesh, car2sph, sh2stl, WritePartNetcdf
from funcs import align_mesh_to_pca
from SHPSG import SHPSG_fixed

import os

import trimesh

from pathlib import Path

import uuid # For guaranteed unique temporary file names

def get_project_paths():
    """ Dynamically resolve project directories relative to this script using pathlib. """
    # Resolve the absolute path and step up to the project root 
    # (.parent.parent assumes this script is inside /scripts/ or /src/)
    project_root = Path(__file__).resolve().parent.parent.parent
    
    # Map out the directories using the / operator
    paths = {
        'root': project_root,
        'simulations': project_root / 'Simulations',
        'stl_models': project_root / 'STL_models'
    }
    return paths


def draw_gamma_rnd(mu,Dm,Dlow,Dhigh,size):

	from scipy.stats import gamma

	nu = mu+1.
	Dn = Dm/(mu+4.)

	F_a = gamma.cdf(Dlow,nu,scale=Dn)
	F_b = gamma.cdf(Dhigh,nu,scale=Dn)

	u = np.random.uniform(F_a,F_b,size=size)

	D = gamma.ppf(u,nu,scale=Dn)

	return D

def generate_particle(i, npar, Ei_val, Fi_val, D2_8_val, D9_15_val, rand_j_val, rand_m_val, rand_p_val, sph_cor, vertices, faces, data_folder, fuse_switch):
    """ Worker function to generate a single particle. """
    
    stlpath = os.path.join(data_folder, f'particle_{i+1}_orig.stl')
    
    if fuse_switch:
        num_branches = np.random.randint(3, 5)
        print(f'Generating Particle {i+1} out of {npar} | {num_branches} STL Branches')
        
        success = False
        max_attempts = 15
        attempt = 0
        
        while not success and attempt < max_attempts:
            branch_meshes = []
            branch_failed = False
            
            for b in range(num_branches):
                if b == 0:
                    b_Ei, b_Fi = Ei_val, Fi_val
                    b_D2_8, b_D9_15 = D2_8_val, D9_15_val
                    b_rand_j, b_rand_m, b_rand_p = rand_j_val, rand_m_val, rand_p_val
                else:
                    #b_Ei = np.random.uniform(0.2, 0.9)
                    #b_Fi = np.random.uniform(0.2, 0.9)
                    #b_Ei = np.random.uniform(0.2, 0.6)
                    #b_Fi = np.random.uniform(0.2, 0.6)
                    b_Ei = np.random.uniform(0.35, 0.65)
                    b_Fi = np.random.uniform(0.35, 0.65)
                    b_D2_8, b_D9_15 = 0.5, 0.
                    b_rand_j = [np.random.rand(n+1,3) for n in range(1,16)]
                    b_rand_m = [np.random.rand(n,3) for n in range(1,16)]
                    b_rand_p = np.random.rand(1,3)
                
                coeff = SHPSG_fixed(b_Ei, b_Fi, b_D2_8, b_D9_15, b_rand_j, b_rand_m, b_rand_p)
                
                unique_id = uuid.uuid4().hex[:8]
                temp_path = os.path.join(data_folder, f"temp_p{i+1}_b{b}_{unique_id}.stl")
                
                sh2stl(coeff, sph_cor, vertices, faces, temp_path)
                mesh = trimesh.load(temp_path)
                
                # Immediate RAM extraction & temp file cleanup
                if os.path.exists(temp_path):
                    os.remove(temp_path)
                
                mesh.merge_vertices()
                mesh.update_faces(mesh.nondegenerate_faces())
                trimesh.repair.fill_holes(mesh)
                mesh.vertices -= mesh.center_mass
                
                if mesh.volume < 0:
                    mesh.faces = np.fliplr(mesh.faces)
                mesh.fix_normals()

                vol_ratio = mesh.volume / (mesh.convex_hull.volume + 1e-12)
                if mesh.volume <= 0.001 or vol_ratio < 0.15:
                    branch_failed = True
                    if b == 0:
                        Ei_val = min(0.95, Ei_val + 0.05)
                        Fi_val = min(0.95, Fi_val + 0.05)
                        rand_j_val = [np.random.rand(n+1,3) for n in range(1,16)]
                        rand_m_val = [np.random.rand(n,3) for n in range(1,16)]
                    break
                    
                mesh = align_mesh_to_pca(mesh)
                mesh.vertices -= mesh.center_mass
                
                if b == 0:
                    mesh.apply_translation(np.random.uniform(-0.01, 0.01, 3))
                    mesh.fix_normals()
                else:
                    #scale_factor = np.random.uniform(0.35, 0.65)
                    #scale_factor = np.random.uniform(0.5, 2.0)
                    scale_factor = np.random.uniform(0.40, 1.10)
                    mesh.apply_scale(scale_factor)
                    
                    rot_matrix = trimesh.transformations.random_rotation_matrix()
                    mesh.apply_transform(rot_matrix)
                    
                    raw_dir = np.random.randn(3)
                    u = raw_dir / np.linalg.norm(raw_dir)
                    
                    anchor = branch_meshes[0]
                    
                    ray_origins = np.array([anchor.center_mass])
                    ray_dirs = np.array([u])
                    
                    locations, index_ray, index_tri = anchor.ray.intersects_location(
                        ray_origins=ray_origins, ray_directions=ray_dirs)
                    
                    if len(locations) > 0:
                        farthest_loc = locations[np.argmax(np.linalg.norm(locations - anchor.center_mass, axis=1))]
                        r_anchor = np.linalg.norm(farthest_loc - anchor.center_mass)
                    else:
                        r_anchor = np.max(np.dot(anchor.vertices - anchor.center_mass, u))
                        
                    branch_origins = np.array([mesh.center_mass])
                    branch_dirs = np.array([-u])
                    
                    b_locations, b_idx_ray, b_idx_tri = mesh.ray.intersects_location(
                        ray_origins=branch_origins, ray_directions=branch_dirs)
                        
                    if len(b_locations) > 0:
                        b_farthest_loc = b_locations[np.argmax(np.linalg.norm(b_locations - mesh.center_mass, axis=1))]
                        r_branch = np.linalg.norm(b_farthest_loc - mesh.center_mass)
                    else:
                        r_branch = np.max(np.dot(mesh.vertices - mesh.center_mass, -u))
                    
                    #shift_dist = r_anchor + r_branch * np.random.uniform(-0.20, 0.20)
                    shift_dist = r_anchor + r_branch * np.random.uniform(-0.35, -0.10)
                    mesh.apply_translation(anchor.center_mass + u * shift_dist)
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
                    # Enforce the fast Manifold3D engine
                    fused = trimesh.boolean.union([aggregate_mesh, secondary], engine='manifold')
                except:
                    union_success = False
                    break
                
                if fused.is_empty or fused.volume <= 0.005:
                    union_success = False
                    break
                
                # Isolate largest manifold component
                components = fused.split(only_watertight=False)
                if len(components) > 1:
                    components = sorted(components, key=lambda c: len(c.faces), reverse=True)
                    fused = components[0]
                
                # Fast intermediate cleanup (skip heavy hole-filling during loop)
                fused.merge_vertices()
                aggregate_mesh = fused

            if union_success:
                success = True
            else:
                attempt += 1

        # FACET DECIMATION / SIMPLIFICATION
        target_faces = 1200
        if success and len(aggregate_mesh.faces) > target_faces:
            try:
                simplified = aggregate_mesh.simplify_quadratic_decimation(target_faces)
                if simplified is not None and not simplified.is_empty:
                    aggregate_mesh = simplified
            except Exception:
                pass

        # Final single-pass topological repair
        aggregate_mesh.merge_vertices()
        trimesh.repair.fill_holes(aggregate_mesh)
        aggregate_mesh.fix_normals()

        if not success:
            print(f"Warning: Particle {i+1} completely failed. Saving fallback.")
            aggregate_mesh = branch_meshes[0]
            
        aggregate_mesh.export(stlpath)
        
    else:
        print(f'Generating Particle {i+1} out of {npar}')
        coeff = SHPSG_fixed(Ei_val, Fi_val, D2_8_val, D9_15_val, rand_j_val, rand_m_val, rand_p_val)
        sh2stl(coeff, sph_cor, vertices, faces, stlpath)
        
    return (Ei_val, Fi_val, rand_j_val, rand_m_val)


if __name__ == '__main__':
    
    
    # Initialize the paths
    paths = get_project_paths()
    
    parallel = True
    
    fuse_switch = True

    #size_switch = 'random'
    size_switch = 'fixed_complexity'
    
    output_folder = 'Irregular_1k_fuse_TEST3'
    
    #output_folder = 'Irregular_10k_random_NEW'
    
    #output_folder = 'Irregular_100_TEST'
    #output_folder = 'Irregular_10k_round_05_rough_0_fuse'
    
    #npar = 10000 # particle number for each parameter group
    
    npar = 1000
    
    # Dynamically construct the output folder path
    data_folder_path = paths['simulations'] / output_folder
    data_folder_path.mkdir(parents=True, exist_ok=True)
    data_folder = str(data_folder_path) + os.sep
    
    if not os.path.isdir(data_folder):
        os.mkdir(data_folder)
    
    get_new_seed = True
    
    if get_new_seed:
        
        rand_j = []
        rand_m = []
        rand_p = []
        
        for i in range(npar):
            
            rand_j_temp = []
            rand_m_temp = []
        
            for n in range(1,16):
                rand_j_temp.append(np.random.rand(n+1,3)) # [-1,1]
                rand_m_temp.append(np.random.rand(n,3))
                
            rand_j.append(rand_j_temp)
            rand_m.append(rand_m_temp)
            rand_p.append(np.random.rand(1,3))
    
    
    if size_switch=='gamma':
    	mu = 7.0
    	Dm = 0.9
    	Dlow = 0.35 
    	Dhigh = 3.0
    
    	D = draw_gamma_rnd(mu,Dm,Dlow,Dhigh,(1,npar))[0]
    
    	Ei_min = 0.75  
    	Ei_max = 0.75 
    	Fi_min = 0.75 
    	Fi_max = 0.75 
    
    	D2_8_min  = 1.0 
    	D9_15_min = 1.0
    	D2_8_max  = 1.0
    	D9_15_max = 1.0
    
            # Linear relationship
    	Ei = (Ei_min*(D-Dlow)+Ei_max*(Dhigh-D))/(Dhigh-Dlow)
    	Fi = (Fi_min*(D-Dlow)+Fi_max*(Dhigh-D))/(Dhigh-Dlow)
    	D2_8 = (D2_8_min*(D-Dlow)+D2_8_max*(Dhigh-D))/(Dhigh-Dlow)
    	D9_15 = (D9_15_min*(D-Dlow)+D9_15_max*(Dhigh-D))/(Dhigh-Dlow)
    
    
    	#Ei = np.exp(-D/4.)*Ei
    	#Fi = np.exp(-D/4.)*Fi 
    
    	#Ei[Ei<0.5] = 0.5
    	#Fi[Fi<0.5] = 0.5
    
    	# Logarithmic relationship
    
    	#Ei = Ei_max*(np.log10(Dhigh/D)/np.log10(Dhigh/Dlow))+Ei_min*(np.log10(D/Dlow)/np.log10(Dhigh/Dlow))
    	#Fi = Fi_max*(np.log10(Dhigh/D)/np.log10(Dhigh/Dlow))+Fi_min*(np.log10(D/Dlow)/np.log10(Dhigh/Dlow))
    	#D2_8 = D2_8_max*(np.log10(Dhigh/D)/np.log10(Dhigh/Dlow))+D2_8_min*(np.log10(D/Dlow)/np.log10(Dhigh/Dlow))
    	#D9_15 = D9_15_max*(np.log10(Dhigh/D)/np.log10(Dhigh/Dlow))+D9_15_min*(np.log10(D/Dlow)/np.log10(Dhigh/Dlow))
    
    	#print('D shape=',np.shape(D))
    	#print('Ei shape = ',np.shape(Ei))
    	#raise Exception()
    
    elif size_switch=='constrained':
        
        D = np.ones((1,npar))
    
        # 1. Sample Elongation and Flatness (Preserves Aspect Ratio)
        Ei_min, Ei_max = 0.2, 0.9 
        Fi_min, Fi_max = 0.2, 0.9 
    
        Ei = np.random.uniform(Ei_min, Ei_max, size=(1,npar))[0]
        Fi = np.random.uniform(Fi_min, Fi_max, size=(1,npar))[0]
        
        # 2. Calculate a Macro-Shape Index (0.0 to 1.0)
        # 0.0 = highly elongated/flat (pristine-like), 1.0 = isometric (aggregate-like)
        macro_index = (np.minimum(Ei, Fi) - Ei_min) / (Ei_max - Ei_min)
        
        # 3. Define Conditional Roundness/Roughness Bounds
        # Lower bounds stay fixed at 1.0 (smooth)
        # Tighten the absolute maximums to reduce overall area ratio blobbiness
        D2_8_max_limit = 4.0   
        D9_15_max_limit = 7.0  
        
        D2_8_dyn_max = 1.0 + macro_index * (D2_8_max_limit - 1.0)
        D9_15_dyn_max = 1.0 + macro_index * (D9_15_max_limit - 1.0)
    
        # 4. Conditionally Sample Roundness and Roughness
        # np.random.uniform accepts arrays for bounds, mapping element-by-element
        D2_8 = np.random.uniform(1.0, D2_8_dyn_max)
        D9_15 = np.random.uniform(1.0, D9_15_dyn_max)
    
    elif size_switch=='gaussian':
        
        D = np.ones((1,npar))
        
        # Sample Elongation and Flatness (Preserves Aspect Ratio)
        Ei_min, Ei_max = 0.2, 0.9 
        Fi_min, Fi_max = 0.2, 0.9 
    
        Ei = np.random.uniform(Ei_min, Ei_max, size=(1,npar))[0]
        Fi = np.random.uniform(Fi_min, Fi_max, size=(1,npar))[0]
        
        # 2. Simple, Uncoupled Gaussian Sampling for Complexity
        # Centered to maintain the correct modal Area Ratio, 
        # with a tight standard deviation to reduce dispersion.
        D2_8_mean, D2_8_std = 3.0, 0.5
        D9_15_mean, D9_15_std = 5.5, 1.0
        
        D2_8 = np.random.normal(D2_8_mean, D2_8_std, size=(1,npar))[0]
        D9_15 = np.random.normal(D9_15_mean, D9_15_std, size=(1,npar))[0]
        
        # 3. Clip to ensure they stay within physical boundaries
        D2_8 = np.clip(D2_8, 1.0, 5.0)
        D9_15 = np.clip(D9_15, 1.0, 10.0)
        
        # 2. Calculate a Macro-Shape Index (0.0 to 1.0)
        # 0.0 = highly elongated/flat (pristine-like), 1.0 = isometric (aggregate-like)
        #macro_index = (np.minimum(Ei, Fi) - Ei_min) / (Ei_max - Ei_min)
        
        # 3. Define Conditional Roundness/Roughness Bounds
        # Lower bounds stay fixed at 1.0 (smooth)
        # Tighten the absolute maximums to reduce overall area ratio blobbiness
        #D2_8_max_limit = 4.0   
        #D9_15_max_limit = 7.0  
        
        #D2_8_dyn_max = 1.0 + macro_index * (D2_8_max_limit - 1.0)
        #D9_15_dyn_max = 1.0 + macro_index * (D9_15_max_limit - 1.0)
    
        # Conditionally Sample Roundness and Roughness using a tight Gaussian
        # Center the distribution at 60% of the maximum allowed complexity
        #D2_8_mean = 1.0 + (D2_8_dyn_max - 1.0) * 0.6
        #D9_15_mean = 1.0 + (D9_15_dyn_max - 1.0) * 0.6
        
        # Define a tight standard deviation (e.g., 15% of the range)
        #D2_8_std = (D2_8_dyn_max - 1.0) * 0.15
        #D9_15_std = (D9_15_dyn_max - 1.0) * 0.15
        
        # Sample normally and clip to ensure we don't violate physical bounds
        #D2_8 = np.random.normal(D2_8_mean, D2_8_std)
        #D2_8 = np.clip(D2_8, 1.0, D2_8_dyn_max)
        
        #D9_15 = np.random.normal(D9_15_mean, D9_15_std)
        #D9_15 = np.clip(D9_15, 1.0, D9_15_dyn_max)
    
    elif size_switch=='gaussian_means':
        D = np.ones((1,npar))
    
        # 1. Uniform Elongation and Flatness
        #Ei_min, Ei_max = 0.2, 0.9 
        #Fi_min, Fi_max = 0.2, 0.9 
        
        Ei_min, Ei_max = 0.45, 0.85 
        Fi_min, Fi_max = 0.45, 0.85
    
        Ei = np.random.uniform(Ei_min, Ei_max, size=(1,npar))[0]
        Fi = np.random.uniform(Fi_min, Fi_max, size=(1,npar))[0]
        
        # 2. Calculate a normalized shape index (0.0 = needle/plate, 1.0 = isometric)
        shape_index = (np.minimum(Ei, Fi) - Ei_min) / (Ei_max - Ei_min)
        
        # 3. Scale the Gaussian means: elongated = smooth (1.0), isometric = rough
        D2_8_mean = 1.0 + shape_index * (4.0 - 1.0)
        D9_15_mean = 1.0 + shape_index * (7.0 - 1.0)
        
        # 4. Use tight standard deviations to crush the variance (blobbiness)
        D2_8_std = 0.25
        D9_15_std = 0.50
        
        D2_8 = np.random.normal(D2_8_mean, D2_8_std)
        D9_15 = np.random.normal(D9_15_mean, D9_15_std)
        
        # 5. Clip to physical bounds
        D2_8 = np.clip(D2_8, 1.0, 5.0)
        D9_15 = np.clip(D9_15, 1.0, 10.0)
       
    elif size_switch=='fixed_complexity':
        
        D = np.ones((1,npar))
    
        # 1. Uniform Elongation and Flatness
        #Ei_min, Ei_max = 0.2, 0.9 
        #Fi_min, Fi_max = 0.2, 0.9 
        
        Ei_min, Ei_max = 0.2, 0.9 
        Fi_min, Fi_max = 0.2, 0.9 
    
        Ei = np.random.uniform(Ei_min, Ei_max, size=(1,npar))[0]
        Fi = np.random.uniform(Fi_min, Fi_max, size=(1,npar))[0]
        
        # 2. Fix the macro-roundness to a constant
        # This provides a consistent, stable base level of large-scale lobing
        D2_8_fixed = 0.5 
        D9_15_fixed = 0.
        D2_8 = np.full(npar, D2_8_fixed) 
        D9_15 = np.full(npar,D9_15_fixed)
        
        
        # 3. Use high-frequency roughness to strictly control Area Ratio
        # Push the mean higher (e.g., 7.5 or 8.0) to chew away more area
        # Use a very tight standard deviation to prevent blobbiness
        #D9_15_mean = 5.0
        #D9_15_std = 1.0
        
        #D9_15 = np.random.normal(D9_15_mean, D9_15_std, size=(1,npar))[0]
        #D9_15 = np.clip(D9_15, 0.0, 100.0)          
    
    elif size_switch=='roughness':
        
        D = np.ones((1,npar))
    
        # 1. Uniform Elongation and Flatness
        Ei_min, Ei_max = 0.2, 0.9 
        Fi_min, Fi_max = 0.2, 0.9 
    
        Ei = np.random.uniform(Ei_min, Ei_max, size=(1,npar))[0]
        Fi = np.random.uniform(Fi_min, Fi_max, size=(1,npar))[0]
        
        # 2. Fix the macro-roundness to a constant
        # This provides a consistent, stable base level of large-scale lobing
        D2_8 = np.full(npar, 0.5) 
        
        # 3. Use high-frequency roughness to strictly control Area Ratio
        # Push the mean higher (e.g., 7.5 or 8.0) to chew away more area
        # Use a very tight standard deviation to prevent blobbiness
        D9_15_mean = 5.0
        D9_15_std = 1.0
        
        D9_15 = np.random.normal(D9_15_mean, D9_15_std, size=(1,npar))[0]
        D9_15 = np.clip(D9_15, 0.0, 100.0)        
    
    elif size_switch=='fixed':
    
    	Ei_min = 0.4  
    	Ei_max = 0.4 
    	Fi_min = 0.4 
    	Fi_max = 0.4 
    
    	D2_8_min  = 0.0 
    	D9_15_min = 0.0
    	D2_8_max  = 1.0
    	D9_15_max = 1.0
    
    	Dlow = 0.
    	Dhigh = 1.
    	D = np.flip(np.linspace(Dlow,Dhigh,npar))
    
            # Linear relationship
    	Ei = (Ei_min*(D-Dlow)+Ei_max*(Dhigh-D))/(Dhigh-Dlow)
    	Fi = (Fi_min*(D-Dlow)+Fi_max*(Dhigh-D))/(Dhigh-Dlow)
    	D2_8 = (D2_8_min*(D-Dlow)+D2_8_max*(Dhigh-D))/(Dhigh-Dlow)
    	D9_15 = (D9_15_min*(D-Dlow)+D9_15_max*(Dhigh-D))/(Dhigh-Dlow)
    
    
    else: # RANDOM!
    	D = np.ones((1,npar))
    
    	Ei_min = 0.2  
    	Ei_max = 0.9 
    	Fi_min = 0.2 
    	Fi_max = 0.9 
    
    	Ei = np.random.uniform(Ei_min,Ei_max,size=(1,npar))[0]
    	Fi = np.random.uniform(Fi_min,Fi_max,size=(1,npar))[0]
    
        # ORIGINAL!!!
    	#D2_8_min  = 1.0 
    	#D9_15_min = 1.0
    	#D2_8_max  = 1.0
    	#D9_15_max = 1.0
        
        # Unlock roughness parameters with high upper bounds to overcome harmonic decay
    	D2_8_min  = 1.0 
    	D2_8_max  = 5.0
    	D9_15_min = 1.0
    	D9_15_max = 10.0
    
    	D2_8 = np.random.uniform(D2_8_min,D2_8_max,size=(1,npar))[0]
    	D9_15 = np.random.uniform(D9_15_min,D9_15_max,size=(1,npar))[0]
    
    
    level = 3 # face number: 20 @ level-0; 80 @ level-1; 320 @ level-2
    
    # create isosahedron surface
    vertices, faces = icosahedron()
    for i in range(level): 
        # subdivide surface
        vertices, faces = subdivsurf(faces,vertices)
        # remove duplicate vertices
        vertices, faces = cleanmesh(faces,vertices)
    # convert from Cartesian to spherical coordinates
    sph_cor = car2sph(vertices)
    
    
    if parallel:
        
        from joblib import Parallel, delayed
        
        print(f"Executing parallel generation of {npar} particles across 12 workers...")
        
        # Run the worker function in parallel
        results = Parallel(n_jobs=12, backend='loky')(
            delayed(generate_particle)(
                i, npar, Ei[i], Fi[i], D2_8[i], D9_15[i], rand_j[i], rand_m[i], rand_p[i], 
                sph_cor, vertices, faces, data_folder, fuse_switch
            ) for i in range(npar)
        )
        
        # Unpack the results to update the parameter arrays with any nudged "escaped" values
        for i, (updated_Ei, updated_Fi, updated_rand_j, updated_rand_m) in enumerate(results):
            Ei[i] = updated_Ei
            Fi[i] = updated_Fi
            rand_j[i] = updated_rand_j
            rand_m[i] = updated_rand_m
    
        print("Generation complete. Writing NetCDF properties file...")
        
        
    else:
 
        for i in range(npar):
            # Call the unified worker function
            updated_Ei, updated_Fi, updated_rand_j, updated_rand_m = generate_particle(
                i, npar, Ei[i], Fi[i], D2_8[i], D9_15[i], rand_j[i], rand_m[i], rand_p[i], 
                sph_cor, vertices, faces, data_folder, fuse_switch)
            
            # Update the parameter arrays with any nudged "escaped" values
            Ei[i] = updated_Ei
            Fi[i] = updated_Fi
            rand_j[i] = updated_rand_j
            rand_m[i] = updated_rand_m

    # Save particle parameters
    WritePartNetcdf(data_folder+'particle_params.nc',D,Ei,Fi,D2_8,D9_15,rand_j,rand_m,rand_p)
    
    # --- NEW CLEANUP BLOCK ---
    print("Cleaning up temporary files...")
    # data_folder_path is already defined as a Path object earlier in your script
    for temp_file in data_folder_path.glob("temp_*.stl"):
        try:
            temp_file.unlink()
        except OSError as e:
            print(f"    -> Could not delete {temp_file}: {e}")