function [videoname, classlabel, tr_index, train_fnames,test_fnames,saction]= getHmdbSplit(split,splitdir)
    saction =      {'brush_hair','cartwheel','catch','chew','clap','climb','climb_stairs',...
        'dive','draw_sword','dribble','drink','eat','fall_floor','fencing',...
        'flic_flac','golf','handstand','hit','hug','jump','kick',...
        'kick_ball','kiss','laugh','pick','pour','pullup','punch',...
        'push','pushup','ride_bike','ride_horse','run','shake_hands','shoot_ball',...
        'shoot_bow','shoot_gun','sit','situp','smile','smoke','somersault',...
        'stand','swing_baseball','sword','sword_exercise','talk','throw','turn',...
        'walk','wave'};
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