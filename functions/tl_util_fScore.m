
function F = tl_util_fScore(rates,beta)

FP = rates(:,1);
TP = rates(:,2);
FN = rates(:,3)+rates(:,4);

nom = (1+beta^2)*TP;
den = (1+beta^2)*TP + beta^2*FN + FP;

F = nom./den;