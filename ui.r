#################################################
#               Sentiment Analysis Of 20 Hotels #
#################################################

library(shiny)
library(text2vec)
library(tm)
library(tokenizers)
library(wordcloud)
library(slam)
library(stringi)
library(magrittr)
library(tidytext)
library(dplyr)
library(visNetwork)
library(tidyr)
library(DT)
library(stringr)
library(tools)

shinyUI(fluidPage(
  title = "Sentiment Analysis Of 20 Hotels",
  titlePanel(title=div(img(src="UniLogo.PNG",align='right'),"Sentiment Analysis Of 20 Hotels")),
  
  # Input in sidepanel:
  sidebarPanel(
    
    fileInput("file", "Upload text file"),
    uiOutput('id_var'),
    uiOutput("doc_var"),
    textInput("stopw", ("Enter your own stopwords and use comma(,) to separate them"), value = "is, above"),
    
    # selectInput("ws", "Weighing Scheme", 
    #             c("weightTf","weightTfIdf"), selected = "weightTf"), # weightTf, weightTfIdf, weightBin, and weightSMART.
    #
    htmlOutput("pre_proc1"),
    htmlOutput("pre_proc2"),
    sliderInput("freq", "Wordcloud Minimum Frequency:", min = 0,  max = 100, value = 2),
    
    sliderInput("max",  "Maximum Number of Words in Wordcloud:", min = 1,  max = 300,  value = 50),  
    
    numericInput("nodes", "Co-occurrence graph with number of central nodes", 4),
    numericInput("connection", "The maximum connection number with the central node", 5),
    
    
    textInput("concord.word",('If you want concordance for a word, please type that word here'),value = 'great'),
    checkboxInput("regx","Find regex matches"),
    sliderInput("window",'Consistency Window',min = 2,max = 100,5),
    
    
    actionButton(inputId = "apply",label = "Commit Changes", icon("refresh"))
    
  ),
  
  # Main Panel:
  mainPanel( 
    tabsetPanel(type = "tabs",
                #
                tabPanel("Overview of 20 Hotel Reviews Dataset",h4(p("See my Data preparation steps below")),
                         
                         p("Manually, I filtered 20 hotels in the excel sheet and extracted data of only Review column into a textpad and saved it as 20_Hotel_Reviews because I built this app in a way that it accepts only a document in txt file format. again, I ensured that each row of the reviews was separated from one another with a new line of character. Also, I have already attached my prepared dataset to be used below. Kind download it under Download text file and then, 
                           on Browse in left side bar panel and upload the downloaded txt file which has been prepared. immediately the file has been uploaded, it will carry out the data processing in 
                            backend with default inputs and show the results in different tabs.", align = "justify"),
                         p("If you wish to modify the input, edit the input in left side bar panel and click on Commit Changes. The outputs in other tabs will be reprocessed.
                           ", align = "Justify"),
                         h5("Note"),
                         p("The changes in output takes effect few seconds after clicking on 'Commit Changes'. This is to allow all the data processing
                          in backend to complete before displaying the result",
                           align = "justify"),
                         #, height = 280, width = 400
                         verbatimTextOutput("start"),
                         h4(p("Download text file")),
                         downloadButton('downloadData1', '20_Hotel_Reviews reviews txt file'),br(),br(),
                        p("Kindly note that download is not supported with RStudio interface.  Thus use a web-browser to open this App and then download the 20 Hotel Reviews file. Please click on Open in Browser as shown at top left of the browser to open this App.")
                         img(src = "UniLogo.PNG")
                )
                ,
                tabPanel("Data Summary",
                         h4("Uploaded data size"),
                         verbatimTextOutput("up_size"),
                         h4("Sample of uploaded datasest"),
                         DT::dataTableOutput("samp_data")
                         ),
                tabPanel("TDM & Word Cloud",
                         h4("DTM Size"),
                         verbatimTextOutput("dtm_size"),
                         hr(),
                         h4("Term Document Matrix [1:10,1:10]"),
                         DT::dataTableOutput("dtmsummary"),
                         hr(),
                         h4("Word Cloud"),
                         plotOutput("wordcloud",height = 700, width = 700),
                         hr(),
                         h4("Weights Distribution of Wordcloud"),
                         DT::dataTableOutput("dtmsummary1")),
                
                #tabPanel("Topic Model - Summary",verbatimTextOutput("summary")),
                tabPanel("Topics Wordcloud",uiOutput("plots2")),
                tabPanel("Topics Co-occurrence",uiOutput("plots3")),
                # tabPanel("Topics eta values",tableOutput("summary2")),
                
                #                         
                tabPanel("Token-Topic Loadings",h4("Top terms for each topic"), DT::dataTableOutput("score")),
                
                tabPanel("Topic Scores as Doc Proportions",br(),br(),
                         downloadButton('downloadData2', 'Download Topic Proportions file (Works only in browser)'), br(),br(),
                         dataTableOutput("table"))
                
                         )
           )
       )
    )
