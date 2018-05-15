
tl__setupEnvironment;
global opt
subj_code = 'VPtaa';
ana = tl_ana_getTrialEvents(subj_code);
BTB.FigPos = [55 4];

%% SILENT INTERRUPTION
%% distribution
init_figure;
t = ana.t_emg2sil(logical(ana.interrupted_silent));
histogram(t,opt.fig.pred_edges)


%% PHASE1 vs PHASE2
%% movement duration difference
init_figure; hold on
histogram(ana.t_emg2bp(logical(ana.trial_type==5)))
histogram(ana.t_emg2bp(logical(ana.trial_type~=5)))

%% difference RP
init_figure;
[mrk,cnt] = tl_proc_loadData(subj_code);
ind1 = find(ana.trial_type==5&ana.emg_onset);
mrk1 = tl_mrk_selectTrials(mrk,ind1,0);
mrk1 = mrk_selectClasses(mrk1,'EMG onset');
mrk1.className = {'Phase 1'};
ind2 = find(ana.trial_type~=5&ana.emg_onset);
mrk2 = tl_mrk_selectTrials(mrk,ind2,0);
mrk2 = mrk_selectClasses(mrk2,'EMG onset');
mrk2.className = {'Phase 2'};
mrk = mrk_mergeMarkers(mrk1,mrk2);
erp = proc_segmentation(cnt,mrk,[-1500 300]);
erp = proc_baseline(erp,100,'beginning');
plot_channel(erp,'Cz');


%% GREEN MOVE
%% movement-interruption for yes/no
init_figure; hold on
t1 = ana.t_emg2int(logical(ana.trial_type==2&ana.yes&ana.prompted));
t2 = ana.t_emg2int(logical(ana.trial_type==2&~ana.yes&ana.prompted));
histogram(t1,opt.fig.pred_edges)
histogram(t2,opt.fig.pred_edges)
legend('yes','no','location','west')

%% movement duration for yes/no
init_figure; hold on
t1 = ana.t_emg2bp(logical(ana.trial_type==2&ana.yes&ana.prompted));
t2 = ana.t_emg2bp(logical(ana.trial_type==2&~ana.yes&ana.prompted));
histogram(t1)
histogram(t2)
legend('yes','no','location','west')


%% RED MOVE
%% stopping movement
init_figure; hold on
t1 = ana.t_emg2int(logical(ana.trial_type==1&ana.button_press));
t2 = ana.t_emg2int(logical(ana.trial_type==1&~ana.button_press));
histogram(t1,opt.fig.pred_edges)
histogram(t2,opt.fig.pred_edges)
legend('finished','stopped','location','west')

%% stopping movement
init_figure; hold on
t1 = ana.t_emg2int(logical(ana.trial_type==1&ana.yes&ana.prompted));
t2 = ana.t_emg2int(logical(ana.trial_type==1&~ana.yes&ana.prompted));
histogram(t1,opt.fig.pred_edges)
histogram(t2,opt.fig.pred_edges)
legend('yes','no','location','west')





