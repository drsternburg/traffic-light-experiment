
function ana = tl_ana_getTrialEvents(subj_code,ana)

if nargin>1
    if isfield(ana,'subj_code')
        if not(strcmp(ana.subj_code,subj_code))
            error('Do not intermix subject analyses')
        end
    end
end

ana.subj_code = subj_code;

trial_type = {'move red','move green','idle red','idle green','phase1'};

%%
mrk = tl_proc_loadData(subj_code);
mrk_uni = tl_mrk_unifyMarkers(mrk,'start');
[~,trial_ind] = tl_mrk_assembleTrials(mrk_uni,'all');
N = length(trial_ind);

%%
for ii = 1:N
    
    mrk_this = mrk_selectEvents(mrk,trial_ind{ii});
    this_start = mrk_this.className{logical(mrk_this.y(:,1))}; % start marker
    this_type = this_start(7:end);
    this_interruption = ['light ' this_type];
    
    % trial type
    ana.trial_type(ii) = find(strcmp(trial_type,this_type));
    
    % movement
    ev_idx = strcmp(mrk_this.className,'EMG onset');
    if any(ev_idx)
        ana.emg_onset(ii) = 1;%trial_ind{ii}(logical(ev_idx));
        % waiting time
        mrk_ = mrk_selectClasses(mrk_this,{this_start,'EMG onset'});
        ana.t_ts2emg(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        if any(strcmp(mrk_this.className,'button press'))
            ana.button_press(ii) = 1;
            % movement duration
            mrk_ = mrk_selectClasses(mrk_this,{'EMG onset','button press'});
            ana.t_emg2bp(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        else
            ana.button_press(ii) = 0;
            ana.t_emg2bp(ii) = NaN;
        end
    else
        ana.emg_onset(ii) = 0;
        ana.button_press(ii) = 0;
        ana.t_ts2emg(ii) = NaN;
        ana.t_emg2bp(ii) = NaN;
    end
    
    % interruptions
    ev_idx = strcmp(mrk_this.className,this_interruption);
    if any(ev_idx)
        ana.interrupted(ii) = 1;%trial_ind{ii}(logical(ev_idx));
        mrk_ = mrk_selectClasses(mrk_this,{this_start,this_interruption});
        ana.t_ts2int(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        if ana.emg_onset(ii)
            mrk_ = mrk_selectClasses(mrk_this,'EMG onset',this_interruption);
            ana.t_emg2int(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        else
            ana.t_emg2int(ii) = NaN;
        end
    else
        ana.interrupted(ii) = 0;
        ana.t_ts2int(ii) = NaN;
    end
    
    % silent interruptions
    ev_idx = strcmp(mrk_this.className,'light silent');
    if any(ev_idx)
        ana.interrupted_silent(ii) = 1;%trial_ind{ii}(logical(ev_idx));
        mrk_ = mrk_selectClasses(mrk_this,{this_start,'light silent'});
        ana.t_ts2sil(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        if ana.emg_onset(ii)
            mrk_ = mrk_selectClasses(mrk_this,'EMG onset','light silent');
            ana.t_emg2sil(ii) = mrk_.time(logical(mrk_.y(2,:)))-mrk_.time(logical(mrk_.y(1,:)));
        else
            ana.t_emg2sil(ii) = NaN;
        end
    else
        ana.interrupted_silent(ii) = 0;
        ana.t_ts2sil(ii) = NaN;
        ana.t_emg2sil(ii) = NaN;
    end
    
    % prompts and responses
    if any(strcmp(mrk_this.className,'prompt'))
        ana.prompted(ii) = 1;
        if any(strcmp(mrk_this.className,'yes'))
            ana.yes(ii) = 1;
        elseif any(strcmp(mrk_this.className,'no'))
            ana.yes(ii) = 0;
        end
    else
        ana.prompted(ii) = 0;
    end
    
end

















