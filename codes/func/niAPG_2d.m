function A_opt = niAPG_2d(X,Y, n, lambda, eta, K,tol, strct)
    % input:
    %   Y - n samples of Y^i, 
    %   X - n samples of ^i, 
    %   K - num of iteration
    %   q - sliding window of Delta_k
    q = 5; 
    [d1, d2] = size(X{1}); %size of the input tensor
    A = cell(1, K); % 
    A{1} = zeros(d1, d2); % initialize the estimated tensor
    prev_mse = Inf; % 初始化前一轮的MSE为无穷大
    for k = 1:K-1  
        if k == 1
            y_k = A{k};
        else
            y_k = A{k} + (k - 1) / (k + 2) * (A{k} - A{k-1});
        end
        
        F_values = zeros(1, min(q, k));
        for t = max(1, k-q):k
            F_values(t - max(1, k-q) + 1) = objective_function(Y, X, A{t}, lambda, n,strct);
        end
        Delta_k = max(F_values);

        if objective_function(Y, X, y_k, lambda, n,strct) <= Delta_k
            v_k = y_k;
        else
            v_k = A{k};
        end

        grad_v_k = gradient_function(Y, X, v_k, n);
        z_k = v_k - eta * grad_v_k;

        A{k+1} = prox_operator(z_k, lambda, eta,strct);
        
        % Y = AX
        Y_pred = zeros(n, 1);
        for i = 1:n
            Y_pred(i) = innerprod(tensor(A{k+1}), tensor(X{i}));
        end
        mse = mean((Y - Y_pred).^2);
        fprintf('Iteration %d, MSE: %4f\n', k, mse);
        
        if abs(prev_mse - mse) < tol
            fprintf('Converged at iteration %d with MSE: %4f\n', k, mse);
            break;
        end
        prev_mse = mse; % 更新前一轮的MSE
    end
    fprintf('Final Iteration %d, MSE: %4f\n', k, mse);
    A_opt = A{K};
end

function F_val = objective_function(Y, X, A, lambda, n,strct)
    % calculate the loss function
    loss = 0;
    for i = 1:n
        loss = loss + (Y(i) - trace(A * X{i}'))^2;
    end
    
    a=3.7;
    if strcmp(strct, 'lr')  % SCAD 正则化
        [~, S, ~] = svd(A, 'econ');
        reg = sum(scad(diag(S), lambda, a)); 
    elseif strcmp(strct, 'sp')  % L1 正则化
        reg = norm(scad(A, lambda, a),1); % L1 norm of the unfolded tensor
    else
        error('Unknown structure type. Choose ''lr'' or ''sp''.');
    end
    F_val = (1/(2*n)) * loss + lambda*reg;
end

function grad = gradient_function(Y, X, A, n)
    grad = zeros(size(A));
    for i = 1:n
        grad = grad + (trace(A* X{i}') - Y(i)) * X{i};
    end
    grad = grad / n;
end

function A_next = prox_operator(Z, lambda, eta,strct)
    if strcmp(strct, 'sp')  
        A_next = sign(Z) .* max(0, abs(Z) - lambda * eta);
    elseif strcmp(strct, 'lr')
        A_next = zeros(size(Z));
        [U, S, V] = svd(Z, 'econ');
        diag_S = diag(S);
        for idx = 1:length(diag_S)
            diag_S(idx) = max((diag_S(idx)-lambda*eta),0);
        end
        A_next = A_next + U * diag(diag_S) * V';
    else
        error('Unknown structure type. Choose ''lr'' or ''sp''.');
    end
end

function penalty_single = scad(x, lambda, a)
    if abs(x) <= lambda
        penalty_single = lambda * abs(x);
    elseif abs(x) <= a * lambda
        penalty_single = (-x.^2 + 2 * a * lambda * abs(x) - lambda^2) / (2 * (a - 1));
    else
        penalty_single = (lambda^2 * (a^2 - 1)) / 2;
    end
end



