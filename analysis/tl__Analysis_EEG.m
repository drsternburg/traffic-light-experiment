
subj_code = 'VPtab';

warning off
[mrk,cnt,mnt] = tl_proc_loadData(subj_code);
trial = tl_mrk_analyzeTrials(mrk);
BTB.FigPos = [55 4]; % internally for MSK

%% (2) RP PHASE 1 vs. PHASE 2

ind1 = trial.phase1; % all phase 1 trials
ind2 = ~trial.phase1 & ~trial.rt & trial.emg_onset & trial.button_press & ... % phase 2 trials with emg onsets ...
       ~(trial.green & trial.prompted & trial.no); % ... excluding green trials where the response to a prompt was 'no' (because these were presumably cued and not self-paced button presses)

mrk1 = tl_mrk_selectTrials(mrk,ind1);
mrk1 = mrk_selectClasses(mrk1,'EMG onset');
mrk1.className = {'Phase 1'};
mrk2 = tl_mrk_selectTrials(mrk,ind2);
mrk2 = mrk_selectClasses(mrk2,'EMG onset');
mrk2.className = {'Phase 2'};
mrk12 = mrk_mergeMarkers(mrk1,mrk2);
erp = proc_segmentation(cnt,mrk12,[-2000 300]);
erp = proc_baseline(erp,100,'beginning');

tl_fig_init;
plot_channel(erp,'Cz');

%% GREEN YES vs. GREEN NO: Movement locked
ind1 = trial.green & trial.move & trial.prompted & trial.yes & trial.emg_onset;
ind2 = trial.green & trial.move & trial.prompted & trial.no & trial.emg_onset;

mrk1 = tl_mrk_selectTrials(mrk,ind1);
mrk1 = mrk_selectClasses(mrk1,'EMG onset');
mrk1.className = {'Green Yes EMG onset'};

mrk2 = tl_mrk_selectTrials(mrk,ind2);
mrk2 = mrk_selectClasses(mrk2,'EMG onset');
mrk2.className = {'Green No EMG onset'};

mrk12 = mrk_mergeMarkers(mrk1,mrk2);
erp = proc_segmentation(cnt,mrk12,[-2000 200]);
erp = proc_baseline(erp,100,'beginning');
rsq = proc_rSquareSigned(erp);

tl_fig_init;
H = grid_plot(erp,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/8);

%% GREEN YES vs. GREEN NO: Light locked
ind1 = trial.green & trial.move & trial.prompted & trial.yes & trial.emg_onset;
ind2 = trial.green & trial.move & trial.prompted & trial.no & trial.emg_onset;

mrk1 = tl_mrk_selectTrials(mrk,ind1);
mrk1 = tl_mrk_unifyMarkers(mrk1,'light');
mrk1 = mrk_selectClasses(mrk1,'light');
mrk1.className = {'Green Light Yes'};

mrk2 = tl_mrk_selectTrials(mrk,ind2);
mrk2 = tl_mrk_unifyMarkers(mrk2,'light');
mrk2 = mrk_selectClasses(mrk2,'light');
mrk2.className = {'Green Light No'};

mrk12 = mrk_mergeMarkers(mrk1,mrk2);
erp = proc_segmentation(cnt,mrk12,[-1500 200]);
erp = proc_baseline(erp,100,'beginning');
rsq = proc_rSquareSigned(erp);

tl_fig_init;
H = grid_plot(erp,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/8);

%% ERP: self-paced vs. cued
ind1 = trial.phase1;
ind2 = trial.rt;

mrk1 = tl_mrk_selectTrials(mrk,ind1);
mrk1 = mrk_selectClasses(mrk1,'EMG onset');
mrk1.className = {'Self-paced'};

mrk2 = tl_mrk_selectTrials(mrk,ind2);
mrk2 = mrk_selectClasses(mrk2,'EMG onset');
mrk2.className = {'Cued'};

mrk12 = mrk_mergeMarkers(mrk1,mrk2);
erp = proc_segmentation(cnt,mrk12,[-1500 0]);
erp = proc_baseline(erp,100,'beginning');
rsq = proc_rSquareSigned(erp);

tl_fig_init;
H = grid_plot(erp,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/8);

%% ERP: MOVE vs. IDLE
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
H = grid_plot(erp,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/8);

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

% plot P300 MOVE vs. IDLE
mrk1 = tl_mrk_selectTrials(mrk,ind_GMY|ind_GMN|ind_RMY|ind_RMN);
mrk1 = tl_mrk_unifyMarkers(mrk1,'light');
mrk1 = mrk_selectClasses(mrk1,'light');
mrk1.className = {'MOVE'};
mrk2 = tl_mrk_selectTrials(mrk,ind_GIY|ind_GIN|ind_RIY|ind_RIN);
mrk2 = tl_mrk_unifyMarkers(mrk2,'light');
mrk2 = mrk_selectClasses(mrk2,'light');
mrk2.className = {'IDLE'};
mrk12 = mrk_mergeMarkers(mrk1,mrk2);

erp = proc_segmentation(cnt,mrk12,[-100 800]);
erp = proc_baseline(erp,100,'beginning');
rsq = proc_rSquareSigned(erp);

tl_fig_init;
H = grid_plot(erp,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/8);
















