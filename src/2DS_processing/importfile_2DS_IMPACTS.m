function TwoDS = importfile_2DS_IMPACTS(fdate)

window = 1;

data_dir = '/home/edwin.dunnavan/Documents/P3_Data/2DS/';

filename_H = strcat(data_dir,'IMPACTS_2DSH-P3_',fdate,'_sizedistributions_v01.nc');
filename_V = strcat(data_dir,'IMPACTS_2DSV-P3_',fdate,'_sizedistributions_v01.nc');

TwoDS.H.Time = datetime(fdate,'InputFormat','yyyyMMdd')+seconds(ncread(filename_H,'time'));
TwoDS.V.Time = datetime(fdate,'InputFormat','yyyyMMdd')+seconds(ncread(filename_V,'time'));

TwoDS.H.IWC = ncread(filename_H,'IWC'); % g/m^3
TwoDS.H.Nt = ncread(filename_H,'NT')./1000; % #/L
TwoDS.H.Dm = ncread(filename_H,'MMD')./1000; % mm
TwoDS.H.Dmv = ncread(filename_H,'MVD')./1000; % mm
TwoDS.H.Dn = ncread(filename_H,'MND')./1000; % mm
TwoDS.H.QC = ncread(filename_H,'PROBE_QC'); % 0=good, 1 = medium, 2 = bad

TwoDS.V.IWC = ncread(filename_V,'IWC'); % g/m^3
TwoDS.V.Nt = ncread(filename_V,'NT')./1000; % #/L
TwoDS.V.Dm = ncread(filename_V,'MMD')./1000; % mm
TwoDS.V.Dmv = ncread(filename_V,'MVD')./1000; % mm
TwoDS.V.Dn = ncread(filename_V,'MND')./1000; % mm
TwoDS.V.QC = ncread(filename_V,'PROBE_QC'); % 0=good, 1 = medium, 2 = bad

TwoDS.H.IWC(TwoDS.H.IWC<0) = NaN;
TwoDS.H.Nt(TwoDS.H.Nt<0) = NaN;
TwoDS.H.Dm(TwoDS.H.Dm<0) = NaN;
TwoDS.H.Dmv(TwoDS.H.Dmv<0) = NaN;
TwoDS.H.Dn(TwoDS.H.Dn<0) = NaN;

TwoDS.V.IWC(TwoDS.V.IWC<0) = NaN;
TwoDS.V.Nt(TwoDS.V.Nt<0) = NaN;
TwoDS.V.Dm(TwoDS.V.Dm<0) = NaN;
TwoDS.V.Dmv(TwoDS.V.Dmv<0) = NaN;
TwoDS.V.Dn(TwoDS.V.Dn<0) = NaN;

TwoDS.H.IWC = movmean(TwoDS.H.IWC,window,'omitnan');
TwoDS.H.Nt = movmean(TwoDS.H.Nt,window,'omitnan');
TwoDS.H.Dm = movmean(TwoDS.H.Dm,window,'omitnan');
TwoDS.H.Dmv = movmean(TwoDS.H.Dmv,window,'omitnan');
TwoDS.H.Dn = movmean(TwoDS.H.Dn,window,'omitnan');

TwoDS.V.IWC = movmean(TwoDS.V.IWC,window,'omitnan');
TwoDS.V.Nt = movmean(TwoDS.V.Nt,window,'omitnan');
TwoDS.V.Dm = movmean(TwoDS.V.Dm,window,'omitnan');
TwoDS.V.Dmv = movmean(TwoDS.V.Dmv,window,'omitnan');
TwoDS.V.Dn = movmean(TwoDS.V.Dn,window,'omitnan');


end