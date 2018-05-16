
function mrk = tl_mrk_setClassifierMarkers(mrk)

global opt

mrk = tl_mrk_unifyMarkers(mrk,'start');

switch opt.cfy.idle_mode
    case 'trial start'
        mrk = mrk_selectClasses(mrk,'start','EMG onset');
        mrk.className = {'Idle','Move'};
    case 'offset'
        mrk1 = mrk_selectClasses(mrk,'EMG onset');
        mrk1.className = {'Move'};
        mrk2 = mrk1;
        mrk2.className = {'Idle'};
        mrk2.time = mrk2.time - opt.cfy.idle_offset;
        mrk = mrk_mergeMarkers(mrk1,mrk2);
    case 'optimal'
        mrk1 = mrk_selectClasses(mrk,'start','EMG onset');
        mrk1.className = {'Idle','Move'};        
        mrk2 = mrk_selectClasses(mrk1,'Move');
        mrk2.className = {'Idle'};
        t_ts2emg = mrk1.time(logical(mrk1.y(2,:)))-mrk1.time(logical(mrk1.y(1,:)));
        i_valid = t_ts2emg >= opt.cfy.min_ts2emg;
        mrk2 = mrk_selectEvents(mrk2,i_valid);
        mrk2.time = mrk2.time - opt.cfy.idle_offset;        
        mrk = mrk_mergeMarkers(mrk1,mrk2);
    otherwise
        error('Unknown idle class mode')
end

mrk = mrk_sortChronologically(mrk);
mrk = mrk_selectClasses(mrk,'Idle','Move');