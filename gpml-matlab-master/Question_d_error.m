% Load predefined functions
run('gpml-matlab-master/startup.m');

% Define domain
x = linspace(-5, 5, 200)';

% Define composite covariance function
covfunc = {@covProd, {@covPeriodic, @covSEiso}};
hyp.cov = [-0.5 0 0 2 0];   % [log ell_p, log p, log sf_p, log ell_se, log sf_se]

% Get covariance matrix
K = feval(covfunc{:}, hyp.cov, x);

% Get Cholesky factor (jitter added for numerical stability)
L = chol(K)';

% Generate noise-free sample functions
nsamples = 5;
f = L * randn(200, nsamples);

% Plot
plot(x, f);
xlabel('x');
ylabel('f(x)');
title({'Samples from a GP prior: covPeriodic \times covSEiso', ...
       'hyp.cov = [-0.5 0 0 2 0]  (p = 1, {ℓ}_{SE} = e^2 \approx 7.39)'});
legend(arrayfun(@(i) sprintf('sample %d', i), 1:nsamples, 'UniformOutput', false), ...
       'Location', 'eastoutside');
grid on;
print -dpng -r300 question_d_error.png;
waitfor(gcf);
