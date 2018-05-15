
function cout = tl_proc_slidingClassification(cnt,mrk,C)

global opt

cnt = proc_selectChannels(cnt,opt.cfy.clab);

mrk = mrk_selectClasses(mrk,'trial start','EMG','trial end');
n_trial = sum(mrk.y(1,:));
i_trial = reshape(1:length(mrk.time),3,n_trial);

%%
cout = cell(1,n_trial);
h = waitbar(0,'Computing sliding classifier output...');
for ii = 1:n_trial
    
    if not(exist('C','var'))
        %% train
        mrk_train = mrk_selectEvents(mrk,'not',i_trial(:,ii));
        mrk_train = tl_mrk_setIdleMoveMarkers(mrk_train);
        fv = tl_proc_extractFeatures(cnt,mrk_train);
        C = train_RLDAshrink(fv.x,fv.y);
    end
    
    %% apply
    mrk_apply = mrk_selectEvents(mrk,i_trial(:,ii));
    t_ts = mrk_apply.time(1);
    t_eo = mrk_apply.time(2);
    t_te = mrk_apply.time(3);
    ival = [t_ts t_te]-t_eo;
    
    mrk_eo = mrk_selectEvents(mrk_apply,2);
    epo = proc_segmentation(cnt,mrk_eo,ival);
    cout{ii} = tl_proc_applySlidingClassifier(epo,C);
    
    %%
    waitbar(ii/n_trial,h);
    
end
close(h)
