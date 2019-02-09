# Learning Analytics Module
# WS 2018/2019
# At University Duisburg-Essen
# Course Project Goal: 
# predicting user grades based on user data from: MCI Dataset
# support the user with understanding of his own learning behavior

#install.packages("plotly")
#install.packages("Rcpp")
#install.packages("randomForest")
#install.packages("caret")
library(e1071)
library(caret)
library(lattice)
library(randomForest)
library(shiny)
library(plotly)
library(shinyjs)
source('ui.R', local = TRUE)
source('server.R')
shinyApp(server = server, ui = ui)