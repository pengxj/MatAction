function dt = readIDTbin(file)
    index = [1,11,41,137,245,341;10,40,136,244,340,436];
    % max_desc = 100000;
    if exist(file, 'file')
        fid = fopen(file,'rb');
        temp = fread(fid, [index(2,end), inf],'single');
        fclose(fid);
        if ~isempty(temp)
            dt.info = temp(index(1,1):index(2,1),:);
            dt.trajectory = temp(index(1,2):index(2,2),:)';
            dt.hog = temp(index(1,3):index(2,3),:)';
            dt.hof = temp(index(1,4):index(2,4),:)';
            dt.mbhx = temp(index(1,5):index(2,5),:)';
            dt.mbhy = temp(index(1,6):index(2,6),:)';
        else
            fprintf([file, '----no trajectories!']);
            dt = [];
        end
    else
        fprintf([file, 'file does not exist, please check!']);
    end
% nbin = 8; grids = [2, 2, 3];
%     nhog = nbin*grids(1)*grids(2)*grids(3);
%     nhof = (nbin+1)*grids(1)*grids(2)*grids(3);
%     nmbh = nbin*grids(1)*grids(2)*grids(3);
%     nfea =37 + nhog + nhof + 2*nmbh;
%     % max_desc = 100000;
%     if exist(file, 'file')
%         fid = fopen(file,'rb');
%         temp = fread(fid, [nfea, inf],'single');
%         fclose(fid);
%         if ~isempty(temp)
%             dt.info = temp(1:7,:);
%             dt.trajectory = temp(8:37,:)';
%             nstar = 38; nend = nstar + nhog -1;
%             dt.hog = temp(nstar:nend,:)';
%             nstar = nend + 1; nend = nend + nhof;
%             dt.hof = temp(nstar:nend,:)';
%             nstar = nend + 1; nend = nend + nmbh;
%             dt.mbhx = temp(nstar:nend,:)';
%             nstar = nend + 1; nend = nend + nmbh;
%             dt.mbhy = temp(nstar:nend,:)';
%         else
%             fprintf([file, '----no trajectories!']);
%             dt = [];
%         end
%     else
%         fprintf([file, 'file does not exist, please check!']);
%     end
end