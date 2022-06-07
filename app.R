library(shiny)
library(bslib)
library(plotly)
library(shinyWidgets)
library(C50)

model <- readRDS("model.rds")

# Define UI for application that draws a histogram
ui <- fluidPage(
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
        tags$style("@import url('https://fonts.googleapis.com/css2?family=VT323&display=swap');"),
        tags$style("@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@100;300;400');")
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
          
          verticalLayout(
            wellPanel(class="calc-display",
              fluidRow(
                column(5, offset=2,
                  span(style="vertical-align: middle", textOutput("predicted_risk"))),
                column(2, offset=2, 
                  span(style="vertical-align: middle", includeHTML("www/heart.svg"))
                )
              )
            ),
            
            fluidRow(
              column(3,
                div(class = "calc-panel",
                  p(class = "calc-panel-title", "Pérfil"),        
                  sliderTextInput(inputId = "sex", label = "Sexo:", force_edges = TRUE, choices = c("Hombre", "Mujer")),
                  sliderTextInput(inputId = "age_category", "Edad:", grid = TRUE, force_edges = TRUE, 
                                choices = c("18-24", "25-29", "30-34", "35-39","40-44","45-49", "50-54", "55-59", "60-64", 
                                            "65-69", "70-74", "75-79","80 or older")),
                  )
              ),
              
                column(3,
                  div(class="calc-panel",
                    p(class = "calc-panel-title", "Estilo de Vida"),        
                    materialSwitch(inputId = "smoking", label = "Fumador", status = "danger"),  
                    materialSwitch(inputId = "alcohol_drinking", label = "Consulmo de alcohol", status = "danger"),
                    materialSwitch(inputId = "physical_activity", label = "Actividad física", status = "success"),
                  )
              ),
              
              
                column(3,
                  div(class="calc-panel",
                    p(class = "calc-panel-title", "Estado de Salud"), 
                    sliderInput(inputId = "bmi", label="I.M.C.", min = 0, max = 100, value = 0),
                    sliderInput(inputId = "physical_health", label="Salud física", min = 0, max = 30, value = 0),
                    sliderInput(inputId = "mental_health", label="Salud mental", min = 0, max = 30, value = 0),  
                    materialSwitch(inputId = "diff_walking", label = "Dificultad para caminar", status = "danger"),
                  )
              ),
              
              
                column(3,
                  div(class="calc-panel",
                    p(class = "calc-panel-title", "Enfermedades"),             
                    materialSwitch(inputId = "diabetic", label = "Diabetes", status = "danger"),  
                    materialSwitch(inputId = "stroke", label = "Ictus", status = "danger"),
                    materialSwitch(inputId = "asthma", label = "Asma", status = "danger"),
                    materialSwitch(inputId = "kidney_disease", label = "Enfermedad renal", status = "danger"),
                    materialSwitch(inputId = "skin_cancer", label = "Cáncer de piel", status = "danger"),
                  )
                )
              )
          )
        )
    
    )),
    
    tags$script(src="scripts/lib/d3.min.js"),
    tags$script(src= "scripts/lib/scrollama.min.js"),
    tags$script(src= "scripts/scroller.js")
    

)

# BMI Smoking AlcoholDrinking Stroke PhysicalHealth MentalHealth DiffWalking Sex AgeCategory Race Diabetic PhysicalActivity SleepTime Asthma KidneyDisease SkinCancer


# Define server logic required to draw a histogram
server <- function(input, output) {

    output$storyPlot <- renderPlotly({
      
      data <- data.frame(x=c(1,2,3,1,2,3), y=c(0, 0.5, 1,1,0.5,1), frame=c("step1","step1","step1","step2","step2","step2")) 
      
      plot_ly (data, x= ~x, y=~y , frame= ~frame, name="storyPlot", type="scatter", mode= 'lines+markers') %>% 
        animation_slider(hide = TRUE) %>% animation_button(visible= FALSE) %>% config(displayModeBar = FALSE)
    })
    
    
  
    output$predicted_risk <- renderText({
  
      sex <- ifelse(input$sex == "Hombre", "Male", "Female")
      
      stroke <- ifelse(input$stroke, "Yes", "No")
      diabetic <- ifelse(input$diabetic, "Yes", "No")
      
      alcohol_drinking <- ifelse(input$alcohol_drinking, "Yes", "No")
      smoking <- ifelse(input$smoking, "Yes", "No")
      
      diff_walking <- ifelse(input$diff_walking, "Yes", "No")
      physical_activity <- ifelse(input$physical_activity, "Yes", "No")
      asthma <- ifelse(input$asthma, "Yes", "No")
      kidney_disease <- ifelse(input$kidney_disease, "Yes", "No")
      skin_cancer <- ifelse(input$skin_cancer, "Yes", "No")
    
      age_category <- input$age_category
    
      new_data <- data.frame(BMI = input$bmi,
                            Smoking = smoking,
                            AlcoholDrinking = alcohol_drinking,
                            Stroke = stroke,
                            PhysicalHealth = input$physical_health,
                            MentalHealth = input$mental_health, 
                            DiffWalking = diff_walking,    
                            Sex = sex,
                            AgeCategory = age_category,
                            Diabetic = diabetic,
                            PhysicalActivity = physical_activity,
                            SleepTime = 5,
                            Asthma= asthma,
                            KidneyDisease = kidney_disease,
                            SkinCancer = skin_cancer)
      
      print(new_data)
      prob_yes <- round(predict(model, new_data, type="prob")[2]*100,1)
      print(prob_yes)
      return(paste0(format(prob_yes, decimal.mark=",", big.mark = "."), "%"))
      
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
