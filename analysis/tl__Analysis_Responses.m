
warning off

subj_code = 'VPtai';
[mrk,cnt,mnt] = tl_proc_loadData(subj_code);
trial = tl_mrk_analyzeTrials(mrk);
BTB.FigPos = [55 4]; % internally for MSK


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
tl_fig_init(30,15);
clrs = lines(10);
ylim = [0 80];

subplot 141
bh = bar([r_GM r_RM;r_GI r_RI]*100);
bh(1).FaceColor = clrs(5,:);
bh(2).FaceColor = clrs(2,:);
set(gca,'xticklabel',{'MOVE','IDLE'},'ylim',ylim,'box','on')
ylabel('Percentage YES answers (%)')
legend('GREEN','RED')
title('Types and Colors')

subplot 142
bh = bar([r_M r_I]*100);
bh.FaceColor = clrs(1,:);
set(gca,'xticklabel',{'MOVE','IDLE'},'ylim',ylim,'box','on')
title('Colors merged')

subplot 143, hold on
bh1 = bar(1,r_G*100);
bh2 = bar(2,r_R*100);
bh1.FaceColor = clrs(5,:);
bh2.FaceColor = clrs(2,:);
set(gca,'xtick',1:2,'xticklabel',{'GREEN','RED'},'ylim',ylim,'box','on')
title('Types merged')

% COVERT VETOS
ind_IY = trial.red & trial.idle & trial.interrupted & ~trial.emg_onset & ~trial.button_press & trial.yes;
ind_IN = trial.red & trial.idle & trial.interrupted & ~trial.emg_onset & ~trial.button_press & trial.no;
ind_MY = trial.red & trial.move & trial.interrupted & ~trial.emg_onset & ~trial.button_press & trial.yes;
ind_MN = trial.red & trial.move & trial.interrupted & ~trial.emg_onset & ~trial.button_press & trial.no;

r_I = sum(ind_IY)/sum([ind_IY ind_IN]);
r_M = sum(ind_MY)/sum([ind_MY ind_MN]);

subplot 144
bh = bar([r_M r_I]*100);
bh.FaceColor = clrs(2,:);
set(gca,'xticklabel',{'MOVE','IDLE'},'ylim',ylim,'box','on')
title('RED, no overt movement')











