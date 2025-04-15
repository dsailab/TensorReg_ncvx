clear;

d = 16;
s= 16;
r= 2;
n= 1000;
sigma =0.1;
sparsity = 0.5;
%[X, Y, B] = generate_entry_sparse(d, s, 0.3, n, sigma);
[X, Y, B] = generate_Tucker_lowrank(d, s, [r,r,r], n, sigma);
%% 

size = [d,d,s];
lambda = 0.3;
eta =  0.1;
K = 30; % steps
strct = 'sp';
tol = 0.01;
tic;
A_opt = niAPG(Y, X, n, lambda, eta, K,tol, strct);
toc;
rm1 = norm((B-A_opt),'fro');
tic;
A_o = lowrank_mode(X,Y,size,n,lambda);
%A_o = sparse_entry(X,Y,size,n,lambda,0.3);
toc;
rm2 = norm((B-A_o),'fro');
%fprintf('rm1 = %f,rm2 = %f',rm1,rm2);


