function X = normalizeIntra(X, ncomponent,n)
% X in colume-wise
    X = reshape(X,[size(X,1)/ncomponent,ncomponent*n]);
    X = bsxfun(@rdivide,X,eps+sqrt(sum(X.^2)));
    X = reshape(X,[size(X,1)*ncomponent,n]);
end