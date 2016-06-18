
var zGridEditor={
	uniqueOffset:0,
	currentGroupId:0,
	currentBoxId:0
};

function setCurrentGroup(obj){
	zGridEditor.currentGroupId=parseInt($(obj).attr("data-id"));
}
function setCurrentBox(obj){
	zGridEditor.currentBoxId=parseInt($(obj).attr("data-id"));
}

(function($, window, document, undefined){
	"use strict";

var uniqueOffset=0;
function getUniqueId(){
	uniqueOffset++;
	return uniqueOffset;
}

function setFormData(formId, formData){
	for(var field in formData){
		var value=formData[field];
		console.log(field+":"+value);
		if($("#"+field).hasClass("zBooleanRadio")){
			if(parseInt(value) == 1){
				$("#"+field+"1").prop("checked", true);
			}else{
				$("#"+field+"0").prop("checked", true);
			}
		}else{
			$("#"+field).val(value);
		}
	}
}


function saveGridGroup(){
	// gridData
	var groupData=zGetFormDataByFormId("gridGroupForm");  

	groupData.grid_id=parseInt(groupData.grid_id);
	groupData.grid_group_id=parseInt(groupData.grid_group_id);

	for(var i=0;i<gridData.groups.length;i++){
		var group=gridData.groups[i];
		if(group.clientSettings.id == zGridEditor.currentGroupId){
			for(var field in groupData){
				group.settings[field]=groupData[field];
			}
			break;
		}
	}
}

function saveGridBox(){
	// gridData 
	var boxData=zGetFormDataByFormId("gridBoxForm"); 

	boxData.grid_id=parseInt(boxData.grid_id);
	boxData.grid_group_id=parseInt(boxData.grid_group_id);
	boxData.grid_box_id=parseInt(boxData.grid_box_id);

	for(var i=0;i<gridData.groups.length;i++){
		var group=gridData.groups[i];
		if(group.clientSettings.id == zGridEditor.currentGroupId){
			for(var n=0;n<group.boxes.length;n++){
				var box=group.boxes[n];
				if(box.clientSettings.id == zGridEditor.currentBoxId){
					box.data=boxData;
					break;
				}
			}
			break;
		}
	}
}

function renderGridHTML(){

	var a=[];
	for(var i=0;i<gridData.groups.length;i++){
		var group=gridData.groups[i]; 
		a.push(renderGroupStart(group));
		for(var n=0;n<group.boxes.length;n++){
			var box=group.boxes[n];
			var b=renderBox(group, box);
			a.push(b);
		}
		a.push(renderGroupEnd(group));
	}
	$("#gridEditorContent").html(a.join("\n"));
}
/*
var boxSettings={
	"grid_box_image_intermediate": "",
	"grid_box_sort": 0,
	"grid_box_column_size": 2,
	"grid_id": 57,
	"grid_box_button_text": "",
	"grid_box_heading": "Heading",
	"grid_box_visible": "1",
	"grid_box_summary": "",
	"grid_box_image": "0", 
	"grid_box_button_url": "",
	"grid_box_id": 1,
	"grid_group_id": 1
};
var	groupSettings={
	"grid_group_box_border_radius": 0, 
	"grid_group_visible": "1",
	"grid_group_heading": "Heading",
	"grid_group_background_type": 0,
	"grid_group_children_center": "0",
	"grid_group_box_border": "",
	"grid_group_background_value": "",
	"grid_group_padding": "",
	"grid_group_box_background_value": "",
	"grid_id": 57,
	"grid_group_box_background_type": 0,
	"grid_group_text": "",
	"grid_group_column_count": 5,
	"grid_group_heading2": "Heading2",
	"grid_group_sort": 1,
	"grid_group_box_layout": 0,
	"grid_group_id": 1,
	"grid_group_section_center": "0"
}; */
var tab="\n";
function renderGroupStart(group){
	var bg=getBackgroundCode(group.settings.grid_group_id, group.settings.grid_group_background_type, group.settings.grid_group_background_value);
	var arrHTML=[];
	if(bg.css!=""){
		arrHTML.push('<style type="text/css">'+bg.css+'</style>');
	}
	arrHTML.push('<section id="gridGroupSection#group.settings.grid_group_id#" class="z-grid-group-section '+bg.class+'">');
	arrHTML.push(tab+'<div class="z-container">');
	if(parseInt(group.settings.grid_group_section_center)==1){
		arrHTML.push(tab+tab+'<div class="z-column z-text-center">');
	}else{
		arrHTML.push(tab+tab+'<div class="z-column">');
	}
	if(group.settings.grid_group_heading!=''){
		arrHTML.push(tab+tab+tab+'<div class="z-grid-group-heading">'+group.settings.grid_group_heading+'</div>');
	}
	if(group.settings.grid_group_heading2!=''){
		arrHTML.push(tab+tab+tab+'<div class="z-grid-group-heading2">'+group.settings.grid_group_heading2+'</div>');
	}
	if(group.settings.grid_group_text!=''){
		arrHTML.push(tab+tab+tab+'<div class="z-grid-group-text">'+group.settings.grid_group_text+'</div>');
	}
	arrHTML.push(tab+tab+'</div>');
	if(parseInt(group.settings.grid_group_children_center)==1){
		arrHTML.push(tab+tab+'<section class="z-grid-box-container z-center-children">');
	}else{
		arrHTML.push(tab+tab+'<section class="z-grid-box-container">');
	}
	return arrHTML.join("\n");
}
function renderGroupEnd(group){
	var arrHTML=[];
	arrHTML.push(tab+tab+'</section>');
	arrHTML.push(tab+'</div>');
	arrHTML.push('</section>');
	return arrHTML.join("\n");
}
function renderBox(group, box){ 
	var bg=getBackgroundCode(group.settings.grid_group_id, group.settings.grid_group_box_background_type, group.settings.grid_group_box_background_value);
	var arrHTML=[tab+tab+tab];
	if(bg.css!=""){
		arrHTML.push('<style type="text/css">'+bg.css+'</style>');
	}

	var arrHTML=[];
	arrHTML.push('<div id="gridBoxDiv#box.settings.grid_box_id#" class="z-#box.settings.grid_box_column_size#of#group.settings.grid_group_column_count#">');

	if(group.settings.grid_group_box_layout==1){
		return renderBoxLayout1(group, box);
	}else if(group.settings.grid_group_box_layout==2){
		return renderBoxLayout2(group, box);
	}else if(group.settings.grid_group_box_layout==3){
		return renderBoxLayout3(group, box);
	}else if(group.settings.grid_group_box_layout==4){
		return renderBoxLayout4(group, box);
	}else if(group.settings.grid_group_box_layout==5){
		return renderBoxLayout5(group, box);
	}else if(group.settings.grid_group_box_layout==6){
		return renderBoxLayout6(group, box);
	}else if(group.settings.grid_group_box_layout==7){
		return renderBoxLayout7(group, box);
	}
	return arrHTML.join("\n"+tab+tab+tab);
}

function renderBoxLayout1(arrHTML, group, box){
	// Vertical - Image / Heading / Heading 2 / Summary / Button 
	if(box.settings.grid_box_image_intermediate!=""){
		arrHTML.push(tab+'<div class="z-grid-image">');
		if(box.settings.grid_box_button_url!=""){
			arrHTML.push('<a href="'+box.settings.grid_box_image+'"><img src="'+box.settings.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.settings.grid_box_heading, '&', '&amp;')+'" /></a>');
		}else{
			arrHTML.push('<img src="'+box.settings.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.settings.grid_box_heading, '&', '&amp;')+'" />');
		}
		arrHTML.push('</div>');
	}
	if(box.settings.grid_box_heading!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-heading">');
		if(box.settings.grid_box_button_url!=""){
			arrHTML.push('<a href="'+box.settings.grid_box_button_url+'">'+box.settings.grid_box_heading+'</a>');
		}else{
			arrHTML.push(box.settings.grid_box_heading);
		}
		arrHTML.push('</div>');
	}
	if(box.settings.grid_box_summary!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-summary">'+box.settings.grid_box_summary+'</div>');
	}
	if(box.settings.grid_box_button_url!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-button">');
		arrHTML.push('<a href="'+box.settings.grid_box_button_url+'" class="z-grid-button-link z-button">'+box.settings.grid_box_button_text+'</a>');
		arrHTML.push('</div>');
	}
	arrHTML.push(tab+'</div>');
	arrHTML.push('</div>');
	return arrHTML;
}

