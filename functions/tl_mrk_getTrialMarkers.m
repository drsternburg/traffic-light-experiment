
function trial_mrk = tl_mrk_getTrialMarkers(mrk)
% Returns the cell trial_mrk that in each entry contains the marker indices
% of single trials, relative to the complete set of markers.

%min_ts2emg = 1300;
min_ts2emg = 0;

mrk = mrk_sortChronologically(mrk);
mrk = tl_mrk_unifyMarkers(mrk,'start');
ci_ts = find(strcmp(mrk.className,'start'));
ci_te = find(strcmp(mrk.className,'trial end'));
ci_emg = find(strcmp(mrk.className,'EMG onset'));
mrk = mrk_sortChronologically(mrk);

% extract markers
idx = 1;
trial_mrk = [];
n_trial = 0;
while idx<length(mrk.time)
    if find(mrk.y(:,idx))==ci_ts
        event_idx = [];
        class_idx = [];
        while 1
            event_idx = [event_idx idx];
            class_idx = [class_idx find(mrk.y(:,idx))];
            if find(mrk.y(:,idx))==ci_te
                break
            end
            idx = idx+1;
        end
        if ismember(ci_emg,class_idx)
            t_ts2emg = mrk.time(event_idx(logical(ci_emg==class_idx)))-mrk.time(event_idx(1));
            if t_ts2emg < min_ts2emg
                continue
            end
        end
        n_trial = n_trial+1;
        trial_mrk{n_trial} = event_idx;
    end
    idx = idx+1;
end
