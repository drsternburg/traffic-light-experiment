
warning off

subj_code = 'VPtae';
[mrk,cnt,mnt] = tl_proc_loadData(subj_code);
trial = tl_mrk_analyzeTrials(mrk);
BTB.FigPos = [55 4]; % internally for MSK


%% (1) SILENT interruptions distribution

tl_fig_init; hold on
ind = trial.interrupted_silent; % all trials with silent interruptions
t = trial.t_emg2sil(ind);
histogram(t,opt.fig.pred_edges)
plot([0 0],get(gca,'ylim'),'k--','linewidth',2)
xlabel('Time to EMG onset (ms)')
ylabel('Counts')
set(gca,'box','on')
title('Silent interruptions distribution')

%% (2) Compare PHASE 1 and PHASE 2 (only self-paced movements)

ind1 = trial.phase1; % all phase 1 trials
ind2 = ~trial.phase1 & ~trial.rt & trial.emg_onset & trial.button_press & ... % phase 2 trials with emg onsets ...
       ~(trial.green & trial.prompted & trial.no); % ... excluding green trials where the response to a prompt was 'no' (because these were presumably cued and not self-paced button presses)

tl_fig_init;

% (a) Movement duration
t1 = trial.t_emg2bp(ind1);
t1(logical(t1>1000)) = [];
t2 = trial.t_emg2bp(ind2);
t2(logical(t2>1000)) = [];

subplot 121, hold on
histogram(t1)
histogram(t2)
legend('Phase1','Phase2')
set(gca,'box','on')
title('Movement duration')
xlabel('EMG onset to button press (ms)')

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

%%
ind1 = trial.green & trial.prompted & trial.yes & trial.emg_onset;
ind2 = trial.green & trial.prompted & trial.no & trial.emg_onset;

% (a)
mrk1 = tl_mrk_selectTrials(mrk,ind1);
mrk1 = mrk_selectClasses(mrk1,'EMG onset');
mrk1.className = {'Green Yes EMG onset'};

mrk2 = tl_mrk_selectTrials(mrk,ind2);
mrk2 = mrk_selectClasses(mrk2,'EMG onset');
mrk2.className = {'Green No EMG onset'};

mrk12 = mrk_mergeMarkers(mrk1,mrk2);
erp = proc_segmentation(cnt,mrk12,[-1500 0]);
erp = proc_baseline(erp,100,'beginning');
rsq = proc_rSquareSigned(erp);

tl_fig_init;
H = grid_plot(erp,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/8);

%% (b)
mrk1 = tl_mrk_selectTrials(mrk,ind1);
mrk1 = tl_mrk_unifyMarkers(mrk1,'light');
mrk1 = mrk_selectClasses(mrk1,'light');
mrk1.className = {'Green Light Yes'};

mrk2 = tl_mrk_selectTrials(mrk,ind2);
mrk2 = tl_mrk_unifyMarkers(mrk2,'light');
mrk2 = mrk_selectClasses(mrk2,'light');
mrk2.className = {'Green Light No'};

mrk12 = mrk_mergeMarkers(mrk1,mrk2);
erp = proc_segmentation(cnt,mrk12,[-100 800]);
erp = proc_selectChannels(erp,'not','EMG');
erp = proc_rejectArtifactsMaxMin(erp,500);
erp = proc_baseline(erp,100,'beginning');
rsq = proc_rSquareSigned(erp);

tl_fig_init;
H = grid_plot(erp,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/8);

%% REACTION TIME
tl_fig_init;

ind = trial.rt;

t = trial.t_emg2int(ind);

edges = -600:50:200;

mrk1 = tl_mrk_selectTrials(mrk,ind);
mrk1 = mrk_selectClasses(mrk1,'EMG onset');
erp = proc_segmentation(cnt,mrk1,[edges(1) edges(end)]);
erp = proc_baseline(erp,100,'beginning');

subplot 211, hold on
histogram(t,edges)
this_ylim = get(gca,'ylim');
plot([0 0],this_ylim,'k--')
set(gca,'xlim',[edges(1) edges(end)],'ylim',this_ylim)
xlabel('Time to EMG onset (ms)')
ylabel('Counts')
title('Reaction Time')
set(gca,'box','on')

subplot 212, hold on
plot_channel(erp,'Cz');

%% REACTION TIME vs. GREEN GO

ind1 = trial.green & trial.move & trial.prompted & trial.no;
ind2 = trial.green & trial.move & trial.prompted & trial.yes;
ind3 = trial.rt;

t1 = trial.t_emg2int(ind1);
t2 = trial.t_emg2int(ind2);
t3 = trial.t_emg2int(ind3);

edges = -800:50:200;

tl_fig_init; hold on

histogram(t1,edges,'normalization','probability')
histogram(t2,edges,'normalization','probability')
histogram(t3,edges,'normalization','probability')
plot([0 0],get(gca,'ylim'),'k--')
legend('GREEN NO (phase 2)','GREEN YES (phase 2)','RT (phase 3)','location','west')
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)])
xlabel('Time to EMG onset (ms)')
ylabel('Counts')
title('Green Interruptions')
set(gca,'box','on')

%% ERP MOVE vs. IDLE
ind1 = trial.move & trial.interrupted;
ind2 = trial.idle & trial.interrupted;

mrk1 = tl_mrk_selectTrials(mrk,ind1);
mrk1 = tl_mrk_unifyMarkers(mrk1,'light');
mrk1 = mrk_selectClasses(mrk1,'light');
mrk1.className = {'MOVE Light'};

mrk2 = tl_mrk_selectTrials(mrk,ind2);
mrk2 = tl_mrk_unifyMarkers(mrk2,'light');
mrk2 = mrk_selectClasses(mrk2,'light');
mrk2.className = {'IDLE Light'};

mrk12 = mrk_mergeMarkers(mrk1,mrk2);
erp = proc_segmentation(cnt,mrk12,[-1500 200]);
erp = proc_selectChannels(erp,'not','EMG');
erp = proc_baseline(erp,100,'beginning');
rsq = proc_rSquareSigned(erp);

tl_fig_init;
plot_channel(erp,'Cz');

tl_fig_init;
H = grid_plot(erp,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/8);

%%
tl_fig_init; hold on
t = 1/cnt.fs:1/cnt.fs:size(cnt.x,1)/cnt.fs;
plot(t,cnt.x(:,8))
mrk1 = mrk_selectClasses(mrk,'EMG onset');
for ii = 1:length(mrk1.time)
    plot([1 1]*mrk1.time(ii)/1000,ylim,'r')
end























