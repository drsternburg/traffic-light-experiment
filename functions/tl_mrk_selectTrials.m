
function mrk_sel = tl_mrk_selectTrials(mrk,ind,in_cell)

mrk2 = tl_mrk_unifyMarkers(mrk,'start');
[~,ind_all] = tl_mrk_assembleTrials(mrk2,'all');
ind = ind_all(ind);

if in_cell
    mrk_sel = cell(1,length(ind));
    for ii = 1:length(ind)
        mrk_sel{ii} = mrk_selectEvents(mrk,ind{ii});
    end
else
    mrk_sel = mrk_selectEvents(mrk,[ind{:}]);
end