
function trial = tl_mrk_analyzeTrials(mrk)
% Extract non-EEG-related information from all trials.
% trial.type  :   identifier for trial type
%                 1 - move red
%                 2 - move green
%                 3 - idle red
%                 4 - idle green
%                 5 - phase1
% trial.event :   binary identifiers for possible events
% trial.time  :   time difference between certain events

%%
trial_ind = tl_mrk_getTrialMarkers(mrk);
N = length(trial_ind);
trial_type = {'move red','move green','idle red','idle green','phase1'};

%%
for ii = 1:N
    
    mrk_this = mrk_selectEvents(mrk,trial_ind{ii});
    this_start = mrk_this.className{logical(mrk_this.y(:,1))}; % start marker
    this_type = this_start(7:end);
    this_interruption = ['light ' this_type];
    
    % trial type
    trial.type(ii) = find(strcmp(trial_type,this_type));
    
    % movement
    ev_idx = strcmp(mrk_this.className,'EMG onset');
    if any(ev_idx)
        trial.event.emg_onset(ii) = 1;%trial_ind{ii}(logical(ev_idx));
        % waiting time
        mrk_ = mrk_selectClasses(mrk_this,{this_start,'EMG onset'});
        trial.time.t_ts2emg(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        if any(strcmp(mrk_this.className,'button press'))
            trial.event.button_press(ii) = 1;
            % movement duration
            mrk_ = mrk_selectClasses(mrk_this,{'EMG onset','button press'});
            trial.time.t_emg2bp(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        else
            trial.event.button_press(ii) = 0;
            trial.time.t_emg2bp(ii) = NaN;
        end
    else
        trial.event.emg_onset(ii) = 0;
        trial.event.button_press(ii) = 0;
        trial.time.t_ts2emg(ii) = NaN;
        trial.time.t_emg2bp(ii) = NaN;
    end
    
    % interruptions
    ev_idx = strcmp(mrk_this.className,this_interruption);
    if any(ev_idx)
        trial.event.interrupted(ii) = 1;%trial_ind{ii}(logical(ev_idx));
        mrk_ = mrk_selectClasses(mrk_this,{this_start,this_interruption});
        trial.time.t_ts2int(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        if trial.event.emg_onset(ii)
            mrk_ = mrk_selectClasses(mrk_this,'EMG onset',this_interruption);
            trial.time.t_emg2int(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        else
            trial.time.t_emg2int(ii) = NaN;
        end
    else
        trial.event.interrupted(ii) = 0;
        trial.time.t_ts2int(ii) = NaN;
    end
    
    % silent interruptions
    ev_idx = strcmp(mrk_this.className,'light silent');
    if any(ev_idx)
        trial.event.interrupted_silent(ii) = 1;%trial_ind{ii}(logical(ev_idx));
        mrk_ = mrk_selectClasses(mrk_this,{this_start,'light silent'});
        trial.time.t_ts2sil(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        if trial.event.emg_onset(ii)
            mrk_ = mrk_selectClasses(mrk_this,'EMG onset','light silent');
            trial.time.t_emg2sil(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        else
            trial.time.t_emg2sil(ii) = NaN;
        end
    else
        trial.event.interrupted_silent(ii) = 0;
        trial.time.t_ts2sil(ii) = NaN;
        trial.time.t_emg2sil(ii) = NaN;
    end
    
    % prompts and responses
    if any(strcmp(mrk_this.className,'prompt'))
        trial.event.prompted(ii) = 1;
        if any(strcmp(mrk_this.className,'yes'))
            trial.event.yes(ii) = 1;
        elseif any(strcmp(mrk_this.className,'no'))
            trial.event.yes(ii) = 0;
        end
    else
        trial.event.prompted(ii) = 0;
    end
    
end

















