function score_test = svm_one_vs_all(K_train,K_test,class_train,num_classes)
%% class_train: 1xn
    score_test = zeros(size(K_test,2), num_classes);
    for class_ind = 1:num_classes
        class_ind
        %train an SVM for each class, test against all test cases.
        Y = 2*(class_train == class_ind)-1; %pos = 1, neg = -1
        libsvm_cl = svmtrain(Y(:), double([(1:length(class_train))' K_train]), '-t 4 -s 0 -h 0 -c 100') ;
        %  [' -t 4 -s 0 -h 0 -w-1 1 -w1 ' num2str(num_classes-1) ' -c 100'] 
        ap = mean(libsvm_cl.sv_coef(Y(libsvm_cl.SVs) > 0)) ;
        am = mean(libsvm_cl.sv_coef(Y(libsvm_cl.SVs) < 0)) ;
        if ap < am
            % fprintf('svmflip: SVM appears to be flipped. Adjusting.\n') ;
            libsvm_cl.sv_coef  = - libsvm_cl.sv_coef ;
            libsvm_cl.rho      = - libsvm_cl.rho ;
        end   
        % test it on test
        score_test(:,class_ind) = libsvm_cl.sv_coef' * K_test(libsvm_cl.SVs,:) - libsvm_cl.rho ;
    end
end