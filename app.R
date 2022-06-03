library(shiny)
library(plotly)

# Define UI for application that draws a histogram
ui <- fluidPage(
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    
    fluidRow(
      column(8, offset=2, 
          tags$section(id="intro", class="text-section",
              h1("¿Todas las personas tienen acceso a la electricidad?"),
              p(class="prose", "Los Objetivos de Desarrollo Sostenible de las Naciones Unidas son un plan para lograr un futuro mejor y más sostenible."),
              p(class="prose", "El Objetivo de Desarrollo Sostenible 7 es:"),
              p(class="prose", strong(em("Garantizar el acceso a una energía asequible, segura, sostenible y moderna para todas las personas."))),
              p(class="prose","¿Estamos cumpliendo el plan?")),
        
          tags$section(id="story",
              div(id="story-scroll", 
                  tags$figure(plotlyOutput(outputId = "storyPlot", height = "100%"),
                    tags$figcaption(em("Fuente de los datos:", strong("Tracking SDG7: The Energy Progress Report del año 2021")))),
                  tags$article(includeHTML("www/story_steps.html"))
                  )
          ),    
          
          tags$section(id="risk", class="text-section",
              p(class="prose", "Los Objetivos de Desarrollo Sostenible de las Naciones Unidas son un plan para lograr un futuro mejor y más sostenible."),
              p(class="prose", "El Objetivo de Desarrollo Sostenible 7 es:"),
              p(class="prose", strong(em("Garantizar el acceso a una energía asequible, segura, sostenible y moderna para todas las personas."))),
              p(class="prose","¿Estamos cumpliendo el plan?")),
          
          
          tags$section(id="calculator",
          sidebarLayout(
            sidebarPanel(
              sliderInput("bins",
                          "Number of bins:",
                          min = 1,
                          max = 50,
                          value = 30)
            ),
            
            # Show a plot of the generated distribution
            mainPanel(
              plotOutput("distPlot")
            )
          ))
    
    )),
    
    tags$script(src="scripts/lib/d3.min.js"),
    tags$script(src= "scripts/lib/scrollama.min.js"),
    tags$script(src= "scripts/scroller.js")
    

)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$storyPlot <- renderPlotly({
      
      data <- data.frame(x=c(1,2,3,1,2,3), y=c(0, 0.5, 1,1,0.5,1), frame=c("step1","step1","step1","step2","step2","step2")) 
      
      plot_ly (data, x= ~x, y=~y , frame= ~frame, name="storyPlot", type="scatter", mode= 'lines+markers') %>% 
        animation_slider(hide = TRUE) %>% animation_button(visible= FALSE) %>% config(displayModeBar = FALSE)
    })
    
    
    output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
      x    <- faithful[, 2]
      bins <- seq(min(x), max(x), length.out = input$bins + 1)
      
      # draw the histogram with the specified number of bins
      hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })
    
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
