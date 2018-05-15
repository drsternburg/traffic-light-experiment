
function mrk = tl_mrk_unifyMarkers(mrk,cl_orig,cl_target)

if nargin<3
    if strcmp(cl_orig,'start')
        cl_orig = {'start move red','start move green','start idle red','start idle green','start phase1'};
        cl_target = 'start all';
    elseif strcmp(cl_orig,'light')
        cl_orig = {'light move red','light move green','light idle red','light idle green'};
        cl_target = 'light';
    else
        error('Wrong unification indentifier.')
    end
end

ci_orig = [];
for ii = 1:length(cl_orig)
    ci_orig = [ci_orig find(strcmp(mrk.className,cl_orig{ii}))];
end

mrk.y(ci_orig(1),:) = sum(mrk.y(ci_orig,:),1);
mrk.y(ci_orig(2:end),:) = [];

mrk.className{ci_orig(1)} = cl_target;
mrk.className(ci_orig(2:end)) = [];