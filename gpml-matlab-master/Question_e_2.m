% Load predefined functions
run('gpml-matlab-master/startup.m');

% Load x and y
load('cw1e.mat');

% Specify the mean, covariance and likelihood functions
meanfunc = [];            % No mean function used
covfunc = {@covSum, {@covSEard, @covSEard}};      % Sum of two SE-ARD covariance functions
likfunc = @likGauss;      % Gaussian likelihood

% Initialize hyperparameters
hyp = struct('mean', [], 'cov', 0.1*randn(6,1), 'lik', 0);   % [log ell_1_a, log ell_2_a, log sf_a, log ell_1_b, log ell_2_b, log sf_b]

% Minimize negative log marginal likelihood
hyp2 = minimize(hyp, @gp, -200, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
nlml = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
fprintf('length-scale-1-a  ell-1-a     = %.4f  (log = %.4f)\n', exp(hyp2.cov(1)), hyp2.cov(1));
fprintf('length-scale-2-a  ell-2-a     = %.4f  (log = %.4f)\n', exp(hyp2.cov(2)), hyp2.cov(2));
fprintf('signal std-a    sigma_f-a = %.4f  (log = %.4f)\n', exp(hyp2.cov(3)), hyp2.cov(3));
fprintf('length-scale-1-b  ell-1-b     = %.4f  (log = %.4f)\n', exp(hyp2.cov(4)), hyp2.cov(4));
fprintf('length-scale-2-b  ell-2-b     = %.4f  (log = %.4f)\n', exp(hyp2.cov(5)), hyp2.cov(5));
fprintf('signal std-b    sigma_f-b = %.4f  (log = %.4f)\n', exp(hyp2.cov(6)), hyp2.cov(6));
fprintf('noise std     sigma_n = %.4f  (log = %.4f)\n', exp(hyp2.lik),    hyp2.lik);
fprintf('neg log marginal likelihood = %.4f\n', nlml);

% Decompose nlml = data fit + complexity penalty + constant
n  = size(x, 1);
Ky = feval(covfunc{:}, hyp2.cov, x) + exp(2*hyp2.lik)*eye(n);
Lk = chol(Ky)';
alpha = Lk' \ (Lk \ y);
datafit    = 0.5 * y' * alpha;               % 0.5 * y' K^-1 y
complexity = sum(log(diag(Lk)));             % 0.5 * log|K|
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
title({sprintf('covSEard + covSEard predictive mean  (nlml = %.2f)', nlml), ...
       sprintf('ℓ_{1a} = %.2f, ℓ_{2a} = %.2f,   ℓ_{1b} = %.2f, ℓ_{2b} = %.2f', ...
               exp(hyp2.cov(1)), exp(hyp2.cov(2)), exp(hyp2.cov(4)), exp(hyp2.cov(5)))});
legend('predictive mean', 'training data', 'Location', 'northeast');
view(-30, 30);
grid on;
rotate3d on;
print -dpng -r300 question_e_2_mean.png;
waitfor(gcf);
