function [cm, avg_acc, index]= get_cm(gt,predict_label,FLAG)
% Get confision matrix and average accuracy from groundtruth and predict
% result.
% Written by Xiaojiang Peng,9/2012. Email: xiaojiangp@gmail.com
% Input:
%     gt and predict_label are both column vectors
%     FLAG=1 is for rate format.
% Output:
%     cm: the confision matrix
%     avg_acc: the average accuracy
%     index: err index
    err = predict_label - gt;
    index = err~=0;
    err_index = find(index);
    err_label = predict_label(index); true_label = gt(index);
    index = [err_index,true_label,err_label];
    nLabel = size(gt,1);
    ncls = max(unique(gt));
    cm = zeros(ncls,ncls);
    for i=1:nLabel
        cm(gt(i),predict_label(i)) = cm(gt(i),predict_label(i))+1;
    end
    if(FLAG)
        sums = sum(cm,2);
        for i=1:ncls
            if sums(i)~=0,
            cm(i,:) = cm(i,:)/sums(i);
            end
        end
    end
    TR = trace(cm);
    S = sum(cm); S=sum(S);
    avg_acc = TR/S;
end