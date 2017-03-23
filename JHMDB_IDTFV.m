function JHMDB_IDTFV()
%JHMDB_IDTFV:  Provide the baseline experiment on the JHMDB dataset with
% Improved dense trajectories and Fisher vector.
% You may need to download video data for JHMDB dataset.
%
% Note : Please check TODOs : change the paths etc..
% 
% Dependency : 
% 1. opencv-2.4.9
% 2. IDT (modified version which saves IDT in a faster scheme included in 'bin/')
%
% Version      : 0.1.0
% Release date : 2015/09/11
% Author       : Xiaojiang Peng | Email: xiaojiangp@gmail.com
% 
% If you find this useful, please refer to:
% Peng, X., Wang, L., Wang, X., Qiao, Y.: Bag of visual words and fusion methods for
%   action recognition: Comprehensive study and good practice. CoRR abs/1405.4506.(2014)

    addpath('util')
    % add dependency from vl_feat toolbox and libsvm
    addpath(genpath('mex'))
    % TODO: add OPENCV to LD_LIB Path. 
    % On Windows OS, you need put the OPNENCV DLL lib path to the Path ENVIRONMENT_VARIABLE
    setenv('LD_LIBRARY_PATH','/home/lear/pweinzae/localscratch/libraries/opencv-2.4.9/release/lib');
    des_accs = [];
    for s = 1:3
        % TODO: change some paths in run_split function
        split_accs = run_hmdb_split('split',s, 'dataset', 'jhmdb');
        des_accs = [des_accs, split_accs];
    end
    des_accs = [des_accs, mean(des_accs,2)]  
end