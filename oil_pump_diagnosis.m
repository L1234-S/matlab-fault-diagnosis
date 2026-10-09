%% 石油开采泵系统故障诊断程序
% 功能：通过传感器数据分析石油泵的工作状态，识别常见故障
% 主要故障类型：泵损伤、流量异常、压力异常、温度异常
%
% 作者：故障诊断系统
% 日期：2026年10月

clear all; close all; clc;

%% 步骤1：生成模拟传感器数据
% 在实际应用中，这些数据来自真实传感器
fprintf('========== 石油开采泵故障诊断系统 ==========\n\n');
fprintf('步骤1：生成传感器数据...\n');

% 时间向量（模拟100秒的运行时间）
t = 0:0.01:100;  % 每0.01秒采样一次
N = length(t);

% 1.1 泵转速数据（正常范围：1000-1500 RPM）
normal_speed = 1200;
pump_speed = normal_speed + 50*sin(0.1*pi*t) + 5*randn(1,N);

% 1.2 泵出口压力数据（正常范围：50-80 MPa）
normal_pressure = 65;
pump_pressure = normal_pressure + 5*sin(0.05*pi*t) + 2*randn(1,N);

% 1.3 流量数据（正常范围：200-300 L/min）
normal_flow = 250;
pump_flow = normal_flow + 30*sin(0.08*pi*t) + 3*randn(1,N);

% 1.4 轴承温度数据（正常范围：40-70℃）
normal_temp = 55;
bearing_temp = normal_temp + 10*sin(0.06*pi*t) + 2*randn(1,N);

% 1.5 振动加速度数据（正常范围：0-2 m/s²）
vibration = 1 + 0.3*sin(0.2*pi*t) + 0.1*randn(1,N);

fprintf('✓ 生成了5个传感器参数的数据序列\n');
fprintf('  - 泵转速: %.0f RPM (正常范围: 1000-1500)\n', mean(pump_speed));
fprintf('  - 出口压力: %.2f MPa (正常范围: 50-80)\n', mean(pump_pressure));
fprintf('  - 流量: %.2f L/min (正常范围: 200-300)\n', mean(pump_flow));
fprintf('  - 轴承温度: %.2f ℃ (正常范围: 40-70)\n', mean(bearing_temp));
fprintf('  - 振动加速度: %.3f m/s² (正常范围: 0-2)\n\n', mean(vibration));

%% 步骤2：定义故障诊断规则
% 基于物理模型和工程经验的诊断规则库
fprintf('步骤2：配置故障诊断规则库...\n');

% 2.1 创建诊断规则结构
fault_rules = struct();

% 规则1：泵损伤（表现为转速下降+流量下降）
fault_rules.pump_damage.speed_threshold = 1100;  % 转速低于此值
fault_rules.pump_damage.flow_threshold = 230;    % 流量低于此值
fault_rules.pump_damage.description = '泵叶轮或泵腔损伤';

% 规则2：流量异常（流量下降但转速正常，可能是堵塞）
fault_rules.blockage.flow_threshold = 220;       % 流量阈值
fault_rules.blockage.speed_threshold = 1150;     % 转速阈值
fault_rules.blockage.description = '进出口管路堵塞';

% 规则3：压力异常（高压可能导致泄漏）
fault_rules.high_pressure.pressure_threshold = 85;
fault_rules.high_pressure.description = '系统压力过高，可能存在泄漏或堵塞';

% 规则4：温度异常（高温表示摩擦增加）
fault_rules.overheat.temp_threshold = 75;
fault_rules.overheat.description = '轴承温度过高，可能存在摩擦增加或冷却系统故障';

% 规则5：振动异常（高振动表示不平衡或损伤）
fault_rules.vibration_fault.vibration_threshold = 1.5;
fault_rules.vibration_fault.description = '振动过大，可能存在泵不平衡或机械松动';

fprintf('✓ 定义了5类诊断规则\n');
fprintf('  1. 泵损伤\n');
fprintf('  2. 管路堵塞\n');
fprintf('  3. 压力异常\n');
fprintf('  4. 温度异常\n');
fprintf('  5. 振动异常\n\n');

