T = readtable('/Users/student/Desktop/work/flux/2-12_all_flux.csv'); %path to the OCR time-series data
num = table2array(T);
ctnt = num(4,2:end); % row with ctnt expression %
ranges = [10,177;195,351;368,520];% edges for the timeframes, here we chose to derive metrics 
                                  % from the timeframes corresponding to
                                  % days 1-2, 3-4 and 5-6 of differentiation
timeSeriesData = num(6:end,2:end).';
[d,n] = size(timeSeriesData);
X = [];
for i=1:d
    features = [];
    smooth = [];
    for j = 1:3 % 3 is the number of time windows we are analysing, set in "ranges" variable
        ts = timeSeriesData(i,ranges(j,1):ranges(j,2));
        std_ts = std(ts);
        mean_ts = mean(ts);
        standardized_ts = (ts - mean_ts) / std_ts; % normalize each time series
        smooth_ts = smoothdata(standardized_ts,'movmean',5); % smooth raw data
        smooth_diff = smoothdata(diff(smooth_ts),'movmean',5); % take a derivative and smooth it
        catch_22 = catch22(smooth_ts.'); %calculate catch22 metrics
        features = [features,[get_features(smooth_ts),get_features(smooth_diff),catch_22.']]; %calculate custom features
    end
    X = [X;features];
end

T_headers = readtable('/Users/student/Desktop/work/flux/headers.csv');
headers = T_headers.Properties.VariableNames;
fid = fopen('/Users/student/Desktop/work/flux/output.csv','w');
fprintf(fid,'%s\n',strjoin(headers,','));
fclose(fid);
dlmwrite('/Users/student/Desktop/work/flux/output.csv',[ctnt.',X],'-append');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [max1,argmax1] = first_max(ts)
    [pks,locs] = findpeaks(ts);
    if isempty(pks)
        [max1,argmax1] = max(ts);
    else
        max1 = pks(1);
        argmax1 = locs(1);
    end
end

function [max2,argmax2] = second_max(ts)
    [pks,locs] = findpeaks(ts);
    if length(pks)>1
        max2 = pks(2);
        argmax2 = locs(2);
    else
        max2 = ts(end);
        argmax2 = length(ts);
    end
end

function [min1,argmin1] = first_min(ts)
    if length(ts) < 3
        [min1,argmin1] = min(ts); 
        return
    end
    [pks,locs] = findpeaks(-ts);
    if length(pks) > 0
        min1 = -pks(1);
        argmin1 = locs(1);
    else
       [min1,argmin1] = min(ts);
    end
end

function plato = plato_length(ts) % longest stretch with gaps below threshold
    l = length(ts);
    if l < 2
        plato = l;
        return
    end
    threshold = 0.05*std(ts);
    for i=1:l
        if max(ts(l-i+1:l))-ts(l-i) > threshold || ts(l-i)-min(ts(l-i+1:l)) > threshold
            break
        end
    end
    plato = i;
end

function features = get_features(ts)
    [max1,argmax1] = first_max(ts); %first local max
    [max2,argmax2] = second_max(ts); %first local max
    [min1,argmin1] = first_min(ts(argmax1:end)); %first local min after initial peak
    argmin1 = argmin1+argmax1-1;
    [max_global,argmax_global] = max(ts); %global max
    [min_global,argmin_global] = min(ts(argmax1:end)); %global min after initial peak
    argmin_global = argmin_global+argmax1-1;
    max_min_dist = argmin1-argmax1;
    max_max_dist = argmax2-argmax1;
    max_max_gap = max1-max2;
    min_max_dist = argmax2-argmin1;
    max_min_gap = max1-min1;
    global_max_min_gap = max_global-min_global;
    max1_to_end = length(ts)-argmax1;
    max2_to_end = length(ts)-argmax2;
    min1_to_end = length(ts)-argmin1;
    num_peaks = findpeaks(ts);
    plato = plato_length(ts(argmax1:end));
    features = [max1,argmax1,max2,argmax2,min1,argmin1,max_global,argmax_global,...
        min_global,argmin_global,max_min_dist,max_max_dist,max_max_gap,min_max_dist,...
        max1_to_end,max2_to_end,min1_to_end,max_min_gap,...
        length(num_peaks),global_max_min_gap,plato];
    median_window = 20; % change to count median values of smaller or larger windows 
    for i=1:floor(length(ts)/median_window)
        features = [features median(ts((i-1)*median_window+1:i*median_window))];
    end
    features = [features median(ts(floor(length(ts)/median_window)*median_window:end))];
end
