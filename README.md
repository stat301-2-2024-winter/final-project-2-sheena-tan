## Introduction

Spotify, an online music streaming platform with over 190 million active users and over 40 million tracks, faces a key challenge: how do you recommend the right music to right user? Out of a robust body of literature on recommendation systems, little work describes how users sequentially interact with recommended content. This gap is particularly evident in the music domain, where understanding when and why users skip tracks serves as crucial implicit feedback. The [Music Streaming Sessions Dataset](https://www.aicrowd.com/challenges/spotify-sequential-skip-prediction-challenge) was released by Spotify in 2018 to encourage research on this overlooked aspect of streaming. 

This project hopes to provide an elementary solution (within the bounds of knowledge learned in class) to Spotify's challenge: **Predict whether individual tracks encountered in a listening session will be skipped by a particular user.** 

This project uses the target variable `skipped`, a modified version of the original challenge's `skip_2` field, where `skip_2` is a boolean variable (`TRUE`/`FALSE`) and `skipped` is a character variable (`yes`/`no`).

## Repository Setup

All data, subsets, splits, and folds can be found in the `data/` subdirectory. For more information on the `data/` subdirectory, refer to its README.me file.

All R scripts can be found in the `scripts/` subdirectory. These include:
-  `0_intial_setup.R`: data quality check and splitting data
-  `1_eda.R`: exploratory data analysis inspecting target variable and other questions of interest
-  `2_recipes.R`: setup pre-processing/recipes/feature engineering
-  `3_fit_baseline.R`: define and fit naive Bayes baseline model
-  `3_fit_lm.R`: define and fit logistic model
-  `3_tune_bt.R`: define and fit boosted tree model
-  `3_tune_knn.R`: define and fit k-nearest neighbors model
-  `3_tune_rf.R`: define and fit random forest model
-  `3_tune_svm.R`: define and fit support vector machine model
-  `4_model_analysis.R`: model selection/comparison & analysis
-  `5_train_final_model.R`: final model training
-  `6_assess_final_model.R`: final model testing and analysis

The `recipes/` subdirectory contains all processed recipes used in this project.

The `results/` subdirectory contains all fitted models used in this project and any saved raw R output from model analysis (e.g., metrics tables). 

The `images/` subdirectory contains all images used in this project.

The `memos/` subdirectory contains two progress reports explaining project progress after initial data exploration and again after initial/baseline model creation. 

Other files include:

-  `Sheena_Tan_final_project.html` and `Sheena_Tan_final_project.qmd`: the (rendered) final project report
-  `Sheena_Tan_executive_summary.html` and `Sheena_Tan_executive_summary.qmd`: the (rendered) final project executive summary
