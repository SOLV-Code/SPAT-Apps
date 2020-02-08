

# packages
library("ggplot2")
library("DT")
library("markdown")
library("rmarkdown")
library("shiny")
library("shinydashboard")
library("shinyjqui")
library("shinyFiles")
library("plotly")
library("SPATFunctions")

# define hardwired menu contents
# (e.g. analysis options etc)

	
# need to make this responsive to package functions	
options.list <- list(transforms = c("none","log","z-score","perc_rank"),
                     corr.methods = c("pearson","kendall", "spearman"),
                     plot.order = c("original","clustered") ,
                     Years = 1960:2020,
                     series.layout = c("single","2panels","2axes"),
                     agg.idx = c("none","mean","median"))


# START UI -------------------------------------------
	
navbarPage("SPAT - Correlation Analysis", id = "MainTab",


# Start  disclaimer panel

	 tabPanel("Disclaimer",

fluidPage(

  titlePanel("Disclaimer"),

  fluidRow(
    column(8,
	  includeMarkdown("Markdown/disclaimer.md")
    )
  )
)


	
	  ),  # end Disclaimer tab panel


  

#######   DATA LOADING


tabPanel("1 Data Loading", value= "data.loading",
  
	pageWithSidebar(
		headerPanel("Data Loading"),
    
		sidebarPanel(
			  tags$h4("Data File"),
			  tags$hr(),
			  fileInput("file.name.2", "Choose CSV File", accept = c("text/csv","text/comma-separated-values,text/plain", ".csv")    ),
			  tags$hr() ,
			  tags$a("Get Some Sample Data",href="https://www.dropbox.com/sh/x219hiswog9gvnl/AAB3YrxZ6ifmf2w22nFggZlca?dl=0",target="_blank")
			  ), # end sidebar

        mainPanel(			
	     	div(style = 'overflow: scroll', tableOutput("input.table"),height = "400px")
			) # end main panel
  
		) #end page with side bar for  data loading
  ),  # end  second tab panel
    





###### GROUP EXPLORATION

tabPanel("2 Explore Groups",	value = "groups",
         
tabsetPanel(type = "tabs",
   tabPanel("Group 1", 
        sidebarLayout(
         sidebarPanel(width =2,    
            uiOutput("group1.menu"),
            selectInput("group1.transform", "x_Group 1 Transform",  
                        choices = options.list$transforms, selected = "none"),
            selectInput("group1.idx", "Group 1 Agg. Index",  
                        choices = options.list$agg.idx, selected = options.list$agg.idx[1])),
         mainPanel(  plotlyOutput("group1.plot"))
        )), # end side bar layout and tab panel for group 1
         
         
     tabPanel("Group 2",sidebarLayout(
    sidebarPanel(width =2,    
                 uiOutput("group2.menu"),
                 selectInput("group2.transform", "x_Group 2 Transform",  
                             choices = options.list$transforms, selected = "none") ,
                 selectInput("group2.idx", "Group 2 Agg. Index",  
                             choices = options.list$agg.idx, selected = options.list$agg.idx[1])),
        mainPanel(plotlyOutput("group2.plot"))
          )),# end side bar layout and tab panel for group 2
  
   tabPanel("Group 3",sidebarLayout(
     sidebarPanel(width =2,    
                  uiOutput("group3.menu"),
                  selectInput("group3.transform", "x_Group 3 Transform",  
                              choices = options.list$transforms, selected = "none") ,
                  selectInput("group3.idx", "Group 3 Agg. Index",  
                              choices = options.list$agg.idx, selected = options.list$agg.idx[1])),
     mainPanel(plotlyOutput("group3.plot"))
   )),# end side bar layout and tab panel for group 2
   
   tabPanel("Group 4",sidebarLayout(
     sidebarPanel(width =2,    
                  uiOutput("group4.menu"),
                  selectInput("group4.transform", "x_Group 4 Transform",  
                              choices = options.list$transforms, selected = "none"),
                  selectInput("group4.idx", "Group 4 Agg. Index",  
                              choices = options.list$agg.idx, selected = options.list$agg.idx[1])),
     mainPanel(plotlyOutput("group4.plot"))
      ))# end side bar layout and tab panel for group 2      
                         
                         
  ) # end tabset  inside GROUP panel

      
         
),  # end tab panel for Explore Groups





###### PAIRWISE EXPLORATION

tabPanel("3 Explore Pairs",	value = "pairwise",
         
         
         sidebarLayout(
           
           sidebarPanel(width =2,
                        uiOutput("var.1.menu"),
                        selectInput("var.1.transform", "Var 1 Transform",  choices = options.list$transforms, selected = "none"),
                        uiOutput("var.2.menu"),
                        selectInput("var.2.transform", "Var 2 Transform",  
                                    choices = options.list$transforms, selected = "none"),
                        sliderInput("var.2.offset", "Var 2 Offset",  sep="",
                                    min = -10, max = 10, value = 0,animate=TRUE)
                        
           ),
           
           mainPanel(
             
             
             tabsetPanel(type = "tabs",
                         
                         tabPanel("Series", 
                                  fluidRow(
                                    column(width = 10,plotlyOutput("series.plot")),
                                    column(width =2,selectInput("series.layout", "Layout",  choices = options.list$series.layout, 
                                                                selected = options.list$series.layout[1]))
                                  ),
                                  fluidRow(
                                    column(width = 10,plotlyOutput("series.corr.plot")),
                                    column(width =2, sliderInput("window", "window",  sep="",
                                                                 min = 4, max = 25, value = 12,animate=FALSE))
                                  )),
                         tabPanel("Some Diagnostic Plot" ),
                         tabPanel("Correlations - Table")            
                         
                         
             ) # end tabset  inside main panel for 2 values
           ) # end main panel inside 2 values
           
           
         ) # end sidebar layout inside 2 values
         
),  # end tab panel for Explore Pairs


###### CORRELATION MATRIX

tabPanel("4 Correlation Matrix",	value = "CorrMat",


				sidebarLayout(
				
				 sidebarPanel(width =2,
						selectInput("method.corr", "Method",  choices = options.list$corr.methods, selected = options.list$corr.methods[1]),
				    selectInput("order.corr", "Ordering",  choices = options.list$plot.order, selected = options.list$plot.order[1]),
				  	numericInput("n.clusters", "Num Groups", value=NA,min=2,max=9),
						sliderInput("yrs.use.main", "Years",sep="",min = 1960, max = 2020, value = c(1980,2020),animate=TRUE),
						uiOutput("var.main.menu")
							),
				mainPanel(
				
					
				tabsetPanel(type = "tabs",
		
						tabPanel("Plot", 
										plotOutput("corr.mat.plot",height=700)), 
						tabPanel("Table",	DT::dataTableOutput("corr.table")),
						tabPanel("Diagnostics") #,
						#tabPanel("Select Variables"
						#) #end  tabpanel for settings


					
					) # end tabset  inside main panel for 2 values		

					) # end main panel inside 1 value
				
			  
				) # end sidebar layout inside 1 value

), # end tab panel for Corr Matrix
 

	
	 tabPanel("Help",  value= "help.panel",

fluidPage(

  titlePanel("Help Page"),

  fluidRow(
    column(8,
	  includeMarkdown("Markdown/help.md")
    )
  )
)


	
	  ),  # end Help tab panel
	
	tabPanel("About",
	
fluidPage(

  titlePanel("About SPAT"),

  fluidRow(
    column(8,
      includeMarkdown("Markdown/about.md")
    )
  )	
)	
	  )  # end about tab panel
	
) # end navbar Page

