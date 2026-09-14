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
from SHPSG import SHPSG_fixed

import os

from pathlib import Path

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


if __name__ == '__main__':
    
    # Initialize the paths
    paths = get_project_paths()

    size_switch = 'random'
    
    output_folder = 'Irregular_10k_random_NEW'
    
    npar = 10000 # particle number for each parameter group
    
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
    
    
    else:
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
    
    # Generate particle characteristics
    for i in range(npar):
        
        print('Creating Particle {} out of {}'.format(i+1,npar))
    
        # random generate SH coefficients
        coeff = SHPSG_fixed(Ei[i],Fi[i],D2_8[i],D9_15[i],rand_j[i],rand_m[i],rand_p[i])
    
        #coeff = SHPSG_fixed(Ei[i],Fi[i],D2_8[i],D9_15[i],rand_j[0],rand_m[0],rand_p[0])
    
        # convert to spherical coordinates
        stlpath = data_folder+'particle_'+str(i+1)+'_orig.stl'
    
        # export to stl files
        sh2stl(coeff, sph_cor, vertices, faces,stlpath)
        
    # Save particle parameters
    WritePartNetcdf(data_folder+'particle_params.nc',D,Ei,Fi,D2_8,D9_15,rand_j,rand_m,rand_p)
    
    
