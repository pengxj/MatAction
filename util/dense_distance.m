function [Distance]=dense_distance(H1,H2,computeUnit,mode,param)
%%[Distance]=dense_distance(H1,H2,computeUnit,SPM,SPM_weight_vector,SPMTempfFilename,mode,param)
%%H1:num1 x dim,H2:num x dim. Distance will be num1 x num2. 
%%mode can be 0: L_p distance(p determined by param), 1: Chi2 distance, 2: Histogram Intersection. 
%%param determines parameters for each method (pass empty if no param is required), it can be 0 for L_inf, or 1 or 2 for L_1 or L_2.
Distance=zeros(size(H1,1),size(H2,1));
switch computeUnit
    case 0
        switch mode
            case 0
                switch param
                    case 1
                    case 2
                        H11 = sum(H1'.*H1',1);
                        H22 = sum(H2'.*H2',1);
                        H12 = H1*H2';
                        Distance = abs(repmat(H11',[1 size(H22,2)]) + repmat(H22,[size(H11,2) 1]) - 2*H12);
                end
            case 1
                parfor i=1:size(Distance,2)
                    Distance(:,i)=0.5*sum(bsxfun(@rdivide,bsxfun(@power,bsxfun(@minus,H1',H2(i,:)'),2),...
                        bsxfun(@plus,H1',H2(i,:)')+eps));
                end
        end
    case 1
        [Dis]=dense_distance_gpu_large32x16(single(H2),single(H1),mode,param);
        switch mode
            case 0
                Distance=Dis;
            case 1
                Distance=double(0.5*Dis);
        end
end
% toc
end
