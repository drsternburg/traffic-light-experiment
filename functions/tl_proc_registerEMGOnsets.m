
function tl_proc_registerEMGOnsets(subj_code,phase_name,interactive,plot_events)

global opt

if not(exist('plot_events','var'))
    plot_events = false;
end

[mrk,cnt] = tl_proc_loadData(subj_code,phase_name);
mrk = mrk_selectClasses(mrk,'not','EMG onset','RemoveVoidClasses',0); % in case EMG onsets have already been registered

%% prepare EMG data
cnt = proc_selectChannels(cnt,'EMG');
[b,a] = butter(6,20/cnt.fs*2,'high');
cnt = proc_filtfilt(cnt,b,a);

%% prepare markers
trial_mrk = tl_mrk_getTrialMarkers(mrk);
i_ts = cellfun(@(v)v(1),trial_mrk);
i_te = cellfun(@(v)v(end),trial_mrk);
n_trial = length(i_ts);

%% get median standard deviation of EMG signal in first 1000ms of all trials
sd_bsln = zeros(opt.emg.wlen_bsln/10,length(i_ts));
for ii = 1:length(i_ts)
    epo = proc_segmentation(cnt,mrk_selectEvents(mrk,i_ts(ii)),[0 opt.emg.wlen_bsln]);
    sd_bsln(:,ii) = epo.x;
end
sd_bsln = sqrt(median(var(sd_bsln,1)));

%%
if interactive
    tl_fig_init;
    %ylim = [-1 1]*max(abs(cnt.x));
    ylim = [0 prctile(abs(cnt.x),99.9)];
    trial_events = ['button press' opt.mrk.def(2,7:11) 'light rt'];
    clrs = lines(length(trial_events)+1);
end

%% trial by trial
t_emg = nan(1,n_trial);
ii = 1;
wlen_det = opt.emg.wlen_det/10;
while ii<=n_trial
    
    % extract EMG signal of trial
    t_ts = mrk.time(i_ts(ii));
    t_te = mrk.time(i_te(ii));
    epo = proc_segmentation(cnt,mrk_selectEvents(mrk,i_ts(ii)),[0 t_te-t_ts]);
    
    % get time and name of events occurring within trial
    ev_time = zeros(1,length(trial_mrk{ii})-2);
    ev_name = cell(1,length(trial_mrk{ii})-2);
    for jj = 2:length(trial_mrk{ii})-1
        mrk_ = mrk_selectEvents(mrk,trial_mrk{ii}(jj));
        ev_time(jj-1) = mrk_.time - t_ts;
        ev_name(jj-1) = mrk_.className;
    end
    
    % detect first 50ms window where SD > 3.5*SD_baseline
    i_start = opt.emg.wlen_minWT/10 + 1;
    i_emg = i_start;
    detected = false;
    while i_emg+wlen_det<=length(epo.x)
        sd = std(epo.x(i_emg:i_emg+wlen_det-1));
        if sd>sd_bsln*opt.emg.sd_fac
            if not(i_emg==i_start)
                detected = true;
            end
            break
        end
        i_emg = i_emg+1;
    end
    
    if detected
        t_emg_ = epo.t(i_emg) + opt.emg.wlen_det/2; % add half the detection window
        %t_emg_ = epo.t(i_emg);
    else
        ii = ii+1;
        continue
    end
    
    if interactive
        
        fprintf('Trial %d/%d: ',ii,n_trial)
        
        %plot(epo.t,epo.x,'k')
        plot(epo.t,abs(epo.x),'k')
        hold on
        plot([1 1]*t_emg_,ylim,'color',clrs(end,:),'linewidth',2)
        
        if plot_events
            % plot events within trial
            h = [];
            for jj = 1:length(ev_time)
                i_clr = find(strcmp(ev_name{jj},trial_events));
                if not(isempty(i_clr))
                    h = [h plot([1 1]*(ev_time(jj)),ylim,'--','color',clrs(i_clr,:),'linewidth',1.5)];
                    tpos = ylim(2)-ylim(2)*.1*jj;
                    text(ev_time(jj))
                end
            end
            %legend(h,ev_name,'location','northwest')
        end
        set(gca,'ylim',ylim,'xlim',[0 t_te-t_ts])
        
        % prompt for input
        r = input(sprintf('Detected automatically: %4.1f ms; accept (ENTER) or new: ',t_emg_),'s');
        clf
        if not(isempty(r))
            if not(isempty(str2num(r))) % number entered
                t_emg(ii) = str2num(r)+t_ts;
            elseif strcmp(r,'r') % rewind by one trial
                ii = ii-1;
                continue
            elseif strcmp(r,'f') % fast-forward (interrupt interactive mode)
                interactive = false;
                t_emg(ii) = t_emg_+t_ts;
                ii = ii+1;
                continue
            elseif strcmp(r,'d') % dismiss trial
                t_emg(ii) = NaN;
                ii = ii+1;
                continue
            end
        else
            t_emg(ii) = t_emg_+t_ts;
        end
        
    else % no interaction
        
        t_emg(ii) = t_emg_+t_ts;
        
    end
    
    ii = ii+1;
    
end

fprintf('%d EMG onsets assigned to %d trials.\n',sum(not(isnan(t_emg))),n_trial)
close gcf

%% insert new markers
t_emg(isnan(t_emg)) = [];
mrk2.time = t_emg;
mrk2.y = ones(1,length(t_emg));
mrk2.className = {'EMG onset'};
mrk = mrk_mergeMarkers(mrk,mrk2);
mrk = mrk_sortChronologically(mrk);

%% cleanup lost button presses
trials = tl_mrk_analyzeTrials(mrk);
trial_ind = tl_mrk_getTrialMarkers(mrk);
trial_ind = trial_ind(trials.button_press&~trials.emg_onset);
if not(isempty(trial_ind))
    mrk = mrk_selectEvents(mrk,'not',[trial_ind{:}]);
    fprintf('%d trials removed with lost button presses.\n',length(trial_ind))
end

%% save new marker struct
global BTB
ds_list = dir(BTB.MatDir);
ds_idx = strncmp(subj_code,{ds_list.name},5);
ds_name = ds_list(ds_idx).name;
filename = sprintf('%s%s/%s_%s_%s_mrk',BTB.MatDir,ds_name,opt.session_name,phase_name,subj_code);
save(filename,'mrk')
















