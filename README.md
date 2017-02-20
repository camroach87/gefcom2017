# gefcom-2017-d
GEFCom2017-D modelling and forecasts. D stands for defined-data track.


## To do

* Create a doc comparing some models with and without a trend variable.
* Maybe train a new model based of months surrounding forecast period - probably makes more sense than above point.

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

