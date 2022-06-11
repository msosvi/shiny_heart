library(shiny)
library(bslib)
library(plotly)
library(shinyWidgets)
library(C50)

model <- readRDS("model.rds")


# Función para recuperar la categoría a la que pertenece una edad.
get_age_category <- local({
  ages_categories = c("18-24", "25-29", "30-34", "35-39","40-44","45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80 or older")
  ages_df <- data.frame(age=c(18:115))
  ages_df$age_category = cut(ages_df$age, c(18, 24, 29, 34, 39, 44, 49, 54, 59, 64, 69, 74, 79, 115), labels = ages_categories, include.lowest=TRUE, right = TRUE)  
  
  function(age){
    return(ages_df[ages_df$age==age, "age_category"])
  }
})



ui <- fluidPage(
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
        tags$style("@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@100;300;400;700');"),
        tags$link(href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.3/font/bootstrap-icons.css", rel="stylesheet", type="text/css")
    ),
    
    fluidRow(
      column(8, offset=2, 
          tags$section(id="intro", class="text-section",
              h1("¿Está tu corazón en riesgo?"),
              p(class="prose", "Los Objetivos de Desarrollo Sostenible de las Naciones Unidas son un plan para lograr un futuro mejor y más sostenible."),
              p(class="prose", "El Objetivo de Desarrollo Sostenible 7 es:"),
              p(class="prose", strong(em("Garantizar el acceso a una energía asequible, segura, sostenible y moderna para todas las personas."))),
              p(class="prose","¿Estamos cumpliendo el plan?")),
        
          tags$section(id="story",
              div(id="story-scroll", 
                  tags$figure(plotlyOutput(outputId = "storyPlot", height = "100%"),
                      tags$figcaption(em("Fuente de los datos:", strong("Personal Key Indicators of Heart Disease Dataset. Kaggle.com")))), 
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
                column(5, offset=1,
                  textOutput("predicted_risk")),
                column(2, offset=3, 
                  includeHTML("www/heart.svg")
                )
              )
            ),
            
            fluidRow(column(12, a(id="help-icon", class="bi bi-question-circle pull-right", onclick="showHideHelpText();"))),
            fluidRow(
              column(3,
                div(class = "calc-panel",
                  p(class = "calc-panel-title", "Pérfil"),        
                  radioButtons(inputId = "sex", label = "Sexo", choices = c("Hombre", "Mujer"), selected="Mujer", inline=TRUE),
                  sliderInput(inputId = "age", "Edad", min = 18, max = 115, value = 18 ),
                  )
              ),
              
                column(3,
                  div(class="calc-panel",
                    p("Estilo de Vida", class = "calc-panel-title", onclick="showHideHelpText();"),        
                    materialSwitch(inputId = "smoking", label = "Fumador", status = "danger"),  
                    helpText("¿Has fumado al menos 100 cigarrillos en su vida?"),
                   
                    materialSwitch(inputId = "alcohol_drinking", label = "Consulmo de alcohol", status = "danger"),
                    helpText("¿Bebes más de 14 bebidas a la semana si eres hombre o más de 7 si eres mujer?"),
                    
                    materialSwitch(inputId = "physical_activity", label = "Actividad física", status = "success"),
                    helpText("¿Has hecho ejercicio físico de forma habitual en los últimos 30 días."),
                    
                    sliderInput(inputId = "sleep_time", label="Horas de sueño", min = 0, max = 24, value = 8),
                    helpText("¿Cuántas horas duermes al día normalmente?")
                   
                  )
              ),
              
              
                column(3,
                  div(class="calc-panel",
                    p(class = "calc-panel-title", "Estado de Salud", onclik="showHideHelpText();"), 
                    sliderInput(inputId = "bmi", label="I.M.C.", min = 0, max = 100, value = 23),
                    helpText("Indice de masa corporal (IMC), indica si el peso es correcto en función de la estatura. ", 
                             "Se calcula dividiendo los kilogramos de peso por el cuadrado de la estatura en metros."),
                    
                    sliderInput(inputId = "physical_health", label="Salud física", min = 0, max = 30, value = 0),
                    helpText("Pensando en tu salud física, que incluye enfermedades y lesiones físicas, ", 
                             "¿durante cuántos días de los últimos 30 tu salud física no fue buena?"),
                    
                    sliderInput(inputId = "mental_health", label="Salud mental", min = 0, max = 30, value = 0),  
                    helpText("Pensando en tu salud mental, ", 
                             "¿durante cuántos días de los últimos 30 tu salud mental no fue buena?"),
                    
                    materialSwitch(inputId = "diff_walking", label = "Dificultad para caminar", status = "danger"),
                    helpText("¿Tienes serias dificultades para caminar o subir escaleras?")
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
    
      age_category <- get_age_category(input$age)
    
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
                            SleepTime = input$sleep_time,
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
