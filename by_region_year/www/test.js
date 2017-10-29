Shiny.addCustomMessageHandler("jsondata",

function(message){

	var json_data = message;

	//global variables
	var keyArray = ["count","population","rateper100K"];

	document.write(json_data.count)});

