########## HYDROMETEOR VIEWER ##########

'''
To use selectHydroViewer_full.py, just run it from your terminal with this argument structure

TEMPLATE:
python3 selectHydroViewer_full.py Date 2DS Channel StartTime EndTime 48 DMin DMax ARMin ARMax AreaRatioMin AreaRatioMax AngleMin AngleMax InterArival Habit CenterIn Edge

where

Date: Date of IOP in YYYMMDD format
2DS: Instrument (keep set at 2DS)
Channel: Horizontal (i.e., H) or Vertical (i.e., V)
StartTime: Start time of images in hhmmss format
EndTime: End time of images in hhmmss format
DMin: Minimum ellipse Dmajor (in mm)
DMax: Maximum ellipse Dmajor (in mm)
ARMin: Minimum ellipse aspect ratio
ARMax: Maximum ellipse aspect ratio
AreaRatioMin: Minimum ellipse area ratio
AreaRatioMax: Maximum ellipse area ratio
AngleMin: Minimum ellipse angle from the horizontal (in degrees)
AngleMax: Maximum ellipse angle from the horizontal (in degrees)
InterArrival: Minimum interarrival time (in seconds)
Habit: Habit type(s) to use in particle plotting (use commas to specify multiple habits).
        77 - zero image; 67 - center-out image; 116 - tiny; 111- oriented; 108 - linear; 97 - aggregate;
        103 - graupel; 115 - sphere; 104 - hexagonal; 105 - irregular; 100 - dendrite
        all - plots all habits;
CenterIn: (1) If center of particle is within buffer strip, (0) If center of particle is not within buffer strip.
Edge: int
    If particle is touching buffer strip (set to 0 for particle being entirely inside buffer width)

-------------------------------------------------------
Example:
    
    python3 selectHydroViewer_full.py 20230228 2DS H 000000 235959 48 0.5 5.0 0.1 1.0 0.4 1.0 -90 90 1e-5 all 1 0


'''

# IMPORT PACKAGES
import sys
import numpy as np
import xarray as xr
from PIL import Image #, ImageDraw
import matplotlib.pyplot as plt
from matplotlib.patches import Ellipse

from glob import glob

import os

import fnmatch

# IMAGE BUFFER & PLOTTING FUNCTIONS
def probe_defaults(probeName):
    invalidSlice = np.array([-1., -1., -1., -1., -1., -1., -1., -1.])
    if probeName=='2DS' or probeName=='HVPS':
        boundary = np.array([43690, 43690, 43690, 43690, 43690, 43690, 43690, 43690])
        boundaryTime = 0;
        bufferShape = [1700, 128]
    elif probeName=='CIP' or probeName=='PIP':
        boundary = np.array([170, 170, 170, 170, 170, 170, 170, 170])
        boundaryTime = 0;
        bufferShape = [1700, 64]
        
    return boundary, boundaryTime, invalidSlice, bufferShape

def load_partData(inFile, probeName):
    ds1 = xr.open_dataset(inFile)
    # check if rectangular & elliptical fits are part of particle data
    iRecEll = 0
    for varname, da in ds1.data_vars.items():
        if varname=='image_EllipseL':
            iRecEll = 1

    time = (ds1['Time'].values).astype(int)
    frame = (ds1['parent_rec_num'].values).astype(int)
    partNum = (ds1['particle_num'].values).astype(int)
    pos = (ds1['position'].values).astype(int)

    center_in = (ds1['image_center_in'].values).astype(int) # 1 if center in
    entire_in = (ds1['image_touching_edge'].values).astype(int) # 0 if entire in

    xpos = ds1['image_Ellipse_xpos'].values
    ypos = ds1['image_Ellipse_ypos'].values


    length = (ds1['image_length'].values).astype(int)
    longestY = (ds1['image_longest_y'].values).astype(int)
    width = (ds1['image_width'].values).astype(int)
    dmax = ds1['image_diam_minR'].values
    dmax[np.isnan(dmax)] = -1 # set dummy value for particle size if NaN
    if iRecEll==1:
        #drec = ds1['image_RectangleL'].values
        dell = ds1['image_EllipseL'].values
        delw = ds1['image_EllipseW'].values
        ang = ((180./np.pi)*(ds1['image_EllipseAngle'].values))

        AR_ellipse = np.ones_like(delw)
        
        AR_ellipse[dell>0] = delw[dell>0]/dell[dell>0]

    else:
        #drec = np.empty(len(time))*np.nan
        dell = np.empty(len(time))*np.nan
    area = ds1['image_area'].values
    perim = ds1['image_perimeter'].values
    reject = (ds1['image_auto_reject'].values).astype(int)
    habit = (ds1['holroyd_habit'].values).astype(int)
    if probeName=='2DS' or probeName=='HVPS':
        tempTime = ds1['Time_in_seconds'] # time in TAS clock cycles
        intArr = np.zeros(len(tempTime.values))
        intArr[1:] = np.diff(tempTime.values) # time difference between particles
    else:
        intArr = ds1['inter_arrival'].values
    
    return time, frame, partNum, pos, xpos, ypos, center_in, entire_in, length, longestY, width, dmax, dell, delw, ang, AR_ellipse, area, perim, reject, habit, intArr

