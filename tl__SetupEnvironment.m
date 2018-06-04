
global BTB opt
opt = struct;

opt.session_name = 'TrafficLight';

%%
BTB.PrivateDir = 'C:\bbci';
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
opt.eeg.bv_workspace = 'C:\Vision\Workfiles\TrafficLight';
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
opt.pred.thresh_move = 10; % for the fake classifier of phase 1
opt.pred.thresh_idle = -10; % for the fake classifier of phase 1
opt.pred.wt_prctl = [10 75];

%% figure parameters
opt.fig.pred_edges = -2500:100:300;

%% feedback parameters
opt.feedback.name  = 'TrafficLight';

opt.feedback.blocks = {'Training1','Phase1','Training2','Phase2','RT'};

record_audio = [0 0 1 1 0];
listen_to_keyboard = [0 0 0 0 0];
make_interruptions = [0 0 1 1 1];
make_prompts = [0 0 1 1 0];

end_pause_counter_type = [1 % button presses
                          1 % button presses
                          4 % seconds
                          4 % seconds 
                          4 % seconds
                          ];
end_after_x_events = [10
                      100
                      1*60
                      60*60
                      8*60
                      ];
                  
pause_every_x_events = [10
                        20
                        1*60
                        15*60
                        4*60
                        ];

bci_delayed_idle = [0 0 0 1 0];

trial_assignment = {1,...
                    1,...
                    tl_acq_drawTrialAssignments(100,[0 0 .5 .5]),...
                    tl_acq_drawTrialAssignments(1500,[.25 .25 .25 .25]),...
                    tl_acq_drawTrialAssignments(100,[0 0 0 1])};

for ii = 1:length(opt.feedback.blocks)
    
    opt.feedback.rec_params(ii).record_audio = record_audio(ii);
    opt.feedback.pyff_params(ii).listen_to_keyboard = int16(listen_to_keyboard(ii));
    opt.feedback.pyff_params(ii).make_interruptions = int16(make_interruptions(ii));
    opt.feedback.pyff_params(ii).make_prompts = int16(make_prompts(ii));
    opt.feedback.pyff_params(ii).end_pause_counter_type = int16(end_pause_counter_type(ii));
    opt.feedback.pyff_params(ii).end_after_x_events = int16(end_after_x_events(ii));
    opt.feedback.pyff_params(ii).pause_every_x_events = int16(pause_every_x_events(ii));
    opt.feedback.pyff_params(ii).bci_delayed_idle = int16(bci_delayed_idle(ii));
    if not(isempty(trial_assignment{ii}))
        opt.feedback.pyff_params(ii).trial_assignment = int16(trial_assignment{ii});
    end
    
end

%%
clear trial_assignment fv_ivals Wps Ws n record_audio save_opt listen_to_keyboard make_interruptions end_after_x_events end_pause_counter_type pause_every_x_events bci_delayed_idle ii










