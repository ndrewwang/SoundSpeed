#SYMBOLIC REGRESSION FUNCTION
import numpy as np
import pandas as pd
import workflows as wf
import os, sys
        
def run_SR(training_data,FEATENG_STEPS,expressions):
    PREDICTORS = ['T','r','m']
    TARGET = 'd'
    SCALING_TYPE = 'standard_nomean' 
    FIT_INTERCEPT = True
    UNITS = {}
    FEATSEL_RUNS = 5
    TRANSFORMATIONS = expressions
    STD_ALPHA = 1 
    REJECTION_THR = 2

    # ---------------- INSTANTIATE WORKFLOW --------------------------------------

    workflow = wf.WorkflowAF(feateng_steps = FEATENG_STEPS,
                            units =  UNITS,
                            featsel_runs = FEATSEL_RUNS,
                            transformations = TRANSFORMATIONS,
                            xtrain = training_data[PREDICTORS], 
                            ytrain = training_data[TARGET], 
                            scaling_type = SCALING_TYPE,
                            stdalpha =  STD_ALPHA, 
                            rejection_thresshold = REJECTION_THR, 
                            fit_intercept = FIT_INTERCEPT) 

    # ---------------- RUN TRAINING WORKFLOW --------------------------------------
    trained_workflow = workflow.run_workflow()
    # ------------------------- INSPECT SYMBOLIC MODEL RESULTS --------------------------
    coeffs = trained_workflow.coeff_table
    eqn = trained_workflow.eqn
    eqn_str = str(eqn)
    # ------------------------- EVALUATE SYMBOLIC MODEL --------------------------
    import sklearn.metrics as skmetrics 

    y_real = training_data[TARGET]
    y_hat = trained_workflow.predict(x = training_data[PREDICTORS])
    
    mse = skmetrics.mean_squared_error(y_real, y_hat)
    r2 = skmetrics.r2_score(y_real, y_hat)
    mape = skmetrics.mean_absolute_percentage_error(y_real, y_hat)
    rmse = np.sqrt(mse)
    return eqn, eqn_str, coeffs, rmse, r2, mape, y_real, y_hat, trained_workflow