def get_partInds(time, dmax, AR, AreaRatio, ang, reject, habit, intArr, center_in, entire_in, startTime, endTime, minD, maxD, minAR, maxAR, minArea, maxArea, minAng, maxAng, intArrThresh, rejStatus, habitStatus, centerStatus, entireStatus):

    if rejStatus[0]=='None':
        if habitStatus[0]=='None':
            partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                (AR>=minAR)& (AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)& (ang>=minAng)& (ang<=maxAng)& (intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus))[0]
        else:
            if isinstance(habitStatus, int):
                habitStatus = [habitStatus]

            if len(habitStatus)==1 and habitStatus!='all':
                partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                    (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & (habit==habitStatus[0]))[0]
            elif len(habitStatus)==2:
                partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                    (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & ((habit==habitStatus[0]) | (habit==habitStatus[1])))[0]
            elif len(habitStatus)==3:
                partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                    (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & ((habit==habitStatus[0]) | (habit==habitStatus[1]) |
                                                             (habit==habitStatus[2])))[0]
            elif len(habitStatus)==4:
                partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                    (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & ((habit==habitStatus[0]) | (habit==habitStatus[1]) |
                                                             (habit==habitStatus[2]) | (habit==habitStatus[3])))[0]
            elif habitStatus == 'all':
                partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                    (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & ((habit==habitStatus[0]) | (habit==habitStatus[1]) |
                                                             ((habit==97) | (habit==100)| (habit==103)| (habit==104)| (habit==105)| (habit==108)| (habit==111)| (habit==115))))[0]


    else:
        if isinstance(rejStatus, int):
                rejStatus = [rejStatus]

        if habitStatus[0]=='None':
            if len(rejStatus)==1:
                partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                    (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & (reject==rejStatus[0]))[0]
            elif len(rejStatus)==2:
                partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                    (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & ((reject==rejStatus[0]) | (reject==rejStatus[1])))[0]
            elif len(rejStatus)==3:
                partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                    (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & ((reject==rejStatus[0]) | (reject==rejStatus[1]) |
                                                             (reject==rejStatus[2])))[0]
            elif len(rejStatus)==4:
                partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                    (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & ((reject==rejStatus[0]) | (reject==rejStatus[1]) |
                                                             (reject==rejStatus[2]) | (reject==rejStatus[3])))[0]
        else:
            if isinstance(habitStatus, int):
                habitStatus = [habitStatus]

            if habitStatus=='all':
                if len(rejStatus)==1:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                        (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & 
                                        ((habit==97) | (habit==100)| (habit==103)| (habit==104)| (habit==105)| (habit==108)| (habit==111)| (habit==115)) & (reject==rejStatus[0]))[0]
                elif len(rejStatus)==2:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                       (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)& (intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & 
                                       ((habit==97) | (habit==100)| (habit==103)| (habit==104)| (habit==105)| (habit==108)| (habit==111)| (habit==115)) &
                                        ((reject==rejStatus[0]) | (reject==rejStatus[1])))[0]
                elif len(rejStatus)==3:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                        (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & 
                                        ((habit==97) | (habit==100)| (habit==103)| (habit==104)| (habit==105)| (habit==108)| (habit==111)| (habit==115)) &
                                        ((reject==rejStatus[0]) | (reject==rejStatus[1]) | (reject==rejStatus[2])))[0]
                elif len(rejStatus)==4:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                        (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & 
                                        ((habit==97) | (habit==100)| (habit==103)| (habit==104)| (habit==105)| (habit==108)| (habit==111)| (habit==115)) &
                                        ((reject==rejStatus[0]) | (reject==rejStatus[1]) | (reject==rejStatus[2]) |
                                         (reject==rejStatus[3])))[0]
                

            if len(habitStatus)==1 and habitStatus!='all':
                if len(rejStatus)==1:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                        (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & (habit==habitStatus[0]) & (reject==rejStatus[0]))[0]
                elif len(rejStatus)==2:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                       (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)& (intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & (habit==habitStatus[0]) &
                                        ((reject==rejStatus[0]) | (reject==rejStatus[1])))[0]
                elif len(rejStatus)==3:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                        (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & (habit==habitStatus[0]) &
                                        ((reject==rejStatus[0]) | (reject==rejStatus[1]) | (reject==rejStatus[2])))[0]
                elif len(rejStatus)==4:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                        (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & (habit==habitStatus[0]) &
                                        ((reject==rejStatus[0]) | (reject==rejStatus[1]) | (reject==rejStatus[2]) |
                                         (reject==rejStatus[3])))[0]
            elif len(habitStatus)==2:
                if len(rejStatus)==1:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                        (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & ((habit==habitStatus[0]) | (habit==habitStatus[1])) &
                                        (reject==rejStatus[0]))[0]
                elif len(rejStatus)==2:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                        (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & ((habit==habitStatus[0]) | (habit==habitStatus[1])) &
                                        ((reject==rejStatus[0]) | (reject==rejStatus[1])))[0]
                elif len(rejStatus)==3:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                        (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & ((habit==habitStatus[0]) | (habit==habitStatus[1])) &
                                        ((reject==rejStatus[0]) | (reject==rejStatus[1]) | (reject==rejStatus[2])))[0]
                elif len(rejStatus)==4:
                    partInds = np.where((time>=startTime) & (time<endTime) & (dmax>=minD) & (dmax<maxD) &
                                        (AR>=minAR)&(AR<=maxAR)& (AreaRatio>=minArea)& (AreaRatio<=maxArea)&(ang>=minAng)& (ang<=maxAng)&(intArr>=intArrThresh) &(center_in==centerStatus)&(entire_in==entireStatus) & ((habit==habitStatus[0]) | (habit==habitStatus[1])) &
                                        ((reject==rejStatus[0]) | (reject==rejStatus[1]) | (reject==rejStatus[2]) |
                                         (reject==rejStatus[3])))[0]
                    
    return partInds

