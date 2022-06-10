// using d3 for convenience
var storyScroll = d3.select("#story-scroll");
var figure = storyScroll.select("figure");
var article = storyScroll.select("article");
var step = article.selectAll(".step");
var calculator = d3.select("#calculator");

var helpBlocks = calculator.selectAll(".help-block");


function animate(frameName) {

    frame = [frameName];

    Plotly.animate('storyPlot', frame, 
    {
      transition: {
        duration: 500,
        easing: 'cubic-in-out'
      },
  
      frame: {
        duration: 500
      }
    });
  
  }
  

// initialize the scrollama
var scroller = scrollama();

// generic window resize listener event
function handleResize() {
    // 1. update height of step elements
    var stepH = Math.floor(window.innerHeight * 1.1);
    step.style("height", stepH + "px");

    // 2. update height of graphic element
    var height = window.innerHeight * 0.8;
    var marginTop = (window.innerHeight - height) / 3;

    figure
        .style("height", height + "px")
        .style("top", marginTop + "px");
        
    calculator
        .style("height", height + "px")
        .style("top", marginTop + "px");
        
    // 3. tell scrollama to update new element dimensions
    scroller.resize();
}

// scrollama event handlers
function handleStepEnter(response) {
    console.log(response);
    // response = { element, direction, index }

    // add color to current step only
    /* step.classed("is-active", function (d, i) {
        return i === response.index;
    }); */

    var plotFrame = response.element.attributes["data-step"].nodeValue;

    // update graphic based on step
    console.log("Response index:" + response.index + " - data-step: " + plotFrame);
    animate(plotFrame);

}

function setupStickyfill() {
    d3.selectAll(".sticky").each(function () {
        Stickyfill.add(this);
    });
}

function init() {
    setupStickyfill();

    // 1. force a resize on load to ensure proper dimensions are sent to scrollama
    handleResize();

    // 2. setup the scroller passing options
    // 		this will also initialize trigger observations
    // 3. bind scrollama event handlers (this can be chained like below)
    scroller
        .setup({
            step: "#story-scroll article .step",
            offset: 0.75,
           // debug: true
        })
        .onStepEnter(handleStepEnter);
        
    // setup resize event
	  window.addEventListener('resize', handleResize);  
	  
	  //Evento para mostrar graficamente lo roto que está el corazón
	  $('#predicted_risk').on('shiny:value', function(event) {
      console.log(event.value);
      
      var stroke_width = 12 * parseFloat(event.value.replace(/,/, '.')) /100;
      console.log(stroke_width);
      
      d3.select("#broken_heart").style("stroke-width", stroke_width);
    });
	  
}

function showHideHelpText(){
  if (helpBlocks.style("display")=="none"){
     helpBlocks.style("display","block");
  } else{
     helpBlocks.style("display","none");
  }
}


// kick things off
init();