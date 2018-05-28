
global BTB opt
opt = struct;

opt.session_name = 'TrafficLight';

%%
addpath(fullfile(BTB.PrivateDir,'traffic-light-experiment'))
addpath(fullfile(BTB.PrivateDir,'traffic-light-experiment','functions'))
addpath(fullfile(BTB.PrivateDir,'traffic-light-experiment','acquisition'))

%%
BTB.Acq.Geometry = [1281 1 1280 998];
BTB.Acq.Dir = fullfile(BTB.PrivateDir,'traffic-light-experiment','acquisition');
BTB.Acq.IoAddr = hex2dec('0378');
BTB.PyffDir = 'C:\bbci\pyff\src';
BTB.Acq.Prefix = 't';
BTB.Acq.StartLetter = 'a';
BTB.FigPos = [1 1];

%% parameters for raw data
opt.eeg.nr_eeg_chans = 30;
opt.eeg.bv_workspace = 'C:\Vision\Workfiles\IntentionPrompting_motor';
opt.eeg.orig_fs = 1000;
Wps = [42 49]/opt.eeg.orig_fs*2;
[n,Ws] = cheb2ord(Wps(1),Wps(2),3,40);
[opt.eeg.filt.b,opt.eeg.filt.a] = cheby2(n,50,Ws);
opt.eeg.fs = 100;

%% markers
opt.mrk.min_ts2bp = 1500;
opt.mrk.def = {  2 'button press';...
               -10 'start silent';...
               -11 'start move red';...
               -12 'start move green';...
               -13 'start idle red';...
               -14 'start idle green';...
               -20 'light silent';...
               -21 'light move red';...
               -22 'light move green';...
               -23 'light idle red';...
               -24 'light idle green';...
               -30 'trial end';...
               -40 'prompt'
               }';

%% parameters for finding EMG onsets
opt.emg.emg2bp_range = [150 700]; % ms
opt.emg.wlen_bsln = 1000; % ms
opt.emg.wlen_det = 50; % ms
opt.emg.sd_fac = 3.5;

%% parameters for classification
fv_ivals = fliplr(-[0 50 100 200 300 450 650 900 1200]);
fv_ivals = [fv_ivals(1:end-1)'+10 fv_ivals(2:end)'];
opt.cfy.baseln_len = 50;
opt.cfy.baseln_pos = 'end';
opt.cfy.fv_ivals = fv_ivals;
opt.cfy.fv_window = [opt.cfy.fv_ivals(1)-10 0];
opt.cfy.clab = {'not','E*'};
opt.cfy.idle_mode = 'optimal';
opt.cfy.idle_offset = -opt.cfy.fv_window(1);
opt.cfy.min_ts2emg = -opt.cfy.fv_window(1)*2+500;

% for the fake classifier of phase 1:
opt.cfy.C.gamma = randn;
opt.cfy.C.b = randn;
opt.cfy.C.w = randn(size(opt.cfy.fv_ivals,1)*opt.eeg.nr_eeg_chans,1);

%% parameters for finding optimal prediction threshold
opt.pred.tp_ival = [-600 -100];
opt.pred.fscore_beta = .5;
opt.pred.thresh = 0; % for the fake classifier of phase 1

%% figure parameters
opt.fig.pred_edges = -2500:100:300;

%% feedback parameters
opt.feedback.name  = 'TrafficLight';

opt.feedback.blocks = {'Training1','Phase1','Training3','Phase2'};

opt.feedback.rec_params(1).record_audio = 0;
opt.feedback.rec_params(1).save_opt = 0;
opt.feedback.pyff_params(1).listen_to_keyboard = int16(0); % turn off keyboard mode
opt.feedback.pyff_params(1).make_interruptions = int16(0); % no interruptions
opt.feedback.pyff_params(1).end_pause_counter_type = int16(1); % button presses
opt.feedback.pyff_params(1).end_after_x_events = int16(10); % 10
opt.feedback.pyff_params(1).pause_every_x_events = int16(10); % no pause

opt.feedback.rec_params(2).record_audio = 0;
opt.feedback.rec_params(2).save_opt = 1;
opt.feedback.pyff_params(2).listen_to_keyboard = int16(0); % turn off keyboard mode
opt.feedback.pyff_params(2).make_interruptions = int16(0); % no interruptions
opt.feedback.pyff_params(2).end_pause_counter_type = int16(1); % button presses
opt.feedback.pyff_params(2).end_after_x_events = int16(100); % 100
opt.feedback.pyff_params(2).pause_every_x_events = int16(20); % 4 pauses

opt.feedback.rec_params(3).record_audio = 1;
opt.feedback.rec_params(3).save_opt = 0;
opt.feedback.pyff_params(3).listen_to_keyboard = int16(0); % turn off keyboard mode
opt.feedback.pyff_params(3).make_interruptions = int16(1); % elicit interruptions
opt.feedback.pyff_params(3).end_pause_counter_type = int16(3); % IDLE interruptions
opt.feedback.pyff_params(3).end_after_x_events = int16(10); % 10
opt.feedback.pyff_params(3).pause_every_x_events = int16(10); % no pause
trial_assignment = tl_acq_drawTrialAssignments(100,[0 0 .5 .5]); % only IDLE interruptions
opt.feedback.pyff_params(3).trial_assignment = int16(trial_assignment);

opt.feedback.rec_params(4).record_audio = 1;
opt.feedback.rec_params(4).save_opt = 1;
opt.feedback.pyff_params(4).listen_to_keyboard = int16(0); % turn off keyboard mode
opt.feedback.pyff_params(4).make_interruptions = int16(1); % elicit interruptions
opt.feedback.pyff_params(4).end_pause_counter_type = int16(2); % MOVE interruptions
opt.feedback.pyff_params(4).end_after_x_events = int16(100); % 100
opt.feedback.pyff_params(4).pause_every_x_events = int16(20); % 4 pauses
trial_assignment = tl_acq_drawTrialAssignments(1000,[.25 .25 .25 .25]); % MOVE and IDLE interruptions with equal rates
opt.feedback.pyff_params(4).trial_assignment = int16(trial_assignment);

%%
clear trial_assignment fv_ivals Wps Ws n










