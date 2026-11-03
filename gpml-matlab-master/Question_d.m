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
R = chol(K + 1e-6*eye(200));

% Generate noise-free sample functions
nsamples = 5;
f = R' * randn(200, nsamples);

% Both figures use the same size so the exported PNGs match
figpos = [100 100 800 800];

% Plot
figure('Position', figpos);
plot(x, f);
xlabel('x');
ylabel('f(x)');
title({'Samples from a GP prior: covPeriodic \times covSEiso', ...
       'hyp.cov = [-0.5 0 0 2 0]  (p = 1, {ℓ}_{SE} = e^2 \approx 7.39)'});
legend(arrayfun(@(i) sprintf('sample %d', i), 1:nsamples, 'UniformOutput', false), ...
       'Location', 'eastoutside');
grid on;
set(gcf, 'PaperPositionMode', 'auto');
print -dpng -r300 question_d.png;

% Plot each sample separately (same samples as above)
colors = get(gca, 'ColorOrder');
figure('Position', figpos);
for i = 1:nsamples
  subplot(nsamples, 1, i);
  plot(x, f(:, i), 'Color', colors(i, :));
  ylabel(sprintf('f_%d(x)', i));
  xlim([-5 5]);
  ylim([-2.5 2.5]);
  set(gca, 'YTick', [-2 0 2]);
  grid on;
end
xlabel('x');
set(gcf, 'PaperPositionMode', 'auto');
print -dpng -r300 question_d_samples.png;
waitfor(gcf);
