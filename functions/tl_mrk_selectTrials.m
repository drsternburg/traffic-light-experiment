
function mrk = tl_mrk_selectTrials(mrk,ind_sel,incell)

ind_all = tl_mrk_getTrialMarkers(mrk);
if nargin<3
    incell = false;
end
if any(ind_sel==0)
    ind_sel = find(ind_sel);
end
if nargin==1
    ind_sel = 1:length(ind_all);
end

if incell
    mrk2 = cell(1,length(ind_sel));
    for ii = 1:length(ind_sel)
        mrk2{ii} = mrk_selectEvents(mrk,ind_all{ind_sel(ii)});
    end
    mrk = mrk2;
else
    mrk = mrk_selectEvents(mrk,[ind_all{ind_sel}]);
end