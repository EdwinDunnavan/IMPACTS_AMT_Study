function Merged = importfile_Merged_IMPACTS(fdate)

window = 1;

data_dir = '/home/edwin.dunnavan/Documents/P3_Data/Merged/';

filename_H = strcat(data_dir,'Merged_Horizontal/IMPACTS_MergedHorizontal-P3_',fdate,'_sizedistributions_v01.nc');

if isfile(filename_H)
Merged.H.Time = datetime(fdate,'InputFormat','yyyyMMdd')+seconds(ncread(filename_H,'time'));
Merged.H.IWC = ncread(filename_H,'IWC'); % g/m^3
Merged.H.Nt = ncread(filename_H,'NT')./1000; % #/L
Merged.H.Dm = ncread(filename_H,'MMD')./1000; % mm
Merged.H.Dmv = ncread(filename_H,'MVD')./1000; % mm
Merged.H.Dn = ncread(filename_H,'MND')./1000; % mm
Merged.H.QC = ncread(filename_H,'PROBE_QC'); % 0=good, 1 = medium, 2 = bad
Merged.H.IWC(Merged.H.IWC<0) = NaN;
Merged.H.Nt(Merged.H.Nt<0) = NaN;
Merged.H.Dm(Merged.H.Dm<0) = NaN;
Merged.H.Dmv(Merged.H.Dmv<0) = NaN;
Merged.H.Dn(Merged.H.Dn<0) = NaN;
Merged.H.IWC = movmean(Merged.H.IWC,window,'omitnan');
Merged.H.Nt = movmean(Merged.H.Nt,window,'omitnan');
Merged.H.Dm = movmean(Merged.H.Dm,window,'omitnan');
Merged.H.Dmv = movmean(Merged.H.Dmv,window,'omitnan');
Merged.H.Dn = movmean(Merged.H.Dn,window,'omitnan');
else
Merged.H = struct();
end


filename_V = strcat(data_dir,'Merged_Vertical/IMPACTS_MergedVertical-P3_',fdate,'_sizedistributions_v01.nc');
if isfile(filename_V)
Merged.V.Time = datetime(fdate,'InputFormat','yyyyMMdd')+seconds(ncread(filename_V,'time'));
Merged.V.IWC = ncread(filename_V,'IWC'); % g/m^3
Merged.V.Nt = ncread(filename_V,'NT')./1000; % #/L
Merged.V.Dm = ncread(filename_V,'MMD')./1000; % um
Merged.V.Dmv = ncread(filename_V,'MVD')./1000; % um
Merged.V.Dn = ncread(filename_V,'MND')./1000; % um
Merged.V.QC = ncread(filename_V,'PROBE_QC'); % 0=good, 1 = medium, 2 = bad
Merged.V.IWC(Merged.V.IWC<0) = NaN;
Merged.V.Nt(Merged.V.Nt<0) = NaN;
Merged.V.Dm(Merged.V.Dm<0) = NaN;
Merged.V.Dmv(Merged.V.Dmv<0) = NaN;
Merged.V.Dn(Merged.V.Dn<0) = NaN;
Merged.V.IWC = movmean(Merged.V.IWC,window,'omitnan');
Merged.V.Nt = movmean(Merged.V.Nt,window,'omitnan');
Merged.V.Dm = movmean(Merged.V.Dm,window,'omitnan');
Merged.V.Dmv = movmean(Merged.V.Dmv,window,'omitnan');
Merged.V.Dn = movmean(Merged.V.Dn,window,'omitnan');
else

    Merged.V = struct();

end


end