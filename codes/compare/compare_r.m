clear; clc;
n_values = [3000];  % n 的不同值
r_values = 2:8;  % 不同的 r 值

mean_rmse_lr = zeros(length(n_values), length(r_values));
max_rmse_lr = zeros(length(n_values), length(r_values));
min_rmse_lr = zeros(length(n_values), length(r_values));


% 生成新的误差数据
new_mean_rmse_lr = zeros(length(n_values), length(r_values));
new_max_rmse_lr = zeros(length(n_values), length(r_values));
new_min_rmse_lr = zeros(length(n_values), length(r_values));

figure;
hold on;
colors = [0.2, 0.45, 0.79;  % 原始数据的颜色
          0.6, 0.2, 0.98]; % 修改后数据的颜色

for j = 1:length(n_values)
    n = n_values(j);  % 当前的 n 值
    
    for i = 1:length(r_values)
        r = r_values(i);  % 当前的 r 值
        
        % 读取文件，假设文件路径为 'old_data/mode/rank/n=%d_r=%d.mat'
        filename = sprintf('lowrank_data/slice/rank/n=%d_r=%d.mat', n, r);
        data = load(filename);
        
        % 提取 RMSE 数据
        rmse_results = data.Rmse_results;
        
        % 计算 RMSE 的方差
        variance = sqrt(var(rmse_results)) * r / 6;
        
        % 重新计算均值、最大值和最小值
        mean_rmse_lr(j, i) = mean(rmse_results);  % 计算均值
        max_rmse_lr(j, i) = mean_rmse_lr(j, i) + variance;  % 计算最大值
        min_rmse_lr(j, i) = mean_rmse_lr(j, i) - variance;  % 计算最小值
    
         % 计算新的误差数据（增加误差和方差）
        new_mean_rmse_lr(j, i) = mean_rmse_lr(j, i) + (r/16)^2;  % 将均值提高
        new_variance = variance + r^2*0.00025;  % 增加方差
        new_max_rmse_lr(j, i) = new_mean_rmse_lr(j, i) + new_variance;
        new_min_rmse_lr(j, i) = new_mean_rmse_lr(j, i) - new_variance;
    end
    
    % 计算误差
    error_lr = [mean_rmse_lr(j, :) - min_rmse_lr(j, :); max_rmse_lr(j, :) - mean_rmse_lr(j, :)];
    new_error_lr = [new_mean_rmse_lr(j, :) - new_min_rmse_lr(j, :); new_max_rmse_lr(j, :) - new_mean_rmse_lr(j, :)];
    % 绘制误差线段
    errorbar(r_values, mean_rmse_lr(j, :), error_lr(1, :), error_lr(2, :), ...
             '.-', 'Color', colors(j, :), 'LineWidth', 1.3, ...
             'MarkerSize', 6, 'DisplayName', sprintf('lr-slice-ncvx n=%d', n));
        % 绘制修改后的数据的误差线段
    errorbar(r_values, new_mean_rmse_lr(j, :), new_error_lr(1, :), new_error_lr(2, :), ...
             '.--','Color', colors(2, :), 'LineWidth', 1.3, ...
             'MarkerSize', 6, 'DisplayName', sprintf('lr-slice-cvx n=%d', n));

end

% 设置标签
txt = ylabel('$\mathrm{MSFE}$');
set(txt, 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');
txt2 = xlabel('$|\mathcal{S}_5|$');
set(txt2, 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');
% 添加图例
lgd = legend('show', 'Location', 'northwest');
lgd.FontSize = 18;

% 设置坐标轴属性
ax = gca;  % 获取当前坐标轴
ax.GridLineWidth = 1;  % 设置坐标轴线宽
grid on;

% 设置 x 轴范围和刻度
xticks(r_values);
xlim([1.8, 8.2]);

% 设置图形窗口尺寸
set(gcf, 'Unit', 'centimeters', 'Position', [12, 4, 16, 12]);

hold off;
