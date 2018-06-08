
subj_code = 'VPtab';

%%
warning off
[mrk,cnt,mnt] = tl_proc_loadData(subj_code);
trial = tl_mrk_analyzeTrials(mrk);
BTB.FigPos = [55 4]; % internally for MSK
tl_fig_init(30,20);

%% (1) SILENT interruptions distribution
subplot(3,4,[1 2]), hold on

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

subplot(3,4,3), hold on

% (a) waiting time
t1 = trial.t_ts2emg(ind1);
%t1(logical(t1>1000)) = [];
t2 = trial.t_ts2emg(ind2);
%t2(logical(t2>1000)) = [];
histogram(t1/1000,'normalization','probability')
histogram(t2/1000,'normalization','probability')
lh = legend('Phase1','Phase2');
set(lh,'box','off')
set(gca,'box','on')
title('Waiting time')
xlabel('Time to EMG onset (s)')

subplot(3,4,4), hold on

% (b) Movement duration
t1 = trial.t_emg2bp(ind1);
t1(logical(t1>1000)) = [];
t2 = trial.t_emg2bp(ind2);
t2(logical(t2>1000)) = [];
histogram(t1,'normalization','probability')
histogram(t2,'normalization','probability')
lh = legend('Phase1','Phase2');
set(lh,'box','off')
set(gca,'box','on')
title('Movement duration')
xlabel('EMG onset to button press (ms)')

%% (3) GREEN MOVE
ind1 = trial.green & trial.move & trial.prompted & trial.yes;
ind2 = trial.green & trial.move & trial.prompted & trial.no;

% (a) Movement to interruption
t1 = trial.t_emg2int(ind1);
t2 = trial.t_emg2int(ind2);

subplot(3,4,5), hold on

histogram(t1,opt.fig.pred_edges,'normalization','probability')
histogram(t2,opt.fig.pred_edges,'normalization','probability')
plot([0 0],get(gca,'ylim'),'k--','linewidth',2)
lh = legend('YES','NO','location','northwest');
set(lh,'box','off')
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)])
xlabel('Time to EMG onset (ms)')
ylabel('Probability')
title('Green Move Lights')
set(gca,'box','on')

% (b) Movement duration
t1 = trial.t_emg2bp(ind1);
t2 = trial.t_emg2bp(ind2);
[~,edges] = histcounts([t1 t2],'binmethod','scott');

subplot(3,4,6), hold on

histogram(t1,edges,'normalization','probability')
histogram(t2,edges,'normalization','probability')
lh = legend('yes','no','location','northeast');
set(lh,'box','off')
xlabel('EMG onset to button press (ms)')
title('Green Move Lights')
set(gca,'box','on')

%% (3) RED MOVE

% (a) Movement to interruption (completed vs. aborted)
ind1 = trial.red & trial.move & trial.interrupted & trial.emg_onset &  trial.button_press;
ind2 = trial.red & trial.move & trial.interrupted & trial.emg_onset & ~trial.button_press;
t1 = trial.t_emg2int(ind1);
t2 = trial.t_emg2int(ind2);

subplot(3,4,7), hold on

histogram(t1,opt.fig.pred_edges)
histogram(t2,opt.fig.pred_edges)
this_ylim = get(gca,'ylim');
plot([0 0],this_ylim,'k--','linewidth',2)
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)],'ylim',this_ylim)
xlabel('Time to EMG onset (ms)')
ylabel('Counts')
title('Red Move Lights')
set(gca,'box','on')
lh = legend('Completed button press','Aborted button press','location','northwest');
set(lh,'box','off')

% (b) Movement to interruption (yes vs. no)
ind1 = trial.red & trial.move & trial.emg_onset & trial.prompted & trial.yes;
ind2 = trial.red & trial.move & trial.emg_onset & trial.prompted & trial.no;
t1 = trial.t_emg2int(ind1);
t2 = trial.t_emg2int(ind2);

subplot(3,4,8), hold on

histogram(t1,opt.fig.pred_edges)
histogram(t2,opt.fig.pred_edges)
plot([0 0],this_ylim,'k--','linewidth',2)
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)],'ylim',this_ylim)
xlabel('Time to EMG onset (ms)')
ylabel('Counts')
title('Red Move Lights')
set(gca,'box','on')
lh = legend('YES','NO','location','northwest');
set(lh,'box','off')

%% (3) REACTION TIME
ind3 = trial.rt;
t3 = trial.t_emg2int(ind3);

subplot(3,4,9), hold on

histogram(t3,opt.fig.pred_edges,'normalization','probability')
plot([0 0],get(gca,'ylim'),'k--','linewidth',2)
set(gca,'xlim',[-1000 opt.fig.pred_edges(end)])
xlabel('Time to EMG onset (ms)')
ylabel('Probability')
title('GO lights (RT task)')
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
clrs = lines(10);
ylim = [0 80];

subplot(3,4,10), hold on
bh = bar([r_GM r_RM;r_GI r_RI]*100);
bh(1).FaceColor = clrs(5,:);
bh(2).FaceColor = clrs(2,:);
set(gca,'xtick',[1 2],'xticklabel',{'MOVE','IDLE'},'ylim',ylim,'box','on')
ylabel('%')
lh = legend('YES','NO');
set(lh,'box','off')
grid on

subplot(3,4,11), hold on
bh = bar([r_M r_I]*100);
bh.FaceColor = clrs(1,:);
set(gca,'xtick',[1 2],'xticklabel',{'MOVE','IDLE'},'ylim',ylim,'box','on')
ylabel('%')
title('Percentage of YES answers')
grid on

subplot(3,4,12), hold on
bh = bar([r_G r_R]*100);
bh.FaceColor = clrs(1,:);
set(gca,'xtick',[1 2],'xticklabel',{'GREEN','RED'},'ylim',ylim,'box','on')
ylabel('%')
grid on














