function A_opt = niAPG(Y, X, n, lambda, eta, K, tol, strct)
    % 输入:
    %   Y - 包含n个样本的Y^(i)，大小为cell(1, n)，每个元素是d*d*s的三阶tensor
    %   X - 包含n个样本的X^(i)，大小为cell(1, n)，每个元素是d*d*s的三阶tensor
    %   lambda - 正则化参数
    %   eta - 步长参数
    %   K - 最大迭代次数
    %   tol - 收敛阈值，若MSE的变化小于tol，则提前终止算法
    %   strct - 指定正则化方式，'lr' 为 SCAD 正则化，'sp' 为 L1 正则化
    q = 5;
    [d1, d2, s] = size(X{1}); % 假设每个张量的维度相同
    A = cell(1, K); % 创建一个cell数组保存每个A_k的值
    A{1} = zeros(d1, d2, s); % 初始A_1为随机张量
    
    prev_mse = Inf; % 初始化前一轮的MSE为无穷大
    for k = 1:K-1
        if k == 1
            y_k = A{k};
        else
            y_k = A{k} + (k - 1) / (k + 2) * (A{k} - A{k-1});
        end
        
        F_values = zeros(1, min(q, k));
        for t = max(1, k-q):k
            F_values(t - max(1, k-q) + 1) = objective_function(Y, X, A{t}, lambda, n, strct);
        end
        Delta_k = max(F_values);
        if objective_function(Y, X, y_k, lambda, n, strct) <= Delta_k
            v_k = y_k;
        else
            v_k = A{k};
        end
        grad_v_k = gradient_function(Y, X, v_k, n);
        z_k = v_k - eta * grad_v_k;

        % 更新 A_{k+1}，执行prox运算
        A{k+1} = prox_operator(z_k, lambda, eta, [d1, d2, s],strct);
        
        % 计算MSE并检查是否收敛
        Y_pred = zeros(n, 1);
        for i = 1:n
            Y_pred(i) = innerprod(tensor(A{k+1}), tensor(X{i}));
        end
        mse = mean((Y - Y_pred).^2);
        
        % 打印当前的均方误差
        fprintf('Iteration %d, MSE: %4f\n', k, mse);
        
        % 检查MSE的差值
        if abs(prev_mse - mse) < tol || (prev_mse-mse)<0
            fprintf('Converged at iteration %d with MSE: %4f\n', k, mse);
            break;
        end
        prev_mse = mse; % 更新前一轮的MSE
    end
    fprintf('Final Iteration %d, MSE: %4f\n', k, mse);
    A_opt = A{k}; % 如果在迭代中提前停止，则返回实际迭代次数的结果
end

function F_val = objective_function(Y, X, A, lambda, n, strct)
    loss = 0;
    for i = 1:n
        loss = loss + (Y(i) - innerprod(tensor(X{i}), tensor(A)))^2;
    end
    Ak = mode_n_unfold(A, 1);
    a = 3.7;
    if strcmp(strct, 'lr')  % SCAD 正则化
        [~, S, ~] = svd(Ak, 'econ');
        reg = sum(scad(diag(S), lambda, a)); 
    elseif strcmp(strct, 'sp')  % L1 正则化
        reg = norm(scad(Ak, lambda, a),1); % L1 norm of the unfolded tensor
    else
        error('Unknown structure type. Choose ''lr'' or ''sp''.');
    end
    
    F_val = (1/(2*n)) * loss + lambda * reg; % 总目标函数值
end

function grad = gradient_function(Y, X, A, n)
    grad = zeros(size(A));
    for i = 1:n
        grad = grad + (innerprod(tensor(X{i}), tensor(A)) - Y(i)) * X{i};
    end
    grad = grad / n;
end

function A_next = prox_operator(Z, lambda, eta, original_size, strct)
    if strcmp(strct, 'sp')  
        A_next = sign(Z) .* max(0, abs(Z) - lambda * eta);

    elseif strcmp(strct, 'lr')  
        Ak = mode_n_unfold(Z, 1);
        [U, S, V] = svd(Ak, 'econ');
        diag_S = diag(S);
        for idx = 1:length(diag_S)
            diag_S(idx) = max((diag_S(idx) - lambda * eta), 0);
        end
        A_next = mode_n_fold(U * diag(diag_S) * V', 1, original_size);
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

% function penalty_derivative = scad_derivative(x, lambda, a)
%     if abs(x) <= lambda
%         penalty_derivative = lambda * sign(x);
%     elseif abs(x) <= a * lambda
%         penalty_derivative = (a * lambda - abs(x)) / (a - 1) * sign(x);
%     else
%         penalty_derivative = 0;
%     end
% end

