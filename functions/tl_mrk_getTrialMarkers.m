
function trial_mrk = tl_mrk_getTrialMarkers(mrk)

global opt

mrk = mrk_sortChronologically(mrk);
mrk = tl_mrk_unifyMarkers(mrk,'start');
ci_ts = find(strcmp(mrk.className,'start'));
ci_te = find(strcmp(mrk.className,'trial end'));
ci_bp = find(strcmp(mrk.className,'button press'));

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
        if ismember(ci_bp,class_idx)
            t_ts2bp = mrk.time(event_idx(logical(ci_bp==class_idx)))-mrk.time(event_idx(1));
            if t_ts2bp < opt.mrk.min_ts2bp
                continue
            end
        end
        n_trial = n_trial+1;
        trial_mrk{n_trial} = event_idx;
    end
    idx = idx+1;
end