function renderBoxLayout2(arrHTML, group, box){
	// Vertical - Heading / Image / Heading 2 / Summary / Button
	return arrHTML;
}

function renderBoxLayout3(arrHTML, group, box){
	// Vertical - Heading / Heading 2 / Image / Summary / Button
	return arrHTML;
}

function renderBoxLayout4(arrHTML, group, box){
	// Left: Image | Right: Heading / Heading 2 / Summary / Button
	return arrHTML;
}

function renderBoxLayout5(arrHTML, group, box){
	// Left: Heading / Heading 2 / Summary / Button | Right: Image
	return arrHTML;
}

function renderBoxLayout6(arrHTML, group, box){
	// Image with White Heading on Black Overlay
	return arrHTML;
}

function renderBoxLayout7(arrHTML, group, box){
	// Image with Black Heading on White Overlay
	return arrHTML;
}

function getBackgroundCode(id, backgroundType, backgroundValue){ 
	var arrClass=[];
	var arrCSS=[];
	if(backgroundType==1){ // White Overlay
		arrayAppend(arrClass, "z-bg-white");
	}else if(backgroundType==2){ // Black Overlay
		arrayAppend(arrClass, "z-bg-black");
	}else if(backgroundType==3){ // White 80% Overlay
		arrayAppend(arrClass, "z-bg-white-transparent");
	}else if(backgroundType==4){ // Black 80% Overlay
		arrayAppend(arrClass, "z-bg-black-transparent");
	}else if(backgroundType==5){ // Image and Color Picker
		var v=zStringReplaceAll(backgroundValue, ".backgroundClass{", "gridBackgroundInstance"+id+"{"); 
		arrayAppend(arrCSS, v);
	}else if(backgroundType==6){ // Color Picker
		arrayAppend(arrCSS, ".backgroundClass"+id+"{ background-color:#"+backgroundValue+"; }"); 
	}
	var rs={
		class:arrClass.join(" "),
		css:arrCSS.join(" ")
	};
	return rs;
}