def get_imageData(inFile, frameStart):
    ds = xr.open_dataset(inFile)
    data = ds['data'][frameStart-1:frameStart][0].values
    
    return data

def get_slice_endpoints(probeName, buf, boundary, boundaryTime, invalidSlice): # get slice start/end indices, and also for the boundaries
    numPart = 0 # number of particles in buffer
    startInd = [] # index of the start of a particle
    endInd = [] # index of the end of a particle
    boundaryInd = [] # index of the particle boundary (series of 8 consecutive '43690' values)
    
    j = 0
    while (buf[j,0] != -1) and (j+1 < buf.shape[0]):
        if (np.array_equal(buf[j,:],boundary)) and ((buf[j+1,0]==boundaryTime) or (probeName=='CIP') or
                                                   (probeName=='PIP')): # particle boundary
            boundaryInd.append(j)
            if j>0:
                endInd.append(j-1) # index of particle end before the particle boundary (current particle)
                numPart = numPart + 1 # for particle preceeding boundary
            startInd.append(j+2) # index of particle start after the particle boundary (next particle)
        j = j + 1
    
    boundaryInd = np.array(boundaryInd, dtype='int')
    if (boundaryInd.size>0) or (boundaryInd[0]>0): # no boundaries or first boundary after first slice in buffer
        startInd = np.insert(startInd, 0, 0)
    startInd = np.array(startInd, dtype='int')
    
    if boundaryInd[-1]+3 < buf.shape[0]: # particle occurs after last boundary if it's 3rd from last slice in record
        endInd.append(buf.shape[0]-1) # last particle ends at end of buffer
        endInd = np.array(endInd, dtype='int') 
    else:
        endInd = np.array(endInd, dtype='int') # boundary found at very end of record -- no more particles in buffer
        
    return numPart, boundaryInd, startInd, endInd
        
