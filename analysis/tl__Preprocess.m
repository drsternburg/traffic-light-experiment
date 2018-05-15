
tl__setupEnvironment;
global opt

%%
ds_name = 'VPtaa_18_05_09';
subj_code = ds_name(1:5);

%%
phase_name = 'Phase1';
fname = sprintf('%s/%s_%s_%s',ds_name,opt.session_name,phase_name,ds_name(1:5));

tl_proc_convertBVData(fname,opt);

tl_mrk_initialCleanup(subj_code,phase_name);

tl_proc_registerEMGOnsets(subj_code,phase_name,1);

%%
phase_name = 'Phase2';
fname = sprintf('%s/%s_%s_%s',ds_name,opt.session_name,phase_name,ds_name(1:5));

tl_proc_convertBVData(fname,opt);

tl_mrk_initialCleanup(subj_code,phase_name);

tl_proc_registerEMGOnsets(subj_code,phase_name,1);

tl_proc_registerResponses(subj_code);

