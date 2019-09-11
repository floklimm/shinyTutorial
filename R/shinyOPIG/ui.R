#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(visNetwork)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("shinyOPIG"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       sliderInput("bins",
                   "Number of bins:",
                   min = 1,
                   max = 20,
                   value = 10)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      # use three different tabs
      tabsetPanel(
        tabPanel("Histogram", plotOutput("distPlot")), 
        tabPanel("Network Plot", visNetworkOutput("network")), 
        tabPanel("Table", tableOutput("degreeTable"))
      )
    )
  )
))