% read_impacts_ellipse.m

%function m = read_impacts_ellipse(fname,probe_type,pos_switch,varargin)

function m = read_impacts_ellipse(fdate,probe_type,pos_switch,varargin)

fdir = '/localdata/edunnavan/P3_probe_data/IMPACTS/';

m = struct;

m.P3 = importfile_P3_metnav(fdate);
m.TwoDS = importfile_2DS_IMPACTS(fdate);
m.FCDP = importfile_FCDP_IMPACTS(fdate);
m.Merged = importfile_Merged_IMPACTS(fdate);


if strcmp(probe_type,'2DS')

    m.Dthresh = 0.3;
    m.ar_thresh = 0.1; % Based on what Joe does; this helps get rid of apparently nonphysical streaks.
    m.iat_thresh = 1e-5;
    m.NPixel_thresh = 800;
    m.area_thresh = 0.2;

    m.pos_switch = pos_switch;

    m.pixel_size = 0.01;

    %files_H = dir(strcat(fdir,fdate,'/',probe_type,'/','proc3.',fdate(3:4),'*',probe_type,'.H*.nc'));
    %files_V = dir(strcat(fdir,fdate,'/',probe_type,'/','proc3.',fdate(3:4),'*',probe_type,'.V*.nc')); 

    %files_H = dir(strcat(fdir,fdate,'/',probe_type,'/','proc_new.',fdate(3:4),'*',probe_type,'.H*.nc'));
    %files_V = dir(strcat(fdir,fdate,'/',probe_type,'/','proc_new.',fdate(3:4),'*',probe_type,'.V*.nc')); 

    files_H = dir(strcat(fdir,fdate,'/',probe_type,'/','proc_5.',fdate(3:4),'*',probe_type,'.H*.nc'));
    files_V = dir(strcat(fdir,fdate,'/',probe_type,'/','proc_5.',fdate(3:4),'*',probe_type,'.V*.nc')); 

elseif strcmp(probe_type,'HVPS')

    m.Dthresh = 1.0;
    m.ar_thresh = 0.1; % Based on what Joe does; this helps get rid of apparently nonphysical streaks.
    m.iat_thresh = 10^(-6);
    m.NPixel_thresh = 150;
    m.area_thresh = 0.4;

    m.pos_switch = pos_switch;

    m.pixel_size = 0.15;

    %files_H = dir(strcat(fdir,fdate,'/',probe_type,'/HVPSA/','proc3.',fdate(3:4),'*',probe_type,'A*.nc'));
    %files_V = dir(strcat(fdir,fdate,'/',probe_type,'/HVPSB/','proc3.',fdate(3:4),'*',probe_type,'B*.nc'));

    files_H = dir(strcat(fdir,fdate,'/',probe_type,'/HVPSA/','proc_new.',fdate(3:4),'*',probe_type,'A*.nc'));
    files_V = dir(strcat(fdir,fdate,'/',probe_type,'/HVPSB/','proc_new.',fdate(3:4),'*',probe_type,'B*.nc'));

end


  fH_names = strcat({files_H.folder},'/',{files_H.name});

  m.H = read_impacts_netcdf(fH_names,m,varargin);

  fV_names = strcat({files_V.folder},'/',{files_V.name});

  m.V = read_impacts_netcdf(fV_names,m,varargin);


  m.H.IWC = interp1(m.TwoDS.H.Time(~isnan(m.TwoDS.H.IWC)),m.TwoDS.H.IWC(~isnan(m.TwoDS.H.IWC)),m.H.time,'nearest');
  m.V.IWC = interp1(m.TwoDS.V.Time(~isnan(m.TwoDS.V.IWC)),m.TwoDS.V.IWC(~isnan(m.TwoDS.V.IWC)),m.V.time,'nearest');

  m.H.Dmv = interp1(m.TwoDS.H.Time(~isnan(m.TwoDS.H.Dmv)),m.TwoDS.H.Dmv(~isnan(m.TwoDS.H.Dmv)),m.H.time,'nearest');
  m.V.Dmv = interp1(m.TwoDS.V.Time(~isnan(m.TwoDS.V.Dmv)),m.TwoDS.V.Dmv(~isnan(m.TwoDS.V.Dmv)),m.V.time,'nearest');

  m.H.Dm = interp1(m.TwoDS.H.Time(~isnan(m.TwoDS.H.Dm)),m.TwoDS.H.Dm(~isnan(m.TwoDS.H.Dm)),m.H.time,'nearest');
  m.V.Dm = interp1(m.TwoDS.V.Time(~isnan(m.TwoDS.V.Dm)),m.TwoDS.V.Dm(~isnan(m.TwoDS.V.Dm)),m.V.time,'nearest');

  m.H.Nt = interp1(m.TwoDS.H.Time(~isnan(m.TwoDS.H.Nt)),m.TwoDS.H.Nt(~isnan(m.TwoDS.H.Nt)),m.H.time,'nearest');
  m.V.Nt = interp1(m.TwoDS.V.Time(~isnan(m.TwoDS.V.Nt)),m.TwoDS.V.Nt(~isnan(m.TwoDS.V.Nt)),m.V.time,'nearest');

