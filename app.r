Sys.setenv(JAVA_HOME='')
require("shiny")
require("shinycssloaders")
require("randomForest")
require("caret")
options(shiny.maxRequestSize = 10*1024^2)
#UI
ui <- fluidPage(img(src='niperlogo.png', align = "left",width=100,height=130),
                h1(HTML(paste0("TNF",tags$sub("i"),"Pred: Tool to predict TNF-alpha inhibitors")), align = 'center'),
                h4(HTML(paste0("Department of Pharmacoinformatics")), align = 'center'),
                h6(HTML(paste0("National Institute of Pharmaceutical Education and Research, S.A.S. Nagar")), align = 'center'),
                hr(),
                
                  fluidRow(align = 'center',
                    fileInput(
                      inputId="mols", label="Choose an sdf file (Example: molecules.sdf)", 
                      accept = c(".sdf")
                    ),
                    em("wait until upload is completed",br()),
                    actionButton("start","Predict"),
                    
                                       
                  ),
                br(),
                tags$div( withSpinner(uiOutput("downloadit")), align = 'center')
                ,
                hr(),
                strong(verbatimTextOutput("info"), align="center"),
                strong( "Prof. Prabha Garg",br(),
                "Professor (Department of Pharmacoinformatics)",br(),
                "National Institute of Pharmaceutical Education & Research (NIPER)",br(),
                "Sector-67, S.A.S. Nagar, Mohali-160062, Punjab. (India)"),
                a(br(),"visit us", href="http://14.139.57.41/", target="_blank") 
)
#SERVER
server <- function(input, output, session) 
{
  load('data/bin.Rdata')
  output$info <- renderText({
    paste(
          "This tool is developed by Niharika K Prabha, Anju Sharma and Hardeep Sandhu under the guidance of Prof. Prabha Garg.",
           sep="\n")
  })
  
  des <- reactive(
          {
            if(input$start == 0)
              return() 
            else
            #descriptor calculation
            infile <- input$mols
            
            molecules <- rcdk::load.molecules(infile$datapath,typing = T,aromaticity = T)
            molecules <- lapply(molecules, rcdk::get.largest.component)
            rcdk::write.molecules(molecules, 'data/temp/processed.sdf')

            system(paste("java -jar data/padel/bin.jar -2d -fingerprints -removesalt -retainorder -detectaromaticity -standardizenitro -descriptortypes data/des_type.xml -dir data/temp/processed.sdf -file data/temp/out.csv"))
            des1 <- read.csv('data/temp/out.csv')
            des1 <- des1[,-1]
            padel_des <- predict(c, des1)
            padel_des <- padel_des[,names(rf_gridsearch$trainingData)[-25]]

            
            return(padel_des)
          }
  )
  
  
inhibitors <- reactive(
          {
          	if(input$start == 0)
                  return()
          	if(!is.null(des()))
          	# prediction
              prob <- predict(rf_gridsearch, des(), type = 'prob')[,2]
          	  pred <- predict(rf_gridsearch, des())
          	  levels(pred) <- c('non-inhibitors', 'inhibitors')
          	  return(data.frame(pred, prob))
          }
  )

  results <- reactive(
    {
      if(input$start == 0)
        return()
      if(!is.null(inhibitors()))
	    infile <- input$mols
		  mols <- rcdk::load.molecules(infile$datapath)
		  molnames <-  unlist(lapply(mols, rcdk::get.title))
		  mols <- lapply(mols, rcdk::remove.hydrogens)
		  smiles <-  unlist(lapply(mols, rcdk::get.smiles))
      prob <- inhibitors()[,2]
      pred <- inhibitors()[,1]
      print(as.character(pred))
      print(prob)
      data.frame(Sr_No=1:length(inhibitors()[,1]), Title=molnames, SMILES=smiles,Prediction = pred, Inhibiting_probability = prob)
    }
  )
  
  output$downloadData <- downloadHandler(
    filename =  "results.csv",
    content = function(file) {
      write.csv(results(), file, row.names = FALSE)
    }
  )
  
  output$downloadit <- renderUI({
    if(!is.null(results()))
      downloadButton("downloadData", "Download Results", icon = icon('download'))
  })
}
shinyApp(ui, server)