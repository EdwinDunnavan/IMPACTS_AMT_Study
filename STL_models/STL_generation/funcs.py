import numpy as np
#from scipy.special import sph_harm
from scipy.special import lpmv
from math import factorial
from ellipsoid_fit import ellipsoid_fit, ellipsoid_plot

import os

def align_mesh_to_pca(mesh):
    """
    Aligns the mesh's principal axes to Cartesian axes while guaranteeing 
    a right-handed transformation to prevent inverted face normals.
    """
    transform = mesh.principal_inertia_transform
    
    # If determinant is negative, matrix contains a reflection that inverts face normals
    if np.linalg.det(transform[:3, :3]) < 0:
        transform[:3, 0] *= -1  # Flip X-axis orientation to enforce SO(3) rotation
        
    mesh.apply_transform(transform)
    mesh.fix_normals()
    return mesh

def robust_sph_harm(m, n, theta, phi):
    """
    Version-proof Spherical Harmonic generator to replace missing scipy.special.sph_harm.
    m: order
    n: degree
    theta: azimuthal angle [0, 2*pi]
    phi: polar angle [0, pi]
    """
    x = np.cos(phi)
    abs_m = abs(m)
    
    # Evaluate Associated Legendre Polynomial
    p = lpmv(abs_m, n, x)
    
    # Normalization constant
    norm = np.sqrt(((2*n + 1) / (4 * np.pi)) * (factorial(n - abs_m) / factorial(n + abs_m)))
    
    if m >= 0:
        # Include Condon-Shortley phase for m > 0
        phase = (-1)**m if m > 0 else 1.0
        y = phase * norm * p * np.exp(1j * m * theta)
    else:
        # Conjugate property for negative m
        pos_y = ((-1)**abs_m) * norm * p * np.exp(1j * abs_m * theta)
        y = ((-1)**abs_m) * np.conj(pos_y)
        
    return y

# calculate coordinates with SH expansion
def sph2cart(coeff, phi, theta):
    x = 0
    y = 0
    z = 0
    index = 0
    for n in range(9):
        order = [*range(-n,n+1)]
        for m in range(2*n+1):
            # Swap out the old sph_harm for our robust_sph_harm
            x += coeff[index,0]*robust_sph_harm(order[m], n, theta, phi)
            y += coeff[index,1]*robust_sph_harm(order[m], n, theta, phi)
            z += coeff[index,2]*robust_sph_harm(order[m], n, theta, phi)
            index += 1
    return x, y, z

# # calcualte coordinates with SH expansion
# def sph2cart(coeff, phi, theta):
#     x = 0
#     y = 0
#     z = 0
#     index = 0
#     for n in range(9):
#         order = [*range(-n,n+1)]
#         for m in range(2*n+1):
#             x += coeff[index,0]*sph_harm(order[m], n, theta, phi)
#             y += coeff[index,1]*sph_harm(order[m], n, theta, phi)
#             z += coeff[index,2]*sph_harm(order[m], n, theta, phi)
#             index += 1
#     return x, y, z

# define hexagonal prism surface
def hexagonal():
    
    v = np.array([[1.0000,0,    1.0000],
                 [0.5000,   -1.0000,   -1.0000],
                 [0.5000,   -1.0000,    1.0000],
                 [-0.5000,   -1.0000,   -1.0000],
                 [-1.0000,         0,   -1.0000],
                 [1.0000,         0,   -1.0000],
                 [0.5000,    1.0000,   -1.0000],
                 [-0.5000,    1.0000,   -1.0000],
                 [-1.0000,         0,    1.0000],
                 [-0.5000,   -1.0000,    1.0000],
                 [0.5000,    1.0000,    1.0000],
                 [-0.5000,    1.0000,    1.0000]])
    
    f = np.array([[1 ,    2,     3],
                  [4 ,    2,     5],
                  [4 ,    3,     2],
                  [6 ,    5,     2],
                  [6 ,    2,     1],
                  [7 ,    5,     6],
                  [7 ,    6,     1],
                  [8 ,    5,     7],
                  [9 ,    4,     5],
                  [9 ,    1,     3],
                  [9 ,    5,     8],
                  [10,     3,     4],
                  [10,     4,     9],
                  [10,     9,     3],
                  [11,     7,     1],
                  [11,     8,     7],
                  [11,     1,     9],
                  [12,     9,     8],
                  [12,     8,    11],
                  [12,    11,     9]])
    
    return v, f
    


