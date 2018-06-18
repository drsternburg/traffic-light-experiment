
warning off

%%
ds_name = 'VPtat_18_06_18';
subj_code = ds_name(1:5);

%%
phase_name = 'Phase1';
fname = sprintf('%s/%s_%s_%s',ds_name,opt.session_name,phase_name,subj_code);
%%
tl_proc_convertBVData(fname);
%%
tl_mrk_initialCleanup(subj_code,phase_name);
%%
tl_proc_registerEMGOnsets(subj_code,phase_name,0);

%%
phase_name = 'Phase2';
fname = sprintf('%s/%s_%s_%s',ds_name,opt.session_name,phase_name,subj_code);
%%
tl_proc_convertBVData(fname);
%%
tl_mrk_initialCleanup(subj_code,phase_name);
%%
tl_proc_registerEMGOnsets(subj_code,phase_name,0);
%%
%tl_proc_registerResponses(subj_code,12.5);

%%
phase_name = 'RT';
fname = sprintf('%s/%s_%s_%s',ds_name,opt.session_name,phase_name,subj_code);
%%
tl_proc_convertBVData(fname);
%%
tl_mrk_initialCleanup(subj_code,phase_name);
%%
tl_proc_registerEMGOnsets(subj_code,phase_name,0);
