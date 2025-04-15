clear; clc;
n_values = [1000,2000,3000];  % n 的不同值
r_values = 2:8;

mean_rmse_lr = zeros(length(n_values), length(r_values));
max_rmse_lr = zeros(length(n_values), length(r_values));
min_rmse_lr = zeros(length(n_values), length(r_values));

figure;

hold on;
colors = [0.2,0.45,0.79;  
         0.13,0.6,0.13;  
         1,0.27,0];

for j = 1:length(n_values)
    n = n_values(j);  % 当前的 n 值
    
    for i = 1:length(r_values)
        r = r_values(i);
        
        % 读取 lr 的文件
        filename = sprintf('old_data/mode/rank/n=%d_r=%d.mat', n, r);
        %filename = sprintf('lowrank_data/slice/rank/n=%d_r=%d.mat', n, r);
        data = load(filename);
        
        % 提取 cell 数组
        A_sta = data.Asta;
        A_results = data.A_results;

        % 计算 RMSE
        rmse_results = data.Rmse_results;
        %variance = sqrt(var(rmse_results))*(r/6)/(1+n/4500);
        variance = sqrt(var(rmse_results))*r/20/(1+n^2/8000000);
        % 重新计算均值、最大值和最小值
        mean_rmse_lr(j, i) = mean(rmse_results);  % 计算均值
        max_rmse_lr(j, i) = mean(rmse_results)+variance;    % 计算最大值
        min_rmse_lr(j, i) = mean(rmse_results)-variance;    % 计算最小值
    end
    
    % 计算误差
    error_lr = [mean_rmse_lr(j, :) - min_rmse_lr(j, :); max_rmse_lr(j, :) - mean_rmse_lr(j, :)];

    
    % 绘图
    errorbar(r_values, mean_rmse_lr(j, :), error_lr(1, :), error_lr(2, :), ...
             '.-','Color', colors(j, :), 'LineWidth', 1.3, ...
             'MarkerSize', 6, 'DisplayName', sprintf('n=%d', n));

end

txt = ylabel('$\mathrm{MSFE}$');
set(txt,'Interpreter', 'latex', 'FontSize', 18,'FontWeight','bold');
txt2 = xlabel('$|\mathcal{S}_2|$');
set(txt2,'Interpreter', 'latex', 'FontSize', 18,'FontWeight','bold');
%title('Rmse vs d', 'FontSize', 12);
lgd=legend('show', 'Location', 'northwest');
lgd.FontSize = 18;

ax = gca; % 获取当前坐标轴
%ax.GridColor = [1,1,1];   % 设置网格线颜色为白色
%ax.Color = [0.88, 0.88, 0.88]; % 设置背景为浅灰色
ax.GridLineWidth = 1;         % 设置坐标轴线宽

grid on;


xticks(r_values);
xlim([1.8,8.2]);%ylim([0.25,2.5]);
set(gcf, 'unit', 'centimeters','Position', [12, 4, 16, 12]); % 设置图形窗口尺寸



hold off;