clear;
d = 8;
r= 2;
n= 1000;
sigma =0.1;
[X, Y, B] = generate_rank(d, r, n, sigma);
%% 
size = [d,d];
lambda = 0.1;
eta =  0.1;
K = 25; % steps
strct = 'lr';
tol = 0.01;
tic;
A_opt = niAPG(Y, X, n, lambda, eta, K,tol, strct);
toc;
%A = lowrank_mode(X,Y,size,n,lambda);
%% 


rm1 = norm((B-A_opt),'fro');
%rm2 = norm((B-A),'fro');
%fprintf('rm1 = %f,rm2 = %f',rm1,rm2);
%% 

% 创建坐标网格
[x, y, z] = meshgrid(1:d, 1:d, 1:d);

% 将 B 和 A_opt 转换为列向量
B_flat = B(:);
A_opt_flat = A_opt(:);

% 计算差异
diff = abs(B_flat - A_opt_flat);

% 创建颜色数组
colors = zeros(length(diff), 3); % RGB 颜色

% 初始化计数器
blue_count = 0; % 蓝色点的数量
red_count = 0;  % 红色点的数量

% 根据差异填充颜色数组，并统计点的数量
for i = 1:length(diff)
    if diff(i) < 1e-2
        colors(i, :) = [0.2,0.45,0.79]; % 蓝色
        blue_count = blue_count + 1; % 统计蓝色点
    else
        colors(i, :) = [1,0.27,0]; % 红色
        red_count = red_count + 1; % 统计红色点
    end
end

% 输出统计结果
fprintf('蓝色点的数量: %d\n', blue_count);
fprintf('红色点的数量: %d\n', red_count);

% 使用 scatter3 函数绘制点云图
figure;
scatter3(x(:), y(:), z(:), 10, colors, 'filled');
xlabel('X');
ylabel('Y');
zlabel('Z');
title('3D Visualization of Original and Predicted Tensor');
axis equal;
grid on;
view(3); % 设置 3D 视角



