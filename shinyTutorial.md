# shinyTutorial
This is a small tutorial for the R package Shiny. Dominik Schwarz and I wrote it for internal usage for the Oxford Protein Informatics Group (OPIG) in 2019 but we make it publicly available.


## Tutorial

### What is Shiny and why should I care?
Shiny is a RStudio package/library that allows the construction of interactive web pages that call R code. The two reasons I ended up using it for one of my research projects was two-fold:
- Shiny allows the incorporation of R code (which my project was written in), and
- It was fairly straightforward to build the webtool (in comparison with, for example, Flask in Python or D3 in JavaScript).

The Shiny app I created is [scPPIN-online](https://floklimm.shinyapps.io/scPPIN-online/). Give it a try. (Just click on `Compute` without providing an input file - this loads an example data set.)

To get a broader overview about the type of applications one can create with Shiny see this [Gallery](https://shiny.rstudio.com/gallery/).



### Aim of this tutorial
This tutorial will guide you stepwise through the creation of a simple Shiny app. You will learn about the structure of a Shiny app and how you can use input and output functions. As an example, we use a small network but the presented tools are also applicable to other data types (e.g., data tables, protein structures, ...).

> Any task in this tutorial will be highlighted like this.

If you should run into problems, we provide a fully functional app in the `shinyOPIG` folder.

### My first Shiny app
Every Shiny app has the same structure: It consists of one 'ui.R' file and a 'server.ui' file. (In principle both parts of the program can also be in the same file but it is usually recommended to have them separately to avoid confusion.)

The `User Interface` (UI) defines a webpage that is shown to the user and is also used by them to give commands or input data to the server. One of Shiny's conveniences is that you don't have to code any HTML yourself, rather it provides you with certain tools that you code in R that generate HTML objects that form the UI. The downside of this approach is that it limits the customizability. (but you can actually include plain HTML code, if necessary)

The `Server` defines all the background computations that your program executes. This can be any type of R commands, which includes external libraries (e.g., BioConductor, Dplyr, ggplot2, ...). As you can execute unix commands from R with the `system` command, one can also call compiled programs. The mentioned scPPIN-online tool, for example, prepares the data in R, writes a text file, executes a C++ program, and reads the output into R.

Now we will create our first Shiny app: Rstudio allows us to create an example Shiny app under `File > New File > Shiny Web App > ...`.

> Use R Studio to create a new Shiny app. Use a `multiple file app` and name it `shinyOPIG-MYNAMES`.

This creates two files (ui.R and server.R). The default application is an interactive histogram of the `Old Faithful Geyser` data.

> Explore the application by executing it by clicking `Run App`.

The app has a fairly simple structure: The user can specify the number of bins in the histogram with a slider (which is coded in the UI part of the app). The SERVER part does the construction of the actual histogram, and shows it in the UI.  

### Loading a more interesting data set

The 'Old Faithful Geyser Data' is a placeholder the data we are interested in.Have a look at the provided text file `opigAuthorList.txt`. It is a semicolon-separated file with each line being the list of authors of one paper that was written by OPIG in 2019. We want to use this data to create a histogram of authorships.

To load data and count occurrences, we can use the code below:

```
# load a list of OPIG authors
opigPublication <- read.delim("opigAuthorList.txt", header=FALSE, sep=";",strip.white=TRUE)
occurrences<-table(unlist(opigPublication)) # count the occurrences
occurrences<- sort(occurrences,decreasing=TRUE) # sort them
occurrencesClean <- occurrences[2:length(occurrences)] # we do not take the whitespace author name
```


We will have to assign this new data to the `x` vector, which we use in the histogram

```
x <- occurrences[2:length(occurrences)] # we do not take the whitespace author name into account
```

> Incorporate the code above into the SERVER script. Copy the file `opigAuthorList.txt` into the folder with your Shiny script. Execute the Shiny app to check if the new data is plotted.
> (You might need to set your working directory to source file location for the correct loading of the data.)

### Create a more complex UI

Thus far, we only change the server side of things. Now we will make the UI a bit more complex. First, we use the provided functions and customize them for our purposes:

> Change the title of the App to `shinyOPIG`.

The slider values are not really appropriate for our purposes

> Change the minimum, maximum, and default value of the slider to values of your choice.

Often, we analyse data and want to provide output in different formats or varying levels of detail. One way to create an overview of such different outputs is the usage of tabs.

```
# Show a plot of the generated distribution
mainPanel(
  # use three different tabs
  tabsetPanel(
    tabPanel("Histogram", plotOutput("distPlot")),
    tabPanel("Network Plot", visNetworkOutput("network")),
    tabPanel("Table", tableOutput("degreeTable"))
  )
)
```

> Incorporate the code above into the UI and explore the new version of the app.

As you see, we now have three tabs, but two of them are empty. The reason for this is that we have not defined the content of the table that will be displayed. To do this, we can use `renderTable`:

```
output$degreeTable <- renderTable(occurrencesClean)
```

> Use `renderTable` in the SERVER file to show in the third tab a list of authors and their number of authorships.

### Illustrating networks in Shiny

Now we will construct a co-authorship network and visualise it in the second tab. There are multiple network/graph libraries in R. For our purposes, [visNetwork](https://datastorm-open.github.io/visNetwork/) is best because it is fairly easy to incorporate in Shiny.

First, we construct a simple example network:

```
output$network <- renderVisNetwork({
   # minimal example
   nodes <- data.frame(id = 1:3)
   edges <- data.frame(from = c(1,2), to = c(1,3))

   visNetwork(nodes, edges)
 })
```

> Visualise your first network with this small example graph. You can zoom in and out and also drag nodes around.

Constructing a network from the publication data, is a bit more involved:

```
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


    # OPIG network
    nodes <- data.frame(id =names(occurrencesClean)) # all authors on OPIG papers
    edges <- data.frame(from = unlist(edgeFrom), to = unlist(edgeTo))
    visNetwork(nodes, edges)
  })
```

> Replace the sample network with the OPIG network.

Now we will make the network a bit prettier. First, we introduce node labels

```
nodes$label = names(occurrencesClean)
```

and second, we change the network's appearance

```
visNetwork(nodes, edges, main = "OPIG's 2019 publication network", height = "500px") %>%
      visNodes(color = "purple") %>%
      visInteraction(hover = TRUE) %>%
      visEdges(width=2,smooth=TRUE,color="grey")
```

> Implement these changes in appearance.

Penultimately, we make a node's size proportional to it's degree

```
nodes$size = 5*occurrencesClean
```

> Make all nodes' size five-fold their degree with the code above.

For the final task, we do not provide code but you should be able to combine the introduced functions:

> Create a new input-slider (or alternatively, radio buttons, or a selection box) that allows the user to change the proportionality factor of the node size.



### Optional: Publish the application (Internet required)
Thus far, we run the application on our local machine. The main aim for creating the app, however, is to make it accessible to other scientists. To do this, there are two options:
1. Share the script publicly (e.g., on GitHub) so that other scientists can run it on their machine, or
2. Share the app as a webpage.

The latter is the most user friendly. To share the app as a webpage we need a server that is publicly available. Shiny provides a free service under [Shinyapps](shinyapps.io) which can be used to share up to five applications. (This is also the service that we used for [scPPIN-online](https://floklimm.shinyapps.io/scPPIN-online/).)

> Sign up to the free tier of shinyapps.io and make your application available.

> Share the link with another group/individual and test each others application. Does it behave as intended?

There exists also the possibility to install Shiny Server on one of our own machines/servers and host the application in-house. (This is currently not implemented at the Department of Statistics.)

### Optional: Some ideas how to extend the app
- Change the appearance of the network [visNetwork](https://datastorm-open.github.io/visNetwork/). You can, for example, use photos as node-icons.
- Allow additional inputs in Shiny (e.g., Let the user change the colour of the bar plot).
- Let the user download the result of your degree-analysis (look up the `downloadButton` function).
- Allow users to provide their own file with author lists (look up the `fileInput` function).
- visNetwork allows the definition of `groups`. Use this functionality to change the appearance of all nodes that represent OPIG members.

## Conclusions

To conclude, Shiny is useful for the following tasks:
- We can incorporate R code to make an interactive web app.
- There exists a lot of different functions to create elements (e.g., sliders, output tables, ...) that can be used to make an app.
- The R library `visNetwork` allows the creation of interactive network visualisations.
- We can easily deploy the application to shinyapps.io to make publicly available.

## Further Reading
If you are interested in more information, here are some resources for Shiny:
- [Gallery of user-created web apps](http://www.showmeshiny.com/)
- [Sharing Shiny apps online: User guide](https://docs.rstudio.com/shinyapps.io/index.html)
