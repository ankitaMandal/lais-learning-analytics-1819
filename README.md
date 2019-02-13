# Learning Analytics Insights 
<p align="center">
  <img src="www/lais-logo.png" width="300">
</p>

# lais-learning-analytics-1819
Learning Analytics Insights is a Project developed as a part of Learning Analytics lecture(WS 18/19), taught by Prof. Dr. Mohamed Chatti and Dr. Arham Muslim at the University of Duisburg Essen. The R based application can be used for predicting student grades (based on inputs taken from a Survey and an open source data set) and for visualizing the results.

<p align="center">
  <img src="www/architecture.png" width="500" title="hover text">
</p>


# Dataset
  https://archive.ics.uci.edu/ml/datasets/student+performance
  
  This data approach student achievement in secondary education of two Portuguese schools. The data attributes include student grades, demographic, social and school related features) and it was collected by using school reports and questionnaires. Two datasets are provided regarding the performance in two distinct subjects: Mathematics (mat) and Portuguese language (por). In [Cortez and Silva, 2008], the two datasets were modeled under binary/five-level classification and regression tasks. Important note: the target attribute G3 has a strong correlation with attributes G2 and G1. This occurs because G3 is the final year grade (issued at the 3rd period), while G1 and G2 correspond to the 1st and 2nd period grades. It is more difficult to predict G3 without G2 and G1, but such prediction is much more useful (see paper source for more details).

We removed G2 and G3 and other unimportant variables from this dataset after analyzing the variable importance. (We used Mean Decreasing Accuracy and Mean Decreasing Gini and finalized only 16 out of the 31 variables for our application).

We added another column G4, to classify G3 into three classes: <br>
 G3=0-10  implies G4=1 <br>
 G3=11-15 implies G4=2 <br>
 G3=16-20 implies G4=3 <br>
# Description of used libraries(R-packages)/algorithms
shiny: Web Application Framework for R.
shinyjs: To Easily Improve the User Experience of Your Shiny Apps in Seconds
plotly: To Create Interactive Web Graphics via 'plotly.js'
caret: The caret package (short for _C_lassification _A_nd _RE_gression _T_raining) is a set of functions that attempt to streamline the process for creating predictive models. Used for: 
                                                                data splitting
                                                                pre-processing
                                                                feature selection
                                                                model tuning using resampling and
                                                                variable importance estimation.
 
randomForest: Breiman and Cutler's Random Forests for Classification of grades into three classes 
Random forests or random decision forests are an ensemble learning method for classification, regression and other tasks that operates by constructing a multitude of decision trees at training time and outputting the class that is the mode of the classes (classification) or mean prediction (regression) of the individual trees. Random decision forests correct for decision trees' habit of overfitting to their training set.

References: https://en.wikipedia.org/wiki/Random_forest <br>
           https://cran.r-project.org/web/packages/
            

# Example visualizations

<p align="center">
  <img src="www/heatmap.png" width="600">
</p>
<p align="center">
  <img src="www/bubblechart.png" width="600">
</p>

 
# How to run the project

1. Create a folder where your project code should be saved, say 'lais-app'.


2. Clone the project using git clone
3. Install R (version 3.5.2 or newer) in your system: 
    https://cran.r-project.org/mirrors.html

   Also recommended: R Studio (if in case you want to play around with the code)
    https://www.rstudio.com/products/rstudio/download/

4. Install the above mentioned packages using install(packagename) 

5. Use "path/to/R.exe" -e "shiny::runApp('path/to/lais-app', launch.browser = TRUE)" to run application from terminal. Otherwise zou can also import the project in R Studio and launch it by clicking on Run-App.




# Link to Project Video
https://www.youtube.com/watch?v=YfhbxSe0qtM&feature=youtu.be


# Group Members
Volkan Yücepur <br>
Ankita Mandal <br>
Florian Richtscheid <br>
Hadis Fouladikia <br>
Negin Ahmadian <br>
Moloud Kordestani <br>

