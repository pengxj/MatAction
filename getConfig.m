function [videoname, classlabel,fv_dir, vocab_dir, descriptor_path, video_dir,actions, tr_index] = getConfig(split, DATASET)
    % TODO : Change the paths
    switch DATASET
        case 'hmdb51'
            fv_dir = ['/scratch/gpuhost2/xpeng/data/HMDB51-VTE-LSTM/fvecs_split', num2str(split)]; % Path where features will be saved
            vocab_dir = '~temp';
            descriptor_path = '/home/lear/xpeng/data_scratch2/hmdb51_org_idt';%'E:\myfile\code\testdata';
            video_dir = '/home/lear/xpeng/data_scratch2/hmdb51_org_idt';%'H:\data\hmdb51_org_idt';
            splitdir = '/scratch/gpuhost2/xpeng/data/HMDB51/HMDB51_TestTrain_7030_splits';%'H:\data\HMDB51_TestTrain_7030_splits';
            [videoname, classlabel, tr_index, ~, ~, actions]= getHmdbSplit(split,splitdir);
        case 'jhmdb'
            fv_dir = ['/home/lear/xpeng/data/JHMDB/features/idt_fvecs_split', num2str(split)]; % Path where features will be saved
            vocab_dir = '~temp';
            descriptor_path = '/home/lear/xpeng/data/JHMDB/features/jhmdb_idt';%'E:\myfile\code\testdata';
            video_dir = '/home/lear/xpeng/data/JHMDB/philippeJHMDB/original/JHMDB_video/ReCompress_Videos';%'H:\data\hmdb51_org_idt';
            splitdir = '/home/lear/xpeng/data/JHMDB/philippeJHMDB/original/splits';%'H:\data\HMDB51_TestTrain_7030_splits';
            [videoname, classlabel, tr_index, ~, ~, actions]= getJhmdbSplit(split,splitdir);
    end
end
