
function t_ts2emg = tl_acq_quickInspection(subj_code)
% Performs a quick inspection of recorded Phase1 data and returns the
% waiting times

%% prepare data
[mrk,cnt,mnt] = tl_proc_loadData(subj_code,'Phase1');
trial = tl_mrk_analyzeTrials(mrk);
mrk = tl_mrk_selectTrials(mrk,trial.emg_onset);
mrk = mrk_selectClasses(mrk,{'start phase1','EMG onset'});

%% cross-validation
mrk_ = tl_mrk_setClassifierMarkers(mrk);
fv = tl_proc_extractFeatures(cnt,mrk_);
loss = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',{@sample_KFold,[3 10]});
acc = 100*(1-loss);
fprintf('\nClassification accuracy: %2.1f\n',acc)

%% waiting time histogram
ci_emg = strcmp(mrk.className,'EMG onset');
ci_ts = strcmp(mrk.className,'start phase1');
i_emg = logical(mrk.y(logical(ci_emg),:));
i_ts = logical(mrk.y(logical(ci_ts),:));

t_ts2emg = mrk.time(i_emg) - mrk.time(i_ts);

tl_fig_init;
if verLessThan('matlab', '8.4')
    hist(t_ts2emg/1000)
else
    histogram(t_ts2emg/1000)
end
xlabel('Waiting time (s)')
ylabel('# counts')

%% visualization of RPs
epo = proc_segmentation(cnt,mrk,[-1000 0]);
epo = proc_baseline(epo,200,'beginning');
rsq = proc_rSquareSigned(epo);

tl_fig_init;
H = grid_plot(epo,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/7);
