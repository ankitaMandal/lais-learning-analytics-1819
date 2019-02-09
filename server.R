############################## READ CSV FILES FROM OUTSIDE ##############################
# Preprocessed csv File. We added a 4th Grade column to classify grades to three classes
# https://archive.ics.uci.edu/ml/datasets/student+performance
data_por<-read.csv("data/student-por-4.csv", header = TRUE,sep=";") # Portuguese-Class Data
data_mat<-read.csv("data/student-mat-4.csv", header = TRUE,sep=";") # Mathematics-Class Data

server <- function(input, output, session) {
  ############################## RANDOM FOREST MODEL ##############################
  
  # Read csv file as per user input
  # This function is called in the server code below
  # it returns three things in list-form
  # 1) data from csv
  # 2) new data from the survey
  # 3) the predicted value from random forest
  getPrediction <- reactive({
    # If Mathematics else Portuguese
    if(input$subject=='Mathematics') data1 <-data_mat else data1<-data_por
    data1$G4 <- as.factor(data1$G4)
    
    ###SELECT ONLY IMPORTANT VARIABLES - ###
    data <- data.frame(age=data1$age,
                       address=data1$address,
                       Pstatus=data1$Pstatus,
                       Mjob=data1$Mjob,
                       Fjob=data1$Fjob,
                       reason=data1$reason,
                       traveltime=data1$traveltime,
                       failures=data1$failures,
                       schoolsup=data1$schoolsup,
                       activities=data1$activities,
                       famrel=data1$famrel,
                       freetime=data1$freetime,
                       Walc=data1$Walc,
                       health=data1$health,
                       absences=data1$absences,
                       G1=data1$G1,
                       G4=data1$G4) 
    
    ##GET NEW DATA FROM UI SURVEY
    UIage <- as.integer(input$age)
    UIaddress <- input$address
    UIPstatus <- input$Pstatus
    UIMjob <- input$Mjob
    UIFjob <- input$Fjob
    UIreason <- input$reason
    UItraveltime <- as.integer(input$traveltime)
    UIfailures <- as.integer(input$failures)
    UIschoolsup <- input$schoolsup
    UIactivities <- input$activities
    UIfamrel <- as.integer(input$famrel)
    UIfreetime <- as.integer(input$freetime)
    UIWalc <- as.integer(input$Walc)
    UIhealth <- as.integer(input$health)
    UIabsences <- as.integer(input$absences)
    UIG1 <- as.integer(input$G1)
    G4 <- NA
    
    ##BIND EVERYTHING IN A DATA FRAME
    newdata <- data.frame(age=UIage,	address=UIaddress,	Pstatus=UIPstatus,		
                          Mjob=UIMjob,	Fjob=UIFjob,	reason=UIreason,	
                          traveltime=UItraveltime,		failures=UIfailures,	schoolsup=UIschoolsup,
                          activities=	UIactivities,	famrel=UIfamrel,	
                          freetime=UIfreetime,		Walc=UIWalc, health=UIhealth,
                          absences=UIabsences,G1=UIG1)
    
    ##ADJUST LEVELS OF NEW DATA TO AVOID ERRORS
    levels(newdata$address) <- levels(data1$address)
    levels(newdata$Pstatus) <- levels(data1$Pstatus)
    levels(newdata$Mjob) <- levels(data1$Mjob)
    levels(newdata$Fjob) <- levels(data1$Fjob)
    levels(newdata$reason) <- levels(data1$reason)
    levels(newdata$schoolsup) <- levels(data1$schoolsup)
    levels(newdata$activities) <- levels(data1$activities)
    
    # not needed anymore, binding already above
    # newdata <- cbind(age, address, Pstatus, Mjob, Fjob, reason, traveltime, failures, schoolsup,
    #                  activities, famrel, freetime, Walc, health, absences, G1)
  
    # Data Partition
    set.seed(123)
    ind <- sample(2, nrow(data), replace = TRUE, prob = c(0.7, 0.3))
    train <- data[ind==1,]
    test <- data[ind==2,]
    
    # Random Forest
    library(randomForest)
    set.seed(222)
    rf <- randomForest(G4 ~ ., data=train, ntree = 20,
                       mtry = 8,importance = TRUE, proximity = TRUE)
    print(rf)
    attributes(rf)
    
    # Prediction & Confusion Matrix - train data
    library(caret)
    p1 <- predict(rf, train)
    confusionMatrix(p1, train$G4)
    
    # # Prediction & Confusion Matrix - test data
    # p2 <- predict(rf, test)
    # confusionMatrix(p2, test$G4)
    
    # Error rate of Random Forest
    # plot(rf)
    
    str(newdata)
    str(data)
    
    # Tune mtry
    # t <- tuneRF(train[,-22], train[,22], stepFactor = 0.5,
    #             plot = TRUE, ntreeTry = 300,
    #             trace = TRUE, improve = 0.05)
    
    ###CLASSIFY NEW DATA USING MODEL
    p1 <- predict(rf, newdata, type="response",predict.all=TRUE)
    pred_val <- tail(c(p1$individual),1)
    print(pred_val)
    
    ##RETURN DATA FROM CSV, NEW DATA FROM UI SURVEY AND PREDICTED VALUE
    my_list <- list(data, newdata, pred_val)
    print(my_list)
    return(my_list)
  })

  ############################## FINALE GRADE ##############################
  # OUTPUT
  output$finalgrade <- reactive(input$predictionSlider)

  ############################## OBSERVERS ##############################
  observeEvent(input$start,{
    updateNavbarPage(session,"LaiS",selected = "Survey")
  })
  
  observeEvent(input$saveOverviewNotes, {
    buffer <- input$text
    updateTextAreaInput(session, inputId = "text", label = NULL, value = paste(buffer, "Overview: ", input$overviewNotes, sep = "\n"))
    showModal(modalDialog(
      size= 's',
      "Notes Saved! Click on My Notes Section to Download them.",
      easyClose = TRUE
    ))
  })
  
  observeEvent(input$saveHeatmapNotes, {
    buffer <- input$text
    updateTextAreaInput(session, inputId = "text", label = NULL, value = paste(buffer, "Heatmap: ", input$heatmapNotes, sep = "\n"))
    showModal(modalDialog(
      size= 's',
      "Notes Saved! Click on My Notes Section to Download them.",
      easyClose = TRUE
    ))
  })
  
  observeEvent(input$saveBubbleNotes, {
    buffer <- input$text
    updateTextAreaInput(session, inputId = "text", label = NULL, value = paste(buffer, "Bubblechart: ", input$bubbleNotes, sep = "\n"))
    showModal(modalDialog(
      size= 's',
      "Notes Saved! Click on My Notes Section to Download them.",
      easyClose = TRUE
    ))
  })
  
  # Observe the start Prediction event
  observeEvent(input$startPrediction,{
    #choices vector
    choices = c('Absences' = 'absences','Activities' = 'activities','Address' = 'address','Age'='age','Alc consumption/week'= 'Walc',
                'Failures'='failures','Family relation'='famrel','Fathers job'='Fjob','Freetime'='freetime', 'Grade 1'='G1','Health'='health',
                'Mothers job'='Mjob','Parents cohabituation'='Pstatus', 'Reason'='reason','Extra School Support'='schoolsup', 'Traveltime'='traveltime')
    
    updateNavbarPage(session,"LaiS",selected = "Prediction")

    library(shinyjs)
    ##HIDE Take Survey Dialog boxes##
    shinyjs::hide(id = "takeSurveyDialog1")
    shinyjs::hide(id = "takeSurveyDialog2")
    shinyjs::hide(id = "takeSurveyDialog3")
    
    new <- switch(getPrediction()[[3]],
                  "1" = "You might fail.",
                  "2" = "Between 11 to 15.",
                  "3" = "Between 16 to 20.")
    
    displayData <- getPrediction()[[1]]
    print(displayData$age)
    
    # OUTPUT the Panel for Suggestions and Predictions
    output$SuggestionPanel <- renderUI({
      
      fluidRow(
        column(6, offset = 3,
               wellPanel(
                 h1("Your predicted grade is: "),
                 h2(new)
               )
        )
      )
    })
    
    # OUTPUT the whole Analytics Area to the Frontend
    output$AnalyticsPanel <- renderUI({
      
      # Call the Data here
      output$overviewchart <- renderPlotly({
        # i <- c(getPrediction()[[1]]$absences, getPrediction()[[1]]$age, getPrediction()[[1]]$failures, getPrediction()[[1]]$Mjob, 
        # getPrediction()[[1]]$Fjob, getPrediction()[[1]]$Walc)
        j <- c(getPrediction()[[1]]$G1)
        #x <- c('Product A', 'Product B', 'Product C')
        #y <- c(20, 14, 23)
        x <- c('Walc', 'Absences', 'Traveltime', 'Freetime')
        
        y <- c(
          round(abs(cor(getPrediction()[[1]]$Walc, j))*100, digits = 0),
          round(abs(cor(getPrediction()[[1]]$absences, j))*100, digits = 0),
          round(abs(cor(getPrediction()[[1]]$traveltime, j))*100, digits = 0),
          round(abs(cor(getPrediction()[[1]]$freetime, j))*100, digits = 0))

        text <- c('Weekly alcohol consumption', 'Absences', 'Traveltime', 'Freetime')
        data <- data.frame( attr = c("Walc", "Absences", "Traveltime", "Freetime"), y, text)
        
        p <- plot_ly(data, x = ~attr, y = ~y, type = 'bar',
                     text = y, textposition = 'auto',
                     marker = list(color = 'rgb(158,202,225)',
                                   line = list(color = 'rgb(8,48,107)', width = 1.5))) %>%
          layout(title = "Negative Correlations with Grade",
                 xaxis = list(title = "", categoryorder = "array", categoryarray = ~attr,  dtick = 1),
                 yaxis = list(title = "First Grade"))
      })
      
      # OUTPUT of the heatmap with labeled axes
      output$heatmapchart <- renderPlotly({
        ############################## HEATMAP ##############################
        # DATA
        set.seed(123)
        # switch to the right selected attribute from the input
        # and map it to the csv file attributes
        hmx <- switch(input$heatmapSelectionX,
                       "absences" = c(getPrediction()[[1]]$absences),
                       "age" = c(getPrediction()[[1]]$age),
                       "address" = c(getPrediction()[[1]]$address),
                       "Pstatus" = c(getPrediction()[[1]]$Pstatus),
                       "Mjob" = c(getPrediction()[[1]]$Mjob),
                       "Fjob" = c(getPrediction()[[1]]$Fjob),
                       "reason" = c(getPrediction()[[1]]$reason),
                       "traveltime" = c(getPrediction()[[1]]$traveltime),
                       "failures" = c(getPrediction()[[1]]$failures),
                       "schoolsup" = c(getPrediction()[[1]]$schoolsup),
                       "activities" = c(getPrediction()[[1]]$activities),
                       "famrel" = c(getPrediction()[[1]]$famrel),
                       "freetime" = c(getPrediction()[[1]]$freetime),
                       "Walc" = c(getPrediction()[[1]]$Walc),
                       "health" = c(getPrediction()[[1]]$health),
                       "G1" = c(getPrediction()[[1]]$G1))
        
        hmy <- switch(input$heatmapSelectionY,
                      "absences" = c(getPrediction()[[1]]$absences),
                      "age" = c(getPrediction()[[1]]$age),
                      "address" = c(getPrediction()[[1]]$address),
                      "Pstatus" = c(getPrediction()[[1]]$Pstatus),
                      "Mjob" = c(getPrediction()[[1]]$Mjob),
                      "Fjob" = c(getPrediction()[[1]]$Fjob),
                      "reason" = c(getPrediction()[[1]]$reason),
                      "traveltime" = c(getPrediction()[[1]]$traveltime),
                      "failures" = c(getPrediction()[[1]]$failures),
                      "schoolsup" = c(getPrediction()[[1]]$schoolsup),
                      "activities" = c(getPrediction()[[1]]$activities),
                      "famrel" = c(getPrediction()[[1]]$famrel),
                      "freetime" = c(getPrediction()[[1]]$freetime),
                      "Walc" = c(getPrediction()[[1]]$Walc),
                      "health" = c(getPrediction()[[1]]$health),
                      "G1" = c(getPrediction()[[1]]$G1))
        
        hmXtitle <- switch(input$heatmapSelectionX,
                           "address" = "(1 = Urban, 2 = Rural)",
                           "Pstatus" = "(1 = Together, 2 = Apart)",
                           "Mjob" = "(1 = Teacher, 2 = Healthcare, 3 = Civil services, 4 = @Home, 5 = other)",
                           "Fjob" = "(1 = Teacher, 2 = Healthcare, 3 = Civil services, 4 = @Home, 5 = other)",
                           "reason" = "(1 = close to home, 2 = school rep., 3 = course pref., 4 = other)",
                           "traveltime" = " (1 = <15 min, 2 = 15 to 30 min, 3 = 30 min to 1 hour, 4 = >1 hour)",
                           "schoolsup" = "(1 = yes, 2 = no)",
                           "activities" = "(1 = yes, 2 = no)",
                           "famrel" = "(from 1 - very bad to 5 - excellent)",
                           "freetime" = "(from 1 - very low to 5 - very high)",
                           "Walc" = "(from 1 - very low to 5 - very high)",
                           "health" = "(from 1 - very bad to 5 - very good)")
        
        hmYtitle <- switch(input$heatmapSelectionY,
                          "address" = "(1 = Urban, 2 = Rural)",
                          "Pstatus" = "(1 = Together, 2 = Apart)",
                          "Mjob" = "(1 = Teacher, 2 = Healthcare, 3 = Civil services, 4 = @Home, 5 = other)",
                          "Fjob" = "(1 = Teacher, 2 = Healthcare, 3 = Civil services, 4 = @Home, 5 = other)",
                          "reason" = "(1 = close to home, 2 = school rep., 3 = course pref., 4 = other)",
                          "traveltime" = " (1 = <15 min, 2 = 15 to 30 min, 3 = 30 min to 1 hour, 4 = >1 hour)",
                          "schoolsup" = "(1 = yes, 2 = no)",
                          "activities" = "(1 = yes, 2 = no)",
                          "famrel" = "(from 1 - very bad to 5 - excellent)",
                          "freetime" = "(from 1 - very low to 5 - very high)",
                          "Walc" = "(from 1 - very low to 5 - very high)",
                          "health" = "(from 1 - very bad to 5 - very good)")
        
        x <- c(getPrediction()[[1]]$hmx)
        y <- c(getPrediction()[[1]]$hmy)
        z <- c(getPrediction()[[1]]$G1)
        
        vals <- unique(scales::rescale(c(z)))
        o <- order(vals, decreasing = FALSE)
        cols <- scales::col_numeric(input$heatmapColoring, domain = NULL)(vals)
        colz <- setNames(data.frame(vals[o], cols[o]), NULL)
        
        titlex = paste(input$heatmapSelectionX, hmXtitle, sep=" ")
        titley = paste(input$heatmapSelectionY, hmYtitle, sep=" ")
        
        # change the title automatically
        hmapX <- list(title = titlex, dtick = 1, ticks = "inside")
        hmapY <- list(title = titley, dtick = 1, ticks = "inside")
        plot_ly(z = z, x = hmx, y = hmy, colorscale = colz, type = "heatmap") %>% layout(title = "Heatmap", xaxis = hmapX, yaxis = hmapY)
      })
      
      ############################## BUBBLECHART ##############################
      # OUTPUT of the bubblechart with labeled axes
      output$bubblechart <- renderPlotly({
        set.seed(123)
        bcx <- switch(input$bubblechartSelectionX,
                      "absences" = c(getPrediction()[[1]]$absences),
                      "age" = c(getPrediction()[[1]]$age),
                      "address" = c(getPrediction()[[1]]$address),
                      "Pstatus" = c(getPrediction()[[1]]$Pstatus),
                      "Mjob" = c(getPrediction()[[1]]$Mjob),
                      "Fjob" = c(getPrediction()[[1]]$Fjob),
                      "reason" = c(getPrediction()[[1]]$reason),
                      "traveltime" = c(getPrediction()[[1]]$traveltime),
                      "failures" = c(getPrediction()[[1]]$failures),
                      "schoolsup" = c(getPrediction()[[1]]$schoolsup),
                      "activities" = c(getPrediction()[[1]]$activities),
                      "famrel" = c(getPrediction()[[1]]$famrel),
                      "freetime" = c(getPrediction()[[1]]$freetime),
                      "Walc" = c(getPrediction()[[1]]$Walc),
                      "health" = c(getPrediction()[[1]]$health),
                      "G1" = c(getPrediction()[[1]]$G1)
        )
        bcy <- switch(input$bubblechartSelectionY,
                      "absences" = c(getPrediction()[[1]]$absences),
                      "age" = c(getPrediction()[[1]]$age),
                      "address" = c(getPrediction()[[1]]$address),
                      "Pstatus" = c(getPrediction()[[1]]$Pstatus),
                      "Mjob" = c(getPrediction()[[1]]$Mjob),
                      "Fjob" = c(getPrediction()[[1]]$Fjob),
                      "reason" = c(getPrediction()[[1]]$reason),
                      "traveltime" = c(getPrediction()[[1]]$traveltime),
                      "failures" = c(getPrediction()[[1]]$failures),
                      "schoolsup" = c(getPrediction()[[1]]$schoolsup),
                      "activities" = c(getPrediction()[[1]]$activities),
                      "famrel" = c(getPrediction()[[1]]$famrel),
                      "freetime" = c(getPrediction()[[1]]$freetime),
                      "Walc" = c(getPrediction()[[1]]$Walc),
                      "health" = c(getPrediction()[[1]]$health),
                      "G1" = c(getPrediction()[[1]]$G1)
        )
        bcXtitle <- switch(input$bubblechartSelectionX,
                           "address" = "(1 = Urban, 2 = Rural)",
                           "Pstatus" = "(1 = Together, 2 = Apart)",
                           "Mjob" = "(1 = Teacher, 2 = Healthcare, 3 = Civil services, 4 = @Home, 5 = other)",
                           "Fjob" = "(1 = Teacher, 2 = Healthcare, 3 = Civil services, 4 = @Home, 5 = other)",
                           "reason" = "(1 = close to home, 2 = school rep., 3 = course pref., 4 = other)",
                           "traveltime" = " (1 = <15 min, 2 = 15 to 30 min, 3 = 30 min to 1 hour, 4 = >1 hour)",
                           "schoolsup" = "(1 = yes, 2 = no)",
                           "activities" = "(1 = yes, 2 = no)",
                           "famrel" = "(from 1 - very bad to 5 - excellent)",
                           "freetime" = "(from 1 - very low to 5 - very high)",
                           "Walc" = "(from 1 - very low to 5 - very high)",
                           "health" = "(from 1 - very bad to 5 - very good)"
        )
        bcYtitle <- switch(input$bubblechartSelectionY,
                           "address" = "(1 = Urban, 2 = Rural)",
                           "Pstatus" = "(1 = Together, 2 = Apart)",
                           "Mjob" = "(1 = Teacher, 2 = Healthcare, 3 = Civil services, 4 = @Home, 5 = other)",
                           "Fjob" = "(1 = Teacher, 2 = Healthcare, 3 = Civil services, 4 = @Home, 5 = other)",
                           "reason" = "(1 = close to home, 2 = school rep., 3 = course pref., 4 = other)",
                           "traveltime" = " (1 = <15 min, 2 = 15 to 30 min, 3 = 30 min to 1 hour, 4 = >1 hour)",
                           "schoolsup" = "(1 = yes, 2 = no)",
                           "activities" = "(1 = yes, 2 = no)",
                           "famrel" = "(from 1 - very bad to 5 - excellent)",
                           "freetime" = "(from 1 - very low to 5 - very high)",
                           "Walc" = "(from 1 - very low to 5 - very high)",
                           "health" = "(from 1 - very bad to 5 - very good)"
        )
        bx <- c(bcx)
        by <- c(bcy)
        bz <- c(getPrediction()[[1]]$G1)
        df <- data.frame(bx, by, bz)
        
        titlex = paste(input$bubblechartSelectionX, bcXtitle, sep=" ")
        titley = paste(input$bubblechartSelectionY, bcYtitle, sep=" ")
        
        bmapX <- list(title = titlex, dtick = 1, ticks = "inside")
        bmapY <- list(title = titley, dtick = 1, ticks = "inside")
        
        plot_ly(df, x = bx, y = by, text = bz, type = 'scatter', mode = 'markers', color = bz, colors = 'Reds', 
                marker = list(size = bz*3, opacity = 0.5))%>% layout(title = 'Bubblechart', xaxis = bmapX, yaxis = bmapY)
      })
      
      navlistPanel(well = TRUE, widths = c(2,10),
                   tabPanel("Overview",
                            sidebarPanel(
                              h2("Overview"), hr(),
                              textAreaInput(inputId = 'overviewNotes', "Notepad", "My insights are...", width = '100%', height = '200px'),
                              actionButton(inputId = 'saveOverviewNotes', label = 'Save note')
                            ),
                            mainPanel(
                              wellPanel(
                                h3("Description"), hr(), 
                                h5("Here you can see the Overview of the dataset. Here you can see negatively correlated factors, 
                                   that you can maybe control with behaviour. It can affect your grade.")),
                              plotlyOutput('overviewchart', height = "900px")
                            )            
                   ),
                   tabPanel("Heatmap",
                            sidebarPanel(
                              h2("Heatmap Settings"), hr(),
                              selectInput(inputId = 'heatmapSelectionX', width = '200px',
                                          label = 'Choose the x-axes', choices = choices, selected = 'age'),
                              selectInput(inputId = 'heatmapSelectionY', width = '200px', 
                                          label = 'Choose the y-axes', choices = choices, selected = 'absences'),
                              selectInput(inputId = 'heatmapColoring', width = '200px', 
                                          label = 'Choose the Color', choices = c('Blues', 'Reds', 'Oranges')),
                              textAreaInput(inputId = 'heatmapNotes', "Notepad", "My insights are...", width = '100%', height = '200px'),
                              actionButton(inputId = 'saveHeatmapNotes', label = 'Save note')
                            ),
                            mainPanel(
                              wellPanel(
                                h3("Description"), hr(), 
                                h5("Here you can see the Heatmap. Set the X and Y Axes as you like.
                                   Change the parameters by your self and get some individual insights 
                                   about your learning behavior. The color intensity shows you the impact to the grade. More dark means better grade.")),
                                plotlyOutput("heatmapchart", width = "100%", height = "100%")
                                )
                              ),
                   tabPanel("Bubble-Chart",
                            sidebarPanel(
                              h2("Bubblechart Settings"), hr(),
                              selectInput(inputId = 'bubblechartSelectionX', width = '200px', 
                                          label = 'Choose the x-axes', choices = choices, selected = 'age'),
                              selectInput(inputId = 'bubblechartSelectionY', width = '200px', 
                                          label = 'Choose the y-axes', choices = choices, selected = 'absences'),
                              selectInput(inputId = 'bubblechartColoring', width = '200px',
                                          label = 'Choose the Color', choices = c('Blues', 'Reds', 'Oranges'), selected = 'Reds'),
                              textAreaInput(inputId = 'bubbleNotes', "Notepad", "My insights are...", width = '100%', height = '200px'),
                              actionButton(inputId = 'saveBubbleNotes', label = 'Save note')
                            ),
                            mainPanel(
                              wellPanel(
                                h3("Description"), hr(), 
                                h5("Here you can see the Bubble Chart. Set the X and Y Axes as you like.
                                   Change the parameters by your self and get some individual insights 
                                   about your learning behavior. The color intensity shows you the impact to the grade. More dark means better grade.")),
                              plotlyOutput("bubblechart", width = "100%", height = "100%")
                                )         
                              )
                   )
      
    })#renderUI AnalyticsPanel Ends
    
    # OUTPUT of the notes summary
    output$NotesPanel <- renderUI({
      fluidRow(column(8, offset = 2, wellPanel(
                 textAreaInput(inputId = 'text', label = "Summary", width = '600px', height = '500px'),
                 downloadButton('downloadWord', label = 'Download .docx'), downloadButton('downloadTxt', label='Download .txt'))))
    })

    # Download Handler
    output$downloadWord <- downloadHandler(
      filename = function() { "LaiS_My_Notes.docx" },
      content = function(file) { cat(input$text, file=file) }
    )
    
    # Download Handler
    output$downloadTxt <- downloadHandler(
      filename = function() { "LaiS_My_Notes.txt" },
      content = function(file) { cat(input$text, file=file) }
    )
  })#observeEvend Ends
}