% Load predefined functions
run('gpml-matlab-master/startup.m');

% Load x and y
load('cw1a.mat');

% Specify the mean, covariance and likelihood functions
meanfunc = [];            % No mean function used
covfunc = @covSEiso;      % Squared Exponental covariance function
likfunc = @likGauss;      % Gaussian likelihood

% Multiple random restarts
rng(1); # set seed to 1
N = 100;
results = zeros(N, 7);   % [init log ell, log sf, log sn, opt log ell, log sf, log sn, nlml]
for i = 1:N
  hyp  = struct('mean', [], 'cov', [rand*3-3, rand*3-3], 'lik', rand*3-3);
  hyp2 = minimize(hyp, @gp, -200, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
  nlml = gp(hyp2, @infGaussLik, meanfunc, covfunc, likfunc, x, y);
  results(i, :) = [hyp.cov, hyp.lik, hyp2.cov, hyp2.lik, nlml];
end

% Find different optimals
[~, idx, grp] = unique(round(results(:, 4:6) * 10) / 10, 'rows');
optima = results(idx, 4:7);
counts = accumarray(grp, 1);
[optima, order] = sortrows(optima, 4); % from best to worst
counts = counts(order);

% Print a table to visualize
fprintf('\n%-6s %8s %8s %8s %10s %8s\n', 'optim', 'ell', 'sf', 'sn', 'nlml', 'count');
for k = 1:size(optima, 1)
  fprintf('%-6d %8.3f %8.3f %8.3f %10.3f %5d/%d\n', k, exp(optima(k, 1:3)), optima(k, 4), counts(k), N);
end
if size(optima, 1) > 1
  d = optima(2, 4) - optima(1, 4);
  fprintf('\nDelta nlml = %.2f  ->  likelihood ratio = exp(%.2f) = 10^%.1f\n', d, d, d / log(10));
end

% Plot contour
lell = linspace(-3, 3, 30);
lsn  = linspace(-3, 0.5, 30);
lsf  = linspace(-1.5, 1, 8);
Z = zeros(numel(lsn), numel(lell));
for i = 1:numel(lsn)
  for j = 1:numel(lell)
    best = Inf;
    for k = 1:numel(lsf)
      h = struct('mean', [], 'cov', [lell(j), lsf(k)], 'lik', lsn(i));
      best = min(best, gp(h, @infGaussLik, meanfunc, covfunc, likfunc, x, y));
    end
    Z(i, j) = best;
  end
end
figure;
contour(lell, lsn, log(Z - min(Z(:)) + 1), 30);
hold on;
plot(optima(:, 1), optima(:, 3), 'r*', 'MarkerSize', 12);
xlabel('log length-scale  log(ℓ)');
ylabel('log noise std  log(\sigma_n)');
title('NLML contour (log scale), \sigma_f optimised');
colorbar;
print -dpng -r300 question_b_contour.png;

% Predictions for each optimal
xs = linspace(-4, 4, 10000)';
figure;
for k = 1:size(optima, 1)
  h = struct('mean', [], 'cov', optima(k, 1:2), 'lik', optima(k, 3));
  [mu, s2] = gp(h, @infGaussLik, meanfunc, covfunc, likfunc, x, y, xs);
  subplot(size(optima, 1), 1, k);
  f = [mu + 2*sqrt(s2); flip(mu - 2*sqrt(s2), 1)];
  fill([xs; flip(xs, 1)], f, [7 7 7]/8);
  hold on;
  plot(xs, mu);
  plot(x, y, '+');
  xlabel('x');
  ylabel('y');
  title(sprintf('Optimal %d: ℓ = %.3f, \\sigma_f = %.3f, \\sigma_n = %.3f, nlml = %.2f', ...
        k, exp(optima(k, 1:3)), optima(k, 4)));
  grid on;
end
print -dpng -r300 question_b_fits.png;