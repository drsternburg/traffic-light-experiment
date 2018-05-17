
warning off

subj_code = 'VPtaa';
[mrk,cnt] = tl_proc_loadData(subj_code);
trial = tl_mrk_analyzeTrials(mrk);
BTB.FigPos = [55 4]; % internally for MSK


%% (1) SILENT interruptions distribution

tl_fig_init; hold on
ind = trial.interrupted_silent; % all trials with silent interruptions
t = trial.t_emg2sil(ind);
histogram(t,opt.fig.pred_edges)
plot([0 0],get(gca,'ylim'),'k--')
xlabel('Time to EMG onset (ms)')
ylabel('Counts')
set(gca,'box','on')

% --> unfortunately, most MOVE interruptions occured ~ 200ms after EMG
% onset


%% (2) Compare PHASE 1 and PHASE 2 (only self-paced movements)

ind1 = trial.phase1; % all phase 1 trials
ind2 = ~trial.phase1 & trial.emg_onset & ... % phase 2 trials with emg onsets ...
       ~(trial.green & trial.prompted & trial.no); % ... excluding green trials where the response to a prompt was 'no' (because these were presumably cued and not self-paced button presses)

tl_fig_init;

% (a) Movement duration
t1 = trial.t_emg2bp(ind1);
t2 = trial.t_emg2bp(ind2);

subplot 121, hold on
histogram(t1)
histogram(t2)
legend('Phase1','Phase2')

% (b) Readiness potential
mrk1 = tl_mrk_selectTrials(mrk,ind1);
mrk1 = mrk_selectClasses(mrk1,'EMG onset');
mrk1.className = {'Phase 1'};
mrk2 = tl_mrk_selectTrials(mrk,ind2);
mrk2 = mrk_selectClasses(mrk2,'EMG onset');
mrk2.className = {'Phase 2'};
mrk12 = mrk_mergeMarkers(mrk1,mrk2);
erp = proc_segmentation(cnt,mrk12,[-2000 300]);
erp = proc_baseline(erp,100,'beginning');

subplot 122
plot_channel(erp,'Cz');

% --> Movements where significantly faster during Phase 1 and the readiness
% potential qualitatively stronger


%% (3) GREEN MOVE interruptions (yes vs. no)
ind1 = trial.green & trial.move & trial.prompted & trial.yes;
ind2 = trial.green & trial.move & trial.prompted & trial.no;

tl_fig_init;

% (a) Movement to interruption
t1 = trial.t_emg2int(ind1);
t2 = trial.t_emg2int(ind2);

subplot 121, hold on
histogram(t1,opt.fig.pred_edges)
histogram(t2,opt.fig.pred_edges)
plot([0 0],get(gca,'ylim'),'k--')
legend('yes','no','location','west')
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)])
xlabel('Time to EMG onset (ms)')
ylabel('Counts')
title('Green Move Interruptions')
set(gca,'box','on')

% (b) Movement duration
t1 = trial.t_emg2bp(ind1);
t2 = trial.t_emg2bp(ind2);

subplot 122, hold on
histogram(t1)
histogram(t2)
legend('yes','no','location','west')
xlabel('EMG onset to button press (ms)')
ylabel('Counts')
title('Green Move Interruptions')
set(gca,'box','on')

% --> Although these are all MOVE interruptions, there seems to be a clear
% distinction between cued (i.e. no) and self-paced (i.e. yes) button
% presses, both in terms of reaction time for cued movements (left) and
% movement duration (right)
% --> I find it very suspicious that the reaction time to go cues was
% ~500 ms, since normal RTs are around 250ms. If this is because of the
% processing time for differentiating green from red (i.e. deciding whether
% to go or stop), we might need to consider to separate green and red
% trials into blocks again


%% (3) RED MOVE interruptions

tl_fig_init;

% (a) Movement to interruption (completed vs. aborted)
ind1 = trial.red & trial.move & trial.interrupted & trial.emg_onset &  trial.button_press;
ind2 = trial.red & trial.move & trial.interrupted & trial.emg_onset & ~trial.button_press;
t1 = trial.t_emg2int(ind1);
t2 = trial.t_emg2int(ind2);

subplot 121, hold on
histogram(t1,opt.fig.pred_edges)
histogram(t2,opt.fig.pred_edges)
this_ylim = get(gca,'ylim');
plot([0 0],this_ylim,'k--')
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)],'ylim',this_ylim)
xlabel('Time to EMG onset (ms)')
ylabel('Counts')
title('Red Move Interruptions')
set(gca,'box','on')
legend('Completed button press','Aborted button press','location','west')

% (b) Movement to interruption (yes vs. no)
ind1 = trial.red & trial.move & trial.emg_onset & trial.prompted & trial.yes;
ind2 = trial.red & trial.move & trial.emg_onset & trial.prompted & trial.no;
t1 = trial.t_emg2int(ind1);
t2 = trial.t_emg2int(ind2);

subplot 122, hold on
histogram(t1,opt.fig.pred_edges)
histogram(t2,opt.fig.pred_edges)
plot([0 0],this_ylim,'k--')
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)],'ylim',this_ylim)
xlabel('Time to EMG onset (ms)')
ylabel('Counts')
title('Red Move Interruptions')
set(gca,'box','on')
legend('yes','no','location','west')

% --> There were 11 cases of completed button presses, where the
% interruptions came too late to stop. The two cases of aborted movements
% are very suspicious as in the GREEN interruptions, i.e. it is very weird
% to start a movement half a second after a RED light. These seem to be
% cases of confusing RED for GREEN lights...?




