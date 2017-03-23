function [gmm,codebook] = getIdtEncoder(split, videoname,vocab_dir,descriptor_dir, gmmSize)
    if ~exist(vocab_dir,'dir'), mkdir(vocab_dir), end
    samples = 256000;
    numWords = 4000;
    gmm.gmmSize = gmmSize;
    pcaFactor = 0.5;
    whiten = 1;
    sampleFeatFile = fullfile(vocab_dir,sprintf('%d_featfile.mat',split));
    gmmFilePath = fullfile(vocab_dir,sprintf('%d_gmmModel_%d.mat',split,gmmSize));
    codebookFilePath = fullfile(vocab_dir,sprintf('%d_codebook_%d.mat',split,numWords));
    if exist(gmmFilePath,'file')
        tmp = load(gmmFilePath); %gmm
        gmm = tmp.gmm;
    end
    if exist(codebookFilePath,'file')
        tmp = load(codebookFilePath); %codebook
        codebook = tmp.codebook;
        return;
    end
    if ~exist(sampleFeatFile,'file')
        hogAll = zeros(samples,96);
        hofAll = zeros(samples,108);
        mbhxAll = zeros(samples,96);
        mbhyAll = zeros(samples,96);
        warning('getEncoder : generate encoder from subset of videos...')
        num_videos = 3000;
        if num_videos>numel(videoname), num_videos = numel(videoname); end
        num_samples_per_vid = ceil(samples/ num_videos);
        videoname = videoname(randperm(numel(videoname)));
        st = 1;
        for i = 1 : num_videos
            timest = tic();
            descriptorFile = fullfile(descriptor_dir,sprintf('%s.bin',videoname{i}));
            dt = readIDTbin(descriptorFile);
            if ~isempty(dt)
                rnsam = randperm(size(dt.hog,1));
                if numel(rnsam) > num_samples_per_vid
                    rnsam = rnsam(1:num_samples_per_vid);
                end
                send = st + numel(rnsam) - 1;
                hogAll(st:send,:) = dt.hog(rnsam,:);
                hofAll(st:send,:) = dt.hof(rnsam,:);
                mbhxAll(st:send,:) = dt.mbhx(rnsam,:);
                mbhyAll(st:send,:) = dt.mbhy(rnsam,:);
            end
            st = st + numel(rnsam); 
            timest = toc(timest);
            fprintf('%d/%d -> %s --> %1.2f sec\n',i,num_videos,videoname{(i)},timest);
        end
        if send ~= samples
            hogAll(send+1:samples,:) = [];
            hofAll(send+1:samples,:) = [];
            mbhxAll(send+1:samples,:) = [];
            mbhyAll(send+1:samples,:) = [];
        end
        fprintf('start computing pca\n');
        
        [gmm.pcamap.hog, gmm.centre.hog] = xpca(hogAll', whiten, size(hogAll,2)*pcaFactor);        
        [gmm.pcamap.hof, gmm.centre.hof] = xpca(hofAll', whiten, size(hofAll,2)*pcaFactor);
        [gmm.pcamap.mbhx, gmm.centre.mbhx] = xpca(mbhxAll', whiten, size(mbhxAll,2)*pcaFactor);
        [gmm.pcamap.mbhy, gmm.centre.mbhy] = xpca(mbhyAll', whiten, size(mbhyAll,2)*pcaFactor);
        
        fprintf('start saving descriptors\n');
        save(sampleFeatFile,'hogAll','hofAll','mbhxAll','mbhyAll','gmm','-v7.3'); 
    else
        load(sampleFeatFile);
    end        
    %=========gmm & kmeans=============
    fprintf('start create gmm & kmeans hog\n');
    hogProjected = bsxfun(@minus,hogAll,gmm.centre.hog) * gmm.pcamap.hog;
    [codebook.means.hog, ~] = vl_kmeans(hogProjected', numWords, 'verbose', 'algorithm', 'elkan') ;
    codebook.kdtree.hog = vl_kdtreebuild(codebook.means.hog, 'numTrees', 2) ;
    [gmm.means.hog, gmm.covariances.hog, gmm.priors.hog] = vl_gmm(hogProjected', gmmSize);
    
    fprintf('start create gmm & kmeans hof\n');
    hofProjected = bsxfun(@minus,hofAll,gmm.centre.hof) * gmm.pcamap.hof;
    [codebook.means.hof, ~] = vl_kmeans(hofProjected', numWords, 'verbose', 'algorithm', 'elkan') ;
    codebook.kdtree.hof = vl_kdtreebuild(codebook.means.hof, 'numTrees', 2) ;
    [gmm.means.hof, gmm.covariances.hof, gmm.priors.hof] = vl_gmm(hofProjected', gmmSize);
    
    fprintf('start create gmm & kmeans mbhx\n');
    mbhxProjected = bsxfun(@minus,mbhxAll,gmm.centre.mbhx) * gmm.pcamap.mbhx;
    [codebook.means.mbhx, ~] = vl_kmeans(mbhxProjected', numWords, 'verbose', 'algorithm', 'elkan') ;
    codebook.kdtree.mbhx = vl_kdtreebuild(codebook.means.mbhx, 'numTrees', 2) ;
    [gmm.means.mbhx, gmm.covariances.mbhx, gmm.priors.mbhx] = vl_gmm(mbhxProjected', gmmSize);
    
    fprintf('start create gmm & kmeans mbhy\n');
    mbhyProjected = bsxfun(@minus,mbhyAll,gmm.centre.mbhy) * gmm.pcamap.mbhy;
    [codebook.means.mbhy, ~] = vl_kmeans(mbhyProjected', numWords, 'verbose', 'algorithm', 'elkan') ;
    codebook.kdtree.mbhy = vl_kdtreebuild(codebook.means.mbhy, 'numTrees', 2) ;
    [gmm.means.mbhy, gmm.covariances.mbhy, gmm.priors.mbhy] = vl_gmm(mbhyProjected', gmmSize);
    
    fprintf('start saving gmm and codebook\n');
    save(gmmFilePath,'gmm');  
    save(codebookFilePath, 'codebook');
end
