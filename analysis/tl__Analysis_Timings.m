
warning off

subj_code = 'VPtat';
[mrk,cnt,mnt] = tl_proc_loadData(subj_code);
trial = tl_mrk_analyzeTrials(mrk);
BTB.FigPos = [55 4]; % internally for MSK


%% (1) SILENT interruptions distribution
tl_fig_init; hold on

ind = trial.interrupted_silent; % all trials with silent interruptions
t = trial.t_emg2sil(ind);
histogram(t,opt.fig.pred_edges)
plot([0 0],get(gca,'ylim'),'k--','linewidth',2)
xlabel('Trial start to EMG onset (ms)')
ylabel('Counts')
set(gca,'box','on')
title('Silent interruptions distribution')

%% (2) Compare PHASE 1 and PHASE 2 (only self-paced movements)

ind1 = trial.phase1; % all phase 1 trials
ind2 = ~trial.phase1 & ~trial.rt & trial.emg_onset & trial.button_press & ... % phase 2 trials with emg onsets ...
       ~(trial.green & trial.prompted & trial.no); % ... excluding green trials where the response to a prompt was 'no' (because these were presumably cued and not self-paced button presses)

tl_fig_init;

% (a) waiting time
subplot 121, hold on
t1 = trial.t_ts2emg(ind1);
%t1(logical(t1>1000)) = [];
t2 = trial.t_ts2emg(ind2);
%t2(logical(t2>1000)) = [];
histogram(t1/1000,'normalization','probability')
histogram(t2/1000,'normalization','probability')
legend('Phase1','Phase2')
set(gca,'box','on')
title('Waiting time')
xlabel('Trial start to EMG onset (s)')

% (b) Movement duration
subplot 122, hold on
t1 = trial.t_emg2bp(ind1);
t1(logical(t1>1000)) = [];
t2 = trial.t_emg2bp(ind2);
t2(logical(t2>1000)) = [];
histogram(t1,'normalization','probability')
histogram(t2,'normalization','probability')
legend('Phase1','Phase2')
set(gca,'box','on')
title('Movement duration')
xlabel('EMG onset to button press (ms)')

%% (3) GREEN LIGHTS
hnorm = 'count';
xlim = [-1000 600];
tl_fig_init(20,20);

% (a) MOVE
ind1 = trial.green & trial.move & trial.emg_onset & trial.yes;
ind2 = trial.green & trial.move & trial.emg_onset & trial.no;
ind12 = trial.green & trial.move;
f12 = sum(ind1|ind2)/sum(ind12);
ind3 = trial.idle & trial.interrupted_silent & trial.emg_onset;
ind31 = trial.idle;
f3 = sum(ind3)/sum(ind31);
t1 = trial.t_emg2int(ind1);
t2 = trial.t_emg2int(ind2);
t3 = trial.t_emg2sil(ind3);
c1 = histcounts(t1,opt.fig.pred_edges,'normalization',hnorm);
c2 = histcounts(t2,opt.fig.pred_edges,'normalization',hnorm);
c3 = histcounts(t3,opt.fig.pred_edges,'normalization',hnorm);

subplot 211, hold on
histogram('BinEdges',opt.fig.pred_edges,'BinCounts',c1/f12)
histogram('BinEdges',opt.fig.pred_edges,'BinCounts',c2/f12)
histogram('BinEdges',opt.fig.pred_edges,'BinCounts',c3/f3,'displaystyle','stairs','linewidth',2)
plot([0 0],get(gca,'ylim'),'k--','linewidth',2)
legend('YES','NO','location','northwest')
set(gca,'xlim',xlim)
xlabel('Trial start to EMG onset (ms)')
ylabel('Counts')
title('Green Move')
set(gca,'box','on')

% (b) IDLE
ind4 = trial.green & trial.idle & trial.emg_onset & trial.prompted & trial.yes;
ind5 = trial.green & trial.idle & trial.emg_onset & trial.prompted & trial.no;
t4 = trial.t_emg2int(ind4);
t5 = trial.t_emg2int(ind5);
c4 = histcounts(t4,opt.fig.pred_edges,'normalization',hnorm);
c5 = histcounts(t5,opt.fig.pred_edges,'normalization',hnorm);

subplot 212, hold on
histogram('BinEdges',opt.fig.pred_edges,'BinCounts',c4)
histogram('BinEdges',opt.fig.pred_edges,'BinCounts',c5)
plot([0 0],get(gca,'ylim'),'k--','linewidth',2)
legend('YES','NO','location','northeast')
set(gca,'xlim',xlim)
xlabel('Trial start to EMG onset (ms)')
ylabel('Counts')
title('Green Idle')
set(gca,'box','on')

%% (3) RED LIGHTS
tl_fig_init(20,20);

% (a) Move
ind1 = trial.red & trial.move & trial.interrupted & trial.emg_onset &  trial.button_press;
ind2 = trial.red & trial.move & trial.emg_onset & trial.prompted & trial.yes;
ind3 = trial.red & trial.move & trial.emg_onset & trial.prompted & trial.no;
t1 = trial.t_emg2int(ind1);
t2 = trial.t_emg2int(ind2);
t3 = trial.t_emg2int(ind3);

subplot 211, hold on
histogram(t1,opt.fig.pred_edges)
histogram(t2,opt.fig.pred_edges)
histogram(t3,opt.fig.pred_edges)
this_ylim = get(gca,'ylim');
plot([0 0],this_ylim,'k--','linewidth',2)
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)],'ylim',this_ylim)
xlabel('Trial start to EMG onset (ms)')
ylabel('Counts')
title('Red Move')
set(gca,'box','on')
legend('Completed (not prompted, implied YES)','Aborted YES','Aborted NO','location','west')

% (b) Idle
ind1 = trial.red & trial.idle & trial.interrupted & trial.emg_onset &  trial.button_press;
ind2 = trial.red & trial.idle & trial.emg_onset & trial.prompted & trial.yes;
ind3 = trial.red & trial.idle & trial.emg_onset & trial.prompted & trial.no;
t1 = trial.t_emg2int(ind1);
t2 = trial.t_emg2int(ind2);
t3 = trial.t_emg2int(ind3);

subplot 212, hold on
histogram(t1,opt.fig.pred_edges)
histogram(t2,opt.fig.pred_edges)
histogram(t3,opt.fig.pred_edges)
this_ylim = get(gca,'ylim');
plot([0 0],this_ylim,'k--','linewidth',2)
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)],'ylim',this_ylim)
xlabel('Trial start to EMG onset (ms)')
ylabel('Counts')
title('Red Idle')
set(gca,'box','on')
legend('Completed (not prompted, implied YES)','Aborted YES','Aborted NO','location','west')

%% (3) REACTION TIME
tl_fig_init;
hold on

ind3 = trial.rt;
t3 = trial.t_emg2int(ind3);

histogram(t3,opt.fig.pred_edges,'normalization','probability')
plot([0 0],get(gca,'ylim'),'k--','linewidth',2)
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)])
xlabel('Trial start to EMG onset (ms)')
ylabel('Probability')
title('GO lights')
set(gca,'box','on')











