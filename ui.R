#install.packages("plotly")
#install.packages("Rcpp")
library(shiny)
library(plotly)
library(shinyjs)
ui <- navbarPage(title = "LaiS",id="LaiS",
                 # Home Area with Introduction and Start Button, thats triggers
                 # the survey page for starting with the data gathering
                 tabPanel(title = "Home",
                          column(6, offset = 3, 
                                 wellPanel(h1("LaiS - Learning Analytics Insights"), hr(),
                                           h2("This platform helps you to enhance your self-regulated learning"),
                                           h5("(1) Please run at first the survey. We need your data to give you support"),
                                           h5("(2) In Prediction you will see the results"),
                                           h5("(3) In Analytics you can explore some beautiful charts!"),
                                           h5("(4) My Notes shows all your taken notes from previous analysis"),
                                           hr(),div(align="center",actionButton(inputId = "start", "Let's Start!"))
                                           )
                                 )
                 ),
                
                 # Survey Area
                 # Running the Survey within Sub-pages, finally with a Predict Button
                 tabPanel(title = "Survey",value="Survey",
                          # the inputId's are the same as the from the excel file of the dataset
                          fluidRow(
                            column(5, offset=2,
                                   wellPanel(h3("Personal/Demographic Information", align="center"),
                                             div(align="center",
                                                 selectInput(inputId = 'address', width = '600px',
                                                             label = 'Do you live in an urban area or a rural one?', choices = c('Urban'='U', 'Rural'='R')),
                                                 selectInput(inputId = 'Pstatus', width = '600px', 
                                                             label = 'Are your parents living together or apart?', choices = c('Apart'='A', 'Together'='T')),
                                                 selectInput(inputId = 'Mjob', width = '600px', 
                                                             label = 'Profession of Mother?', choices = c('Teacher'='teacher', 
                                                                                                          'Health Care Related'='health',
                                                                                                          'Civil Services'='services',
                                                                                                          'Stay at home mom'='at_home','Other'='other')),
                                                 selectInput(inputId = 'Fjob', width = '600px', 
                                                             label = 'Profession of Father?', 
                                                             choices = c('Teacher'='teacher', 'Health Care Related'='health','Civil Services'='services',
                                                                         'Stay at home mom'='at_home','Other'='other')), 
                                                 sliderInput(inputId = 'age', width = '600px', 
                                                             label = 'What is your age?', 
                                                             min = 15, max = 22, value = 20),
                                                 
                                                 sliderInput(inputId = 'famrel', width = '600px', 
                                                             label = 'How is the quality of your family relationships? (from 1 - very bad to 5 - excellent)', 
                                                             min = 1, max = 5, value = 3),
                                                 
                                                 sliderInput(inputId = 'health', width = '600px', 
                                                             label = 'How is your current health status? (from 1 - very bad to 5 - very good)', 
                                                             min = 1, max = 5, value = 3)
                                            )
                                   ),
                                   wellPanel(h3("Academic Information", align="center"),
                                             div(align="center",
                                                 selectInput(inputId = 'subject', width = '600px', 
                                                             label = 'Which class do you want to predict?', choices = c('Portugese', 'Mathematics')),
                                                 
                                                 selectInput(inputId = 'reason', width = '600px', 
                                                             label = 'Why do you choose this school?', 
                                                             choices = c('close to home'='home', 'school reputation'='reputation', 'course preference'='course', 'other'='other')),
                                                 
                                                 selectInput(inputId = 'schoolsup', width = '600px', 
                                                             label = 'Do you get extra educational support from school?', choices = c('yes', 'no')),
                                                 
                                                 selectInput(inputId = 'activities', width = '600px', 
                                                             label = 'Do you have extra-curricular activities?', choices = c('yes', 'no')),
                                                 
                                                 selectInput(inputId = 'traveltime', width = '600px', 
                                                             label = 'How much time do you spend travelling everyday?', 
                                                             choices = c(' <15 min'= 1, '15 to 30 min'=2,' 30 min. to 1 hour'=3,'>1 hour'=4)),
                                                 
                                                 sliderInput(inputId = 'absences', width = '600px', 
                                                             label = 'How many school absences do you have? (in days)', 
                                                             min = 0, max = 93, value = 0),
                                                 
                                                 sliderInput(inputId = 'failures', width = '600px', 
                                                             label = 'How many past class failures do you have?', min = 0, max = 3, value = 0),
                                                 
                                                 sliderInput(inputId = 'G1', width = '600px', 
                                                             label = 'What is your first period grade?', 
                                                             min = 0, max = 20, value = 0) 
                                              )
                                   ),
                                   wellPanel(h3("Leisure Information",  align="center"),
                                             div(align="center",
                                                 sliderInput(inputId = 'freetime', width = '600px', 
                                                             label = 'How much freetime after school do you have? (from 1 - very low to 5 - very high)', 
                                                             min = 1, max = 5, value = 3),
                                                 sliderInput(inputId = 'Walc', width = '600px', 
                                                             label = 'How much alcohol do you consume  at the weekend? (from 1 - very low to 5 - very high)', 
                                                             min = 1, max = 5, value = 3)
                                              )
                                   ),

                                   column(4, offset = 4,
                                          div(align="center",
                                              useShinyjs(),
                                              actionButton(inputId = 'startPrediction', label = 'Start Prediction'),
                                              tags$div(style='margin-bottom: 50px;')
                                          )
                                   )
                            ),
                            column(5,
                                   div(align="center",useShinyjs(),
                                       uiOutput("SuggestionPanel"),
                                          wellPanel(id="takeSurveyDialog1",h4("Please take the survey to view your Predictions."))
                                   )
                            )
                          )          
                 ),
                 
                 # Analytics Area where the user can explore different Charts
                 # Here the user will get a better picture and understanding
                 # the navlistPanel is used for the view of different analytic-parts
                 tabPanel(title = "Analytics",value="Analytics",
                          ##MESSAGE FOR NEW USER WHO HAVEN'T TAKEN A SURVEY###
                          uiOutput("AnalyticsPanel"),
                          column(5, offset = 3,useShinyjs(),
                                 wellPanel(id="takeSurveyDialog2",h4("Please take the survey to view Analytics.")
                                 ))
                 ),
                 
                 # Notes area where the user can see a summary of the notes
                 tabPanel(title = "My Notes", value = "Notes",
                          ##MESSAGE FOR NEW USER WHO HAVEN'T TAKEN A SURVEY###
                          uiOutput("NotesPanel"),
                          column(5, offset = 3,useShinyjs(),
                                 wellPanel(id="takeSurveyDialog3",h4("Please take the survey to view Your Notes.")
                                 ))
                 )
)