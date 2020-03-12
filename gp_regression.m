close all
clc
clear all
set(groot, 'DefaultAxesTickLabelInterpreter', 'latex')
hold on
% data = readtable('~/MATLAB Projects/Ring-road-simulator-master/vehicles_data.csv','ReadVariableNames',true);
data = readtable('~/vehicles_data.csv','ReadVariableNames',true);
r = 200;                  % ring radius (m)


scatter3(data.latitude, data.longitude, data.friction,'.')
xlabel('Latitude')
ylabel('Longitude')
zlabel('Friction')


x = (0:0.01:2*pi);
x_lat = r*cos(x)/800000 + 40.861785;
x_lon = r*sin(x)/800000 - 77.836118;


xtest = table(x_lat', x_lon');
xtest.Properties.VariableNames = {'latitude', 'longitude'};

model_gpr = fitrgp(data(:,{'latitude', 'longitude', 'friction'}),'friction', 'KernelFunction','ardsquaredexponential');

ypred = predict(model_gpr,xtest);

plot3(x_lat, x_lon, ypred,'LineWidth',2)
grid on
view(45,45)