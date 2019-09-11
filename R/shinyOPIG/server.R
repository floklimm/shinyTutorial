#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# shinyOPIG
# by
# Florian Klimm & Dominik Schwarz, 2019

library(shiny)
library(visNetwork)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  # load a list of OPIG authors
  opigPublication <- read.delim("opigAuthorList.txt", header=FALSE, sep=";",strip.white=TRUE, stringsAsFactors=FALSE)
  occurrences<-table(unlist(opigPublication)) # count the occurances
  occurrences<- sort(occurrences,decreasing=TRUE) # sort them
  occurrencesClean <- occurences[2:length(occurrences)] # we do not take the whitespace author name

  
  output$degreeTable <- renderTable(occurrencesClean)
  
  # here the histogram plotting is happening
  output$distPlot <- renderPlot({

    # generate bins based on input$bins from ui.R
    x <- occurrencesClean
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')

  })
  
  # this constructs the network 
  output$network <- renderVisNetwork({
    ## minimal example
    #nodes <- data.frame(id = 1:3)
    #edges <- data.frame(from = c(1,2), to = c(1,3))
    
    # construct egdes from the author lists in an ugly triple for loop
    edgeFrom <- list()
    edgeTo <- list()
    nPublications <- length(opigPublication[,1])
    for (i in 1:nPublications){ # go over each publication
      authorlistThisPublication <- opigPublication[i,]
      nAuthors <- length(authorlistThisPublication)
      # go pairwise over all authors in this paper
      for (author1 in (1:(nAuthors-1))){
        # only check authors if this is not an empty author
        if (!identical(authorlistThisPublication[,author1],"") ){
          for (author2 in ((author1+1):nAuthors)){
            # only add authors if it is not an empty author
            if (!identical(authorlistThisPublication[,author2],"")) {
              # actually add the names of the authors to two lists (one for start and one for end of the edges)
              edgeFrom <- c(edgeFrom,authorlistThisPublication[,author1])
              edgeTo <- c(edgeTo,authorlistThisPublication[,author2])
            }
          
          }
        }
      }
    }
    
    
    # Construct node and edge lists
    nodes <- data.frame(id =names(occurrencesClean)) # all authors on OPIG papers
    edges <- data.frame(from = unlist(edgeFrom), to = unlist(edgeTo)) 
    
    # use the names as node labels
    nodes$label = names(occurrencesClean)
    
    # make the node's size proportional to their degree
    nodes$size = input$nodeSize*occurrencesClean
    
    # do the actual visualistion
    visNetwork(nodes, edges, , main = "OPIG's 2019 publication network", height = "500px") %>%
      visNodes(color = "purple") %>%
      visInteraction(hover = TRUE) %>%
      visEdges(width=2,smooth=TRUE,color='grey')
  })
  
  

})