# define icosahedron surface
def icosahedron():
    # create unit regular icosahedron
    t = (1+np.sqrt(5)) / 2
    #create vertices
    v = np.array([[-1, t, 0], # v1
         [1, t, 0], # v2
         [-1,-t, 0], # v3
         [1,-t, 0], # v4
         [0,-1, t], # v5
         [0, 1, t], # v6
         [0,-1,-t], # v7
         [0, 1,-t], # v8
         [t, 0,-1], # v9
         [t, 0, 1], # v10
         [-t, 0,-1], # v11
         [-t, 0, 1]])# v12
    # normalise vertices to unit size
    v = v/np.linalg.norm(v[0,:])/2
    #create faces
    f = np.array([[0,11, 5], # f1
         [0, 5, 1], # f2
         [0, 1, 7], # f3
         [0, 7,10], # f4
         [0,10,11], # f5
         [1, 5,9], # f6
         [5,11, 4], # f7
         [11,10, 2], # f8
         [10, 7, 6], # f9
         [7, 1, 8], # f10
         [3,9, 4], # f11
         [3, 4, 2], # f12
         [3, 2, 6], # f13
         [3, 6, 8], # f14
         [3, 8,9], # f15
         [4,9, 5], # f16
         [2, 4,11], # f17
         [6, 2,10], # f18
         [8, 6, 7], # f19
         [9, 8, 1]])# f20
    return v,f

# calculate sphercial coordinates based on xyz
def car2sph(xyz):
    ptsnew = np.hstack((xyz, np.zeros(xyz.shape)))
    xy = xyz[:,0]**2 + xyz[:,1]**2
    ptsnew[:,3] = np.sqrt(xy + xyz[:,2]**2)
    ptsnew[:,4] = np.arctan2(np.sqrt(xy), xyz[:,2]) # for elevation angle defined from Z-axis down
    #ptsnew[:,4] = np.arctan2(xyz[:,2], np.sqrt(xy)) # for elevation angle defined from XY-plane up
    ptsnew[:,5] = np.arctan2(xyz[:,1], xyz[:,0])
    return ptsnew

# subdivide triangle faces
def subdivsurf(f,v):
    f_ = np.zeros((len(f)*4,3))
    for i in range(len(f)): # for each triangle
        tri = f[i,:]
        # calculate mid points (add new points to v)
        [a,v] = getMidPoint(tri[0],tri[1],v)
        [b,v] = getMidPoint(tri[1],tri[2],v)
        [c,v] = getMidPoint(tri[2],tri[0],v)
        # generate new subdivision triangles
        nfc = np.array([[tri[0],a,c],
               [tri[1],b,a],
               [tri[2],c,b],
               [a,b,c]])
        # replace triangle with subdivision
        idx = range(4*i,4*(i+1),1)
        f_[idx,:] = nfc
    return v,f_.astype(int)

def getMidPoint(t1,t2,v):
    # GETMIDPOINT calculates point between two vertices
    # Calculate new vertex in sub-division and normalise to unit length
    # then find or add it to v and return index
    # get vertice positions
    p1 = v[t1,:]
    p2 = v[t2,:]
    # calculate mid point (on unit sphere)
    pm = (p1 + p2) / 2
    pm = pm/np.linalg.norm(pm)/2
    # add to vertices list, return index
    i = len(v)
    v = np.vstack((v,pm))
    return [i,v]

def cleanmesh(f,v):
    # remove duplicate vertices
    v,AC,TC = np.unique(v,return_index = True, return_inverse=True,axis = 0)
    # reassign faces to trimmed vertex list
    for i in range(len(f)):
        for j in range(3):
            f[i,j] = TC[f[i,j]]
    return v,f

from stl import mesh
from mpl_toolkits import mplot3d
import matplotlib.pyplot as plt

def plotstl(stlpath,figpath):
    # create a new plot
    #fig = plt.figure(figsize=(3, 3))
    #ax = mplot3d.Axes3D(fig, proj_type ='ortho') 
    
    #fig = plt.figure()
    #ax = mplot3d.Axes3D(fig, proj_type ='ortho') 
    fig, ax = plt.subplots(subplot_kw={"projection": "3d"})
    #plt.rc('font', size=6) 

    # load STL files and add the vectors to the plot
    your_mesh = mesh.Mesh.from_file(stlpath)
    surf = mplot3d.art3d.Poly3DCollection(your_mesh.vectors,linewidth=0.15,facecolors='grey', 
                                          edgecolor = 'b',alpha=0.5)
    # set axis properties
    ax.add_collection3d(surf)

    # set scale
    ax.set_xlim([-1, 1])
    ax.set_ylim([-1, 1])
    ax.set_zlim([-1, 1])
    ax.set_xticks(np.arange(-1, 1.2, step=0.2))
    ax.set_yticks(np.arange(-1, 1.2, step=0.2))
    ax.set_zticks(np.arange(-1, 1.2, step=0.2))
    
    center, evecs, radii = ellipsoid_fit(np.reshape(your_mesh.vectors,(1280*3, 3)),mode=0)

    ellipsoid_plot(center, radii, evecs, ax, plot_axes=False, cage_color='b', cage_alpha=0.2)

    # Show the plot to the screen
    plt.show()

    fig.savefig(figpath,dpi = 300, bbox_inches='tight')

