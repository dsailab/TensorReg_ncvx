function [X, Y, B] = generate_rank(d, r, n, sigma)
    U = normrnd(0, 1, [d, r]); 
    V = randn(r,d); % 右因子，从正态分布生成
    B = U * V; % 

    X = cell(1, n);  % sensing vectors
    Y = zeros(n, 1); % measurements
    
    for i = 1:n
        X{i} = normrnd(0, 1, [d, d]);
        Y_mean = trace(B*X{i}'); % y_i = a_i^T S a_i + eta_i
        eta = normrnd(0, sigma);
        Y(i) = Y_mean + eta; 
    end
end
