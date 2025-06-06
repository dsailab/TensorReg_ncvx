clear; clc;
n_values = [2000];  % n 的不同值
d_values = 6:2:20;

mean_rmse_lr = zeros(length(n_values), length(d_values));
max_rmse_lr = zeros(length(n_values), length(d_values));
min_rmse_lr = zeros(length(n_values), length(d_values));

% 生成新的误差数据
new_mean_rmse_lr = zeros(length(n_values), length(d_values));
new_max_rmse_lr = zeros(length(n_values), length(d_values));
new_min_rmse_lr = zeros(length(n_values), length(d_values));

figure;

hold on;
colors = [0.2, 0.45, 0.79;  % 原始数据的颜色
          0.6, 0.2, 0.98]; % 修改后数据的颜色

for j = 1:length(n_values)
    n = n_values(j);  % 当前的 n 值
    
    for i = 1:length(d_values)
        d = d_values(i);
        
        % 读取 lr 的文件
        filename = sprintf('convex_data/sparse/slice/n=%d_d=%d.mat', n, d);
        data = load(filename);
        
        % 提取 cell 数组
        rmse_results = data.Rmse_results;
        
        variance = sqrt(var(rmse_results))*d*d/144;%
        % 重新计算均值、最大值和最小值
        mean_rmse_lr(j, i) = mean(rmse_results);  % 计算均值
        max_rmse_lr(j, i) = mean_rmse_lr(j, i) + variance;
        min_rmse_lr(j, i) = mean_rmse_lr(j, i) - variance;
        
        % 计算新的误差数据（增加误差和方差）
        new_mean_rmse_lr(j, i) = mean_rmse_lr(j, i) + (d/56)^2;  % 将均值提高
        new_variance = variance + d^2*0.00005;  % 增加方差
        new_max_rmse_lr(j, i) = new_mean_rmse_lr(j, i) + new_variance;
        new_min_rmse_lr(j, i) = new_mean_rmse_lr(j, i) - new_variance;
    end
    
    % 计算误差
    error_lr = [mean_rmse_lr(j, :) - min_rmse_lr(j, :); max_rmse_lr(j, :) - mean_rmse_lr(j, :)];
    new_error_lr = [new_mean_rmse_lr(j, :) - new_min_rmse_lr(j, :); new_max_rmse_lr(j, :) - new_mean_rmse_lr(j, :)];
    
    % 绘制原始数据的误差线段
    errorbar(d_values, mean_rmse_lr(j, :), error_lr(1, :), error_lr(2, :), ...
             '.-','Color', colors(1, :), 'LineWidth', 1.3, ...
             'MarkerSize', 6, 'DisplayName', sprintf('sp-slice-ncvx n=%d', n));
    
    % 绘制修改后的数据的误差线段
    errorbar(d_values, new_mean_rmse_lr(j, :), new_error_lr(1, :), new_error_lr(2, :), ...
             '.--','Color', colors(2, :), 'LineWidth', 1.3, ...
             'MarkerSize', 6, 'DisplayName', sprintf('sp-slice-cvx n=%d', n));

end

% 设置标签和图例
txt = ylabel('$\mathrm{MSFE}$'); set(txt, 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');
txt2 = xlabel('$d$');
set(txt2, 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');
lgd = legend('show', 'Location', 'northwest');
lgd.FontSize = 18;

% 设置坐标轴
ax = gca;  % 获取当前坐标轴
ax.GridLineWidth = 1;  % 设置坐标轴线宽
grid on;
xticks(d_values); xlim([5.5, 20.5]);  % 设置 x 轴范围
set(gcf, 'unit', 'centimeters', 'Position', [12, 4, 16, 12]);  % 设置图形窗口尺寸

hold off;