end



function mH = read_impacts_netcdf(file_total,m,varargin)

avg_window = 5; % in minutes

mH = struct;

mH.date = [];
mH.Time = [];
mH.msec = [];
mH.seconds = [];
mH.Dmajor = [];
mH.Dmax = [];
mH.AR = [];
mH.area_ratio = [];
mH.EllipAng = [];
mH.habit = [];
mH.NPixels = [];
mH.iat = [];
mH.numSub = [];
mH.perimeter = [];
mH.fineDetail = [];
mH.circularity = [];

for ftemp = file_total

    fname = ftemp{1};

date = ncread(fname,'Date');

edge = ncread(fname,'image_touching_edge');
center = ncread(fname,'image_center_in');
reject = ncread(fname,'image_auto_reject');
iat = ncread(fname,'inter_arrival');
fineDetail = ncread(fname,'fine_detail_ratio');

Time = ncread(fname,'Time');
msec = ncread(fname,'msec');

hh = floor(double(Time)./10000);
mm = floor((double(Time)-hh.*10000)./100);
ss = floor((double(Time)-hh.*10000-mm.*100));

seconds = hh.*3600 + mm.*60 + ss + double(msec)./1000;

perimeter = ncread(fname,'image_perimeter');

area = ncread(fname,'image_area');

NPixels = area./m.pixel_size.^2;

circularity = sqrt(area)./perimeter;

habit = categorical(ncread(fname,'holroyd_habit'),[77 67 116 115 111 108 97 103 104 105 100],...
                               {'M' 'C' 't' 's' 'o' 'l' 'a' 'g' 'h' 'i' 'd'});

Dmajor = ncread(fname,'image_EllipseL');
Dminor = ncread(fname,'image_EllipseW');
Dmax = ncread(fname,'image_diam_minR');

EllipAng = rad2deg(ncread(fname,'image_EllipseAngle'));

AR = Dminor./Dmajor;

area_ratio = area./(0.25.*pi.*Dmajor.*Dminor);

try 

    numSub = ncread(fname,'subparticle_num');

catch

    numSub = ones(size(Dmajor));

end

switch m.pos_switch 
    case 'entire_in'
        indx = ((Dmajor>m.Dthresh)&(edge==0)&(NPixels>=m.NPixel_thresh) & (AR>=m.ar_thresh) & ...
            (area_ratio>=m.area_thresh)&(reject==48 | reject==72 | reject==104 | reject==117) & (iat>=m.iat_thresh));

    case 'center_in'
        indx = ((Dmajor>m.Dthresh)&(center==1)&(NPixels>=m.NPixel_thresh) & (AR>=m.ar_thresh) & ...
            (area_ratio>=m.area_thresh)&(reject==48 | reject==72 | reject==104 | reject==117) & (iat>=m.iat_thresh));

end

if ~isempty(varargin{1})

    indx = indx & (Time>=varargin{1}{1}(1) & Time<=varargin{1}{1}(2));

end


%Time_temp = Time(indx);

