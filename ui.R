library(shiny)

shinyUI(
    fluidPage(
        titlePanel("The next word predictor"),
        sidebarLayout(
            sidebarPanel(h4("Enter your sentence below"),
                         textInput(inputId = "in_sentence",label = "",value = ""),
                         sliderInput("num2predict",
                                     "Select the number of words to predict:", 
                                     min=1,
                                     max=10,
                                     value=4
                         )
            ),
            mainPanel(
                tabsetPanel(
                    tabPanel("Prediction",
                             h4("The highest probable next word is:"),
                             HTML("<span style='color:red'>"),
                             h3(textOutput("highestprediction"),align="center"),
                             HTML("</span>"),
                             br(),
                             h4(textOutput("listprob")),
                             hr(),
                             div(dataTableOutput("predictionTable"),
                                 style='font-size:100%'
                             )        
                    ),
                    tabPanel("How to",
                             includeMarkdown("description.Rmd")
                    )
                )
            )
        )
    )
)