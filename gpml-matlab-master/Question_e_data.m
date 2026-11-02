% Load predefined functions
run('gpml-matlab-master/startup.m');

% Load x and y and reshape
load('cw1e.mat');

% Visualize data
mesh(reshape(x(:,1),11,11), reshape(x(:,2),11,11), reshape(y,11,11));
X1 = reshape(x(:,1), 11, 11);
X2 = reshape(x(:,2), 11, 11);
Y  = reshape(y, 11, 11);

figure;
mesh(X1, X2, Y);
hold on;
plot3(x(:,1), x(:,2), y, 'r.', 'MarkerSize', 12);   
xlabel('x_1');
ylabel('x_2');
zlabel('y');
title('cw1e training data');
view(-30, 30);        
grid on;
rotate3d on;          
print -dpng -r300 question_e_data.png;
waitfor(gcf);

