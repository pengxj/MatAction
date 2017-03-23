function X = normalizeL2(X)
% X in colume-wise
    X = bsxfun(@rdivide,X,eps+sqrt(sum(X.^2)));
end