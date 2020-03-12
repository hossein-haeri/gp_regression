close all
clc
clear all
set(groot, 'DefaultAxesTickLabelInterpreter', 'latex')
hold on
grid on
% data = readtable('~/MATLAB Projects/Ring-road-simulator-master/vehicles_data.csv','ReadVariableNames',true);
data = readtable('~/vehicles_data.csv','ReadVariableNames',true);
r = 200;                  % ring radius (m)


% scatter3(data.latitude, data.longitude, data.friction,'.')

% x represents query point (test point)
p = (0:0.01:2*pi)';
x_lat = r*cos(p)/800000 + 40.861785;
x_lon = r*sin(p)/800000 - 77.836118;

% 
% fig = figure('Position',[50, 50, 1050, 1050]);



model_gpr = fitrgp(data(:,{'latitude', 'longitude', 'time', 'friction'}),'friction', 'KernelFunction','ardexponential');

v = VideoWriter('video.avi');
v.FrameRate = 10;
open(v);


for t= 10:0.1:100
    cla
    hold on
    if t == 0
    xlabel('Latitude')
    ylabel('Longitude')
    zlabel('Friction')
    zlim([0,4])
    set(gcf,'Position',[0, 0, 1080, 760])
    end
    
    inds = find(data.time<t);
    ind = inds(end);
    real_time_data = data(1:ind,:);
    model_gpr = fitrgp(real_time_data(:,{'latitude', 'longitude', 'time', 'friction'}),'friction', 'KernelFunction','ardsquaredexponential');
    
    
    

    
    x_time = ones(numel(p),1) * t;
    xtest = table(x_lat, x_lon, x_time);
    xtest.Properties.VariableNames = {'latitude', 'longitude', 'time'};
    
    ypred = predict(model_gpr,xtest);
    
    friction_true = sin(3*p + 0.1*t) + 2;
    
    tau = (t - data.time);
    for i = 1:numel(data.time)
        if tau(i) > 0 && tau(i) < 20 % if is not a future data point
            s = scatter3(data.latitude(i), data.longitude(i), data.friction(i), 200, '.', 'MarkerEdgeColor',[0, 0.4470, 0.7410],'DisplayName','data');
            s.MarkerEdgeAlpha = ((20 - tau(i))/20)^2;
            s.MarkerFaceAlpha = ((20 - tau(i))/20)^2;
        end
    end
    
    plot3(x_lat, x_lon, ypred,'LineWidth', 2, 'Color', [0.850, 0.325, 0.098],'DisplayName','GPR')
    plot3(x_lat, x_lon, friction_true,'LineWidth', 2, 'Color', [0.4660, 0.6740, 0.1880], 'LineStyle','--','DisplayName','True')
    
    view(45,45)
    
    drawnow
    frame = getframe(gcf);
    writeVideo(v,frame);

end

close(v);




