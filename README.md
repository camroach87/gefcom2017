# gefcom-2017-d
GEFCom2017-D modelling and forecasts. D stands for defined-data track.

## To do

* log(Demand): Fit models to log of demand to enforce positive constraint. Should improve accuracy.
* Fit L1 and L2 regularization models to all zones. Also best performing manually specified model and baseline model. Compare CV performance and RMSE on test set performance across all zones.
* Compare an L2 model using weather in all zones to a simple boosting model that just uses average of all zones weather info.
* Bootstrapping. Preserve correlations between zones etc.
* Calc quantiles.
* Calc pinball loss scores on test set.
* Write function to output results to excel template.


## Questions

* Why not use lagged demand as explanatory variables? Can easily include in bootstrap (alongside historical weather) so why not do that? Will decrease residuals but give better fitting models. If not, why not? The goal is to get the model as accurate as possible right? And even though demand at, say, t-1, $d_{t-1}$ is going to be highly correlated with $d_t$, so too is $\text{temp}_t$ and $\text{temp}_{t-1}$, so why use temp but not lagged demand??