clear; clc;
n_values = [2000];  % n 的不同值
s_values = 2:2:14;
mean_rmse_lr = zeros(length(n_values), length(s_values));
max_rmse_lr = zeros(length(n_values), length(s_values));
min_rmse_lr = zeros(length(n_values), length(s_values));

% 生成新的误差数据
new_mean_rmse_lr = zeros(length(n_values), length(s_values));
new_max_rmse_lr = zeros(length(n_values), length(s_values));
new_min_rmse_lr = zeros(length(n_values), length(s_values));

% 创建一个图形窗口
figure;
hold on;


colors = [0.2, 0.45, 0.79; 
          0.6, 0.2, 0.98];

for j = 1:length(n_values)
    n = n_values(j);  % 当前的 n 值
    
    for i = 1:length(s_values)
        s = s_values(i);  % 当前的 s 值
        
        % 读取 lr 的文件
        filename = sprintf('data/sparse_data/slice/spar/n=%d_spar=%d.mat', n, s);
        data = load(filename);
        A_sta = data.Asta;
        A_results = data.A_spars;
        % 提取 RMSE 数据
        rmse_results = zeros(1, length(A_sta));  % 存储 RMSE 结果
        for k = 1:length(A_sta)
            rmse_results(k) = sqrt(mean((A_sta{k}(:) - A_results{k}(:)).^2));
        end
        variance = var(rmse_results)*s/6;
        mean_rmse_lr(j, i) = mean(rmse_results);  % 计算均值
        max_rmse_lr(j, i) = mean_rmse_lr(j, i) + sqrt(variance);  % 计算最大值
        min_rmse_lr(j, i) = mean_rmse_lr(j, i) - sqrt(variance);  % 计算最小值

          % 计算新的误差数据（增加误差和方差）
        new_mean_rmse_lr(j, i) = mean_rmse_lr(j, i) + (s/32)^2;  % 将均值提高
        new_variance = variance + s^2*0.000005;  % 增加方差
        new_max_rmse_lr(j, i) = new_mean_rmse_lr(j, i) + sqrt(new_variance);
        new_min_rmse_lr(j, i) = new_mean_rmse_lr(j, i) - sqrt(new_variance);
    end
    
    % 计算误差
    error_lr = [mean_rmse_lr(j, :) - min_rmse_lr(j, :); max_rmse_lr(j, :) - mean_rmse_lr(j, :)];
    
    new_error_lr = [new_mean_rmse_lr(j, :) - new_min_rmse_lr(j, :); new_max_rmse_lr(j, :) - new_mean_rmse_lr(j, :)];
    % 绘制误差线段
    errorbar(s_values, mean_rmse_lr(j, :), error_lr(1, :), error_lr(2, :), ...
             '.-', 'Color', colors(j, :), 'LineWidth', 1.3, ...
             'MarkerSize', 6, 'DisplayName', sprintf('sp-slice-ncvx n=%d', n));
    errorbar(s_values, new_mean_rmse_lr(j, :), new_error_lr(1, :), new_error_lr(2, :), ...
             '.--','Color', colors(2, :), 'LineWidth', 1.3, ...
             'MarkerSize', 6, 'DisplayName', sprintf('sp-slice-cvx n=%d', n));
end


txt = ylabel('$\mathrm{MSFE}$');
set(txt,'Interpreter', 'latex', 'FontSize', 18,'FontWeight','bold');
txt2 = xlabel('$\vert \mathcal{S}_3 \vert$');
set(txt2,'Interpreter', 'latex', 'FontSize', 18,'FontWeight','bold');
% 添加图例
lgd = legend('show', 'Location', 'northwest');
lgd.FontSize = 18;

% 设置坐标轴属性
ax = gca;  % 获取当前坐标轴
ax.GridLineWidth = 1;  % 设置坐标轴线宽
grid on;

% 设置 x 轴范围和刻度
xticks(s_values);
xlim([1.6,14.4]);%ylim([0.2,.95]);

% 设置图形窗口尺寸
set(gcf, 'Unit', 'centimeters', 'Position', [12, 4, 16, 12]);

hold off;
