
function zAjaxWalkscore(obj){
	var tempObj={};
	tempObj.id="zAjaxWalkScore";
	tempObj.url="/z/misc/walkscore/index?latitude="+obj.latitude+"&longitude="+obj.longitude;
	tempObj.cache=false;
	tempObj.callback=zAjaxWalkscoreCallback;
	tempObj.ignoreOldRequests=false;
	zAjax(tempObj);	
}
var zWalkscoreIndex=0;
function zAjaxWalkscoreCallback(r){
	var d1=document.getElementById("walkscore-div");
	var json=eval('(' + r + ')');
	//if we got a score
	if (json && json.status === 41) {
		d1.innerHTML='Walkscore not available';
		return;
	}else if (json && json.status === 1) {
		var htmlStr = 'Walk Score&#8482;: ' + json.walkscore + " Description: "+json.description;//'<a target="_blank" href="' + json.ws_link + '">Walk Score</a>&#8482;: ' + json.walkscore + " Description: "+json.description;
	}
	//if no score was available
	else if (json && json.status === 2) {
		var htmlStr = '';//'<a target="_blank" href="http://www.wal'+'kscore.com" rel="nofollow">Walk Score</a>&#8482;: <a target="_blank" href="' + json.ws_link + '">Get Score</a>';
	}else{
		d1=false;	
	}
	zWalkscoreIndex++;
	//make sure we have a place to put it:
	if (d1) { //if you want to wrap P tags around the html, can do that here before inserting into page element
		htmlStr = htmlStr + getWalkScoreInfoHtml(zWalkscoreIndex);
		d1.innerHTML = htmlStr;
	}
}
//show/hide the walkscore info window
function toggleWalkScoreInfo(index) {
	var infoElem = document.getElementById("walkscore-api-info" + index);
	if (infoElem && infoElem.style.display === "block")
		infoElem.style.display = "none";
	else if (infoElem)
		infoElem.style.display = "block";
}
function getWalkScoreInfoHtml(index) {
	return '<span id="walkscore-api-info' + index + '" class="walkscore-api-info" style="font-size:12px; padding-top:10px; display:block; float:left; clear:both;">Walk Score measures how walkable an address is based on the distance to nearby amenities. A score of 100 represents the most walkable area compared to other areas.<hr /></span></span>';// <a href="http://www.walkscore.com" target="_blank">Learn more</a>. <hr /></span></span>';
}