%% 步骤3：实时故障检测
fprintf('步骤3：执行故障检测分析...\n');

% 3.1 计算各参数的统计指标
speed_mean = mean(pump_speed);
speed_std = std(pump_speed);
pressure_mean = mean(pump_pressure);
pressure_max = max(pump_pressure);
flow_mean = mean(pump_flow);
flow_min = min(pump_flow);
temp_mean = mean(bearing_temp);
temp_max = max(bearing_temp);
vibration_mean = mean(vibration);
vibration_max = max(vibration);

% 3.2 初始化故障诊断结果
diagnosis_result = struct();
diagnosis_result.faults = {};
diagnosis_result.fault_count = 0;
diagnosis_result.system_status = '正常';

% 3.3 检测故障1：泵损伤
if speed_mean < fault_rules.pump_damage.speed_threshold && ...
   flow_mean < fault_rules.pump_damage.flow_threshold
    diagnosis_result.faults{end+1} = fault_rules.pump_damage.description;
    diagnosis_result.fault_count = diagnosis_result.fault_count + 1;
    fprintf('  ⚠ 检测到故障：%s\n', fault_rules.pump_damage.description);
end

% 3.4 检测故障2：管路堵塞
if flow_mean < fault_rules.blockage.flow_threshold && ...
   speed_mean > fault_rules.blockage.speed_threshold
    diagnosis_result.faults{end+1} = fault_rules.blockage.description;
    diagnosis_result.fault_count = diagnosis_result.fault_count + 1;
    fprintf('  ⚠ 检测到故障：%s\n', fault_rules.blockage.description);
end

% 3.5 检测故障3：压力异常
if pressure_max > fault_rules.high_pressure.pressure_threshold
    diagnosis_result.faults{end+1} = fault_rules.high_pressure.description;
    diagnosis_result.fault_count = diagnosis_result.fault_count + 1;
    fprintf('  ⚠ 检测到故障：%s\n', fault_rules.high_pressure.description);
end

% 3.6 检测故障4：温度异常
if temp_max > fault_rules.overheat.temp_threshold
    diagnosis_result.faults{end+1} = fault_rules.overheat.description;
    diagnosis_result.fault_count = diagnosis_result.fault_count + 1;
    fprintf('  ⚠ 检测到故障：%s\n', fault_rules.overheat.description);
end

% 3.7 检测故障5：振动异常
if vibration_max > fault_rules.vibration_fault.vibration_threshold
    diagnosis_result.faults{end+1} = fault_rules.vibration_fault.description;
    diagnosis_result.fault_count = diagnosis_result.fault_count + 1;
    fprintf('  ⚠ 检测到故障：%s\n', fault_rules.vibration_fault.description);
end

% 3.8 判断系统总体状态
if diagnosis_result.fault_count == 0
    diagnosis_result.system_status = '正常';
    fprintf('  ✓ 未检测到故障，系统运行正常\n');
elseif diagnosis_result.fault_count <= 2
    diagnosis_result.system_status = '警告';
else
    diagnosis_result.system_status = '故障';
end

fprintf('\n');

%% 步骤4：数据可视化
fprintf('步骤4：绘制诊断图表...\n');

% 4.1 创建图形窗口
figure('Name', '石油泵故障诊断系统', 'NumberTitle', 'off', 'Position', [100, 100, 1400, 900]);

% 4.2 绘制转速曲线
subplot(3,2,1);
plot(t, pump_speed, 'b-', 'LineWidth', 1.5);
yline(fault_rules.pump_damage.speed_threshold, 'r--', '故障阈值', 'LineWidth', 2);
xlabel('时间 (秒)'); ylabel('转速 (RPM)');
title('泵转速监测');
grid on;
legend('测量值', '故障阈值');

% 4.3 绘制压力曲线
subplot(3,2,2);
plot(t, pump_pressure, 'g-', 'LineWidth', 1.5);
yline(fault_rules.high_pressure.pressure_threshold, 'r--', '高压阈值', 'LineWidth', 2);
xlabel('时间 (秒)'); ylabel('压力 (MPa)');
title('系统压力监测');
grid on;
legend('测量值', '高压阈值');

