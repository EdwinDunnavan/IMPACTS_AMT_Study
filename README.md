<p align="center">
    <img src="assets/P3_WFF_IMPACTS_with_column_ex_rotated_newcoords.png" alt="P3 aircraft image with 2D-S location/coordinates and STL/ellipsoid projection coordinates." width="100%">
<p>

# IMPACTS_AMT_Study
This repository contains source code, in situ 2D-S measurements, 
and plotting/utilities for the *Atmospheric Measurement Techniques* article
entitled "Universality of ice particle shapes and orientations as revealed by
the 2D-S in situ optical array probe."

## How to generate figures from AMT paper
Figure 6 can be generated with the "plot_habit_fraction_timeseries.m" script, 
Figures 9 and 13 can be generated using the matlab script "IMPACTS_boxchart.m". 
Figures 10, 11, 12, and 14 can be generated directly from "generate_IMPACTS_figures.m".
Comparison ellipse fit joint distributions can be generated    

## How to load and use the ellipse fit data
The ellipse fit data is available in the /Data directory as a .mat file. This data
can be loaded with Matlab
```matlab
load('Data/processed/IMPACTS_EllipseFits_2020_2023.mat')
```
The data can also be read using Python. However, due to the structure format of the 
.mat file, it is easiest to convert the matlab structure to a Python dictionary
using the lightweight pymatreader library which can be installed using either pip

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
sea level (Alt_MSL). The "TwoDS" field has the original H and V channel bulk size distribution parameters 
such as mean volume diameter (Dmv), number concentration (Nt), and ice water content (IWC). The fields
"H" and "V", corresponding to the 2D-S H and V channels, have both the particle-by-particle ellipse fit 
data but also the time-interpolated bulk size distribution, habit fractions, and environmental parameters as well.  

## How to create new STL models

There are two ways to create a new directory of STL models. The first approach is to 
use the "generate_hexagonal.m" Matlab script which creates hexagonal columns with
sizes and aspect ratios governed by a gamma size distribution and various parameterizations,
respectively. The second STL generation method is with the use of the SHPSG library
() which is modified and included in this repository in /src/Ellipsoid_STL_projections/STL_generation/. 
The easiest way to create a directory of randomly generated "irregular" particles is to run the
"SHPSG_IMPACTS.py" python script. Users can activate the OAP_venv virtual environment and then directly
run the script after modifying the IMPACTS_SHPSG.py parameters

```bash
source ./environments/bin/activate
cd ./src/Ellipsoid_STL_projections/STL_generation
python3 SPSG_IMPACTS.py
```
  
## How to generate a folder of rotated/projected STL particles

## How to read simulated STL/ellipsoid models and plot figures
There are two steps to reading in a folder of STL modeled particles. The first
is to read in the folder of STL models with "read_stl_data.m" 

```matlab
particle_folder = './Data/Simulation_Dendrite_2/IMPACTS_2020_N2e5_habit/';
stemp = read_stl_data(particle_folder);
```

The output variable (stemp) has


## How to produce 2D-S buffer strip images

Buffer strip images with fitted ellipses such as shown in Figure 4 and Figure 8
can be generated with the "select_Hydroviewer_full.py" python code in 
/scripts/Hydroviewer/. Please note that only a sample set of netcdf 2D-S diode files
are included in /Data/sample_raw/. To generate buffer strips based on particle criteria,
users can use the virtual environment in environments/OAP_images_venv.
```bash
source environments/OAP_images_venv/bin/activate
```
Then, users can generate buffer strips by using inline commands with python

```python
python3 select_Hydroviewer_full.py 20200220 2DS H 000000 235959 48 0.5 3.0 0.2 1.0 0.4 1.0 -90 90 1e-5 all 1 0
```
