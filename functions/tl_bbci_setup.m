
function bbci = tl_bbci_setup

global opt

bbci = struct;

bbci.source.min_blocklength = 10;
bbci.source.marker_mapping_fcn = '';

bbci.source.acquire_fcn = @bbci_acquire_bv;
bbci.source.acquire_param = {struct('fs',opt.eeg.fs,'filt_b',opt.eeg.filt.b,'filt_a',opt.eeg.filt.a)};

bbci.feature.proc= {{@proc_selectChannels,opt.cfy.clab}, ...
                    {@proc_baseline,opt.cfy.baseln_len,opt.cfy.baseln_pos}, ...
                    {@proc_jumpingMeans,opt.cfy.fv_ivals}};
bbci.feature.ival= [opt.cfy.fv_ivals(1) opt.cfy.fv_ivals(end)];

bbci.classifier.C = opt.cfy.C;

bbci.control(1).fcn = @tl_bbci_control_button;
bbci.control(1).condition.marker = opt.mrk.def{1,strcmp(opt.mrk.def(2,:),'button press')};
bbci.control(1).param = {opt};
bbci.control(2).fcn = @tl_bbci_control_light;
bbci.control(2).param = {opt};

bbci.feedback(1).control= 1;
bbci.feedback(1).receiver= 'pyff';
bbci.feedback(2).control= 2;
bbci.feedback(2).receiver= 'pyff';

bbci.quit_condition.marker = 255;

bbci.log.output = 'screen&file';
bbci.log.filebase = '~/bbci/log/log';
bbci.log.classifier = 1;


