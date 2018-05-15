
function fv = tl_proc_extractFeatures(cnt,mrk)

global opt

cnt = proc_selectChannels(cnt,opt.cfy.clab);

fv = proc_segmentation(cnt,mrk,opt.cfy.fv_window);
fv = proc_baseline(fv,opt.cfy.baseln_len,opt.cfy.baseln_pos);
fv = proc_jumpingMeans(fv,opt.cfy.fv_ivals);
fv = proc_flaten(fv);
