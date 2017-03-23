function feat_all = encodeVideos(videoname,gmm,codebook,fv_dir,descriptor_dir, encode)
%ENCODEVIDEOS:   encode all video IDT features with 'encode' method.
% For simplity, we only integrate Fisher vector method here
    if ~exist(fv_dir,'dir'), mkdir(fv_dir), end
    [path, ~, ~]=fileparts(videoname{1});
    if ~exist(fullfile(fv_dir,path),'dir')    
        for i = 1 : numel(videoname)
            [path, ~, ~]=fileparts(videoname{i});
            if ~exist(fullfile(fv_dir,path), 'dir')
                mkdir(fullfile(fv_dir,path));
            end
        end    
    end
    fv_hog = zeros( numel(videoname),size(gmm.pcamap.hog,2)*2*size(gmm.means.hog,2));
    fv_hof = zeros( numel(videoname),size(gmm.pcamap.hof,2)*2*size(gmm.means.hof,2));
    fv_mbhx = zeros( numel(videoname),size(gmm.pcamap.mbhx,2)*2*size(gmm.means.mbhx,2));
    fv_mbhy = zeros( numel(videoname),size(gmm.pcamap.mbhy,2)*2*size(gmm.means.mbhy,2));
    for i = 1 : numel(videoname)
        timest = tic();
        savefile = fullfile(fv_dir, sprintf('%s.mat',videoname{i}));
        if ~exist(savefile, 'file')
            descriptorFile = fullfile(descriptor_dir,sprintf('%s.bin',videoname{i}));
            dt = readIDTbin(descriptorFile);
            if ~isempty(dt)
                fv_hog(i,:) = vl_fisher( (bsxfun(@minus,dt.hog,gmm.centre.hog)*gmm.pcamap.hog)', gmm.means.hog, gmm.covariances.hog, gmm.priors.hog);
                fv_hof(i,:) = vl_fisher( (bsxfun(@minus,dt.hof,gmm.centre.hof)*gmm.pcamap.hof)', gmm.means.hof, gmm.covariances.hof, gmm.priors.hof);
                fv_mbhx(i,:) = vl_fisher( (bsxfun(@minus,dt.mbhx,gmm.centre.mbhx)*gmm.pcamap.mbhx)', gmm.means.mbhx, gmm.covariances.mbhx, gmm.priors.mbhx);
                fv_mbhy(i,:) = vl_fisher( (bsxfun(@minus,dt.mbhy,gmm.centre.mbhy)*gmm.pcamap.mbhy)', gmm.means.mbhy, gmm.covariances.mbhy, gmm.priors.mbhy);
            else
                fv_hog(i,:) = 1/size(fv_hog,2);
                fv_hof(i,:) = 1/size(fv_hof,2);
                fv_mbhx(i,:) = 1/size(fv_mbhx,2);
                fv_mbhy(i,:) = 1/size(fv_mbhy,2);
            end
            save_fv(savefile, fv_hog(i,:), fv_hof(i,:),fv_mbhx(i,:), fv_mbhy(i,:));
        else
            load(savefile);
            fv_hog(i,:) = fvec_hog; fv_hof(i,:) = fvec_hof;
            fv_mbhx(i,:) = fvec_mbhx; fv_mbhy(i,:) = fvec_mbhy;
        end
        timest = toc(timest);
        fprintf('%d -> %s -->  %1.1f sec.\n',i,videoname{i},timest);
    end
    feat_all = {fv_hog, fv_hof, fv_mbhx, fv_mbhy};
    save_all_fv(sprintf('%s/fv_hog.mat',fv_dir),fv_hog);
    save_all_fv(sprintf('%s/fv_hof.mat',fv_dir),fv_hof);
    save_all_fv(sprintf('%s/fv_mbhx.mat',fv_dir),fv_mbhx);
    save_all_fv(sprintf('%s/fv_mbhy.mat',fv_dir),fv_mbhy);
end

function save_all_fv(filepath,fvecs)          
   save(filepath,'fvecs','-v7.3');
end
function save_fv(filepath,fvec_hog, fvec_hof, fvec_mbhx, fvec_mbhy)          
   save(filepath,'fvec_hog', 'fvec_hof', 'fvec_mbhx', 'fvec_mbhy');
end
