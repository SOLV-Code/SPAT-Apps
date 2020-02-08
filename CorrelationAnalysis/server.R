





function(input, output, session) {

print("Testing")




# Think it needs these here for the server deployment
library("ggplot2")
library("DT")
library("markdown")
library("rmarkdown")
library("shiny")
library("shinydashboard")
library("shinyjqui")
library("shinyFiles")
library("tidyverse")
library("SPATFunctions")
library("mclust")


# range of clusters to test for elbow plot and similat diagnostics
# make this a GUI Setting later
clusters.range <- 1:10 


	volumes.use <- getVolumes()
	shinyDirChoose(input,"repdir",roots=getVolumes())
	reports.path.use <- reactive(input$repdir)
	output$reports.path.use <- renderPrint({   parseDirPath(roots=volumes.use, selection =reports.path.use())  })


	# Read in user-selected input file
    data.file <- reactive({
		inFile <- input$file.name.2
		if(is.null(inFile)){data.use <-  SPATFunctions::SPATData_EnvCov}   
		if(!is.null(inFile)){data.use <- read.csv(inFile$datapath, stringsAsFactors=FALSE)  
		print(head(data.use))
			}
	
	# do steps here to check/filter the input file 	
		data.use <- data.use #%>% drop_na() # but needs to depend on selected subset, 
		                                    # so not doing anything here
	
	return(data.use)
			
	})


	output$input.table <- renderTable({ data.file() })  # masking issue with package DT? shiny::renderTable doesn't fix it


	# generate dynamic dropdown menus for the UI
	# can probably streamline this to reduce the repetition, but for now just make it work
	
	numeric.vars <- reactive({
			num.idx <-  unlist(lapply(data.file(), is.numeric))  
			var.vec <- sort(names(data.file())[num.idx])
			var.vec <- var.vec[!(tolower(var.vec) %in% c("year","yr"))]

			return(var.vec)
			})
	
	char.vars <- reactive({
			num.idx <-  unlist(lapply(data.file(), is.numeric))  
			var.vec <- sort(names(data.file())[!num.idx])
			return(var.vec)
			})	
	

	# Variable List for Dropdown - Main Panel
	output$var.main.menu <- renderUI({
			selectInput("var.main", label = "Numeric Variables", choices = numeric.vars(),  
			     multiple=TRUE,selected = numeric.vars()  )
			})	
			
	
	output$group1.menu <- renderUI({
	  selectInput("var.group1", label = "Numeric Variables", choices = numeric.vars(),  
	              multiple=TRUE,selected = numeric.vars()[1]  )
	})
	output$group2.menu <- renderUI({
	  selectInput("var.group2", label = "Numeric Variables", choices = numeric.vars(),  
	              multiple=TRUE,selected = numeric.vars()[1]  )
	})
	output$group3.menu <- renderUI({
	  selectInput("var.group3", label = "Numeric Variables", choices = numeric.vars(),  
	              multiple=TRUE,selected = numeric.vars()[1]  )
	})
	output$group4.menu <- renderUI({
	  selectInput("var.group4", label = "Numeric Variables", choices = numeric.vars(),  
	              multiple=TRUE,selected = numeric.vars()[1]  )
	})
	

	# Variable List for Dropdown - Pairwise Var 1
	output$var.1.menu <- renderUI({
	  selectInput("var.1", label = "Var 1", choices = numeric.vars(),  
	              multiple=FALSE,selected = numeric.vars()[1]  )
	})	
				

	# Variable List for Dropdown - Pairwise Var 2
	output$var.2.menu <- renderUI({
	  selectInput("var.2", label = "Var 2", choices = numeric.vars(),  
	              multiple=FALSE,selected = numeric.vars()[2]  )
	})	
				
			
	# prototype placeholders
	tmp <- reactive({ return(matrix(1:6,ncol=2)) }) 
	output$tbl <- renderTable({ tmp() })  # masking issue with package DT? shiny::renderTable doesn't fix it
	output$plot.sample <- renderPlot({	plot(1:5,1:5)  	})
 	output$plot.sample2 <- renderPlot({	plot(1:8,1:8)  	})  

			   

#--------------------------------------------
# Main Panel - Correlation MAtrix

   selectedData.main <- reactive({
    print(input$var.main)
     
     # filter out selected years and variables
		data.use <- data.file()  %>% 
		            dplyr::filter(yr >= input$yrs.use.main[1] & yr <= input$yrs.use.main[2]) %>%
		            dplyr::select(input$var.main)
		#data.use  <- transformData(x=data.use ,type= input$transform.1value, cols=input$var.1val,zero.convert = NA)
	
		
		data.use <- data.use 
		# final step is to filter out NA years  		
	  data.use <- data.use %>% drop_na() 
		
		
			print(head(data.use))
		return(data.use)
	})
 
  corr.mat <- reactive({
  		print("calculating correlation matrix")
		
		data.in <- selectedData.main()
		#print(head(data.in))
		corr.out <- calcCorrMatrix(data.in,method = input$method.corr )
		return( corr.out)
	})
  

  output$corr.table <-  DT::renderDataTable(
    # download button: in shiny or within datatable?
    # https://stackoverflow.com/questions/50039186/r-shiny-how-to-add-download-buttons-in-dtrenderdatatable
    #https://github.com/rstudio/DT/issues/267
    #https://community.rstudio.com/t/r-shiny-to-download-xlsx-file/18441
    # https://shiny.rstudio.com/reference/shiny/1.0.4/downloadButton.html
    
    DT::datatable( round(corr.mat()[["cor.mat"]],2),
       options = list(lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')),
                                              pageLength = 15),
      rownames= TRUE
    )
  )



  output$corr.mat.plot <- renderPlot({
	print("starting main plot")
	
    corr.fit <- corr.mat()
    print(input$order.corr)
    plotCorrMatrix(corr.fit$cor.mat,order=input$order.corr,n.groups=input$n.clusters)  
    
    })
	
  




#--------------------------------------------
# PAIRWISE CORRELATION
   ## TEMP KLUDGE FOR HANDLING YEAR COLUMN!!!!
   ## NEED TO MAKE IT REACTIVE
  
   selectedData.pairwise <- reactive({
			
		data.use <- data.file()  %>% dplyr::select(yr,input$var.1,input$var.2)
    
		print(head(data.use))
		
		data.use <- shiftSeries(data.use, offsets=c(0,0,input$var.2.offset))
		print(head(data.use))
		
		data.use <- transformData(data.use,type=input$var.1.transform,
		                        cols=names(data.use)[2],
		                        zero.convert = NA )
		
		data.use <- transformData(data.use,type=input$var.2.transform,
		                          cols=names(data.use)[3],
		                          zero.convert = NA )	
		print(head(data.use))
	return(data.use)
  
  })
 

  
  output$series.plot <- renderPlotly({
	print("starting series plot")
	
	data.plot <- selectedData.pairwise()
  plotPair(data.plot,layout = input$series.layout,plot.type="shiny")

  })
  
  output$series.corr.plot <- renderPlotly({
    print("starting series corr plot")
    
    data.plot <- selectedData.pairwise()
    compair.out <- comPair(data.plot, window = input$window,plot.type="shiny")
    
    return(compair.out$plot)

    
  })  
  
  
  
  #--------------------------------------------
  # Grouping Plots

  selectedData.group1 <- reactive({
    # transforms not linked up yet , offsets not meaningful for this?    
    data.use <- data.file()  %>% dplyr::select(yr,input$var.group1)
    return(data.use) })

  output$group1.plot <- renderPlotly({
    print("starting group 1 plot")
    data.plot <- selectedData.group1()
    group1.out <- plotGroup(data.plot,agg.idx = input$group1.idx,plot.type="shiny")
    return(group1.out$plot)
    
  })
  
  selectedData.group2 <- reactive({
    # transforms not linked up yet , offsets not meaningful for this?    
    data.use <- data.file()  %>% dplyr::select(yr,input$var.group2)
    return(data.use) })
  
  output$group2.plot <- renderPlotly({
    print("starting group 2 plot")
    data.plot <- selectedData.group2()
    group2.out <- plotGroup(data.plot,agg.idx = input$group2.idx,plot.type="shiny")
    return(group2.out$plot)
    
  })
 
  selectedData.group3 <- reactive({
    # transforms not linked up yet , offsets not meaningful for this?    
    data.use <- data.file()  %>% dplyr::select(yr,input$var.group3)
    return(data.use) })
  
  output$group3.plot <- renderPlotly({
    print("starting group 3 plot")
    data.plot <- selectedData.group3()
    group3.out <- plotGroup(data.plot,agg.idx = input$group3.idx,plot.type="shiny")
    return(group3.out$plot)
    
  }) 
  
  selectedData.group4 <- reactive({
    # transforms not linked up yet , offsets not meaningful for this?    
    data.use <- data.file()  %>% dplyr::select(yr,input$var.group4)
    return(data.use) })
  
  output$group4.plot <- renderPlotly({
    print("starting group 4 plot")
    data.plot <- selectedData.group4()
    group4.out <- plotGroup(data.plot,agg.idx = input$group4.idx,plot.type="shiny")
    return(group4.out$plot)
    
  })  


} # end server.R