def image_buffer(buf, probeName, boundaryInd): # generate matrix of 1's and 0's from buffer
    if probeName=='2DS' or probeName=='HVPS':
        #boundaryData = np.tile([2,2,1,1], 32) # alternate 1's and 2's for boundary slice (white & cyan pixels)
        boundaryData = np.tile([1,1,1,1], 32) # array of white pixels for boundary slice
        buf[buf==-1] = 0 # change invalid values to 0 (unshadowed segment)
        #buf[buf==-1] = 255 # change invalid values to 255 (unshadowed segment)
        buf = 65535 - buf # 0: shadowed; 1: unshadowed

        # convert decimal to binary (8 image words for each slice)
        imageData = np.ones([1700,128]) # set up image buffer (1 means unshadowed pixels - RGB(255,255,255) is white

        for x in np.arange(buf.shape[0]):
            tempBuf = np.array([np.binary_repr(int(buf[x,0]),16), np.binary_repr(int(buf[x,1]),16),
                                np.binary_repr(int(buf[x,2]),16), np.binary_repr(int(buf[x,3]),16),
                                np.binary_repr(int(buf[x,4]),16), np.binary_repr(int(buf[x,5]),16),
                                np.binary_repr(int(buf[x,6]),16), np.binary_repr(int(buf[x,7]),16)])
            sliceBuf = []
            for y in np.arange((buf.shape[1])*16):
                sliceBuf.append(tempBuf[(np.floor(y/16)).astype(int)][np.mod(y,16)])
            sliceBuf = np.asarray(sliceBuf, dtype='int')
            imageData[x,:] = sliceBuf
    elif probeName=='CIP' or probeName=='PIP':
        #boundaryData = np.tile([2,2,1,1], 16) # alternate 1's and 2's for boundary slice (white & cyan pixels)
        boundaryData = np.tile([1,1,1,1], 16) # array of white pixels for boundary slice
        #buf[buf==-1] = 0 # change invalid values to 0 (unshadowed segment)
        buf[buf==-1] = 255 # change invalid values to 1 (unshadowed segment)
        
        # convert decimal to binary (8 image words for each slice)
        imageData = np.ones([1700,64]) # set up image buffer (1 means unshadowed pixels - RGB(255,255,255) is white

        for x in np.arange(buf.shape[0]):
            tempBuf = np.array([np.binary_repr(int(buf[x,0]),8), np.binary_repr(int(buf[x,1]),8),
                                np.binary_repr(int(buf[x,2]),8), np.binary_repr(int(buf[x,3]),8),
                                np.binary_repr(int(buf[x,4]),8), np.binary_repr(int(buf[x,5]),8),
                                np.binary_repr(int(buf[x,6]),8), np.binary_repr(int(buf[x,7]),8)])
            sliceBuf = []
            for y in np.arange((buf.shape[1])*8):
                sliceBuf.append(tempBuf[(np.floor(y/8)).astype(int)][np.mod(y,8)])
            sliceBuf = np.asarray(sliceBuf, dtype='int')
            imageData[x,:] = sliceBuf

    imageData[boundaryInd,:] = boundaryData # write in boundary slice
    
    if boundaryInd[-1]+1 < buf.shape[0]:
        imageData[boundaryInd+1,:] = 1
    else:
        imageData[boundaryInd[0:-2]+1,:] = 1
    
    return (imageData)

