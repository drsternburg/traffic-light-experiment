
function mrk = tl_mrk_unifyMarkers(mrk,type,cl_target)
% Unifies marker families

switch type
    case 'start'
        cl_orig = {'start move red','start move green','start idle red','start idle green','start phase1','start rt','start'};
    case 'light'
        cl_orig = {'light move red','light move green','light idle red','light idle green','light rt'};
    case 'light move'
        cl_orig = {'light move red','light move green'};
    case 'light idle'
        cl_orig = {'light idle red','light idle green'};
    otherwise
        error('Unknown unification indentifier.')
end
if nargin < 3
    cl_target = type;
end

ci_orig = [];
for ii = 1:length(cl_orig)
    ci_orig = [ci_orig find(strcmp(mrk.className,cl_orig{ii}))];
end

mrk.y(ci_orig(1),:) = sum(mrk.y(ci_orig,:),1);
mrk.y(ci_orig(2:end),:) = [];

mrk.className{ci_orig(1)} = cl_target;
mrk.className(ci_orig(2:end)) = [];