// This function reads the DOM to find the current sort position of all groups and boxes. If a box or group is removed from the DOM, the underlying data will also be automtically removed by this function
function setSortOrder(){
	var arrGroup={};
	var boxGroups={};
	$(".z-grid-group").each(function(){
		var id=parseInt($(this).attr("data-id"));
		arrGroup.push(id);
		boxGroups[id]=[];

		$(".z-grid-box", this).each(function(){
			var id=parseInt($(this).attr("data-id"));
			boxGroups[id].push(id);
		});
	});
 	
 	var newGridData={
 		groups:[],
 		settings:{}
 	};
 	for(var i=0;i<arrGroup.length;i++){
 		var group=getGroupById(arrGroup[i]);
 		var newGroup={
 			settings:group.settings,
 			clientSettings:group.clientSettings,
 			boxes:[]
 		};
 		newGroup.settings.grid_group_sort=i;
 		for(var n=0;n<group.boxes.length;n++){
 			var box=getBoxById(group, group.boxes[n].clientSettings.id);
 			box.data.grid_box_sort=n;
 			newGroup.boxes.push(box);
 		}
 		newGridData.groups.push(newGroup);
 	}
 	gridData=newGridData;
}

function getGroupById(id){
	for(var i=0;i<gridData.groups.length;i++){
		var group=gridData.groups[i];
		if(group.clientSettings.id == id){
			return group;
		}
	}
	throw("Failed to getGroupById:"+id);
}
function getBoxById(group, id){
	for(var i=0;i<group.boxes.length;i++){
		var box=group.boxes[i];
		if(box.clientSettings.id == id){
			return box;
		}
	}
	throw("Failed to getGroupById:"+id);
}

function setupGroupForm(){
	var group=getGroupById(zGridEditor.currentGroupId);

	setFormData("gridGroupForm", group.settings); 
	$("#gridGroupForm .tabWaitButton").click("click", function(e){
		e.preventDefault();
	});
	$("#gridGroupForm .tabSaveButton").click("click", function(e){
		e.preventDefault();

		saveGridGroup();
	});
	$("#gridGroupForm .tabCancelButton").click("click", function(e){
		e.preventDefault();
	});
/*
	$("##gridGroupSaveButton").bind("click", function(){
		// update the main data structure

		// render

		// close modal
		zCloseModal();
	});
	$("##gridGroupCancelButton").bind("click", function(){
		// close modal
		zCloseModal();
	});*/
}
function setupBoxForm(){
	var group=getGroupById(zGridEditor.currentGroupId);
	var box=getGroupById(zGridEditor.currentBoxId);

	setFormData("gridGroupForm", group.settings); 
	setFormData("gridBoxForm", box.settings);
	if(parseInt(box.settings.grid_box_visible) == 1){
		$("#grid_box_visible1").prop("checked", true);
	}else{
		$("#grid_box_visible0").prop("checked", true);
	}

	group.settings.grid_group_column_count=parseInt(group.settings.grid_group_column_count);
	box.settings.grid_box_column_size=parseInt(box.settings.grid_box_column_size);

	var columnSize=document.getElementById("grid_box_column_size");
	for(var i=0;i<columnSize.options.length;i++){
		var n=columnSize.options[i];
		if(parseInt(n.value) > group.settings.grid_group_column_count){
			n.disabled=true;
		}else{
			n.disabled=false;
		}
	}
	$("#gridBoxForm .tabWaitButton").click("click", function(e){
		e.preventDefault();
	});
	$("#gridBoxForm .tabSaveButton").click("click", function(e){
		e.preventDefault();
	});
	$("#gridBoxForm .tabCancelButton").click("click", function(e){
		e.preventDefault();
	});
	/*
	$("##gridBoxSaveButton").bind("click", function(){
		// update the main data structure

		// render

		// close modal
		zCloseModal();
	});
	$("##gridBoxCancelButton").bind("click", function(){
		// close modal
		zCloseModal();
	});*/
}

function setupGridEditor(){

	for(var i=0;i<gridData.groups.length;i++){
		var group=gridData.groups[i]; 
		group.clientSettings={
			id:getUniqueId()
		};
		for(var n=0;n<group.boxes.length;n++){
			var box=group.boxes[n];
			box.clientSettings={
				id:getUniqueId()
			};
		}
	}
}

zArrDeferredFunctions.push(function(){

	$(".groupFormButton").bind("click", function(e){
		setCurrentGroup(this);
	});

	$(".boxFormButton").bind("click", function(e){
		setCurrentBox(this);
	});
	/*
	setupGroupForm();
	setupBoxForm();
	*/
});

window.renderGridHTML=renderGridHTML;
})(jQuery, window, document, "undefined"); 