# ===== MAIN SCRIPT ===== #
'''
Main script that calls subroutines to plot particles meeting user-specified criteria.

Parameters
----------
dateFile: str
    Date of IOP in yyyymmdd.
probeName: str
    Probe type ('2DS' or 'HVPS'). Used in determining image decryption methods specific to the manufacturer.
probeOrient: str
    Probe Orientation. Either 'H' or 'V'.
startTime: str
    Flight time to begin the plotting job in HHMMSS.
endTime: str
    Flight time to end the plotting job in HHMMSS.
rejStatus: float tuple
    Array of rejection status values (from image_auto_reject variable) of which to plot particles.
        48 - accepted; 97 - aspect ratio > 6; 116 - aspect ratio > 5 + image touching edge;
        112 - < 25% shadowed diodes in rectangle encompassing particle; 104, 72, 117 - hollow particle;
        115 - split image; 122 - zero area image; 102 - zero area image
minD: float
    Minimum particle size (mm) of which to plot particles.
maxD: float
    Maximum particle size (mm) of which to plot particles.
minAR: float
    Minimum particle ellipse fit aspect ratio of which to plot particles
maxAR: float
    Maximum particle ellipse fit aspect ratio of which to plot particles
minAng: float
    Minimum particle ellipse fit angle (in degrees) of which to plot particles
maxAng: float
    Maximum particle ellipse fit angle (in degrees) of which to plot particles
intArrThresh: float
    Minimum inter-arrival time (s) of which to plot particles.
habitStatus: float tuple
    Array of habit type to use in particle plotting.
        77 - zero image; 67 - center-out image; 116 - tiny; 111- oriented; 108 - linear; 97 - aggregate;
        103 - graupel; 115 - sphere; 104 - hexagonal; 105 - irregular; 100 - dendrite
        all - plots all habits;
centerStatus: int
    If center of particle is within buffer strip
entireStatus: int
    If particle is touching buffer strip (set to 0 for particle being entirely inside buffer width)

'''
dateFile = sys.argv[1]
probeName = sys.argv[2]
probeOrient = sys.argv[3]
startTime = sys.argv[4]
endTime = sys.argv[5]
rejStatus = sys.argv[6]
minD = sys.argv[7]
maxD = sys.argv[8]
minAR = sys.argv[9]
maxAR = sys.argv[10]
minArea = sys.argv[11]
maxArea = sys.argv[12]
minAng = sys.argv[13]
maxAng = sys.argv[14]
intArrThresh = sys.argv[15]
habitStatus = sys.argv[16]
centerStatus = sys.argv[17]
entireStatus = sys.argv[18]


# ---------- Initialize Particle Criteria ----------
#if startTime=='None':
#    startTime = int(time[0])
#else:
startTime = int(startTime)

#if endTime=='None':
#    endTime = int(time[-1])
#else:
endTime = int(endTime)

if rejStatus!='None':
    rejStatus = np.array(rejStatus.split(','), dtype=np.uint8)

if minD=='None':
    minD = 0.
else:
    minD = np.float(minD)

if maxD=='None':
    maxD = 999.
else:
    maxD = np.float(maxD)

if minAR=='None':
    minAR = 0.
else:
    minAR = np.float(minAR)

if maxAR=='None':
    maxAR = 1.0
else:
    maxAR = np.float(maxAR)

if minArea=='None':
    minArea = 0.
else:
    minArea = np.float(minArea)

if maxArea=='None':
    maxArea = 1.0
else:
    maxArea = np.float(maxArea)

if minAng=='None':
    minAng = -90.
else:
    minAng = np.float(minAng)

if maxAng=='None':
    maxAng = 90.
else:
    maxAng = np.float(maxAng)

if intArrThresh=='None':
    intArrThresh = -999.
else:
    intArrThresh = np.float(intArrThresh)
    
if habitStatus!='None' and habitStatus!='all':
    habitStatus = np.array(habitStatus.split(','), dtype=np.uint8)

if centerStatus=='None':
    centerStatus = 0
else:
    centerStatus = np.int(centerStatus)

if entireStatus=='None':
    entireStatus = 1
else:
    entireStatus = np.int(entireStatus)   

print('----- USER DEFINED VALUES -----')
print('startTime = {}; endTime = {}\nminD = {} mm; maxD = {} mm\nminAR={}; maxAR={};\nminAreaRatio={}; maxAreaRatio={};\nminAng={};maxAng={};\nintArrThresh = {} s;\ncenter_in = {}; entire_in = {},\n rejStatus = {}; habitStatus = {}'
      .format(startTime, endTime, minD, maxD, minAR, maxAR, minArea, maxArea,minAng, maxAng, intArrThresh,centerStatus, entireStatus, rejStatus, habitStatus))
print('-------------------------------')
# --------------------------------------------------
    

if probeName=='2DS':
    diodesize = 0.01

if probeName == 'HVPS':
    diodesize = 0.15

plt.ioff()

[boundary, boundaryTime, invalidSlice, bufferShape] = probe_defaults(probeName)

# Find all proc files with corresponding imgdata 

# HARDCODE IN RELATIVE PATH
IMPACTS_dir = '/localdata/edunnavan/P3_probe_data/IMPACTS/'

#from pathlib import Path

#github_dir = Path(__file__).resolve().parent.parent

#IMPACTS_dir = str(github_dir / 'Data' / 'sample_raw' )


