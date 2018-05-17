
function trial = tl_mrk_analyzeTrials(mrk)
% Extract non-EEG-related information from trials. Returns binary
% identifiers for possible events as well as time difference between
% certain events.

%%
trial_ind = tl_mrk_getTrialMarkers(mrk);
N = length(trial_ind);

%%
% binary indicators:
trial.phase1 = false(1,N);              % phase1 trial
trial.move = false(1,N);                % move trial (both red and green)
trial.idle = false(1,N);                % idle trial (both red and green)
trial.red = false(1,N);                 % red trial (both move and idle)
trial.green = false(1,N);               % green trial (both move and idle)
trial.emg_onset = false(1,N);           % trial contains emg onset
trial.button_press = false(1,N);        % trial contains button press
trial.interrupted = false(1,N);         % trial contains interruption (both red and green)
trial.interrupted_silent = false(1,N);  % trial contains silent interruption
trial.prompted = false(1,N);            % trial contains prompt
trial.yes = false(1,N);                 % trial contains yes answer
trial.no = false(1,N);                  % trial contains no answer
% time differences:
trial.t_ts2emg = nan(1,N);              % trial start to emg onset (waiting times)
trial.t_emg2bp = nan(1,N);              % emg onset to button press (movement duration)
trial.t_ts2int = nan(1,N);              % trial start to interruption
trial.t_emg2int = nan(1,N);             % emg onset to interruption
trial.t_ts2sil = nan(1,N);              % trial start to silent interruption
trial.t_emg2sil = nan(1,N);             % emg onset to silent interruption

%%
for ii = 1:N
    
    mrk_this = mrk_selectEvents(mrk,trial_ind{ii});
    this_start = mrk_this.className{logical(mrk_this.y(:,1))}; % start marker
    this_type = this_start(7:end);
    this_interruption = ['light ' this_type];
    
    % trial type
    switch this_type
        case 'phase1'
            trial.phase1(ii) = true;
        case 'move red'
            trial.move(ii) = true;
            trial.red(ii) = true;
        case 'move green'
            trial.move(ii) = true;
            trial.green(ii) = true;
        case 'idle red'
            trial.idle(ii) = true;
            trial.red(ii) = true;
        case 'idle green'
            trial.idle(ii) = true;
            trial.green(ii) = true;
    end
    
    % movement
    if any(strcmp(mrk_this.className,'EMG onset'))
        trial.emg_onset(ii) = true;
        % waiting time
        mrk_ = mrk_selectClasses(mrk_this,{this_start,'EMG onset'});
        trial.t_ts2emg(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        if any(strcmp(mrk_this.className,'button press'))
            trial.button_press(ii) = true;
            % movement duration
            mrk_ = mrk_selectClasses(mrk_this,{'EMG onset','button press'});
            trial.t_emg2bp(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        end
    end
    
    % interruption
    if any(strcmp(mrk_this.className,this_interruption))
        trial.interrupted(ii) = true;
        mrk_ = mrk_selectClasses(mrk_this,{this_start,this_interruption});
        trial.t_ts2int(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        if trial.emg_onset(ii)
            mrk_ = mrk_selectClasses(mrk_this,'EMG onset',this_interruption);
            trial.t_emg2int(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        end
    end
    
    % silent interruption
    if any(strcmp(mrk_this.className,'light silent'))
        trial.interrupted_silent(ii) = true;
        mrk_ = mrk_selectClasses(mrk_this,{this_start,'light silent'});
        trial.t_ts2sil(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        if trial.emg_onset(ii)
            mrk_ = mrk_selectClasses(mrk_this,'EMG onset','light silent');
            trial.t_emg2sil(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        end
    end
    
    % prompt and response
    if any(strcmp(mrk_this.className,'prompt'))
        trial.prompted(ii) = true;
        if any(strcmp(mrk_this.className,'yes'))
            trial.yes(ii) = true;
        elseif any(strcmp(mrk_this.className,'no'))
            trial.no(ii) = true;
        end
    end
    
end

















