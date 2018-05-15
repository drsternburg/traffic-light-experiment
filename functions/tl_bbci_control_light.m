function packet = tl_bbci_control_light(cfy_out,event,opt)

if cfy_out >= opt.pred.thresh
    packet = {'i:cl_output',1};
elseif cfy_out < 0
    packet = {'i:cl_output',-1};
else
    packet = {'i:cl_output',0};
end