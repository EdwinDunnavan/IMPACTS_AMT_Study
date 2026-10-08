import numpy as np
import os
import trimesh
from pathlib import Path
from joblib import Parallel, delayed

def get_base_hexagon():
    """ 
    Generates the base hexagonal prism using the exact vertices and faces 
    from gen_stl_hexagonal.m to guarantee coordinate system alignment.
    """
    # Vertices from gen_stl_hexagonal.m (divided by 2)
    vertices = np.array([
        [ 1.0000,       0,  1.0000],
        [ 0.5000, -1.0000, -1.0000],
        [ 0.5000, -1.0000,  1.0000],
        [-0.5000, -1.0000, -1.0000],
        [-1.0000,       0, -1.0000],
        [ 1.0000,       0, -1.0000],
        [ 0.5000,  1.0000, -1.0000],
        [-0.5000,  1.0000, -1.0000],
        [-1.0000,       0,  1.0000],
        [-0.5000, -1.0000,  1.0000],
        [ 0.5000,  1.0000,  1.0000],
        [-0.5000,  1.0000,  1.0000]
    ]) / 2.0
    
    # Faces from gen_stl_hexagonal.m
    faces_matlab = np.array([
        [ 1,  2,  3], [ 4,  2,  5], [ 4,  3,  2], [ 6,  5,  2],
        [ 6,  2,  1], [ 7,  5,  6], [ 7,  6,  1], [ 8,  5,  7],
        [ 9,  4,  5], [ 9,  1,  3], [ 9,  5,  8], [10,  3,  4],
        [10,  4,  9], [10,  9,  3], [11,  7,  1], [11,  8,  7],
        [11,  1,  9], [12,  9,  8], [12,  8, 11], [12, 11,  9]
    ])
    
    # Python is 0-indexed (subtract 1), and we flip left-to-right (matching fliplr in MATLAB)
    faces = (faces_matlab - 1)[:, ::-1]
    
    return trimesh.Trimesh(vertices=vertices, faces=faces, process=True)

def generate_capped_column(i, npar, data_folder):
    """ Worker function to generate a single capped column mathematically. """
    
    stlpath = os.path.join(data_folder, f'particle_{i+1}_orig.stl')
    print(f'Generating Capped Column {i+1} out of {npar}')
    
    # 1. Create mathematically perfect base meshes
    column = get_base_hexagon()
    plate_top = get_base_hexagon()
    plate_bot = get_base_hexagon()
    
    # 2. Randomize Dimensions
    Wc = np.random.uniform(0.3, 0.6)  # Column width
    Lc = np.random.uniform(1.0, 2.5)  # Column length
    
    Wp = Wc * np.random.uniform(1.5, 3.0)  # Plate width (wider than column)
    Tp = np.random.uniform(0.05, 0.2)      # Plate thickness (thin)
    
    # 3. Apply Scaling [X, Y, Z]
    column.apply_scale([Wc, Wc, Lc])
    plate_top.apply_scale([Wp, Wp, Tp])
    plate_bot.apply_scale([Wp, Wp, Tp])
    
    # 4. Exact Mathematical Z-Translation (with micro-overlap for CSG)
    overlap = 0.005 # 5 microns to ensure Manifold3D works perfectly
    
    # The base hexagon from MATLAB spans Z from -0.5 to +0.5. 
    # Therefore, its actual physical length after scaling is exactly Lc (for column) and Tp (for plate).
    # To place the plate perfectly on top, shift it by half the column length plus half the plate thickness.
    z_shift = (Lc / 2.0) + (Tp / 2.0) - overlap
    
    plate_top.apply_translation([0, 0, z_shift])
    plate_bot.apply_translation([0, 0, -z_shift])
    
    # 5. CSG Fusion
    try:
        fused = trimesh.boolean.union([column, plate_top, plate_bot], engine='manifold')
        
        if fused.is_empty:
            raise ValueError("Union resulted in empty mesh")
            
        # Final cleanup
        fused.merge_vertices()
        fused.update_faces(fused.unique_faces())
        fused.update_faces(fused.nondegenerate_faces())
        trimesh.repair.fill_holes(fused)
        fused.fix_normals()
        
    except Exception as e:
        print(f"Warning: Union failed on CC {i+1}: {e}. Exporting column only.")
        fused = column

    # 6. Export directly
    fused.export(stlpath)
    
    return True

if __name__ == '__main__':
    project_root = Path(__file__).resolve().parent.parent.parent
    
    output_folder = 'CappedColumns_10k'
    npar = 10000
    
    data_folder_path = project_root / 'Simulations' / output_folder
    data_folder_path.mkdir(parents=True, exist_ok=True)
    data_folder = str(data_folder_path) + os.sep
    
    print(f"Executing parallel generation of {npar} Capped Columns...")
    
    # Run the worker function in parallel
    Parallel(n_jobs=12, backend='loky')(
        delayed(generate_capped_column)(
            i, npar, data_folder
        ) for i in range(npar)
    )

    print("Generation complete.")