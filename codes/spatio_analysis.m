% 指定CSV文件的路径
filePath = 'NA-1990-2002-Monthly.csv';

% 使用readtable读取CSV文件
data = readtable(filePath);

% 显示数据
disp(data);
