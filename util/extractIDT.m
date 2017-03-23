function extractIDT(video_dir, videoname,descriptor_dir)
    if ~exist(descriptor_dir,'dir'), mkdir(descriptor_dir), end
    [path, ~, ~]=fileparts(videoname{1});
    if ~exist(fullfile(descriptor_dir,path),'dir')    
        for i = 1 : numel(videoname)
            [path, ~, ~]=fileparts(videoname{i});
            if ~exist(fullfile(descriptor_dir,path), 'dir')
                mkdir(fullfile(descriptor_dir,path));
            end
        end    
    end
    for i = 1 : numel(videoname)
        timest = tic();
        descriptorFile = fullfile(descriptor_dir,sprintf('%s.bin',videoname{i}));
        if exist(descriptorFile,'file')
            
        else
           extract_improvedfeatures(sprintf('%s/%s.avi',video_dir, videoname{i}),descriptorFile) ;                
        end
        sDescription = dir(descriptorFile);
        sizef = sDescription.bytes / (1024 * 1024);
        timest = toc(timest);
        fprintf('%d -> %s --> size %1.1f Mb--> %1.1f sec.\n',i,descriptorFile,sizef,timest);
    end
end
