function code = encodeFeatures(descrs,encoder,use_vlfeat)
%ENCODEFEATURES:
%   descrs    input features dim x n in column-wise
%   encoder   codebook or gmm
%             it has fields words, numWords, kdtree, and type when comes from kmean method,
%             has fields means, covariances, priors, and type when comes from gmm method.
%   use_vlfeat  1: use vl_fisher for fisher vector method, 0: use pure matlab code for fisher vector
beta = 0.5; KNN = 5;
switch encoder.type
    case 'vq'
        [words,distances] = vl_kdtreequery(encoder.kdtree, encoder.words, descrs, ...
            'MaxComparisons', 100) ;
        z = vl_binsum(zeros(encoder.numWords,1), 1, double(words)) ;
        code = z(:)';
    case 'sa-k'
        [I,D] = vl_kdtreequery(encoder.kdtree, encoder.words, descrs, ...
            'NUMNEIGHBORS', KNN, 'MaxComparisons', 100) ;
        D=exp(-beta*D); I = double(I);
        soft_assignment=bsxfun(@rdivide,D,sum(D,1));        
        X = zeros(encoder.numWords, size(descrs,2), 'single') ;
        for i=1:KNN
            X(sub2ind(size(X),I(i,:),1:size(descrs,2)))=soft_assignment(i,:);
        end
        code1 = sum(X,2); %'sum'
        code2 = max(X,[],2); %'max'
        code = [code1,code2];
    case 'spc'
        param.lambda = 0.12;
        X = mexLasso(descrs,encoder.words,param);X=full(X);
        code1 = sum(abs(X),2); %'sum'
        code2 = max(abs(X),[],2); %'max'
        code = [code1,code2];
    case 'llc'
        X = LLC_coding_appr(encoder,descrs,KNN)';
        code1 = sum(abs(X),2); %'sum'
        code2 = max(abs(X),[],2); %'max'
        code = [code1,code2];
    case 'vlad-all'
        assign = zeros(encoder.numWords, size(descrs,2), 'single') ;
        disMatrix=dense_distance(encoder.words',descrs',1,0,2);%====== the 3rd param sets GPU unit
        disMatrix=exp(-beta*disMatrix);
        assign=bsxfun(@rdivide,disMatrix,sum(disMatrix,1));
        z = vl_vlad(single(descrs), single(encoder.words), assign, 'Unnormalized') ;
        code = z(:)';
    case 'vlad-k'
        assign = zeros(encoder.numWords, size(descrs,2), 'single') ;
        [I,D] = vl_kdtreequery(encoder.kdtree, encoder.words, descrs, ...
            'NUMNEIGHBORS', KNN, 'MaxComparisons', 100) ;
        D=exp(-beta*D); I = double(I);
        temp=bsxfun(@rdivide,D,sum(D,1)); 
        for i=1:KNN
            assign(sub2ind(size(assign),I(i,:),1:size(descrs,2)))=temp(i,:);
        end
        z = vl_vlad(single(descrs), single(encoder.words), assign, 'Unnormalized') ;
        code = z(:)';
    case 'fv'        
        if use_vlfeat==1
          z = vl_fisher(descrs, encoder.means, encoder.covariances, encoder.priors) ;
        else
          P = get_posteriors(descrs, encoder.means, encoder.covariances, encoder.priors);
          P(find(P<1e-4)) = 0;
          P = bsxfun(@rdivide,P,sum(P,1));
          dimension = size(descrs,1); numData = size(descrs,2);
          sqrtInvSigma = sqrt(1./encoder.covariances);
          uprefix = 1./(sqrt(encoder.priors));%numData*
          vprefix = 1./(sqrt(2*encoder.priors));%numData*
          z = zeros(2*dimension*encoder.numWords,1);
          for gmm_i = 1:encoder.numWords
              if encoder.priors(gmm_i)<1e-6,
                  continue;
              end
              diff = bsxfun(@minus,descrs,encoder.means(:,gmm_i));
              diff = bsxfun(@times, diff, sqrtInvSigma(:,gmm_i));
              % mean
              z((gmm_i-1)*dimension+1:gmm_i*dimension) = ...
                  uprefix(gmm_i)*sum(bsxfun(@times,P(gmm_i,:), diff),2);
              % var
              z(encoder.numWords*dimension+(gmm_i-1)*dimension+1:encoder.numWords*dimension+gmm_i*dimension) = ...
                  vprefix(gmm_i)*sum(bsxfun(@times,P(gmm_i,:), diff.^2 - 1),2);
          end
        end
        code = z(:)';
    case 'svc'
        s = 0.1;
        [words,distances] = vl_kdtreequery(encoder.kdtree, encoder.words, ...
            descrs,'MaxComparisons', 15) ;
        assign = zeros(encoder.numWords, numel(words), 'single') ;
        assign(sub2ind(size(assign), double(words), 1:numel(words))) = 1 ;
        z = vl_vlad(single(descrs), single(encoder.words), assign, 'Unnormalized') ;
        px = sum(assign,2)';
        px = px/size(descrs,2);
        px(find(px<1e-4)) = 1; % no divide
        z = reshape(z,size(descrs,1),encoder.numWords);
        z = [s*ones(1,encoder.numWords);z];
        z = bsxfun(@rdivide,z,sqrt(px))/size(descrs,2);
        z = reshape(z,size(descrs,1)*encoder.numWords+encoder.numWords,1);
        code = z(:)';
    case 'svc-k'
        s = 0.1;
        assign = zeros(encoder.numWords, size(descrs,2), 'single') ;
        [I,D] = vl_kdtreequery(encoder.kdtree, encoder.words, descrs, ...
            'NUMNEIGHBORS', KNN, 'MaxComparisons', 100) ;
        D=exp(-beta*D); I = double(I);
        temp=bsxfun(@rdivide,D,sum(D,1)); 
        for i=1:KNN
            assign(sub2ind(size(assign),I(i,:),1:size(descrs,2)))=temp(i,:);
        end
        z = vl_vlad(single(descrs), single(encoder.words), assign, 'Unnormalized') ;
        px = sum(assign,2)';
        px = px/size(descrs,2);
        px(find(px<1e-4)) = 1; % no divide
        z = reshape(z,size(descrs,1),encoder.numWords);
        z = [s*ones(1,encoder.numWords);z];
        z = bsxfun(@rdivide,z,sqrt(px))/size(descrs,2);
        z = reshape(z,size(descrs,1)*encoder.numWords+encoder.numWords,1);
        code = z(:)';
    case 'svc-all'
        s = 0.1; beta = 0.5; KNN = 50; % approximate svc-all
        assign = zeros(encoder.numWords, size(descrs,2), 'single') ;
        [I,D] = vl_kdtreequery(encoder.kdtree, encoder.words, descrs, ...
            'NUMNEIGHBORS', KNN, 'MaxComparisons', 100) ;
        D=exp(-beta*D); I = double(I);
        temp=bsxfun(@rdivide,D,sum(D,1)); 
        for i=1:KNN
            assign(sub2ind(size(assign),I(i,:),1:size(descrs,2)))=temp(i,:);
        end
