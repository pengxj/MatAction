function [videoname, classlabel, tr_index, train_fnames,test_fnames,saction]= getJhmdbSplit(split,splitdir)
    saction =      {'brush_hair','catch','clap','climb_stairs','golf','jump',...
        'kick_ball','pick','pour','pullup', 'push', 'run','shoot_ball',...
        'shoot_bow','shoot_gun','sit', 'stand','swing_baseball','throw', 'walk','wave'};
    cnt = 1; 
    for iaction = 1:length(saction)
        itr = 1;
        ite = 1;
        fname = sprintf('%s/%s_test_split%d.txt',splitdir,saction{iaction},split);
        fid = fopen(fname);
        while 1
            tline = fgetl(fid);
            if tline==-1
                break
            end
            [tline, u] = strtok(tline,' ');
            u = str2num(u);
            video = tline(1:end-4);%sprintf('%s.bin',tline(1:end-4))
            if u==1 % ignore testing
                train_fnames{iaction}{itr} = video;%tline
                videoname(cnt) = {sprintf('%s/%s',saction{iaction}, video)}; 
                classlabel(cnt) = iaction;
                tr_index(cnt) = 1;
                cnt = cnt + 1;
                itr = itr + 1;
            elseif u==2
                test_fnames{iaction}{ite} = video;%tline
                videoname(cnt) = {sprintf('%s/%s',saction{iaction}, video)}; 
                classlabel(cnt) = iaction;
                tr_index(cnt) = 0;
                cnt = cnt + 1;
                ite = ite + 1;
            end
        end
        fclose(fid);
    end
end