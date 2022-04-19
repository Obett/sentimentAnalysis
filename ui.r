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
    textInput("stopw", ("Enter stop words separated by comma(,)"), value = "will,can"),
    
    # selectInput("ws", "Weighing Scheme", 
    #             c("weightTf","weightTfIdf"), selected = "weightTf"), # weightTf, weightTfIdf, weightBin, and weightSMART.
    #
    htmlOutput("pre_proc1"),
    htmlOutput("pre_proc2"),
    sliderInput("freq", "Minimum Frequency in Wordcloud:", min = 0,  max = 100, value = 2),
    
    sliderInput("max",  "Maximum Number of Words in Wordcloud:", min = 1,  max = 300,  value = 50),  
    
    numericInput("nodes", "Number of Central Nodes in co-occurrence graph", 4),
    numericInput("connection", "Number of Max Connection with Central Node", 5),
    
    
    textInput("concord.word",('Enter word for which you want to find concordance'),value = 'good'),
    checkboxInput("regx","Check for regex match"),
    sliderInput("window",'Concordance Window',min = 2,max = 100,5),
    
    
    actionButton(inputId = "apply",label = "Apply Changes", icon("refresh"))
    
  ),
  
  # Main Panel:
  mainPanel( 
    tabsetPanel(type = "tabs",
                #
                tabPanel("Overview & 20 Hotel Reviews Dataset",h4(p("How to use this App")),
                         
                         p("To use this app you need a document corpus in txt file format. Make sure each document is separated from another document with a new line character.
                           To do Sentiment Analysis Of 20 Hotels in your text corpus, click on Browse in left-sidebar panel and upload the txt file. Once the file is uploaded it will do the computations in 
                            back-end with default inputs and accordingly results will be displayed in various tabs.", align = "justify"),
                         p("If you wish to change the input, modify the input in left side-bar panel and click on Apply changes. Accordingly results in other tab will be refreshed
                           ", align = "Justify"),
                         h5("Note"),
                         p("You might observe no change in the outputs after clicking 'Apply Changes'. Wait for few seconds. As soon as all the computations
                           are over in back-end results will be refreshed",
                           align = "justify"),
                         #, height = 280, width = 400
                         br(),
                         h4(p("Download text file")),
                         downloadButton('downloadData1', '20_Hotel_Reviews reviews txt file'),br(),br(),
                         p("Please note that download will not work with RStudio interface.  So open this app in a web-browser and then download the 20 Hotel Reviews file. For opening this app in web-browser click on \"Open in Browser\" as shown at top left of the browser.")
                         #img(src = "NGT23030556D_PASSPORT.jpg")
                )
                ,
                # tabPanel("20 Hotel Reviews dataset", h4(p("Download Sample text file")),
                #          downloadButton('downloadData1', '20_Hotel_Reviews reviews txt file'),br(),br(),
                #          p("Please note that download will not work with RStudio interface. Download will work only in web-browsers. So open this app in a web-browser and then download the 20 Hotel Reviews file. For opening this app in web-browser click on \"Open in Browser\" as shown below -"),
                #          img(src = "NGT23030556D_PASSPORT.jpg")),
                tabPanel("DTM",
                         verbatimTextOutput("dtmsize"),
                         h4("Sample DTM (Document Term Matrix) "),
                         DT::dataTableOutput("dtm_table"),br(), 
                         h4("Word Cloud"),
                         plotOutput("wordcloud",height = 700, width = 700),br(),
                         #textInput("in",label = "text"),
                         h4("Weights Distribution of Wordcloud"),
                         DT::dataTableOutput("dtmsummary1")),
                # tabPanel("TDM & Word Cloud",
                #          
                #          verbatimTextOutput("dtmsummary"),
                #          br(),
                #          br(),
                #          
                #         ),
                
                tabPanel("TF-IDF", 
                         verbatimTextOutput("idf_size"),
                         h4("Sample TF-IDF (Term Frequency-Inverse Document Frequency) "),
                         DT::dataTableOutput("idf_table"),br(), 
                         h4("Word Cloud"),
                         plotOutput("idf_wordcloud",height = 700, width = 700),br(),
                         #textInput("in",label = "text"),
                         h4("Weights Distribution of Wordcloud"),
                         DT::dataTableOutput("dtmsummary2")),
                tabPanel("Term Co-occurrence",
                         h4("DTM Co-occurrence"),
                         visNetworkOutput("cog.dtm",height = 700, width = 700),
                         h4("TF-IDF Co-occurrence"),
                         visNetworkOutput("cog.idf",height = 700, width = 700)
                ),
                tabPanel("Bigram",
                         h4('Collocations Bigrams'),
                         p('If a corpus has n word tokens, then it can have at most (n-1) bigrams. However, most of
                                    these bigram are uninteresting. The interesting ones - termed collocations bigrams - comprise
                                    those bigrams whose occurrence in the corpus is way more likely than would be true if the 
                                    constituent words in the bigram randomly came together. Below is the list of all collocations 
                                    bigrams (top 100, if collocations bigrams are above 100) from the corpus you uploaded on 
                                    this App',align = "Justify"),
                         DT::dataTableOutput("bi.grams"),
                         h4("Bigram wordcloud"),
                         plotOutput("bi_word_cloud",height=700,width=700),
                         
                ),
                tabPanel("Concordance",
                         h4('Concordance'),
                         p('Concordance allows you to see the local context around a word of interest. It does so by building a moving window of words before and after the focal word\'s every instance in the corpus. Below is the list of all instances of concordance in the corpus for your word of interest entered in the left side bar panel of this app. You can change the concordance window or word of interest in the left side bar panel.',align = "Justify"),
                         #verbatimTextOutput("concordance"))
                         DT::dataTableOutput("concordance")),
                tabPanel("Downloads",
                         h4("Download DTM"),
                         #h3("-------------"),
                         verbatimTextOutput("dtm_text"),
                         downloadButton('download_dtm', 'Download DTM'),br(),
                        
                         
                         h3("-----------------------------------------------------"),
                         h4("Download TF-IDF"),
                         verbatimTextOutput("tfidf_text"),
                         downloadButton('download_tfidf', 'Download TF-IDF'),br(),
                         
                         
                         h3("-----------------------------------------------------"),
                         h4("Download Bigram Corpus"),
                         verbatimTextOutput("bi_text"),
                         downloadButton("download_bigram","Download Bigram Corpus"))
                          
          
                
                
    )
  )
)
)