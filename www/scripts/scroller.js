// using d3 for convenience
var storyScroll = d3.select("#story-scroll");
var figure = storyScroll.select("figure");
//var flourishStory = figure.select("#flourish-story")
var article = storyScroll.select("article");
var step = article.selectAll(".step");


//var flourishStoryUrl =  new URL(flourishStory.attr("src"))
//flourishStoryUrl.hash = "" // Me quedo con la ruta de las story, sin la slide inicial.


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
    })
  
  }
  


// initialize the scrollama
var scroller = scrollama();

// generic window resize listener event
function handleResize() {
    // 1. update height of step elements
    var stepH = Math.floor(window.innerHeight * 1.1);
    step.style("height", stepH + "px");

    // 2. update height of graphic element
    var figureHeight = window.innerHeight * 0.8;
    var figureMarginTop = (window.innerHeight - figureHeight) / 2;

    figure
        .style("height", figureHeight + "px")
        .style("top", figureMarginTop + "px");

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

    var plotFrame = response.element.attributes["data-step"].nodeValue

    // update graphic based on step
    console.log("Response index:" + response.index + " - data-step: " + plotFrame)   
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
}

// kick things off
init();