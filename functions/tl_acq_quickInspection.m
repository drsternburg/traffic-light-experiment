
function t_ts2emg = tl_acq_quickInspection

global opt BTB

%% prepare data
[cnt,mrk,mnt] = tl_proc_loadData(BTB.Tp.Code,'Phase1');
mrk = tl_mrk_assembleTrials(mrk,'phase1');
mrk = mrk_selectClasses(mrk,{'start phase1','EMG onset'});

%% cross-validation
mrk_ = tl_mrk_setIdleMoveMarkers(mrk,opt);
fv = tl_proc_extractFeatures(cnt,mrk_,opt);
loss = crossvalidation(fv,@train_RLDAshrink,'SampleFcn',{@sample_KFold,[3 10]});
acc = 100*(1-loss);
fprintf('\nClassification accuracy: %2.1f\n',acc)

%% waiting time histogram
ci_emg = strcmp(mrk.className,'EMG onset');
ci_ts = strcmp(mrk.className,'start phase1');
i_emg = find(mrk.y(logical(ci_emg),:));
i_ts = find(mrk.y(logical(ci_ts),:));

t_ts2emg = mrk.time(i_emg) - mrk.time(i_ts);

init_figure;
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

init_figure;
H = grid_plot(epo,mnt);
grid_addBars(rsq,'HScale',H.scale,'Height',1/7);
