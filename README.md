# gefcom-2017-d
GEFCom2017-D modelling and forecasts. D stands for defined-data track.

## To do

* New Year Day holiday only assigned to first hour of new year's day. Not sure why. FIX.
* When doing forecasts in March, what happens on DST day? Does forecast data frame return 23 or 24 values? What is the impact on the residual bootstrapping function which always expects 24 periods? TEST!
* Check dates and hour are correct. does dmy_h give the original time-series? Should I switch to HB instead of HE?
* What happens when bootstrapping for those days missing an hour? Does that mean no value is produced for that hour? Maybe should filter out those days from the bootstrapping process? Actually no - it just means there will be a few less values when calculating the quantiles for that hour and day (or days that use DST days in their bootstrapped samples). ACTUALLY what if data is getting out of sync with time? If
* Above point: Can't say the same for residuals though. Need to make sure all 24 periods are present for all blocks.
* Maybe use the same input data for all models (zones and aggregated areas). Just use `spread` to spread all weather variables by zone. Then feed all of these hundreds of variables into each model for each zone and aggregated zone. See how well it works...
* log(Demand): Fit models to log of demand to enforce positive constraint. Should improve accuracy.
* Fit L1 and L2 regularization models to all zones. Also best performing manually specified model and baseline model. Compare CV performance and RMSE on test set performance across all zones.
* Compare an L2 model using weather in all zones to a simple boosting model that just uses average of all zones weather info.
* Bootstrapping. Preserve correlations between zones etc.
* Calc quantiles.
* Calc pinball loss scores on test set.
* Write function to output results to excel template.



## Questions

* Why not use lagged demand as explanatory variables? Can easily include in bootstrap (alongside historical weather) so why not do that? Will decrease residuals but give better fitting models. If not, why not? The goal is to get the model as accurate as possible right? And even though demand at, say, t-1, $d_{t-1}$ is going to be highly correlated with $d_t$, so too is $\text{temp}_t$ and $\text{temp}_{t-1}$, so why use temp but not lagged demand??
