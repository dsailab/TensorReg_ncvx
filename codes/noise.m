%%%%%%%%%%%%%%%%%%%%%%%%% settings %%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;
r = 5;
d = 12; 
n = 1000;
spar = 10;
total_experiments = 1; 
sigma_values = [0.01, 0.1,0.5, 1, 10]; 
s = 20;

%%%%%%%%%%%%%%%%%%%%%%%%% change sigma %%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:length(sigma_values)
    sigma = sigma_values(k);
    filename = sprintf('sdata/2/sigma=%.2f.mat', sigma);
    
    % Load existing results if the file exists
    if isfile(filename)
        load(filename, 'A_results', 'Asta', 'Rmse_results');
        current_experiment_index = numel(Rmse_results) + 1; 
    else
        % Initialize variables if the file does not exist
        A_results = cell(1, total_experiments);
        Rmse_results = zeros(1, total_experiments);
        Asta = cell(1, total_experiments);
        current_experiment_index = 1; % 从1开始
        dsrnsig = [d, s, r, n, sigma];
        
        % Save parameters only once
        save(filename, 'dsrnsig');
    end
    
    size = [d, d, s];
    
    % 继续实验直到 total_experiments
    for i = current_experiment_index:total_experiments
        [X, Y, B] = generate_slice_sparse(d, s,spar , n, sigma);
        Asta{i} = B;
        
        % Call the function
        lambda = 0.3 + sqrt(d*spar*s/n)*0.02; 
        
        A = sparse_slice_l1(X, Y, size, n, lambda);
        A_results{i} = A;
        
        Rmse_results(i) = sqrt(mean((B(:) - A(:)).^2));
        % Display progress
        fprintf('sigma = %.1f, Iteration %d completed with RMSE: %f\n', sigma, i, Rmse_results(i));

        % Save results for current sigma value
        save(filename, 'A_results', 'Asta', 'Rmse_results', '-append');
    end
end
