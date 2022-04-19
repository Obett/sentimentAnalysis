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
  titlePanel(title=div("Sentiment Analysis Of 20 Hotels")),
  
  # Input in sidepanel:
  sidebarPanel(
    
    fileInput("file", "Upload your text file"),
    uiOutput('id_var'),
    uiOutput("doc_var"),
    textInput("stopw", ("Enter your own stopwords and use comma(,) to separate them"), value = "is, above"),
    htmlOutput("pre_proc1"),
    htmlOutput("pre_proc2"),
    sliderInput("freq", "Minimum Frequency in Wordcloud:", min = 0,  max = 100, value = 2),
    
    sliderInput("max",  "Maximum Number of Words in Wordcloud:", min = 1,  max = 300,  value = 50),  
    
    numericInput("nodes", "Co-occurrence graph with number of central nodes", 4),
    numericInput("connection", "The maximum connection number with the central node", 5),
    
    
    textInput("concord.word",('If you want concordance for a word, please enter that word'),value = 'great'),
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
                         br(),
                         h4(p("Download text file")),
                         downloadButton('downloadData1', '20_Hotel_Reviews reviews txt file'),br(),br(),
                         p("Kindly note that download is not supported with RStudio interface.  Thus use a web-browser to open this App and then download the 20 Hotel Reviews file. Please click on Open in Browser as shown at top left of the browser to open this App.")
                         #img(src = "NGT23030556D_PASSPORT.jpg")
                )
                ,
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
                         p('When a corpus contains n word tokens, it can only contain (n-1) bigrams. However, the majority of these bigrams are not interesting. The interesting ones - termed collocations bigrams - comprise
                                    See the list of all collocations 
                                    bigrams below (top 100, if collocations bigrams are above 100) from the corpus you uploaded on 
                                    this App',align = "Justify"),
                         DT::dataTableOutput("bi.grams"),
                         h4("Bigram wordcloud"),
                         plotOutput("bi_word_cloud",height=700,width=700),
                         
                ),
                tabPanel("Concordance",
                         h4('Concordance'),
                         p('You can see the local context for words of interest when using Concordance. The mechanism accomplishes this by building a moving window of words before and after every occurrence of the focal word. In the panel on the left side of this app, you will see a list of all concordances for the term you entered. In the left sidebar panel, you can choose to change the concordance window or word of interest.',align = "Justify"),
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
