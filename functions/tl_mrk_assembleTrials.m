
function [mrk,i_select] = tl_mrk_assembleTrials(mrk,trial_type,events_must,events_mustnt)

global opt

mrk = mrk_sortChronologically(mrk);

% markers
if strcmp(trial_type,'all')
    mrk = tl_mrk_unifyMarkers(mrk,'start');
    ci_ts = find(strcmp(mrk.className,'start'));
else
    ci_ts = find(strcmp(mrk.className,['start ' trial_type]));
end
ci_te = find(strcmp(mrk.className,'trial end'));
ci_bp = find(strcmp(mrk.className,'button press'));

if nargin<3
    events_must = {};
    events_mustnt = {};
end

ci_must = zeros(1,length(events_must));
for ii = 1:length(events_must)
    ci_must(ii) = find(strcmp(mrk.className,events_must{ii}));
end

ci_mustnt = zeros(1,length(events_mustnt));
for ii = 1:length(events_mustnt)
    ci_mustnt(ii) = find(strcmp(mrk.className,events_mustnt{ii}));
end

% extract markers
idx = 1;
i_select = [];
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
        if isempty(ci_must)
            match_must = true;
        else
            match_must = all(ismember(ci_must,class_idx(2:end-1)));
        end
        if isempty(ci_mustnt)
            match_mustnt = true;
        else
            match_mustnt = ~all(ismember(ci_mustnt,class_idx(2:end-1)));
        end
        if match_must && match_mustnt
            if ismember(ci_bp,class_idx)
                t_ts2bp = mrk.time(event_idx(logical(ci_bp==class_idx)))-mrk.time(event_idx(1));
                if t_ts2bp < opt.mrk.min_ts2bp
                    continue
                end
            end
            n_trial = n_trial+1;
            i_select{n_trial} = event_idx;
        end
    end
    idx = idx+1;
end

%
if not(strcmp(trial_type,'all'))
    fprintf('%d trials of type ''%s'' selected.\n',n_trial,trial_type)
else
    fprintf('All %d trials selected.\n',n_trial)
end
if not(isempty(i_select))
    mrk = mrk_selectEvents(mrk,[i_select{:}],'RemoveVoidClasses',0,'Sort',1);
else
    mrk = [];
end


