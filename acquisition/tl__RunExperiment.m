
global opt
warning off

%% setup participant
acq_makeDataFolder;

%% Start BrainVision Recorder and load workspace
system('C:\Vision\Recorder\Recorder.exe &'); pause(8);
bvr_sendcommand('loadworkspace',opt.eeg.bv_workspace);
bvr_sendcommand('stoprecording'); % assert that no previous session is running

%% EEG impedance check
bvr_sendcommand('checkimpedances');
stimutil_waitForInput('Msg','Finished to prepare the cap?');
bvr_sendcommand('viewsignals');

%% Test the triggers
bbci_trigger_parport(10,BTB.Acq.IoLib,BTB.Acq.IoAddr);

%% Setup BBCI for phase 1
bbci = tl_bbci_setup;

%% Training for Phase 1
tl_acq_startRecording('Training1',bbci)

%% Phase 1
tl_acq_startRecording('Phase1',bbci)

%% Preprocess
basename = sprintf('%s_%s_',opt.session_name,'Phase1');
filename = [BTB.Tp.Dir(17:end) '\' basename BTB.Tp.Code];
tl_proc_convertBVData(filename);
tl_mrk_initialCleanup(BTB.Tp.Code,'Phase1');
tl_proc_registerEMGOnsets(BTB.Tp.Code,'Phase1',0)

%% Inspect data
t_ts2emg = tl_acq_quickInspection;

%% Compute sliding classifier output, this might take a while...
[mrk,cnt] = tl_proc_loadData(BTB.Tp.Code,'Phase1');
mrk = tl_mrk_selectTrials(mrk);
mrk = mrk_selectClasses(mrk,{'start phase1','EMG onset','trial end'});
cout = tl_proc_slidingClassification(cnt,mrk);

%% Find and inspect optimal prediction threshold
opt.pred.tp_ival = [-600 -100];
tl_proc_findClassifierThreshold(cout);

%% Confirm threshold, train classifier and update BBCI
mrk = tl_mrk_setClassifierMarkers(mrk);
fv = tl_proc_extractFeatures(cnt,mrk);
opt.cfy.C = train_RLDAshrink(fv.x,fv.y);
bbci = tl_bbci_setup;

%% Training for Phase 2
opt.feedback.pyff_params(3).ir_idle_waittime = tl_acq_drawIdleWaitTimes(100,t_ts2emg);
tl_acq_startRecording('Training2',bbci)

%% Phase 2
opt.feedback.pyff_params(4).ir_idle_waittime = tl_acq_drawIdleWaitTimes(1000,t_ts2emg);
tl_acq_startRecording('Phase2',bbci)

%% Reaction Time
opt.feedback.pyff_params(5).ir_idle_waittime = tl_acq_drawIdleWaitTimes(1000,[2000 5000]);
tl_startRecording('RT',bbci)

%% Save options struct
optfile = [fullfile(BTB.Tp.Dir,opt.session_name) '_' BTB.Tp.Code '_opt'];
save(optfile,'opt')




