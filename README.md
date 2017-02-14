# gefcom-2017-d
GEFCom2017-D modelling and forecasts. D stands for defined-data track.


## To do

* Remove caching from the R package functions (e.g. load\_smd\_data). All caching should be done manually to avoid confusion.
* Double check residual bootstrapping is ok during missing hour when DST kicks in.
* Calc pinball loss scores on test set.
* Model training period
    + Maybe have 2 models. One for DST months and another for non-daylight savings times? When DST starts on March 8th, the time of the peak shifts back one period (from 19 to 20). So, basically, it looks like demand is behaving as before (peak still occurs at same non-DST time), but because we have shifted to DST it looks like the peak has been shifted back by an hour. This may be affecting the model fit.
    + Or maybe train a new model based of months surrounding forecast period - probably makes more sense than above point.

## Questions
* Do I need holiday variables when I have day of year variables?
    + Probably. If holidays don't always fall on same day of year.
* Am I using the correct CV approach? K-fold cross-validation.
    + Yes ok. Bonsoo paper
* Would combining a monthly forecast and normalised demand poe levels improve things? See monthly-consumption-forecasting doc.
    + Subtract monthly average and then add back on using forecast.       + Normalisation will need to happen as well.
    + Uncertainty - forecast hh model minus avg demand. Predict avg demand + uncertainty for avg demand x 1000.
* L1 and L2 regularization with many lagged variables. Uncomfortable that this appears to work so well.
    + I'm not crazy - this seems reasonable. Google lasso autogregression for examples of time-series autogregression.
* Regularization: Does scaling predictor variables matter that much?
    + Not an issue.
* Response var: should I do a log transformation for positivity. Is that always best?
    + Not always best - upper quantiles can stretch out too much. Huge tails in the distribution.
    +Yeo-Johnson family of distributions to keep things positive.

