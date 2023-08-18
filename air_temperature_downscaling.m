function T_hourly = air_temperature_downscaling(Tmins, Tmaxs, lat, lon, start_year, start_month, start_day)

day_num = length(Tmins);
hours_all = day_num * 24; % hourly

Tmins_m = nan(day_num+2, 1);
Tmaxs_m = nan(day_num+2, 1);

Hour_Tmins = nan(day_num+2, 1);
Hour_Tmaxs = nan(day_num+2, 1);

%% calculate the hour of Tmin and Tmax
for day_i = 1:day_num
    Tmin_i = Tmins(day_i);
    Tmax_i = Tmaxs(day_i);

    datatime1= datetime(start_year,start_month,start_day + day_i - 1,[0:23],0,0);

    SZAs_i = solarPosition(datatime1,lat, lon, lon/15);

    filters = find(SZAs_i < 90);
    Hour_set = filters(end) + 1;
    Hour_rise = filters(1);

    if(Hour_set<12 || Hour_rise>12)
        disp('Estimating Hour_set or Hour_set errors!');
    end

    Hour_Tmax = 0.67 * (Hour_set - Hour_rise) + Hour_rise;
    Hour_Tmin = Hour_rise - 1;

    if(Hour_Tmax<12 || Hour_Tmin < 0 || Hour_Tmin>12)
        disp('Estimating Tmin or Tmax errors!');
    end

    Hour_Tmins(day_i + 1) = Hour_Tmin + (day_i - 1)*24;
    Hour_Tmaxs(day_i + 1) = Hour_Tmax + (day_i - 1)*24;
    Tmins_m(day_i + 1) = Tmin_i;
    Tmaxs_m(day_i + 1) = Tmax_i ;

end

%% set the first and last values
Hour_Tmins(1) = Hour_Tmins(2) - 24;
Hour_Tmins(end) = Hour_Tmins(end-1) + 24;
Hour_Tmaxs(1) = Hour_Tmaxs(2) - 24;
Hour_Tmaxs(end) = Hour_Tmaxs(end-1) + 24;

Tmins_m(1) = Tmins(2);
Tmins_m(end) = Tmins(end-1);
Tmaxs_m(1) = Tmaxs_m(2);
Tmaxs_m(end) = Tmaxs_m(end-1);


%% downscale to diurnal cycle
Hours_local = [0:(hours_all-1)] + lon/15; % UTC to Local
% local time T_hourly= pchip([Hour_Tmins; Hour_Tmaxs],[Tmins_m; Tmaxs_m],[0:(hours_all-1)] );
T_hourly= pchip([Hour_Tmins; Hour_Tmaxs],[Tmins_m; Tmaxs_m],Hours_local );

% figure;
% plot([0:(hours_all-1)], T_hourly)
% hold on
% plot([Hour_Tmins - lon/15; Hour_Tmaxs - lon/15],[Tmins_m; Tmaxs_m], 'o')

end
