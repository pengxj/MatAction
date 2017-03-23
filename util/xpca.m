function [projection, projectionCenter]= xpca(descrs, whiten, pca_k)
%XPCA:   pca descrs in column-wise
    whiteningRegul = 0.01;
    projectionCenter = mean(descrs,2) ;
    x = bsxfun(@minus, descrs, projectionCenter) ;
    projectionCenter = projectionCenter';
    X = x*x' / size(x,2) ;
    [V,D] = eig(X) ;
    d = diag(D) ;
    [d,perm] = sort(d,'descend') ;
    energy = sum(d(1:pca_k))/sum(d);
    fprintf('%1.2f energy keeped\n', energy);
    d = d + whiteningRegul * max(d) ;
    m = min(pca_k, size(descrs,1)) ;
    V = V(:,perm) ;
    if whiten
        projection = diag(1./sqrt(d(1:m))) * V(:,1:m)' ;%
        projection = projection';
    else
        projection = V(:,1:m) ;
    end
    clear X V D d ;
end