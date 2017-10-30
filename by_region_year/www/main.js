Shiny.addCustomMessageHandler("jsondata",

function(message){

var json_data = message;
	//global variables
var keyArray = ["count","population","rateper100K"];
var expressed = keyArray[0];

//begin script when window loads
window.onload = initialize();

//the first function called once html is loaded
function initialize() {
	setMap();
};

//set chloropleth map parameters
function setMap(){
	//map frame dimensions
	var width = 960;
	var height = 700;

	//create a new svg element with the above dimensions
	var map = d3.select("#div_map")
			.append("svg")
			.attr("width", width)
			.attr("height", height);

	//create projection
	var projection = d3.geo.albers()
            .center([8.25, 41.88205])
            .parallels([40, 45])
            .scale(105000)
            .rotate([92.35, .5, -4])
            .translate([width / 2, height / 2]);

    //svg path generator
    var path = d3.geo.path()
    		.projection(projection);

    //use queue.js to parallelize data loading
    d3.queue()
    		.defer(d3.csv, "https://raw.githubusercontent.com/lydiajessup/Chicago-Crime-Map/master/data/crim2016.csv")
    		.defer(d3.json, "https://raw.githubusercontent.com/lydiajessup/Chicago-Crime-Map/master/data/community_areas.topojson") //load map
    		.await(callback);	

    function callback(error, crim2016, community_areas){
    	//variable for color
    	var recolorMap = colorScale(crim2016);

    	//variables for csv to json data transfer
    	var jsonCommunities = community_areas.objects.community_areas.geometries;

    	//loop through csv to assign each csv value to json community
    	for (var i = 0; i < crim2016.length; i++){
    		var csvCommunity = crim2016[i]; 	//the current community area
    		var csvCAnum = crim2016[i].ca_num;	 //community number in area
	
    		//loop through json community to find right community
    		for (var a = 0; a < jsonCommunities.length; a++) {

    			//where community number codes match, attach csv to json object
    			if (jsonCommunities[a].properties.area_num_1 == csvCAnum){

    			//assign all value pairs
    			for (var key in keyArray){
    				var attr = keyArray[key];
    				var val = parseFloat(csvCommunity[attr]);
    				jsonCommunities[a].properties[attr] = val;
    			};

    			jsonCommunities[a].properties.community = csvCommunity.community_area; //set prop
    			break;	// stop looking through json communities

    			};
    		};

    	};

    	//add communities to map as enumerated units colorted by data
    	var communities = map.selectAll(".communities")
    			.data(topojson.feature(community_areas, 
    					community_areas.objects.community_areas).features)
    			.enter()	//create elements
    			.append("path")	//append elements to svg
    			.attr("class", "communities")	//assing class for styling
    			.attr("id", function(d) {return d.properties.community })
    			.attr("d", path)	//project data as geometry
    			.style("stroke", "black")
    			.style("fill", function(d) {	//color units
    					return chloropleth(d, recolorMap);
    			})
    			.on("mouseover", highlight)
    			.on("mouseout", dehighlight)
    			//.on("mousemove", moveLabel)
    			.append("desc")	//append the current color
    				.text(function(d){
    					return chloropleth(d, recolorMap);
    			});

	          
    };



};


function colorScale(crim2016) {

	//create quantile classes with color scale
	var color = d3.scale.quantile()	//quantile scale generator
			.range([
				"#edf8fb",
				"#b3cde3",
				"#8c96c6",
				"#8856a7",
				"#810f7c"
			
			]);


//light blue      #edf8fb
//blueish purple  #b3cde3
//violet          #8c96c6
//purple          #8856a7
//brighter purple #810f7c

	//build an array of all currently expressed values for input domain
	var domainArray = [];
	for (var i in crim2016) {
			domainArray.push(Number(crim2016[i][expressed]));
	};

	//pass array of expressed values as domain
	color.domain(domainArray);

	return color;	//return the color scale generator
};

function chloropleth(d, recolorMap) {

	//get data value
	var value = d.properties[expressed];
	//if value exists, assign it a color. otherwise gray
	if (value) {
			return recolorMap(value);
	} else {
			return "#ccc"; 
	
	};
};

/*
//new function
function changeAttribute(attribute, crim2016) {
	//change the expressed attribute
	expressed = attribute;

	//recolor map
	d3.selectAll(".communities")	//select every region
			.style("fill", function(d) {	//color units
				return chloropleth(d, colorScale(crim2016));
			})
			.select("desc")	//replace teh color text in each desc element
				.text(function(d){
					return chloropleth(d, colorScale(crim2016));
				});
};
*/


function highlight(data){
	
	var props = data.properties; //json properties

	d3.select("#"+props.community) //select the current region in the DOM
		.style("fill", "#000"); //set the enumeration unit fill to black

	var labelAttribute = "<h1>"+props[expressed]+
		"</h1><br><b>"+expressed+"</b>"; //label content
	var labelName = props.community //html string for name to go in child div
	
	//create info label div
	var infolabel = d3.select("#div_map")
		.append("div") //create the label div
		.attr("class", "infolabel")
		.attr("id", props.adm1_code+"label") //for styling label
		.html(labelAttribute) //add text
		.append("div") //add child div for feature name
		.attr("class", "labelname") //for styling name
		.html(labelName); //add feature name to label
};


function dehighlight(data) {

	//json or csv properties
	var props = data.properties;	//json properties
	var comm = d3.select("#" + props.community); //select the current community
	var fillcolor = comm.select("desc").text();	//access original color from desc
	comm.style("fill", fillcolor);	//resent enumeration unit to original color

	d3.select("#" + props.community + "label").remove(); //remove info label

};
});
/*
function moveLabel() {

	var x = d3.event.clientX+10;	//horizontal label coordinate
	var y = d3.event.clientY-75;	//vertical label coordinate

	d3.select(".infolabel")	//select the label div for moving
		.style("margin-left", x+"px")	//reposition label horizontally
		.style("margin-top", y+"px");	//repositoin label verticlally
};
*/