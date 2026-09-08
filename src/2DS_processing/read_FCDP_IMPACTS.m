function FCDP = read_FCDP_IMPACTS()

data_dir = '/home/edwin.dunnavan/Documents/P3_Data/FCDP/';

fnames = dir(data_dir);


for ff = 3 : length(fnames)

    filename = strcat(data_dir,fnames(ff).name);


    fdate = datetime(ncreadatt(filename,'/','FlightDate'),'InputFormat','MM/dd/yyyy');


    flightname = strcat('f',string(fdate,'yyyyMMdd'));

    FCDP.(flightname).Time = datetime(fdate,'InputFormat','MM/dd/yyyy')+seconds(ncread(filename,'time'));

    FCDP.(flightname).LWC = ncread(filename,'LWC'); % g/m^3
    FCDP.(flightname).Nt = ncread(filename,'NT')./1000; % #/L
    FCDP.(flightname).Dm = ncread(filename,'MMD'); % um
    FCDP.(flightname).Dmv = ncread(filename,'MVD'); % um
    FCDP.(flightname).Dn = ncread(filename,'MND'); % um
    FCDP.(flightname).QC = ncread(filename,'PROBE_QC'); % 0=good, 1 = medium, 2 = bad

    FCDP.(flightname).LWC(FCDP.(flightname).LWC<-900) = NaN;
    FCDP.(flightname).Nt(FCDP.(flightname).Nt<-900) = NaN;
    FCDP.(flightname).Dm(FCDP.(flightname).Dm<-900) = NaN;
    FCDP.(flightname).Dmv(FCDP.(flightname).Dmv<-900) = NaN;
    FCDP.(flightname).Dn(FCDP.(flightname).Dn<-900) = NaN;
    FCDP.(flightname).QC(FCDP.(flightname).QC<-900) = NaN;


end


end