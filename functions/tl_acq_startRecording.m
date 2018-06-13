
function tl_acq_startRecording(block_name,bbci)
% Executes a recording block

global BTB opt

id = logical(strcmp(opt.feedback.blocks,block_name));

if opt.feedback.rec_params(id).record_audio
    mp3file = sprintf('%s\\%s_%s.mp3',BTB.Tp.Dir,BTB.Tp.Code,opt.feedback.blocks{id});
    ix = 1;
    while 1
        if not(exist(mp3file,'file'))
            break
        else
            mp3file = [mp3file(1:end-4) num2str(ix) mp3file(end-3:end)];
        end
        ix = ix+1;
    end
    system(['C:\mp3recorder\mp3recorder.exe -v 90 -l 0 -f ' mp3file ' &']);
end

pyff('startup'); pause(1)
pyff('init',opt.feedback.name); pause(6);
pyff('set',opt.feedback.pyff_params(id))

basename = sprintf('%s_%s_',opt.session_name,opt.feedback.blocks{id});
bbci_acquire_bv('close');
pyff('play','basename',basename,'impedances',0);
bbci_apply(bbci);

pyff('stop'); pause(1);
bvr_sendcommand('stoprecording');

fprintf('Finished\n')