% 4.4 绘制流量曲线
subplot(3,2,3);
plot(t, pump_flow, 'm-', 'LineWidth', 1.5);
yline(fault_rules.blockage.flow_threshold, 'r--', '堵塞阈值', 'LineWidth', 2);
xlabel('时间 (秒)'); ylabel('流量 (L/min)');
title('泵流量监测');
grid on;
legend('测量值', '堵塞阈值');

% 4.5 绘制温度曲线
subplot(3,2,4);
plot(t, bearing_temp, 'c-', 'LineWidth', 1.5);
yline(fault_rules.overheat.temp_threshold, 'r--', '过热阈值', 'LineWidth', 2);
xlabel('时间 (秒)'); ylabel('温度 (℃)');
title('轴承温度监测');
grid on;
legend('测量值', '过热阈值');

% 4.6 绘制振动曲线
subplot(3,2,5);
plot(t, vibration, 'k-', 'LineWidth', 1.5);
yline(fault_rules.vibration_fault.vibration_threshold, 'r--', '异常阈值', 'LineWidth', 2);
xlabel('时间 (秒)'); ylabel('加速度 (m/s²)');
title('振动加速度监测');
grid on;
legend('测量值', '异常阈值');

% 4.7 绘制系统状态指示板
subplot(3,2,6);
axis off;
% 状态指示灯颜色
if strcmp(diagnosis_result.system_status, '正常')
    status_color = [0, 1, 0];  % 绿色
    status_text = '✓ 系统正常';
elseif strcmp(diagnosis_result.system_status, '警告')
    status_color = [1, 1, 0];  % 黄色
    status_text = '⚠ 警告状态';
else
    status_color = [1, 0, 0];  % 红色
    status_text = '✗ 故障状态';
end

% 绘制状态指示
rectangle('Position', [0.2, 0.6, 0.6, 0.3], 'FaceColor', status_color, 'EdgeColor', 'black', 'LineWidth', 2);
text(0.5, 0.75, status_text, 'HorizontalAlignment', 'center', 'FontSize', 16, 'FontWeight', 'bold');
text(0.5, 0.4, sprintf('检测到 %d 个故障', diagnosis_result.fault_count), ...
    'HorizontalAlignment', 'center', 'FontSize', 12);

fprintf('✓ 已生成诊断图表\n\n');

%% 步骤5：生成诊断报告
fprintf('========== 故障诊断报告 ==========\n\n');
fprintf('系统状态: %s\n', diagnosis_result.system_status);
fprintf('检测时间: %s\n', datetime('now'));
fprintf('分析数据点数: %d\n', N);
fprintf('\n--- 传感器数据统计 ---\n');
fprintf('转速: 平均%.0f RPM, 标准差%.1f RPM\n', speed_mean, speed_std);
fprintf('压力: 平均%.2f MPa, 最大%.2f MPa\n', pressure_mean, pressure_max);
fprintf('流量: 平均%.2f L/min, 最小%.2f L/min\n', flow_mean, flow_min);
fprintf('温度: 平均%.2f℃, 最大%.2f℃\n', temp_mean, temp_max);
fprintf('振动: 平均%.3f m/s², 最大%.3f m/s²\n\n', vibration_mean, vibration_max);

if diagnosis_result.fault_count > 0
    fprintf('--- 检测到的故障 ---\n');
    for i = 1:diagnosis_result.fault_count
        fprintf('%d. %s\n', i, diagnosis_result.faults{i});
    end
    fprintf('\n--- 建议措施 ---\n');
    fprintf('1. 立即停止泵的运行进行检查\n');
    fprintf('2. 检查各传感器的准确性\n');
    fprintf('3. 根据故障类型进行相应维修\n');
    fprintf('4. 维修后需重新运行诊断程序验证\n');
else
    fprintf('--- 诊断结论 ---\n');
    fprintf('所有参数均在正常范围内，系统运行良好\n');
    fprintf('建议: 继续监测，按计划进行定期维护\n');
end

fprintf('\n========== 诊断完成 ==========\n');
