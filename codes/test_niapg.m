clear;

d = 8;
s= 8;
r= 2;
n= 1000;
sigma =0.1;
%sparsity = 0.5;
%[X, Y, B] = generate_entry_sparse(d, s, 0.3, n, sigma);
[X, Y, B] = generate_Tucker_lowrank(d, s, [r,r,r], n, sigma);
%[X, Y, B] = generate_rank(d, r, n, sigma);
%% 

size = [d,d,s];
lambda = 0.3;
eta =  0.1;
K = 25; % steps
strct = 'lr';
tol = 0.01;
tic;
A_opt = niAPG(Y, X, n, lambda, eta, K,tol, strct);
toc;
rm1 = norm((B-A_opt),'fro');
tic;
A_o = lowrank_mode(X,Y,size,n,lambda);
toc;
rm2 = norm((B-A_o),'fro');
%fprintf('rm1 = %f,rm2 = %f',rm1,rm2);
%% 
[x,y] = meshgrid(1:d, 1:d);
% 计算差异
diff = abs(B - A_opt);

% 创建颜色数组
colors = zeros(numel(diff), 3); % RGB 颜色

% 初始化计数器
blue_count = 0; % 蓝色点的数量
red_count = 0;  % 红色点的数量

% 根据误差填充颜色数组，并统计数量
for i = 1:numel(diff)
    if diff(i) < 0.01
        colors(i, :) = [0.2,0.45,0.79]; % 蓝色
        blue_count = blue_count + 1; % 统计蓝色点
    else
        colors(i, :) = [1 0.27 0]; % 红色
        red_count = red_count + 1; % 统计红色点
    end
end

% 输出统计结果
fprintf('蓝色点的数量: %d\n', blue_count);
fprintf('红色点的数量: %d\n', red_count);

% 使用 scatter3 函数绘制点云图
figure;
scatter3(x(:), y(:), A_opt(:), 22, colors, 'filled','MarkerFaceAlpha', 0.7); % 使用 A_opt_slice 的值作为 z 轴
xlabel('X');
ylabel('Y');
zlabel('Z (estimated value)');
axis equal;
grid on;
view(3); % 设置 3D 视角
% 添加一个半透明的 XY 平面
hold on;


z_plane = zeros(d,d);  % Z 坐标为 0，表示 XY 平面
% 绘制半透明的 XY 平面
surf(x, y, z_plane, 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'FaceColor', [0.7 0.7 0.7] );

% 添加每个点到 XY 平面的垂线 %%%%%%%%%%%%%%%
hold on;  % 保持当前图形不清空
for i = 1:numel(x)
    % 绘制垂直线到 XY 平面，Z 坐标为 0，颜色与点相同
    plot3([x(i) x(i)], [y(i) y(i)], [0 A_opt(i)], 'Color', [colors(i, :) 0.6],'LineWidth', 1,'LineStyle', '-');  % 使用相同颜色
end


% 添加边框 %%%%%%%%%%%%%%%
x_min = min(x(:));  % 最小的 x 值
x_max = max(x(:));  % 最大的 x 值
y_min = min(y(:));  % 最小的 y 值
y_max = max(y(:));  % 最大的 y 值
% 绘制边框的四条线
line([x_min x_max], [y_min y_min], [0 0], 'Color', [0.7 0.7 0.7,0.2], 'LineWidth', 2); % 下边框
line([x_max x_max], [y_min y_max], [0 0], 'Color', [0.7 0.7 0.7,0.2], 'LineWidth', 2); % 右边框
line([x_max x_min], [y_max y_max], [0 0], 'Color', [0.7 0.7 0.7,0.2], 'LineWidth', 2); % 上边框
line([x_min x_min], [y_max y_min], [0 0], 'Color', [0.7 0.7 0.7,0.2], 'LineWidth', 2); % 左边框
hold off;
%view([90 36 0]);

%% 
total_points = numel(diff);
% 定义数据
% 定义数据
blue_count1 = 76.45;
red_count1 = total_points - blue_count1;
blue_count2 = 56.68;
red_count2 = total_points - blue_count2;

% 生成 2D 的柱状图
figure;
hold on;

% 设置 X 轴的位置，两个组之间留一点空隙
group1_x = [1, 2];  % Blue1 和 Red1
group2_x = [4, 5];  % Blue2 和 Red2

% 创建两个组的柱状图
b1 = bar(group1_x, [blue_count1, red_count1], 'FaceColor', 'flat');
b1.CData(1, :) = [0.2, 0.45, 0.79]; % 蓝色 1
b1.CData(2, :) = [1, 0.27, 0];      % 红色 1

b2 = bar(group2_x, [blue_count2, red_count2], 'FaceColor', 'flat');
b2.CData(1, :) = [0.2, 0.45, 0.79]; % 蓝色 2
b2.CData(2, :) = [1, 0.27, 0];      % 红色 2

% 设置 X 轴标签
set(gca, 'XTick', [1.5, 4.5]); % 中心位置作为每组的标签
set(gca, 'XTickLabel', {'Nonconvex', 'Convex'}); % 设置新的 X 轴标签

% 设置 Y 轴标签
ylabel('Averaged Counts');

% 设置柱子宽度
b1.BarWidth = 0.8;  % 第一组柱子的宽度
b2.BarWidth = 0.8;  % 第二组柱子的宽度


% 在每个柱子旁边显示数值
for i = 1:length(b1.YData)
    % 在第一组柱子顶部添加数值
    text(b1.XData(i), b1.YData(i) -.5, num2str(b1.YData(i), '%.2f'), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', 10, 'Color', 'black');
end

for i = 1:length(b2.YData)
    % 在第二组柱子顶部添加数值
    text(b2.XData(i), b2.YData(i) -.5, num2str(b2.YData(i), '%.2f'), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', 10, 'Color', 'black');
end

hold off;

%% 
% 绘制俯视的等高线图
figure;
contourf(x, y, B, 10); % 使用填充等高线
colorbar; % 添加颜色条
%colormap jet; % 设置颜色映射
xlabel('X');
ylabel('Y');
axis equal;
grid on;

%% 



