
function [pred,t_pr2emg,t_ts2emg] = tl_proc_findClassifierThreshold(cout,do_fig)

global opt

if nargin==1
    do_fig = 1;
end

edges = [-Inf opt.pred.tp_ival 500];
n_trials = length(cout);

%% define possible threshold range
x_all = cellfun(@(f)getfield(f,'x'),cout,'UniformOutput',false);
x_all = [x_all{:}];
thresh = linspace(prctile(x_all,5),max(x_all),500);

%% find crossing times
t_pr2emg = nan(n_trials,length(thresh));
t_ts2emg = nan(n_trials,1);
for ii = 1:n_trials
    for kk = 1:length(thresh)
        i_crossed = find(cout{ii}.x>=thresh(kk),1);
        if not(isempty(i_crossed))
            t_pr2emg(ii,kk) = cout{ii}.t(i_crossed);
        end
    end
    %t_ts2emg(ii) = -cout{ii}.t(1)-opt.cfy.fv_window(1);
    t_ts2emg(ii) = -cout{ii}.t(1);
end

%% compute detection rates for different thresholds
num = zeros(length(thresh),length(edges));
for kk = 1:length(thresh)
    for ll = 1:length(edges)-1
        num(kk,ll) = sum(t_pr2emg(:,kk)>edges(ll)&t_pr2emg(:,kk)<edges(ll+1));
    end
    num(kk,ll+1) = n_trials - sum(num(kk,:));
end
rate = num/n_trials;

%% compute and smooth F-score
F05 = tl_util_fScore(rate,opt.pred.fscore_beta);
F05 = smooth(F05,15);

%% save stats and determine thresholds
[~,idx_opt] = max(F05);
pred.thresh = thresh(idx_opt);
pred.FP = rate(idx_opt,1);
pred.TP = rate(idx_opt,2);
pred.FN1 = rate(idx_opt,3);
pred.FN2 = rate(idx_opt,4);
pred.F05 = F05(idx_opt);
t_pr2emg = t_pr2emg(:,idx_opt);

opt.pred.thresh_move = pred.thresh;
opt.pred.thresh_idle = median(x_all);

%% visualize
if not(do_fig)
    return
end

tl_fig_init(20,20);
clrs = lines(7);

subplot 211
hold on
for jj = 1:size(rate,2)
    plot(thresh,rate(:,jj),'color',clrs(jj,:),'linewidth',1.5)
end
plot(thresh,F05,'color',clrs(jj+1,:),'linewidth',1.5)
plot([1 1]*pred.thresh,ylim,'color',clrs(jj+2,:))
axis tight
box on
lh = legend(sprintf('False alarms: %2.1f%%',pred.FP*100),...
            sprintf('Correct (between %d and %d): %2.1f%%\n',edges(2),edges(3),pred.TP*100),...
            sprintf('Too late (between %d and %d): %2.1f%%\n',edges(3),edges(4),pred.FN1*100),...
            sprintf('Missed: %2.1f%%\n',pred.FN2*100),...
            sprintf('Smoothed F-score: %1.3f\n',pred.F05),...
            'location','west');
set(lh,'box','off')
xlabel('Threshold')
title(sprintf('TP interval: [%d %d]ms, F-score: %0.2f',edges(2),edges(3),pred.F05))

subplot 212
hold on
edges = [floor(min(t_pr2emg)/100)*100 ...
         edges(2:3) ...
         ceil(max(t_pr2emg)/100)*100];
for ii = 1:length(edges)-1
    edges2 = edges(ii):100:edges(ii+1);
    if verLessThan('matlab', '8.4')
        counts = histc(t_pr2emg,edges2);
        counts = counts(1:end-1);
    else
        counts = histcounts(t_pr2emg,edges2);
    end
    centers = (edges2(1:end-1) + edges2(2:end))/2;
    bar(centers,counts,'facecolor',clrs(ii,:))
end
plot([0 0],ylim.*[1 1],'k--','linewidth',2)
set(gca,'box','on','xlim',[edges(1) edges(end)])
ylabel('Counts')
xlabel('Time to EMG onset (msec)')
title('Distribution of implied silent predictions')



















