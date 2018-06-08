
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

%% (3) GREEN MOVE
ind1 = trial.green & trial.idle & trial.prompted & trial.yes;
ind2 = trial.green & trial.idle & trial.prompted & trial.no;

tl_fig_init;

% (a) Movement to interruption
t1 = trial.t_emg2int(ind1);
t2 = trial.t_emg2int(ind2);

subplot 121, hold on
histogram(t1,opt.fig.pred_edges,'normalization','probability')
histogram(t2,opt.fig.pred_edges,'normalization','probability')
plot([0 0],get(gca,'ylim'),'k--','linewidth',2)
legend('YES','NO','location','northwest')
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)])
xlabel('Trial start to EMG onset (ms)')
ylabel('Probability')
title('Green Lights')
set(gca,'box','on')

% (b) Movement duration
t1 = trial.t_emg2bp(ind1);
t2 = trial.t_emg2bp(ind2);
[~,edges] = histcounts([t1 t2],'binmethod','scott');

subplot 122, hold on
histogram(t1,edges,'normalization','probability')
histogram(t2,edges,'normalization','probability')
legend('yes','no','location','northeast')
xlabel('EMG onset to button press (ms)')
title('Green Lights')
set(gca,'box','on')

%% (3) RED MOVE

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
plot([0 0],this_ylim,'k--','linewidth',2)
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)],'ylim',this_ylim)
xlabel('Trial start to EMG onset (ms)')
ylabel('Counts')
title('Red Move Lights')
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
plot([0 0],this_ylim,'k--','linewidth',2)
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)],'ylim',this_ylim)
xlabel('Trial start to EMG onset (ms)')
ylabel('Counts')
title('Red Move Lights')
set(gca,'box','on')
legend('YES','NO','location','west')

%% (3) REACTION TIME
ind3 = trial.rt;
tl_fig_init;

% (a) Movement to interruption
t3 = trial.t_emg2int(ind3);

subplot 121, hold on
histogram(t3,opt.fig.pred_edges,'normalization','probability')
plot([0 0],get(gca,'ylim'),'k--','linewidth',2)
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)])
xlabel('Trial start to EMG onset (ms)')
ylabel('Probability')
title('GO lights')
set(gca,'box','on')

% (b) Movement duration
t3 = trial.t_emg2bp(ind3);

subplot 122, hold on
histogram(t3,'normalization','probability')
xlabel('EMG onset to button press (ms)')
title('GO Lights')
set(gca,'box','on')

%% RESPONSES

% trial indices
ind_GMY = trial.green & trial.move & trial.prompted & trial.yes;
ind_GMN = trial.green & trial.move & trial.prompted & trial.no;
ind_GIY = trial.green & trial.idle & trial.prompted & trial.yes;
ind_GIN = trial.green & trial.idle & trial.prompted & trial.no;
ind_RMY = trial.red & trial.move & trial.prompted & trial.yes;
ind_RMN = trial.red & trial.move & trial.prompted & trial.no;
ind_RIY = trial.red & trial.idle & trial.prompted & trial.yes;
ind_RIN = trial.red & trial.idle & trial.prompted & trial.no;

% numbers
n_GMY = sum(ind_GMY);
n_GMN = sum(ind_GMN);
n_GIY = sum(ind_GIY);
n_GIN = sum(ind_GIN);
n_RMY = sum(ind_RMY);
n_RMN = sum(ind_RMN);
n_RIY = sum(ind_RIY);
n_RIN = sum(ind_RIN);

% YES ratios
% GREEN
r_GM = n_GMY / (n_GMY+n_GMN);
r_GI = n_GIY / (n_GIY+n_GIN);
r_G  = (n_GMY+n_GIY) / (n_GMY+n_GMN+n_GIY+n_GIN);
% RED
r_RM = n_RMY / (n_RMY+n_RMN);
r_RI = n_RIY / (n_RIY+n_RIN);
r_R  = (n_RMY+n_RIY) / (n_RMY+n_RMN+n_RIY+n_RIN);
% MOVE
r_M  = (n_GMY+n_RMY) / (n_GMY+n_RMY+n_GMN+n_RMN);
% IDLE
r_I  = (n_GIY+n_RIY) / (n_GIY+n_RIY+n_GIN+n_RIN);

% plot ratios
tl_fig_init;
clrs = lines(10);
ylim = [0 80];

subplot 131
bh = bar([r_GM r_RM;r_GI r_RI]*100);
bh(1).FaceColor = clrs(5,:);
bh(2).FaceColor = clrs(2,:);
set(gca,'xticklabel',{'MOVE','IDLE'},'ylim',ylim)
ylabel('%')
legend('YES','NO')

subplot 132
bh = bar([r_M r_I]*100);
bh.FaceColor = clrs(1,:);
set(gca,'xticklabel',{'MOVE','IDLE'},'ylim',ylim)
ylabel('%')
title('Percentage of YES answers')

subplot 133
bh = bar([r_G r_R]*100);
bh.FaceColor = clrs(1,:);
set(gca,'xticklabel',{'GREEN','RED'},'ylim',ylim)
ylabel('%')