if probeName=='2DS':

   fileDir = IMPACTS_dir+dateFile+'/'+probeName+'/'

   #proc_files = glob(fileDir+'proc3.*'+probeOrient+'.nc')


   proc_files = glob(fileDir+'proc_5.*'+probeOrient+'.nc')


   plotDirectory = IMPACTS_dir+dateFile+'/'+probeName+'/Images/'


elif probeName=='HVPS':


   if probeOrient == 'H':

      HVPS_name = 'HVPSA'

   elif probeOrient == 'V':

      HVPS_name = 'HVPSB'


   fileDir = IMPACTS_dir+dateFile+'/'+probeName+'/'+HVPS_name+'/'

   plotDirectory = IMPACTS_dir+dateFile+'/'+probeName+'/'+HVPS_name+'/Images/'

   #proc_files = glob(fileDir+'proc5.*.nc')

   proc_files = glob(fileDir+'proc_5.*.nc')

if not os.path.isdir(plotDirectory):
    os.mkdir(plotDirectory)

# Put in loop here
for ff in range(len(proc_files)):

    particleFile = proc_files[ff]
    
    #timestamp_temp = particleFile[particleFile.find('proc3.')+6:particleFile.find('proc3.')+18]
    
    #order_temp = particleFile[particleFile.find(timestamp_temp+'.')+13:particleFile.find('.'+probeName)]
    
    #timestamp_temp = particleFile[particleFile.find('proc5.')+6:particleFile.find('proc5.')+14]

    # proc_new
    #timestamp_temp = particleFile[particleFile.find('proc_new.')+9:particleFile.find('proc_5.')+21]

    timestamp_temp = particleFile[particleFile.find('proc_5.')+7:particleFile.find('proc_5.')+19]

    #order_temp = particleFile[particleFile.find(timestamp_temp+'.')+9:particleFile.find('.'+probeName)]

    # proc_new
    #order_temp = particleFile[particleFile.find(timestamp_temp+'.')+13:particleFile.find('.'+probeName)]

    order_temp = particleFile[particleFile.find(timestamp_temp+'.')+13:particleFile.find('.'+probeName)]

    if probeName=='2DS':
        #imageFile = fileDir+'imgData_'+timestamp_temp+'_'+order_temp+'.'+probeOrient+'.nc'

        imageFile = fileDir+'imgData_'+timestamp_temp+'.2DS_'+order_temp+'.'+probeOrient+'.nc'

    elif probeName=='HVPS':
        imageFile = fileDir+'imgData_'+timestamp_temp+'.HVPS_'+order_temp+'.V.nc'
        #imageFile = fileDir+'imgData_'+dateFile+'_'+order_temp+'.HVPS.V.nc'

    print('Particle File: ',particleFile)
    print('ImgData File: ',imageFile)

    [time, frame, partNum, pos, xpos, ypos, center_in, entire_in, length, longestY, width, dmax, dell, delw, ang, AR, area, perim, reject, habit, intArr] = load_partData(
        particleFile, probeName) # load Particle Data
    
    AreaRatio = area/(0.25*np.pi*dell*delw)

    # particle indices meeting user criteria
    partInds = get_partInds(time, dmax, AR, AreaRatio, ang, reject, habit, intArr, center_in, entire_in, startTime, endTime, minD, maxD, minAR, maxAR,minArea,maxArea, minAng, maxAng, intArrThresh, rejStatus,
                            habitStatus,centerStatus,entireStatus)
    frameInds = frame[partInds] # frame number of particles meeting user criteria
    partnumInds = partNum[partInds]
    timeInds = time[partInds]

    if len(partInds)==0:
        continue
    
    print('Found {} particles that match your criteria.'.format(len(partInds)))
    print('Constructing image buffers. Estimating ~ {} files will be generated.'.format(
        int(np.ceil((np.sum(length[partInds])+len(partInds))/1700))))
    
    uniqueFrames = np.unique(frameInds)
    
    imgPointer = 0
    imgNum = 1
    imgNew = np.ones(bufferShape) # set up image buffer (1's mean unshadowed pixels)
    
    
    #print('uniqueFrames = {}'.format(uniqueFrames))
    
    ellipse = []
    xcen = []
    ycen = []

    num_iter = 0

    part_count = 0

    img_count = 0
    
    
    # LOOP THROUGH FRAMES FOR PLOTTING
    for iter in range(len(uniqueFrames)):
        partSubinds = partInds[frameInds==uniqueFrames[iter]] # good particles for current frame in plotting loop
        partnumSubinds = partnumInds[frameInds==uniqueFrames[iter]]
        timeSubinds = timeInds[frameInds==uniqueFrames[iter]]
        data = get_imageData(imageFile, uniqueFrames[iter])
        [partCount, boundaryInd, partStart, partEnd] = get_slice_endpoints(probeName, data, boundary, boundaryTime, invalidSlice)
        img = image_buffer(data, probeName, boundaryInd)    
    
        print('Number of ellipses = {}'.format(len(ellipse)))
        print('partSubinds = {}'.format(partSubinds))
        print('timeSubinds = {}'.format(timeSubinds))
    
        for particles in range(len(partSubinds)): # Loop through all particles in frame

            #print('particles={}/{} | iter = {}/{} / switch = {}'.format(particles+1,len(partSubinds),iter+1,len(uniqueFrames),((iter+1==len(uniqueFrames)) and (particles+1==len(partSubinds)))))
    
            img_sub = np.array(255*img[partStart[partnumSubinds[particles]-1]:partEnd[partnumSubinds[particles]-1]+2,:],
                               dtype=np.uint8)
            
            if (imgPointer+img_sub.shape[0]<bufferShape[0]): # current particle fits within buffer
                if imgPointer==0: # indicates we're starting a new image buffer to plot
                    imgTimeStart = timeSubinds[particles]
                imgNew[imgPointer:imgPointer+img_sub.shape[0],:] = img_sub

                img_count += 1
    
                ellipse.append(Ellipse(xy=(xpos[partSubinds[particles]]+imgPointer,ypos[partSubinds[particles]]),\
                                           width = dell[partSubinds[particles]]/diodesize,height=delw[partSubinds[particles]]/diodesize,\
                                           angle=(ang[partSubinds[particles]]),fill=None,edgecolor='red'))

                xcen.append(xpos[partSubinds[particles]]+imgPointer)
                ycen.append(ypos[partSubinds[particles]])
    
                imgPointer = imgPointer + img_sub.shape[0]; # advance plotting strip pointer
    
            if ((imgPointer+img_sub.shape[0]>=bufferShape[0]) or (np.remainder(imgNum+1,1000)==0) or ((iter+1==len(uniqueFrames)) and (particles+1==len(partSubinds)))): # current particle DOES NOT fit within buffer, save current one and begin new one
                imgTimeEnd = timeSubinds[particles]
    
                #fileStr = '{}{}fr{:02d}.{}_{}.pdf'.format(plotDirectory, probeName, imgNum, imgTimeStart, imgTimeEnd)
    
                fileStr_base = '{}{}_{}_{}_{}_{}_img'.format(probeName,probeOrient,dateFile,habitStatus,imgTimeStart,imgTimeEnd)

                count_imgs = len(fnmatch.filter(os.listdir(plotDirectory),fileStr_base+'*'))

                fileStr = plotDirectory+fileStr_base+str(count_imgs+1)

                image = Image.fromarray(imgNew.T.astype(np.uint8))
                fig,ax = plt.subplots(figsize=(1700/plt.rcParams['figure.dpi'],128/plt.rcParams['figure.dpi']))
                
                ax.imshow(image,cmap='gray',origin='lower',resample=False)
                #ax.invert_yaxis()
                #ax.invert_xaxis()
                plt.axis('off')
                plt.tight_layout()
                print('Saving image to file: {}'.format(fileStr))
                print('Total Number of ellipses = {}'.format(len(ellipse)))
                print('Total number of images = {}'.format(img_count))
                # Plot all ellipses for particles in frame
    
                for ee in ellipse:
    
                    ax.add_artist(ee)
    
                fig.savefig(fileStr,bbox_inches='tight',pad_inches=0,format='pdf')
                plt.close(fig)
                imgPointer = 0; imgNum = imgNum + 1; imgNew = np.ones(bufferShape)
    
                imgTimeStart = timeSubinds[particles]
                #imgNew[imgPointer:imgPointer+img_sub.shape[0],:] = img_sub
                imgPointer = imgPointer + img_sub.shape[0]
    
    
                ellipse = []
                xcen = []
                ycen = []    

                img_count = 0
    

                num_iter += 1
    
            if np.remainder(imgNum+1,1000)==0:

                #if num_iter==0:

                print('Finished plotting buffer # {}.'.format(imgNum))
