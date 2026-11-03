% Load predefined functions
run('gpml-matlab-master/startup.m');

% Load x and y
load('cw1e.mat');

% Specify the mean, covariance and likelihood functions
meanfunc = [];            % No mean function used
covfunc = @covSEard;      % Squared Exponental covariance function
likfunc = @likGauss;      % Gaussian likelihood

% Initialize hyperparameters
hyp = struct('mean', [], 'cov', 0.1*randn(3,1), 'lik', 0);   % [log ell_1, log ell_2, log sf]

% Minimize negative log marginal likelihood
hyp2 = minimize(hyp, @gp, -200, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
nlml = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
fprintf('length-scale-1  ell-1     = %.4f  (log = %.4f)\n', exp(hyp2.cov(1)), hyp2.cov(1));
fprintf('length-scale-2  ell-2     = %.4f  (log = %.4f)\n', exp(hyp2.cov(2)), hyp2.cov(2));
fprintf('signal std    sigma_f = %.4f  (log = %.4f)\n', exp(hyp2.cov(3)), hyp2.cov(3));
fprintf('noise std     sigma_n = %.4f  (log = %.4f)\n', exp(hyp2.lik),    hyp2.lik);
fprintf('neg log marginal likelihood = %.4f\n', nlml);

% Decompose nlml = data fit + complexity penalty + constant
n  = size(x, 1);
Ky = feval(covfunc, hyp2.cov, x) + exp(2*hyp2.lik)*eye(n);
R = chol(Ky);
alpha = R \ (R' \ y);
datafit    = 0.5 * y' * alpha;               % 0.5 * y' K^-1 y
complexity = sum(log(diag(R)));             % 0.5 * log|K|
constant   = 0.5 * n * log(2*pi);
fprintf('data fit term   = %.4f\n', datafit);
fprintf('complexity term = %.4f\n', complexity);
fprintf('constant term   = %.4f\n', constant);
fprintf('sum             = %.4f (should equal nlml)\n', datafit + complexity + constant);

% Training residuals
[mu_tr, ~] = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x, y, x);
fprintf('training RMSE   = %.4f\n', sqrt(mean((y - mu_tr).^2)));

% Make predictions on a 2-D grid
[X1s, X2s] = meshgrid(linspace(-4, 4, 100), linspace(-4, 4, 100));
xs = [X1s(:), X2s(:)];
mu = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x, y, xs);
MU = reshape(mu, size(X1s));

% Plot predictive mean with training data
figure;
mesh(X1s, X2s, MU);
hold on;
plot3(x(:,1), x(:,2), y, 'r.', 'MarkerSize', 15);
xlabel('x_1');
ylabel('x_2');
zlabel('y');
title(sprintf('covSEard predictive mean  ({ℓ}_1 = %.2f, {ℓ}_2 = %.2f, nlml = %.2f)', ...
      exp(hyp2.cov(1)), exp(hyp2.cov(2)), nlml));
legend('predictive mean', 'training data', 'Location', 'northeast');
view(-30, 30);
grid on;
rotate3d on;
print -dpng -r300 question_e_1_mean.png;
waitfor(gcf);
