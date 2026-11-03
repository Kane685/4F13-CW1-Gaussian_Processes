# 4F13 Coursework 1: Gaussian Processes

My scripts and figures for Coursework 1 of the Cambridge 4F13 (Probabilistic Machine Learning) module. The coursework covers Gaussian process regression with the GPML toolbox.

## What is (and isn't) in this repository

The original materials were written for teaching, so **I have not uploaded the full source code or the course files.** This repository only contains:

- the scripts I wrote for the coursework questions (`gpml-matlab-master/Question_*.m`)
- the figures those scripts produced (`Figures/`)

It does **not** contain:

- the **GPML toolbox** (v4.2) by Carl Edward Rasmussen and Hannes Nickisch, which is available from <http://gaussianprocess.org/gpml/code>
- the course data files `cw1a.mat` and `cw1e.mat`, or the coursework handout

## Structure

```
.
├── Figures/                    # Output figures (PNG, 300 dpi)
└── gpml-matlab-master/
    ├── Question_a.m            # (a) GP with covSEiso on cw1a
    ├── Question_b.m            # (b) Multiple restarts and local optima of the hyperparameters
    ├── Question_c.m            # (c) GP with covPeriodic on cw1a
    ├── Question_d.m            # (d) Samples from a covPeriodic x covSEiso prior
    ├── Question_d_error.m      # (d) Same as above without diagonal jitter (Cholesky fails)
    ├── Question_e_data.m       # (e) Visualisation of the 2-D cw1e data
    ├── Question_e_1.m          # (e) Model 1: covSEard
    └── Question_e_2.m          # (e) Model 2: covSum of two covSEard
```

## Running the scripts

1. Download GPML v4.2 and unzip it as `gpml-matlab-master/`.
2. Copy the `Question_*.m` files into that folder.
3. Put `cw1a.mat` and `cw1e.mat` in the parent directory, next to `gpml-matlab-master/`.
4. Run the scripts from the parent directory. Each script calls `gpml-matlab-master/startup.m` and loads the data using paths relative to the parent directory. For example:

   ```bash
   octave gpml-matlab-master/Question_a.m
   ```

The scripts were written and tested with GNU Octave 8.4. They should also run in MATLAB.

## Figures

| Question | Figure |
|---|---|
| (a) covSEiso fit with 95% predictive error bars | `Figures/question_a.png` |
| (b) NLML landscape over the hyperparameters | `Figures/question_b_contour.png` |
| (b) Fits at the different local optima | `Figures/question_b_fits.png` |
| (c) covPeriodic fit | `Figures/question_c.png` |
| (d) Samples from the product-kernel prior | `Figures/question_d.png` |
| (d) The same samples plotted separately | `Figures/question_d_samples.png` |
| (e) cw1e training data | `Figures/question_e_data.png` |
| (e) Model 1 (covSEard) predictive mean | `Figures/question_e_1_mean.png` |
| (e) Model 2 (covSEard + covSEard) predictive mean | `Figures/question_e_2_mean.png` |
