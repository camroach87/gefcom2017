# gefcom-2017-d
GEFCom2017-D modelling and forecasts. D stands for defined-data track.

## To do

* PRIORITY: For total should be using column D of the "ISO NE CA" worksheet.
* PRIORITY: Forgot to include Holiday_flag as a covariate!!! FIX!!!
* Increase the number of years of data in
    + Model training set.
    + Weather bootstrap set. Only last 6 years of weather used! Need more variety!
* Monthly consumption forecasting. See doc. Seems to be clear trends for some months. Can use a univariate technique to forecast average hourly demand for each month. Then scale quantiles of normalised demand (demand = demand/avg hourly demand in month)
* When doing forecasts in March, what happens on DST day? Does forecast data frame return 23 or 24 values? What is the impact on the residual bootstrapping function which always expects 24 periods? TEST!
* What happens when bootstrapping for those days missing an hour? Does that mean no value is produced for that hour?
    +Maybe should filter out those days from the bootstrapping process? Actually no - it just means there will be a few less values when calculating the quantiles for that hour and day (or days that use DST days in their bootstrapped samples). ACTUALLY what if data is getting out of sync with time? If
    + Above point: Can't say the same for residuals though. Need to make sure all 24 periods are present for all blocks.
* Maybe use the same input data for all models (zones and aggregated areas). Just use `spread` to spread all weather variables by zone. Then feed all of these hundreds of variables into each model for each zone and aggregated zone. See how well it works...
* log(Demand): Fit models to log of demand to enforce positive constraint. Should improve accuracy.
* Compare an L2 model using weather in all zones to a simple boosting model that just uses average of all zones weather info.
* Calc pinball loss scores on test set.
* Model training period
    + Maybe have 2 models. One for DST months and another for non-daylight savings times? When DST starts on March 8th, the time of the peak shifts back one period (from 19 to 20). So, basically, it looks like demand is behaving as before (peak still occurs at same non-DST time), but because we have shifted to DST it looks like the peak has been shifted back by an hour. This may be affecting the model fit.
    + Or maybe train a new model based of months surrounding forecast period - probably makes more sense than above point.

## Questions

* Am I using the correct CV approach? K-fold cross-validation.
Yes ok. Bonsoo paper
* Would combining a monthly forecast and normalised demand poe levels improve things? See monthly-consumption-forecasting doc.
Subtract monthly average and then add back on using forecast. Normalisation will need to happen as well.
Uncertainty - forecast hh model minus avg demand. Predict avg demand + uncertainty for avg demand x 1000.
* L1 and L2 regularization with many lagged variables. Uncomfortable that this appears to work so well.

* Is there a better way to code my residual bootstrap resampling?
I'm not crazy - this seems reasonable
* Regularization: Does scaling predictor variables matter that much?
No prob
* Response var: should I do a log transformation for positivity. Is that always best?