def sh2stl(coeff, sph_cor, vertices, faces,stlpath):
    # update vertices by SH expansion
    for i in range(3):
        vertices[:,i] = np.real(sph2cart(coeff,sph_cor[:,4],sph_cor[:,5])[i])
    
    # 2. THE RADIAL FLOOR FIX
    # Calculate the exact distance of every vertex from the center (0,0,0)
    r = np.linalg.norm(vertices, axis=1)
    
    # Set a solid core boundary (e.g., radius of 0.05)
    min_r = 0.05
    
    # Identify any vertices that punched too deep and crossed the threshold
    mask = r < min_r
    
    # Push those inverted vertices back out along their vector to rest on the core
    # (The 1e-12 prevents division by zero if a vertex hit exactly 0.0)
    vertices[mask] = (vertices[mask] / (r[mask, None] + 1e-12)) * min_r    
    
    
    # Create the mesh
    cube = mesh.Mesh(np.zeros(faces.shape[0], dtype=mesh.Mesh.dtype))
    for i, f in enumerate(faces):
        for j in range(3):
            cube.vectors[i][j] = vertices[f[j],:]
    # Write the mesh to file "cube.stl"
    if os.path.isfile(stlpath):
        os.remove(stlpath)
    
    cube.save(stlpath)
    
    
