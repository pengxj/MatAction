function des_accs = run_hmdb_split(varargin)
%run_split:
% Example:
%  run_split('split',1,'descriptor',{'mbhx','mbhy'}, 'encode', 'fv', 'gmmSize', 256, 'normalize', 'Power-Intra-L2', 'dataset', 'hmdb51')
% 
%    descriptor: {'hog','hof','mbhx','mbhy'} or its subset.
%    encode: choose one method from {'fv','svc','svc-k','svc-all','vlad','vlad-k','vlad-all','llc','sa-k','vq'}
%    normalize: choose one method from {'Power-L2','Power-Intra-L2'}.

    [split, descriptorType, encode_method, normalize_method, gmmSize, dataset] = parse_parameters(varargin{:});
    % TODO: change some paths in getConfig function
    [videoname, classlabel,fv_dir, vocab_dir, descriptor_path, video_dir, actions,tr_index] = getConfig(split, dataset);
    if ispc,   videoname = strrep(videoname,'/','\\');    end
    
    feat_path = fullfile(fv_dir, sprintf('feat_all_split_%d.mat', split));
    if ~exist(feat_path,'file')
        extractIDT(video_dir,videoname,descriptor_path);
        [gmm,codebook] = getIdtEncoder(split,videoname(tr_index==1),vocab_dir,descriptor_path, gmmSize);
        feat_all = encodeVideos(videoname,gmm,codebook,fv_dir,descriptor_path, encode_method);
        save(feat_path,'feat_all','-v7.3');
    else
        load(feat_path);
    end
    tr_kern_sum = []; ts_kern_sum = []; 
    des_accs = zeros(numel(descriptorType)+1,1);
    trn_indx  = find(tr_index==1);
    test_indx = find(tr_index==0);        
    trainLabels = classlabel(trn_indx);
    testLabels = classlabel(test_indx);
    for i = 1 : numel(descriptorType)
        [~,ides] = ismember(descriptorType{i},{'hog','hof','mbhx','mbhy'});
        if ~exist(sprintf('%s_%s_%d_Kern.mat',descriptorType{i},encode_method,split),'file')
            feature = feat_all{ides};
            feature = normalize(feature',normalize_method, 2*gmmSize); % now feature in column-wise
            TrainData = feature(:,trn_indx);
            TestData = feature(:,test_indx);
            TrainData_Kern = TrainData' * TrainData;
            TestData_Kern = TrainData' * TestData;            
            clear TrainData; clear TestData;
            save(sprintf('%s_%s_%d_Kern.mat',descriptorType{i},encode_method,split), 'TrainData_Kern', 'TestData_Kern','-v7.3');
        else
            load(sprintf('%s_%s_%d_Kern.mat',descriptorType{i},encode_method,split));
        end
        if i==1
            tr_kern_sum = TrainData_Kern;
            ts_kern_sum = TestData_Kern;
        else
            tr_kern_sum = tr_kern_sum + TrainData_Kern;
            ts_kern_sum = ts_kern_sum + TestData_Kern;
        end
        score_test = svm_one_vs_all(TrainData_Kern, TestData_Kern, trainLabels', max(classlabel));
        [~, predict_labels] = max(score_test');
        [~,avg_acc,~] = get_cm(testLabels',predict_labels',1);
        des_accs(i) = avg_acc; 
        fprintf('split---%d, %s--->accuracy:\n %f\n',split, descriptorType{i}, avg_acc);
    end
    save(sprintf('%d_%s_%s_SumKern.mat',split,encode_method,cell2mat(descriptorType)), 'tr_kern_sum', 'ts_kern_sum','-v7.3');
    score_test = svm_one_vs_all(tr_kern_sum, ts_kern_sum, trainLabels', max(classlabel));
    [~, predict_labels] = max(score_test');
    [~,avg_acc,~] = get_cm(testLabels',predict_labels',1);
    des_accs(end) = avg_acc; 
    fprintf('split---%d, %d descriptor combination--->accuracy:\n %f',split, numel(descriptorType), avg_acc);  
end
