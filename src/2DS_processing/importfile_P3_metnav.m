function P3 = importfile_P3_metnav(yyyymmdd)

if strcmp(yyyymmdd(1:4),'2020') || strcmp(yyyymmdd(1:4),'2022')


P3 = importfile_P3_metnav_2020_2022(yyyymmdd);


elseif strcmp(yyyymmdd(1:4),'2023')


P3 = importfile_P3_metnav_2023(yyyymmdd);


else

    print('Enter either a 2020, 2022, or 2023 date')


end


P3.hhmmss = int32(P3.Time.Hour.*10000+P3.Time.Minute.*100+P3.Time.Second);


P3.Alt_MSL = filloutliers(P3.Alt_MSL,'nearest','movmedian',200);




end