function FCDP = importfile_FCDP_IMPACTS(fdate)

window = 1;

data_dir = '/home/edwin.dunnavan/Documents/P3_Data/FCDP/';

filename = strcat(data_dir,'IMPACTS_FastCDP-P3_',fdate,'_sizedistributions_v01.nc');


%flightname = strcat('f',fdate);

FCDP.Time = datetime(fdate,'InputFormat','yyyyMMdd')+seconds(ncread(filename,'time'));

FCDP.LWC = ncread(filename,'LWC'); % g/m^3
FCDP.Nt = ncread(filename,'NT')./1000; % #/L
FCDP.Dm = ncread(filename,'MMD'); % um
FCDP.Dmv = ncread(filename,'MVD'); % um
FCDP.Dn = ncread(filename,'MND'); % um
FCDP.QC = ncread(filename,'PROBE_QC'); % 0=good, 1 = medium, 2 = bad

FCDP.LWC(FCDP.LWC<-900) = NaN;
FCDP.Nt(FCDP.Nt<-900) = NaN;
FCDP.Dm(FCDP.Dm<-900) = NaN;
FCDP.Dmv(FCDP.Dmv<-900) = NaN;
FCDP.Dn(FCDP.Dn<-900) = NaN;
FCDP.QC(FCDP.QC<-900) = NaN;

FCDP.LWC = movmean(FCDP.LWC,window,'omitnan');
FCDP.Nt = movmean(FCDP.Nt,window,'omitnan');
FCDP.Dm = movmean(FCDP.Dm,window,'omitnan');
FCDP.Dmv = movmean(FCDP.Dmv,window,'omitnan');
FCDP.Dn = movmean(FCDP.Dn,window,'omitnan');

end