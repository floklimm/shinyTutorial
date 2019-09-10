# shinyTutorial
This is a small tutorial for the R package Shiny. Dominik Schwarz and I wrote it for internal usage for the Oxford Protein Informatics Group (OPIG) in 2019.


## Tutorial

### What is Shiny and why should I care?
Shiny is a RStudio package/library that allows the construction of interactive web pages that call R code. The two reasons I ended up using it for one of my projects was two-fold:
- Shiny allows the incorporation of R code (which my project was written in), and
- It was fairly straightforward to build the webtool (in comparison with, for example, Flask in Python or D3 in JavaScript).

To get an overview about the type of applications one can create with Shiny see this [Gallery](https://shiny.rstudio.com/gallery/).

### Aim of this tutorial
This tutorial will guide you stepwise through the creation of a simple Shiny app. You will learn about the structure of a Shiny app and how you can use input and output function. As an example, we use a small network but the presented tools are also applicable to other data types (e.g., data tables, protein structures, ...).

### My first Shiny app
Every Shiny app has the same structure: It consists of one 'ui.R' file and a 'server.ui' file.

```
No language indicated, so no syntax highlighting.
But let's throw in a <b>tag</b>.
```


### Further Reading
If you are interested in more information, here are some resources for Shiny:
- [Gallery of user-created web apps](http://www.showmeshiny.com/)
- [Sharing Shiny apps online ](https://www.shinyapps.io/)
