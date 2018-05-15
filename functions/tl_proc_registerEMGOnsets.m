
function tl_proc_registerEMGOnsets(subj_code,phase_name,il)

global opt

[mrk,cnt] = tl_proc_loadData(subj_code,phase_name);
mrk = mrk_selectClasses(mrk,'not','EMG onset','RemoveVoidClasses',0); % in case EMG onset have already been registered

%% prepare EMG data
cnt = proc_selectChannels(cnt,'EMG');
[b,a] = butter(6,20/cnt.fs*2,'high');
cnt = proc_filtfilt(cnt,b,a);
%cnt.x = abs(cnt.x);

%%
if strcmp(phase_name,'Phase2')
    cl_orig_ts = opt.mrk.def(2,3:6);
else
    cl_orig_ts = {'start silent'};
end

mrk2 = tl_mrk_unifyMarkers(mrk,cl_orig_ts,'start all');
[mrk2,i_select] = tl_mrk_assembleTrials(mrk2,'all',{},{});

i_ts = cellfun(@(v)v(1),i_select);
i_te = cellfun(@(v)v(end),i_select);
n_trial = length(i_ts);

%% compute average EMG signal in first 1000ms of all trials
sd_bsln = zeros(opt.emg.wlen_bsln/10,length(i_ts));
for ii = 1:length(i_ts)
    epo = proc_segmentation(cnt,mrk_selectEvents(mrk,i_ts(ii)),[0 opt.emg.wlen_bsln]);
    sd_bsln(:,ii) = epo.x;
end
sd_bsln = std(sd_bsln(:));

%%
if il>0
    init_figure;
    ylim = [-1 1]*max(abs(cnt.x));
    trial_events = ['button press' opt.mrk.def(2,7:11)];
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
    ev_time = zeros(1,length(i_select{ii})-2);
    ev_name = cell(1,length(i_select{ii})-2);
    for jj = 2:length(i_select{ii})-1
        mrk_ = mrk_selectEvents(mrk,i_select{ii}(jj));
        ev_time(jj-1) = mrk_.time - t_ts;
        ev_name(jj-1) = mrk_.className;
    end
    t_bp = ev_time(strcmp(ev_name,'button press'));
        
    % detect first 50ms window where SD > 3.5*SD_baseline
    i_emg = 1;
    while i_emg+wlen_det<=length(epo.x)
        sd = std(epo.x(i_emg:i_emg+wlen_det-1));
        if sd>sd_bsln*opt.emg.sd_fac
            break
        end
        i_emg = i_emg+1;
    end
    t_emg_ = epo.t(i_emg) + opt.emg.wlen_det/2; % add half the detection window
    
    t_emg2bp = t_bp - t_emg_;
    if not(isempty(t_emg2bp))
        range_valid = t_emg2bp > opt.emg.emg2bp_range(1) &&...
                      t_emg2bp < opt.emg.emg2bp_range(2);
    else
        range_valid = 0;
    end
    
    if il==2 || (~range_valid && il==1)
        
        fprintf('Trial %d/%d: ',ii,n_trial)
        
        plot(epo.t,epo.x,'k')
        hold on
        
        if range_valid
            plot([1 1]*t_emg_,ylim,'color',clrs(end,:),'linewidth',2)
        else
            plot([1 1]*t_emg_,ylim,'--','color',clrs(end,:),'linewidth',2)
        end
        
        % plot events within trial
        h = [];
        for jj = 1:length(ev_time)
            i_clr = find(strcmp(ev_name{jj},trial_events));
            if not(isempty(i_clr))
                h = [h plot([1 1]*(ev_time(jj)),ylim,'--','color',clrs(i_clr,:),'linewidth',1.5)];
            end
        end
        legend(h,ev_name,'location','northwest')
        set(gca,'ylim',ylim,'xlim',[0 t_te-t_ts])
        
        % prompt for input
        if range_valid
            r = input(sprintf('%4.1f (found automatically), accept or new: ',t_emg_),'s');
        else
            r = input('please enter manually: ','s');
        end
        clf
        if not(isempty(r))
            r = str2num(r);
            if not(isempty(r)) % number entered
                t_emg(ii) = r+t_ts;
            else % character entered -> rewind
                ii = ii-1;
                continue
            end
        else
            if range_valid
                t_emg(ii) = t_emg_+t_ts;
            end
        end
    else % no interaction
        if range_valid
            t_emg(ii) = t_emg_+t_ts;
        end        
    end
    ii = ii+1;
end
fprintf('%d EMG onsets assigned to %d trials.\n',sum(not(isnan(t_emg))),n_trial)
close gcf

%% insert new markers
t_emg(isnan(t_emg)) = [];
clear mrk2
mrk2.time = t_emg;
mrk2.y = ones(1,length(t_emg));
mrk2.className = {'EMG onset'};
mrk = mrk_mergeMarkers(mrk,mrk2);
mrk = mrk_sortChronologically(mrk);

%% cleanup lost button presses
mrk2 = tl_mrk_unifyMarkers(mrk,cl_orig_ts,'start all');
[~,ind] = tl_mrk_assembleTrials(mrk2,'all',{'button press'},{'EMG onset'});
mrk = mrk_selectEvents(mrk,'not',ind);
fprintf('%d trials removed with lost button presses.\n',length(ind))

%% save new marker struct
global BTB
ds_list = dir(BTB.MatDir);
ds_idx = strncmp(subj_code,{ds_list.name},5);
ds_name = ds_list(ds_idx).name;
filename = sprintf('%s%s/%s_%s_%s_mrk',BTB.MatDir,ds_name,opt.session_name,phase_name,subj_code);
save(filename,'mrk')
