mH.date = [mH.date date(indx)'];
mH.Time = [mH.Time Time(indx)'];
mH.msec = [mH.msec msec(indx)'];
mH.seconds = [mH.seconds seconds(indx)'];
mH.Dmajor = [mH.Dmajor Dmajor(indx)'];
mH.Dmax = [mH.Dmax Dmax(indx)'];
mH.AR = [mH.AR AR(indx)'];
mH.area_ratio = [mH.area_ratio area_ratio(indx)'];
mH.EllipAng = [mH.EllipAng EllipAng(indx)'];
mH.habit = [mH.habit habit(indx)'];
mH.NPixels = [mH.NPixels NPixels(indx)'];
mH.iat = [mH.iat iat(indx)'];
mH.fineDetail = [mH.fineDetail fineDetail(indx)'];
mH.perimeter = [mH.perimeter perimeter(indx)'];
mH.circularity = [mH.circularity circularity(indx)'];
mH.numSub = [mH.numSub numSub(indx)'];

%mH.height = [mH.height height_temp];
%mH.Temp = [mH.Temp Tc_temp];
%mH.Drift = [mH.Drift Drift_temp];
%mH.Roll = [mH.Roll Roll_temp];
%mH.Pitch = [mH.Pitch Pitch_temp];


end


%% Resort all data according to time

yyyy = floor(double(mH.date)./10000);
MM = floor((double(mH.date)-yyyy.*10000)./100);
dd = floor((double(mH.date)-yyyy.*10000-MM.*100));
hh = floor((double(mH.Time)./10000));
mm = floor((double(mH.Time)-hh.*10000)./100);
ss = floor((double(mH.Time)-hh.*10000-mm.*100));
msec = mH.msec;

mH.time = datetime(yyyy,MM,dd,hh,mm,ss,msec);

%Time_total = double(mH.Time)+double(mH.msec)./1000;

[~,idx] = sort(mH.time);

mH.date = mH.date(idx);
mH.Time = mH.Time(idx);
mH.time = mH.time(idx);
mH.msec = mH.msec(idx);
mH.seconds = mH.seconds(idx);
mH.Dmajor = mH.Dmajor(idx);
mH.Dmax = mH.Dmax(idx);
mH.AR = mH.AR(idx);
mH.area_ratio = mH.area_ratio(idx);
mH.EllipAng = mH.EllipAng(idx);
mH.habit = mH.habit(idx);
mH.NPixels = mH.NPixels(idx);
mH.iat = mH.iat(idx);
mH.numSub = mH.numSub(idx);
mH.perimeter = mH.perimeter(idx);
mH.circularity = mH.circularity(idx);
mH.fineDetail = mH.fineDetail(idx);

% Resample habit?

%habit_obj = timeseries(mH.habit,mH.

%% Calculate timeseries data


% Do 1 minute time edges.
%time_start = datetime(yyyy(1),MM(1),dd(1),0,0,mH.seconds(1));
%time_end = datetime(yyyy(end),MM(end),dd(end),0,0,mH.seconds(end));

%tot_time_min = ceil(minutes(time_end-time_start));

time_start = dateshift(mH.time(1),'start','hour')+minutes(floor(minute(mH.time(1))/avg_window)*avg_window);
time_end   = dateshift(mH.time(end),'start','hour')+minutes(ceil(minute(mH.time(end))/avg_window)*avg_window);

tot_time_min = ceil(minutes(time_end-time_start));

%time_dt = datetime(yyyy(end),MM(end),dd(end),0,0,mH.seconds);

time_min = minutes(mH.time-time_start);

%mH.time_bins = 0:avg_window:tot_time_min;
%mH.time_edges = -avg_window/2:avg_window:tot_time_min+avg_window/2;

minutes_edges = 0:avg_window:ceil(tot_time_min/avg_window)*avg_window;
minutes_mid = 0.5.*(minutes_edges(1:end-1)+minutes_edges(2:end));

%mH.Time_dt_bins = time_start+minutes(mH.time_bins);

%mH.Time_dt_bins = Time+minutes(mH.time_bins);

%mH.time_bins_edges = time_start:minutes(avg_window):time_end;

mH.time_bins = time_start+minutes(minutes_mid);

% Bin habit data. There's probably a faster way to do this but this
% "should" work.
mH.irregularFrac = zeros(1,length(mH.time_bins));
mH.dendriteFrac = zeros(1,length(mH.time_bins));
mH.hexagonalFrac = zeros(1,length(mH.time_bins));
mH.aggregateFrac = zeros(1,length(mH.time_bins));
mH.graupelFrac = zeros(1,length(mH.time_bins));
mH.linearFrac = zeros(1,length(mH.time_bins));
mH.orientedFrac = zeros(1,length(mH.time_bins));
mH.sphereFrac = zeros(1,length(mH.time_bins));
mH.tinyFrac = zeros(1,length(mH.time_bins));
mH.CFrac = zeros(1,length(mH.time_bins));
mH.MFrac = zeros(1,length(mH.time_bins));

%% NOTE: Try binning w.r.t. particle index number?

for tt = 1 : length(mH.time_bins)

    % Find all habits in time bin
    habit_temp = mH.habit(time_min>minutes_edges(tt)&time_min<=minutes_edges(tt+1));

    % COUNTS
    mH.irregularFrac(tt) = sum(habit_temp=='i','omitnan');
    mH.dendriteFrac(tt) = sum(habit_temp=='d','omitnan');
    mH.hexagonalFrac(tt) = sum(habit_temp=='h','omitnan');
    mH.aggregateFrac(tt) = sum(habit_temp=='a','omitnan');
    mH.graupelFrac(tt) = sum(habit_temp=='g','omitnan');
    mH.linearFrac(tt) = sum(habit_temp=='l','omitnan');
    mH.orientedFrac(tt) = sum(habit_temp=='o','omitnan');
    mH.sphereFrac(tt) = sum(habit_temp=='s','omitnan');
    mH.tinyFrac(tt) = sum(habit_temp=='t','omitnan');
   
    mH.CFrac(tt) = sum(habit_temp=='C','omitnan');
    mH.MFrac(tt) = sum(habit_temp=='M','omitnan');
 

end

%% smooth habit fraction timeseries?
 min_window = 10;
 mH.irregularFrac = smoothdata(mH.irregularFrac,2,'gaussian',min_window,'omitnan');
 mH.dendriteFrac = smoothdata(mH.dendriteFrac,2,'gaussian',min_window,'omitnan');
 mH.hexagonalFrac = smoothdata(mH.hexagonalFrac,2,'gaussian',min_window,'omitnan'); 
 mH.aggregateFrac = smoothdata(mH.aggregateFrac,2,'gaussian',min_window,'omitnan');
 mH.graupelFrac = smoothdata(mH.graupelFrac,2,'gaussian',min_window,'omitnan');
 mH.linearFrac = smoothdata(mH.linearFrac,2,'gaussian',min_window,'omitnan');
 mH.orientedFrac = smoothdata(mH.orientedFrac,2,'gaussian',min_window,'omitnan');
 mH.sphereFrac = smoothdata(mH.sphereFrac,2,'gaussian',min_window,'omitnan');
 mH.tinyFrac = smoothdata(mH.tinyFrac,2,'gaussian',min_window,'omitnan');
 mH.CFrac = smoothdata(mH.CFrac,2,'gaussian',min_window,'omitnan');
 mH.MFrac = smoothdata(mH.MFrac,2,'gaussian',min_window,'omitnan');

 totFrac = mH.irregularFrac+mH.dendriteFrac+mH.hexagonalFrac+mH.aggregateFrac+...
           mH.graupelFrac+mH.linearFrac+mH.orientedFrac+mH.sphereFrac+mH.tinyFrac+...
           mH.CFrac+mH.MFrac;

 mH.irregularFrac = mH.irregularFrac./totFrac;
 mH.dendriteFrac = mH.dendriteFrac./totFrac; 
 mH.hexagonalFrac = mH.hexagonalFrac./totFrac;
 mH.aggregateFrac = mH.aggregateFrac./totFrac;
 mH.graupelFrac = mH.graupelFrac./totFrac;
 mH.linearFrac = mH.linearFrac./totFrac;
 mH.orientedFrac = mH.orientedFrac./totFrac;
 mH.sphereFrac = mH.sphereFrac./totFrac;
 mH.tinyFrac = mH.tinyFrac./totFrac;
 mH.CFrac = mH.CFrac./totFrac;
 mH.MFrac = mH.MFrac./totFrac; 


%% Calculate mean statistics

[hhmmss_P3,ind_unq] = unique(double(m.P3.hhmmss));

Alt_MSL_P3 = double(m.P3.Alt_MSL(ind_unq));
Tc_P3 = double(m.P3.Static_Air_Temp(ind_unq));
Drift_P3 = double(m.P3.Drift_Angle(ind_unq));
Roll_P3 = double(m.P3.Roll_Angle(ind_unq));
Pitch_P3 = double(m.P3.Pitch_Angle(ind_unq));

mH.height = interp1(hhmmss_P3(~isnan(Alt_MSL_P3)),Alt_MSL_P3(~isnan(Alt_MSL_P3)),double(mH.Time),'nearest');
mH.Temp = interp1(hhmmss_P3(~isnan(Tc_P3)),Tc_P3(~isnan(Tc_P3)),double(mH.Time),'nearest');
mH.Drift = interp1(hhmmss_P3(~isnan(Drift_P3)),Drift_P3(~isnan(Drift_P3)),double(mH.Time),'nearest');
mH.Roll = interp1(hhmmss_P3(~isnan(Roll_P3)),Roll_P3(~isnan(Roll_P3)),double(mH.Time),'nearest');
mH.Pitch = interp1(hhmmss_P3(~isnan(Pitch_P3)),Pitch_P3(~isnan(Pitch_P3)),double(mH.Time),'nearest');

mH.LWC = interp1(m.FCDP.Time(~isnan(m.FCDP.LWC)),m.FCDP.LWC(~isnan(m.FCDP.LWC)),mH.time,'nearest');



end
