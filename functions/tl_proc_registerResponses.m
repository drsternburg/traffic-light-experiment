
function tl_proc_registerResponses(subj_code,offset)

global BTB opt
ds_list = dir(BTB.RawDir);
ds_idx = strncmp(subj_code,{ds_list.name},5);
ds_name = ds_list(ds_idx).name;

mrk = tl_proc_loadData(subj_code,'Phase2');
mrk = mrk_selectClasses(mrk,'not','no','yes');

%%
wavfile = sprintf('%s%s/%s_%s.wav',BTB.RawDir,ds_name,subj_code,'Phase2');
[y,fs] = audioread(wavfile);
n_smpl = size(y,1);

mrk_ = mrk_selectClasses(mrk,'prompt');
t_pr = mrk_.time/1000;

jj = 1;
mrk_resp.y = nan(1,length(t_pr));
mrk_resp.time = nan(1,length(t_pr));
while jj<=length(t_pr)
    a = round((t_pr(jj)+offset)*fs);
    b = min(round((t_pr(jj)+offset+2.5)*fs),n_smpl);
    y = audioread(wavfile,[a b]);
    sound(y,fs);
    r = input(sprintf('Prompt %d/%d, response: ',jj,length(t_pr)),'s');
    if isempty(r)
        jj = jj+1;
        continue
    end
    switch r
        case 'r'
            jj = jj - 1;
            mrk_resp.y(jj) = nan;
            mrk_resp.time(jj) = nan;
            continue
        case 'y'
            mrk_resp.y(jj) = 1;
        case 'n'
            mrk_resp.y(jj) = 2;
        otherwise
            continue
    end
    mrk_resp.time(jj) = mrk_.time(jj)+500;
    jj = jj+1;
end

ri = isnan(mrk_resp.y);
mrk_resp.time(ri) = [];
mrk_resp.y(ri) = [];
fprintf('%d responses registered to %d prompts.\n',length(mrk_resp.time),length(t_pr))

y = zeros(2,length(mrk_resp.y));
y(1,logical(mrk_resp.y==1)) = 1;
y(2,logical(mrk_resp.y==2)) = 1;
mrk_resp.y = y;

%% save new marker struct
mrk_resp.className = {'yes','no'};
mrk = mrk_mergeMarkers(mrk,mrk_resp);
mrk = mrk_sortChronologically(mrk);

filename = sprintf('%s%s/%s_%s_%s_mrk',BTB.MatDir,ds_name,opt.session_name,'Phase2',subj_code);
save(filename,'mrk')