%         assign = zeros(encoder.numWords, size(descrs,2), 'single') ;
%         disMatrix=dense_distance(encoder.words',descrs',1,0,2);%======
%         % scale dist -> 0-20
%         disMatrix=exp(-beta*disMatrix);% 
%         assign=bsxfun(@rdivide,disMatrix,sum(disMatrix,1));
        z = vl_vlad(single(descrs), single(encoder.words), assign, 'Unnormalized') ;
        px = sum(assign,2)';
        px = px/size(descrs,2);
        px(find(px<1e-4)) = 1; % no divide
        z = reshape(z,size(descrs,1),encoder.numWords);
        z = [s*ones(1,encoder.numWords);z];
        z = bsxfun(@rdivide,z,sqrt(px))/size(descrs,2);
        z = reshape(z,size(descrs,1)*encoder.numWords+encoder.numWords,1);
        code = z(:)';
end

% get posteriors by computing in log domain
function posteriors = get_posteriors(descrs,means,covariances,priors)
  dimension = size(descrs,1);
  numData = size(descrs,2); numClusters = length(priors);
  posteriors = zeros(numClusters, numData,'single');
  logWeights = log(priors);
  logCovariances = log(covariances); logCovariances = sum(logCovariances,1);
  invCovariances = 1./covariances;
  halfDimLog2Pi = (dimension / 2.0) * log(2.0*pi);

  for i = 1:numClusters
      tmp = bsxfun(@minus,descrs,means(:,i));
      p = logWeights(i) - halfDimLog2Pi - 0.5 * logCovariances(i) - ...
          0.5 * sum(bsxfun(@times,bsxfun(@times, tmp,invCovariances(:,i)),tmp),1);
      posteriors(i,:) = p;    
  end
  maxPosterior = max(posteriors,[],1);
  posteriors2 = bsxfun(@minus,posteriors,maxPosterior);
  posteriors2 = exp(posteriors2);
  posteriors = bsxfun(@times,posteriors2,1./sum(posteriors2,1));
end
