% ========================================================================
% USAGE: [Coeff]=LLC_coding_appr(B,X,knn,lambda)
% Approximated Locality-constraint Linear Coding
%
% Inputs
%       B       -M x d codebook, M entries in a d-dim space
%       X       -N x d matrix, N data points in a d-dim space
%       knn     -number of nearest neighboring
%       lambda  -regulerization to improve condition
%
% Outputs
%       Coeff   -N x M matrix, each row is a code for corresponding X
%
% Jinjun Wang, march 19, 2010
% ========================================================================

function [Coeff] = LLC_coding_appr(encoder, X, knn, beta)

if ~exist('knn', 'var') || isempty(knn),
    knn = 5;
end

if ~exist('beta', 'var') || isempty(beta),
    beta = 1e-4;
end

B = encoder.words'; 
nframe=size(X,2);
nbase=size(B,1);

% find k nearest neighbors ================ slow
[I,D] = vl_kdtreequery(encoder.kdtree, encoder.words, X, ...
            'NUMNEIGHBORS', knn, 'MaxComparisons', 100) ;

X=X'; I = double(I');
% llc approximation coding
II = eye(knn, knn);
Coeff = zeros(nframe, nbase,'single');
for i=1:nframe
   idx = I(i,:);
   z = bsxfun(@minus,B(idx,:), X(i,:));           % shift ith pt to origin
   C = z*z';                                        % local covariance
   C = C + II*beta*trace(C);                        % regularlization (K>D)
   w = C\ones(knn,1);
   w = w/sum(w);                                    % enforce sum(w)=1
   Coeff(i,idx) = w';
end
