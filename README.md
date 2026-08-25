<p align="center">
    <img src="assets/P3_WFF_IMPACTS_with_column_ex_rotated_newcoords.png" alt="P3 aircraft image with 2D-S location/coordinates and STL/ellipsoid projection coordinates." width="100%">
<p>

# IMPACTS_AMT_Study
This repository contains source code, in situ 2D-S measurements, 
and plotting/utilities for the *Atmospheric Measurement Techniques* article
entitled "Universality of ice particle shapes and orientations as revealed by
the 2D-S in situ optical array probe."

## How generate figures
Figures 9 and 13 can be generated using the matlab script "IMPACTS_boxchart.m" whereas
figures 

## How to load and use the ellipse fit data
The ellipse fit data is available in the /Data directory as a .mat file. This data
can be loaded with Matlab
```matlab
load('Data/processed/IMPACTS_EllipseFits_2020_2023.mat')
```
The data can also be read using Python. However, due to the structure nature of the 
.mat file, it is easiest to convert the matlab structure to a dictionary (Python)
structure using the lightweight pymatreader library which can be installed using either pip

```bash
pip install pymatreader
```

or with conda
```bash
conda install pymatreader
```
The file can then be read in as follows:
```python
from pymatreader import read_mat
m = read_mat('./Data/processed/IMPACTS_EllipseFits_2020_2023.mat')
IMPACTS = m['m']
del m
```
The IMPACTS data is structured as follows:
```text
m/
├── f20200118
├── f20200125
├── f20200201
├── ...
```
where each field starting with "f" represents a separate IOP flight (26 flights/fields in total).

For each flight/field, there are several additional fields corresponding to processing attributes,
measurements from other probes, environmental probe measurements interpolated onto the 2D-S timeseries,
and the 2D-S H/V channel ellipse fit particle-by-particle data. These fields appear as (for example)
```text
f20200220/
├── FCDP
├── P3
├── TwoDS
├── H
├── V
```
"FCDP" has the FCDP bulk size distribution measurements such as liquid water content (LWC)
and number concentration (NT) timeseries. The "P3" field has the environmental parameters measured
onboard the P3 aircraft including for example temperature (Static_Air_Temp) and altitude above mean
sea level (Alt_MSL). The "TwoDS" field has  

## How to create new STL models

## How to generate a folder of rotated/projected STL particles

## How to read simulated STL/ellipsoid models and plot figures
There are two steps to reading in a folder of STL modeled particles. The first
is to read in the folder 

```matlab
particle_folder = './Data/Simulation_Dendrite_2/IMPACTS_2020_N2e5_habit/';
stemp = read_stl_data('./Simulations/Simulation_Dendrite_2/IMPACTS_2020_N2e5_habit/');
```