def WritePartNetcdf(fname,D,Ei,Fi,D2_8,D9_15,rand_j,rand_m,rand_p):
    
    from netCDF4 import Dataset
    
    out = Dataset(fname,'w',clobber=True, format='NETCDF4')
    
    Ntot = len(Ei)
    
    out.N = Ntot
    
    ind = np.arange(1,Ntot+1,1,dtype='i4')
    
    Np = out.createDimension('N',Ntot)
    
    dim1 = out.createDimension('dim1',1)
    dim2 = out.createDimension('dim2',2)
    dim3 = out.createDimension('dim3',3)
    dim4 = out.createDimension('dim4',4)
    dim5 = out.createDimension('dim5',5)
    dim6 = out.createDimension('dim6',6)
    dim7 = out.createDimension('dim7',7)
    dim8 = out.createDimension('dim8',8)
    dim9 = out.createDimension('dim9',9)
    dim10 = out.createDimension('dim10',10)
    dim11 = out.createDimension('dim11',11)
    dim12 = out.createDimension('dim12',12)
    dim13 = out.createDimension('dim13',13)
    dim14 = out.createDimension('dim14',14)
    dim15 = out.createDimension('dim15',15)
    dim16 = out.createDimension('dim16',16)
    
    
    index = out.createVariable('particle_number','i4',('N',))
    Dp = out.createVariable("max_dim","f8",("N",))
    Eip = out.createVariable("Ei","f8",("N",))
    Fip = out.createVariable("Fi","f8",("N",))
    D2_8_p = out.createVariable("D2_8","f8",("N",))
    D9_15_p = out.createVariable("D9_15","f8",("N",))
    
    rand_group = out.createGroup('random')
    rand_j_group = out.createGroup('/random/rand_j')
    rand_m_group = out.createGroup('/random/rand_m')
    #rand_p_group = out.createGroup('/rand/rand_p')
    
    rand_p_p = out.createVariable("/random/rand_p","f8",('N','dim3'))
    
    
    rand_j1_p = out.createVariable("/random/rand_j/j1","f8",('N','dim2','dim3'))
    rand_j2_p = out.createVariable("/random/rand_j/j2","f8",('N','dim3','dim3'))
    rand_j3_p = out.createVariable("/random/rand_j/j3","f8",('N','dim4','dim3'))
    rand_j4_p = out.createVariable("/random/rand_j/j4","f8",('N','dim5','dim3'))
    rand_j5_p = out.createVariable("/random/rand_j/j5","f8",('N','dim6','dim3'))
    rand_j6_p = out.createVariable("/random/rand_j/j6","f8",('N','dim7','dim3'))
    rand_j7_p = out.createVariable("/random/rand_j/j7","f8",('N','dim8','dim3'))
    rand_j8_p = out.createVariable("/random/rand_j/j8","f8",('N','dim9','dim3'))
    rand_j9_p = out.createVariable("/random/rand_j/j9","f8",('N','dim10','dim3'))
    rand_j10_p = out.createVariable("/random/rand_j/j10","f8",('N','dim11','dim3'))
    rand_j11_p = out.createVariable("/random/rand_j/j11","f8",('N','dim12','dim3'))
    rand_j12_p = out.createVariable("/random/rand_j/j12","f8",('N','dim13','dim3'))
    rand_j13_p = out.createVariable("/random/rand_j/j13","f8",('N','dim14','dim3'))
    rand_j14_p = out.createVariable("/random/rand_j/j14","f8",('N','dim15','dim3'))
    rand_j15_p = out.createVariable("/random/rand_j/j15","f8",('N','dim16','dim3'))
    
    rand_m1_p = out.createVariable("/random/rand_m/m1","f8",('N','dim1','dim3'))
    rand_m2_p = out.createVariable("/random/rand_m/m2","f8",('N','dim2','dim3'))
    rand_m3_p = out.createVariable("/random/rand_m/m3","f8",('N','dim3','dim3'))
    rand_m4_p = out.createVariable("/random/rand_m/m4","f8",('N','dim4','dim3'))
    rand_m5_p = out.createVariable("/random/rand_m/m5","f8",('N','dim5','dim3'))
    rand_m6_p = out.createVariable("/random/rand_m/m6","f8",('N','dim6','dim3'))
    rand_m7_p = out.createVariable("/random/rand_m/m7","f8",('N','dim7','dim3'))
    rand_m8_p = out.createVariable("/random/rand_m/m8","f8",('N','dim8','dim3'))
    rand_m9_p = out.createVariable("/random/rand_m/m9","f8",('N','dim9','dim3'))
    rand_m10_p = out.createVariable("/random/rand_m/m10","f8",('N','dim10','dim3'))
    rand_m11_p = out.createVariable("/random/rand_m/m11","f8",('N','dim11','dim3'))
    rand_m12_p = out.createVariable("/random/rand_m/m12","f8",('N','dim12','dim3'))
    rand_m13_p = out.createVariable("/random/rand_m/m13","f8",('N','dim13','dim3'))
    rand_m14_p = out.createVariable("/random/rand_m/m14","f8",('N','dim14','dim3'))
    rand_m15_p = out.createVariable("/random/rand_m/m15","f8",('N','dim15','dim3'))

    # Write particle properties out
    
    index[:] = ind
    
    Dp[:] = D
    Eip[:] = Ei
    Fip[:] = Fi
    D2_8_p[:] = D2_8
    D9_15_p[:] = D9_15
    
    
    for i in range(Ntot):
        
        rand_p_p[i,:] = rand_p[i]
    
        rand_j1_p[i,:,:] = rand_j[i][0]
        rand_j2_p[i,:,:] = rand_j[i][1]
        rand_j3_p[i,:,:] = rand_j[i][2]
        rand_j4_p[i,:,:] = rand_j[i][3]
        rand_j5_p[i,:,:] = rand_j[i][4]
        rand_j6_p[i,:,:] = rand_j[i][5]
        rand_j7_p[i,:,:] = rand_j[i][6]
        rand_j8_p[i,:,:] = rand_j[i][7]
        rand_j9_p[i,:,:] = rand_j[i][8]
        rand_j10_p[i,:,:] = rand_j[i][9]
        rand_j11_p[i,:,:] = rand_j[i][10]
        rand_j12_p[i,:,:] = rand_j[i][11]
        rand_j13_p[i,:,:] = rand_j[i][12]
        rand_j14_p[i,:,:] = rand_j[i][13]
        rand_j15_p[i,:,:] = rand_j[i][14]
        
        rand_m1_p[i,:,:] = rand_m[i][0]
        rand_m2_p[i,:,:] = rand_m[i][1]
        rand_m3_p[i,:,:] = rand_m[i][2]
        rand_m4_p[i,:,:] = rand_m[i][3]
        rand_m5_p[i,:,:] = rand_m[i][4]
        rand_m6_p[i,:,:] = rand_m[i][5]
        rand_m7_p[i,:,:] = rand_m[i][6]
        rand_m8_p[i,:,:] = rand_m[i][7]
        rand_m9_p[i,:,:] = rand_m[i][8]
        rand_m10_p[i,:,:] = rand_m[i][9]
        rand_m11_p[i,:,:] = rand_m[i][10]
        rand_m12_p[i,:,:] = rand_m[i][11]
        rand_m13_p[i,:,:] = rand_m[i][12]
        rand_m14_p[i,:,:] = rand_m[i][13]
        rand_m15_p[i,:,:] = rand_m[i][14]
        

    out.close()
    
