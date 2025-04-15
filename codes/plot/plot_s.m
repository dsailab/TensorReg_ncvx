clear; clc;
f_values = [1,2,3,4,5];  % n 的不同值
s_values = [0.01,0.1,0.5,1,10];

mean_rmse_lr = zeros(length(f_values), length(s_values));

figure;

hold on;
colors = [0.93,0.69,0.13;
    0,0.45,0.74;  
    0.85,0.33,0.10;
    0.69, 0.1, 0.12;
    0.60,0.2,0.6];

for j = 1:length(f_values)
    f = f_values(j);  % 当前的 n 值
    
    for i = 1:length(s_values)
        sigma = s_values(i);
        
        % 读取 lr 的文件
        filename = sprintf('sdata/%d/sigma=%.2f.mat', f, sigma);
        data = load(filename);
        
        % 提取 rmse_results
        rmse_results = data.Rmse_results;
        
        % 计算均值
        mean_rmse_lr(j, i) = mean(rmse_results);  
    end
    if f == 1
        func = 'sp-element';
    end
    if f == 2
        func = 'sp-slice';
    end
    if f == 3
        func = 'sp-fiber';
    end
    if f == 4
        func = 'lr-mode';
    end
    if f == 5
        func = 'lr-slice';
    end
    % 绘图
    plot(s_values, mean_rmse_lr(j, :), 'x-', 'Color', colors(j, :), 'LineWidth', 1.3, ...
         'MarkerSize', 6, 'DisplayName', sprintf('%s', func));
end

% 设置图形属性
txt = ylabel('$\mathrm{MSFE}$'); set(txt, 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');
txt2 = xlabel('$\eta$'); set(txt2, 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');
lgd = legend('show', 'Location', 'best');
lgd.FontSize = 10;

ax = gca; % 获取当前坐标轴
ax.GridLineWidth = 1;  % 设置坐标轴线宽
grid on;

% 设置 x 轴为对数刻度，使得坐标均匀分布
set(gca, 'XScale', 'log');

xticks(s_values);  % 设置 x 轴的刻度
xlim([0.008,12]);
%set(gcf, 'unit', 'centimeters', 'Position', [12, 4, 16, 12]); % 设置图形窗口尺寸

hold off;
