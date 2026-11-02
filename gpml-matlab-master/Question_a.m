% Load predefined functions
run('gpml-matlab-master/startup.m');

% Load x and y
load('cw1a.mat');

% Specify the mean, covariance and likelihood functions
meanfunc = [];            % No mean function used
covfunc = @covSEiso;      % Squared Exponental covariance function
likfunc = @likGauss;      % Gaussian likelihood

% Initialize hyperparameters
hyp = struct('mean', [], 'cov', [-1 0], 'lik', 0);

% Minimize negative log marginal likelihood
hyp2 = minimize(hyp, @gp, -200, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
nlml = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
fprintf('length-scale  ell     = %.4f  (log = %.4f)\n', exp(hyp2.cov(1)), hyp2.cov(1));
fprintf('signal std    sigma_f = %.4f  (log = %.4f)\n', exp(hyp2.cov(2)), hyp2.cov(2));
fprintf('noise std     sigma_n = %.4f  (log = %.4f)\n', exp(hyp2.lik),    hyp2.lik);
fprintf('neg log marginal likelihood = %.4f\n', nlml);

% Make predictions
xs = linspace(-4, 4, 10000)'; 
[mu s2] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x, y, xs);

% Plot 95% confidence bounds
f = [mu+2*sqrt(s2); flip(mu-2*sqrt(s2),1)];
fill([xs; flip(xs,1)], f, [7 7 7]/8)
hold on;
plot(xs, mu);
plot(x, y, '+');

% Labels 
xlabel('x');
ylabel('y');
title('GP regression with covSEiso');
legend('95% predictive error bars', 'predictive mean', 'training data', 'Location', 'southwest');
grid on;
print -dpng -r300 question_a.png;
waitfor(gcf);

