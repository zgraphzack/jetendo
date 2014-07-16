
zArrDeferredFunctions.push(function(){
	if(zIsTouchscreen()){
		 $(".zPhoneLink").each(function(){
			this.href="tel:"+this.innerText;
		 });
	}
});

function gotoReimport(){
	var d2=document.getElementById('mls_id1');
	var d1=d2.options[d2.selectedIndex].value;
	if(d1 !== ''){
		window.open('/z/listing/idx/reimport?mls_id='+d1);
		return false;
	}
}
function gotoFieldNotOutput(){
	var d2=document.getElementById('mls_provider1');
	var d1=d2.options[d2.selectedIndex].value;
	if(d1 !== ''){
		window.open('/z/listing/admin/listing-misc/index?mlsName='+d1);
		return false;
	}
}
function gotoSite(id){
	if(id !== ''){
		window.location.href='/z/server-manager/admin/robots/edit?sid='+escape(id);
	}
}

function setHidden(obj, row){
	me = eval("document.myForm.log_resolver"+row);
	if(obj.checked){
		me.disabled = false;
	}else{
		me.disabled = true;
	}
}
var zIntervalIdForCFCExplorer=0;
function resize_iframe()
{
	clearInterval(zIntervalIdForCFCExplorer);
	var height=window.innerWidth;//Firefox
	if (document.body.clientHeight)
	{
		height=document.body.clientHeight;//IE
	}
	//resize the iframe according to the size of the
	//window (all these should be on the same line)
	if (document.getElementById("comframe")) {
		if (height > 0 && document.getElementById("comframe").offsetTop) {
			var newh = parseInt(height - document.getElementById("comframe").offsetTop - (15));
			if (newh > 0) {
				document.getElementById("comframe").style.height = newh + "px";
			}
		}
	}
} 

function ajaxSaveSorting(){
	var arrId=$( "#sortable" ).sortable("toArray");
	for(var i=0;i<arrId.length;i++){
		arrId[i]=arrId[i].substr(5);
	}
	var link="/z/_com/app/image-library?method=saveSortingPositions&image_library_id="+currentImageLibraryId+"&image_id_list="+arrId.join(",");
	$.get(link, "",     function(data) { 
		if(debugImageLibrary) document.getElementById("forimagedata").value+="\n\nAJAX RESULT:\n"+data+"\n"; 
			var d=document.getElementById("sortable");
			$("#imageLibraryDivCount", window.parent.document).html($("li", d).length+" images in library");
		},     "html");  

	if(debugImageLibrary) document.getElementById("forimagedata").value+="ajaxSaveSorting(): array of image_id:\n"+arrId+"\nLINK:"+link;
}
function ajaxSaveImage(id){
	if(debugImageLibrary) document.getElementById("forimagedata").value+="ajaxSaveImage(): image_id:"+id+"\n";
	var link="/z/_com/app/image-library?method=saveImageId&action=update&image_library_id="+currentImageLibraryId+"&image_id="+id+"&image_caption="+escape(document.getElementById('caption'+id).value);
	if(debugImageLibrary) document.getElementById("forimagedata").value+="\n\n"+link+"\n\n";
	$.get(link, "",     function(data) { if(debugImageLibrary) document.getElementById("forimagedata").value+="\n\nAJAX SAVE IMAGE RESULT:\n"+data+"\n"; },     "html");  
}

function toggleImageCaptionUpdate(id,state,skipUpdate){
	var d=document.getElementById(id);
	var ajaxCall=false;
	if(d.style.display==="block" && state ==="none"){
		ajaxCall=true;	
	}
	var image_id=id.substr("imagecaptionupdate".length);
	d.style.display=state; 
	if(ajaxCall && typeof arrImageLibraryCaptions[image_id] !== "undefined" && arrImageLibraryCaptions[image_id] !== document.getElementById("caption"+image_id).value){
		ajaxSaveImage(image_id);
		arrImageLibraryCaptions[image_id]=document.getElementById("caption"+image_id).value;
	}
}
function confirmDeleteImageId(id){
	if(window.confirm("Are you sure you want to PERMANENTLY DELETE this image?")){
		deleteImageId(id);	
	}
}
function deleteImageId(id){
	var d = document.getElementById('sortable');
	var olddiv = document.getElementById("image"+id);
	d.removeChild(olddiv);
	var link="/z/_com/app/image-library?method=remoteDeleteImageId&image_id="+id;
	if(debugImageLibrary) document.getElementById("forimagedata").value+="\nDelete Image ID:"+id+"\n\n"+link+"\n\n";
	$.get(link, "",     function(data) { if(debugImageLibrary) document.getElementById("forimagedata").value+="\n\nAJAX DELETE IMAGE RESULT:\n"+data+"\n"; },     "html"); 
	ajaxSaveSorting();
}
function setUploadField(){
	var hasFlash = false;
	return;
	try {
		var fo = new ActiveXObject('ShockwaveFlash.ShockwaveFlash');
		if(fo) hasFlash = true;
	}catch(e){
		if(navigator.mimeTypes ["application/x-shockwave-flash"] !== "undefined") hasFlash = true;
	}
	var d = document.getElementById("imagefiles");
	// temporarily disable html 5 multiple file upload until Railo has fixed the bug with it.
	if(1===0){// typeof d.multiple === "boolean" || !hasFlash){
		document.getElementById("flashFileUpload").style.display="none";
	}else{
		document.getElementById("htmlFileUpload").style.display="none";
		document.getElementById("flashFileUpload").style.display="block";
	}
}

   


function getAgentLeads(user_id){
	var siteIdType=agentSiteIdTypeLookup[user_id];
	if(user_id !== ''){
		window.location.href = '/z/inquiries/admin/manage-inquiries/index?agentuserid='+user_id+'&agentusersiteIdType='+siteIdType;
	}else{
		window.location.href = '/z/inquiries/admin/manage-inquiries/index?agentuserid=&agentusersiteidtype=1';
	}
}

// start video-library
var debugVideoLibrary=false;
var arrVideoLibrary=new Object();
var zVideoLibraryIntervalId=false;
var arrCurVideo=[];
var arrQueueVideoMap=[];
var progressBarWidth=100;		
var arrProgressVideo=[];
var videoSortingStarted=false;
var videoSortingChanged=false; 
var currentVideoLibraryId="";
var arrVideoLibraryCaptions=new Array();
var zVideoJsEmbedded=false;
var zVideoJsEmbedIndex=0;

function zAjaxDeleteVideoCallback(r){
	var r2=eval('(' + r + ')');
	if(r2.success){
		var t=arrVideoLibraryComplete[r2.libraryId];
		
		var d=document.getElementById("sortable");
		d.removeChild(arrVideoLibraryComplete[r2.libraryId].NewLI);
		delete arrVideoLibraryComplete[r2.libraryId];
	}else{
		alert('Failed to delete video.');
	}
}
function zDeleteVideo(libraryId){
	var t=arrVideoLibraryComplete[libraryId];
	var r=confirm("Are you sure you want to delete: "+t.name);
	if (r===true){
		//document.getElementById('embedVideoDiv').innerHTML="";
		//document.getElementById('embedMenuDiv').style.display="none";
		var tempObj={};
		tempObj.id="zAjaxDeleteVideo";
		tempObj.url="/z/_com/app/video-library?method=deleteVideo&video_id="+t.video_id+"&libraryid="+libraryId;
		tempObj.cache=false;
		tempObj.callback=zAjaxDeleteVideoCallback;
		tempObj.ignoreOldRequests=false;
		zAjax(tempObj);	
	}
}
function zAjaxSaveQueueToVideoCallback(r){
	var r2=eval('(' + r + ')');
	if(r2.success === false){
		alert("Failed to save video to database.");	
		return;
	}
	var uploadId=arrQueueVideoMap[r2.queue_id];
	arrVideoLibrary[uploadId].width=r2.video_width;
	arrVideoLibrary[uploadId].height=r2.video_height;
	arrVideoLibrary[uploadId].video_id=r2.video_id;
	document.getElementById('divprogressbar'+uploadId).style.display="none";
	arrVideoLibrary[uploadId].divProgressBg.style.display="none";
	arrVideoLibrary[uploadId].divProgressBg2.style.display="none";
	arrVideoLibrary[uploadId].divProgressName.innerHTML+=' | <a href="#" onclick="showEmbedOptions(\''+uploadId+'\'); return false;">Embed</a> | <a href="#" onclick="zDeleteVideo(\''+uploadId+'\'); return false;">Delete</a>';
	
	arrVideoLibraryComplete[uploadId]=arrVideoLibrary[uploadId];
}
function zFixVideoObject(t){
	t.divVideoError=document.getElementById('divvideoerror'+t.id);
	t.divProgressName=document.getElementById('divprogressname'+t.id);
	t.divProgress=document.getElementById('divprogress'+t.id);
	t.divProgressBg=document.getElementById('divprogressbg'+t.id);
	t.divProgressBg2=document.getElementById('divprogressbg2'+t.id);
}

function zAjaxEncodeProgressCallback(r){
	var r2=eval('(' + r + ')');
	var a9=[];
	for(var i=0;i<r2.arrVideos.length;i++){
		r=r2.arrVideos[i];
		var uploadId=arrQueueVideoMap[r.queue_id];
		var t=arrVideoLibrary[uploadId];
		zFixVideoObject(t);
		var curDate=new Date();
		var mult=(100/Math.max(0.01,r.percent));
		var etaTime=mult*(curDate.getTime()-t.startEncodeDate.getTime());
		var dTime=(curDate.getTime()-t.startEncodeDate.getTime())/1000;
		var remainingTime=Math.round(Math.round(((etaTime-(curDate.getTime()-t.startEncodeDate.getTime()))/1000)*100)/100);
		if(r.status === 2){
			t.divVideoError.innerHTML='There was an error encoding the video, please try again or contact the webmaster for assistance. Cause: '+r.errorMessage;
		}else if(r.percent === 100){
			if(r.previewImage){
				$("#divprogressbar"+t.id).css("float", "none");
				t.divProgress.style.width="110px";
				t.divProgress.style.cssFloat="left";
				t.divProgress.innerHTML='<img src="/zupload/video/'+r.filename+'-00001.jpg" width="100" alt="Video" />';
				t.posterImage='/zupload/video/'+r.filename+'-00001.jpg';
			}else{
				t.divProgress.innerHTML='Complete - Image Preview Not Available';
				t.posterImage=false;
			}
			$("#divprogress2_"+t.id).html("Encoding complete.");
			t.divProgressName.style.width="80%";
			t.divProgressName.style.cssFloat="left";
			t.videoFile='/zupload/video/'+r.filename;
			var tempObj={};
			tempObj.id="zAjaxSaveQueueToVideo";
			tempObj.url="/z/_com/app/video-library?method=saveQueueToVideo&queue_id="+r.queue_id;
			tempObj.cache=false;
			tempObj.callback=zAjaxSaveQueueToVideoCallback;
			tempObj.ignoreOldRequests=false;
			zAjax(tempObj);	
		}else{
			if(r.percent === 0){
				remainingTime='Calculating';
			}
			$("#divprogress2_"+t.id).html('Encoding | Progress: '+r.percent+'% | Seconds remaining: '+(remainingTime));
		}
		t.divProgressBg2.style.width=Math.round((r.percent/100)*progressBarWidth)+"px";
		if(r.percent < 100){
			for(var n=0;n<arrProgressVideo.length;n++){
				if(arrProgressVideo[n] === parseInt(r.queue_id)){
					a9.push(arrProgressVideo[n]);
					break;
				}
			}
		}
	}
	arrProgressVideo=a9;
	if(a9.length===0 && zVideoLibraryIntervalId!==false){
		clearInterval(zVideoLibraryIntervalId);
		zVideoLibraryIntervalId=false;
		
	}
}
function zAjaxEncodeProgress(){
	var tempObj={};
	tempObj.id="zAjaxVideoEncodeProgress";
	tempObj.url="/z/_com/app/video-library?method=videoencodeprogress&queue_id_list="+arrProgressVideo.join(",");
	tempObj.cache=false;
	tempObj.callback=zAjaxEncodeProgressCallback;
	tempObj.ignoreOldRequests=false;
	zAjax(tempObj);	
}
function zAjaxEncodeCancelCallback(r){
	var r2=eval('(' + r + ')');
	for(var i in arrVideoLibrary){
		var c=arrVideoLibrary[i];
		if(typeof c.video_id !== "undefined"){
			continue;
		}
		var d=document.getElementById("sortable");
		d.removeChild(c.NewLI);
		delete arrVideoLibrary[i];
	}
	if(zVideoLibraryIntervalId!==false){
		clearInterval(zVideoLibraryIntervalId);
		zVideoLibraryIntervalId=false;
	}
	arrVideoLibrary=[];
	arrProgressVideo=[];
}
function cancelEncoding(){
	if(arrProgressVideo.length === 0){
		alert('No videos are currently being encoded.'); 
		return;
	}
	var tempObj={};
	tempObj.id="zAjaxVideoEncodeCancel";
	tempObj.url="/z/_com/app/video-library?method=videoencodecancel&queue_id_list="+arrProgressVideo.join(",");
	tempObj.cache=false;
	tempObj.callback=zAjaxEncodeCancelCallback;
	tempObj.ignoreOldRequests=false;
	zAjax(tempObj);	
		
}
		
function myUploadSuccess(obj, serverData){ 
	var r2=eval('(' + serverData + ')'); 
	//alert(serverData);
	var ac=arrCurVideo;
	arrCurVideo=[];
	//alert(ac);
	for(var i=0;i<r2.arrVideos.length;i++){
		var r=r2.arrVideos[i];
		if(r.success===false){
			alert(r.message);
			continue;
		}
		arrProgressVideo.push(parseInt(r.queue_id));
		arrQueueVideoMap[parseInt(r.queue_id)]=ac[i];
		arrVideoLibrary[ac[i]].startEncodeDate=new Date();
		arrVideoLibrary[ac[i]].width=r.width;
		arrVideoLibrary[ac[i]].height=r.height;
		arrVideoLibrary[ac[i]].divProgressName.innerHTML=r.video_file;
	}
	clearInterval(zVideoLibraryIntervalId);
	zVideoLibraryIntervalId=setInterval(function(){zAjaxEncodeProgress();},1000);
}
function myUploadError(obj, serverData,s3){			
	alert('Upload Cancelled');//:'+obj.name+" | "+serverData+" | "+s3);	
}
function zAjaxKeepSessionActiveCallback(file, serverdata){
	// do nothing	
}
function keepSessionActive(){ 
	var tempObj={};
	tempObj.id="zKeepSessionActive";
	tempObj.url="/z/_com/app/video-library?method=videokeepsessionactive";
	tempObj.cache=false;
	tempObj.callback=zAjaxKeepSessionActiveCallback;
	tempObj.ignoreOldRequests=false;
	zAjax(tempObj);	
}
	
function ajaxSaveVideo(id){
	if(debugVideoLibrary) document.getElementById("forvideodata").value+="ajaxSaveVideo(): video_id:"+id+"\n";
	var link="/z/_com/app/video-library?method=saveVideoId&action=update&video_library_id="+currentVideoLibraryId+"&video_id="+id+"&video_caption="+escape(document.getElementById('caption'+id).value);
	if(debugVideoLibrary) document.getElementById("forvideodata").value+="\n\n"+link+"\n\n";
	$.get(link, "",     function(data) { if(debugVideoLibrary) document.getElementById("forvideodata").value+="\n\nAJAX SAVE IMAGE RESULT:\n"+data+"\n"; },     "html");  
}
 
function videoModalClose(){
	var embedVideoDiv=document.getElementById('embedVideoDiv');
	embedVideoDiv.innerHTML="";
}

function showEmbedOptions(libraryid){
	var modalContent1=embedCode;		
	zArrModalCloseFunctions.push(videoModalClose);
	zShowModal(modalContent1,{'width':Math.min(1920, zWindowSize.width-50),'height':Math.min(1080, zWindowSize.height-50),"maxWidth":1920, "maxHeight":1080});
	var titleDiv=document.getElementById('embedMenuDivTitle');
	titleDiv.innerHTML=arrVideoLibraryComplete[libraryid].name;
	document.getElementById('video_embed_id').value=libraryid;
	document.getElementById('video_embed_width').value=arrVideoLibraryComplete[libraryid].width;
	document.getElementById('video_embed_height').value=arrVideoLibraryComplete[libraryid].height;
}
function generateEmbedCode(){
	var libraryid = document.getElementById('video_embed_id').value;
	var t=arrVideoLibraryComplete[libraryid];
	var video_embed_width=document.getElementById('video_embed_width').value;
	var video_embed_height=document.getElementById('video_embed_height').value;
	var video_embed_autoplay=0;
	if(document.getElementById('video_embed_autoplay1').checked){
		video_embed_autoplay=1;
	}
	var video_embed_viewing_method=0;
	if(document.getElementById('video_embed_viewing_method_name1').checked){
		video_embed_viewing_method=1;
	}else if(document.getElementById('video_embed_viewing_method_name2').checked){
		video_embed_viewing_method=2;
	}
	var embedCodeTr=document.getElementById('embedCodeTr');
	embedCodeTr.style.display="block";
	var embedTextarea=document.getElementById('embedTextarea');
	
	if(zVideoJsEmbedded===false){
		zVideoJsEmbedded=true;
	}
	zVideoJsEmbedIndex++;
	
	t.video_hash=t.videoFile.split("-")[1].substr(0,32);
	var autoplay=0;
	if(video_embed_autoplay === 1){
		autoplay=1;
	}
	
	var s='<iframe src="'+zVideoJSDomain+'/z/misc/embed/video/'+t.video_id+'-'+t.video_hash+'-'+video_embed_width+'-'+video_embed_height+'-'+autoplay+'-0-0-0-0"  style="margin:0px; border:none; overflow:auto;" seamless="seamless" width="'+video_embed_width+'" height="'+video_embed_height+'"></iframe>';
	 
	embedTextarea.value=s;
	var embedVideoDiv=document.getElementById('embedVideoDiv');
	embedVideoDiv.innerHTML=s;
}
// end video-library

function zOS_mode_check(){
	if(document.zOS_mode_form.zOS_modeVarDumpName){
		if(document.zOS_mode_form.zOS_modeVarDumpName.value.length !== 0){
			document.zOS_mode_form.zOS_mode.value = 'varDump';
			document.zOS_mode_form.zOS_modeValue.value = 'true';					
		}
	}
	return true;
}
function zURLAppend(theLink, appendString){
	if(theLink.indexOf("?") !== -1){
		return theLink+"&"+appendString;
	}else{
		return theLink+"?"+appendString;
	}
}
function zOS_mode_submit(mode, value, value2, value3){
	var theform=document.getElementById("zOS_mode_form");
	var theaction=theform.getAttribute("action");
	if(mode === 'viewMeta'){
		document.getElementById("zOS_modeVarDumpName").value = 'request.zos.templateData.tagContent';
		mode = 'varDump';
	}
	if(typeof value3 === "undefined"){ value3=""; }
	document.getElementById("zOS_mode").setAttribute("value", mode);
	document.getElementById("zOS_modeValue").setAttribute("value", value);
	if(mode === 'viewAsXML'){
		theaction=zURLAppend(theaction, 'zOS_viewAsXML=1'+value3);
	}
	if(mode === 'validateXHTML' && value2 !== "undefined"){
		theaction=zURLAppend(theaction, 'zOS_viewXHTMLError=1'+value3);
	}
	if(mode === 'reset'){
		theaction=zURLAppend(theaction, 'zReset='+value2+value3);
	}
	theform.setAttribute("action", theaction);
	theform.submit();
}
function zOS_mode_status(){
	window.status = 'Warning: All variables will be reposted.';
}
function zOS_mode_status_off(){
	window.status = '';
}
function zOS_mode_hide(){
	var el = document.getElementById("zOS_mode_table_tag");
	el.style.display='none';
}
function zOS_mode_show(){
	var el = document.getElementById("zOS_mode_table_tag");
	el.style.display='block';
}


function rentalForceReserve(obj){
	if(obj.value === "0" && obj.checked){
		var d=document.getElementById("rental_config_reserve_online_name2");
		d.checked=true;
	}
}
function rentalForceCalendar(obj){
	if(obj.value === "1" && obj.checked){
		var d=document.getElementById("rental_config_availability_calendar_name1");
		d.checked=true;
	}
}

var zArrURLParam=[];
function zParseURLParam() {
    var match,
        pl     = /\+/g,  // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g,
        decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
        query  = window.location.search.substring(1);

    zArrURLParam = {};
    while (true){
		match = search.exec(query);
		if(match){
			zArrURLParam[decode(match[1])] = decode(match[2]);
		}else{
			break;
		}
	}
}
zArrDeferredFunctions.push(function(){
	$(window).bind("popstate", zParseURLParam);
	zParseURLParam();
});



var searchCriteriaTrackSubGroup=[];

function clickSearchCriteriaSubGroup(obj){
	groupId=parseInt(obj.target.getAttribute("data-group-id"));
	$(".zSearchCriteriaSubGroup").each(function(){
		var currentGroupId=parseInt(this.getAttribute("data-group-id"));
		if(typeof searchCriteriaTrackSubGroup[currentGroupId] === "undefined"){
			searchCriteriaTrackSubGroup[currentGroupId]={};
			if(document.getElementById("zSearchCriteriaSubGroupContainer"+currentGroupId).style.display=== "block"){
				searchCriteriaTrackSubGroup[currentGroupId].open=true;
			}else{
				searchCriteriaTrackSubGroup[currentGroupId].open=false;
			}
		}
		if(currentGroupId === groupId){
			if(currentGroupId !== groupId || searchCriteriaTrackSubGroup[currentGroupId].open){
				// close the group.
				$("#zSearchCriteriaSubGroupContainer"+currentGroupId).slideUp("fast");
				searchCriteriaTrackSubGroup[currentGroupId].open=false;
				$("#zSearchCriteriaSubGroupToggle"+currentGroupId).html("+");
			}else{
				$("#zSearchCriteriaSubGroupContainer"+currentGroupId).slideDown("fast");
				searchCriteriaTrackSubGroup[currentGroupId].open=true;
				$("#zSearchCriteriaSubGroupToggle"+currentGroupId).html("-");
			}
		}
	});
	return false;
	//searchCriteriaTrackSubGroup	
}
var searchResultsTimeoutID=0;
var searchCriteriaTimeoutID=0;
var searchDisableJump=false;
function ajaxSearchResultsCallback(r){
	clearTimeout(searchResultsTimeoutID);
	var searchForm=$("#zSearchResultsDiv");
	searchForm.fadeIn('fast');
	// uncomment next line to debug easier
	//searchForm.html(r);return;
	var r2=eval('(' + r + ')');
	if(r2.success){ 
		searchForm.html(r2.html);
	}else{
		searchForm.html(r2.errorMessage);
	}
	if(!searchDisableJump){
		zJumpToId("zSearchTitleDiv", -20);
	}
	searchDisableJump=false;
}
var delayedSearchResultsTimeoutId=0;
function getDelayedSearchResults(){
	$("#zSearchTrackerzIndex").val(1);
	clearTimeout(delayedSearchResultsTimeoutId);
	searchDisableJump=true;
	delayedSearchResultsTimeoutId=setTimeout(getSearchResults, 500);
}
function getSearchResults(groupId, zIndex){
	if(typeof groupId === "undefined"){
		groupId=$("#zSearchTrackerGroupId").val();
	}
	if(typeof zIndex=== "undefined"){
		zIndex=$("#zSearchTrackerzIndex").val();
	}
	var tempObj={};
	$("#zSearchTrackerGroupId").val(groupId);
	$("#zSearchTrackerzIndex").val(zIndex);
	tempObj.id="ajaxGetSearchResults";
	tempObj.postObj=zGetFormDataByFormId("searchForm"+groupId);
	tempObj.postObj.groupId=groupId;
	tempObj.postObj.zIndex=zIndex;
	tempObj.postObj.disableSidebar=$("#zSearchFormDiv").attr("data-disable-sidebar");
	
	searchResultsTimeoutID=setTimeout(function(){
		$("#zSearchResultsDiv").html("One moment while we load your search results.");
	}, 500);
	if(groupId === 0){
		if($("#zSearchTextInput").length){
			tempObj.postObj.searchtext=$("#zSearchTextInput").val();
		}
	}else{
		
	}
	tempObj.method="post";
	tempObj.url="/z/misc/search-site/ajaxGetPublicSearchResults";
	
	tempObj.cache=false;
	tempObj.callback=ajaxSearchResultsCallback;
	tempObj.ignoreOldRequests=true;
	zAjax(tempObj);
	if(document.getElementById('contenttop')){
		window.location.href='#contenttop';
	}else{
		var d=$('h1').first();
		if(d.length){
			if(d[0].id===""){
				d[0].id="zHeadingSearchTopLinkId";
			}
			window.location.href='#'+d[0].id;
		}else{
			window.scrollTo(0, 0);
		}
	}
}
function zSearchCriteriaSetupSubGroupButtons(){
		$(".zSearchCriteriaSubGroup").bind("click", clickSearchCriteriaSubGroup);
		$(".zSearchCriteriaSubGroupToggle").bind("click", clickSearchCriteriaSubGroup);
		$(".zSearchCriteriaSubGroupLabel").bind("click", clickSearchCriteriaSubGroup);
	
}
function ajaxSearchCriteriaCallback(r){
	clearTimeout(searchCriteriaTimeoutID);
	var r2=eval('(' + r + ')');
	var searchForm=$("#zSearchFormDiv");
	var searchTitle=$("#zSearchTitleDiv");
	if(r2.success){ 
		searchTitle.html(r2.title);
		searchForm.html(r2.html);
		zSearchCriteriaSetupSubGroupButtons();
		if(r2.groupId === "0"){
			if($("#zSearchTextInput").val() === ""){
				return;
			}
		}
		getSearchResults(r2.groupId, r2.zIndex);
	}else{
		searchForm.html(r2.errorMessage);
	}
}
function getSearchCriteria(groupId, clearCache){
	if(typeof clearCache === "undefined"){
		clearCache=false;
	}
	$("#zSearchTrackerzIndex").val(1);
	$("#zSearchTabDiv a").each(function(){
		currentGroupId=parseInt(this.getAttribute("data-groupId"));
		
		if(groupId===currentGroupId){
			$(this).addClass("zSearchTabDivSelected");
		}else{
			$(this).removeClass("zSearchTabDivSelected");
		}
	});
	searchCriteriaTimeoutID=setTimeout(function(){
		$("#zSearchFormDiv").html("One moment while we load the search form.");
	}, 500);
	
	var tempObj={};
	tempObj.id="ajaxGetSearchCriteria";
	tempObj.url="/z/misc/search-site/ajaxGetPublicSearchCriteria?groupId="+encodeURIComponent(groupId)+"&clearCache="+encodeURIComponent(clearCache);
	
	tempObj.cache=false;
	tempObj.callback=ajaxSearchCriteriaCallback;
	tempObj.ignoreOldRequests=true;
	zAjax(tempObj);
}
function reloadResultsIfBackDetected(){
	var zSearchGroupId=$("#zSearchTrackerGroupId").val();
	if(zSearchGroupId!==""){
		getSearchCriteria(zSearchGroupId);
	}
}

function zFormatDollar(num) {
	var p = num.toFixed(2).split(".");
	return ["$", p[0].split("").reverse().reduce(function(acc, num, i) {
		return num + (i && !(i % 3) ? "," : "") + acc;
	}, "."), p[1]].join("");
}
function zGetPMIRate(loanYears, loanToValue){
	if(loanToValue<0.8){
		return 100;	
	}
	if(loanYears===30){
		if(loanToValue>0.8 && loanToValue<=0.85){
			return 0.32;
		}else if(loanToValue>0.85 && loanToValue<=0.90){
			return 0.52;
		}else if(loanToValue>0.90 && loanToValue<=0.95){
			return 0.78;
		}else if(loanToValue>0.95 && loanToValue<=0.97){
			return 0.90;
		}else{
			return 0;
		}
	}else{
		if(loanToValue>0.8 && loanToValue<=0.85){
			return 0.19;
		}else if(loanToValue>0.85 && loanToValue<=0.90){
			return 0.23;
		}else if(loanToValue>0.90 && loanToValue<=0.95){
			return 0.26;
		}else if(loanToValue>0.95 && loanToValue<=0.97){
			return 0.79;
		}else{
			return 0;	
		}
	}
}
function zCalculateMonthlyPayment(){
	var homeprice=parseFloat(document.getElementById("homeprice").value);
	var percentdown=parseFloat(document.getElementById("percentdown").value);
	var loantype=document.getElementById("loantype");
	var loantypevalue=parseFloat(loantype.options[loantype.selectedIndex].value);	
	var currentrate=parseFloat(document.getElementById("currentrate").value);	
	var homeinsurance=parseFloat(document.getElementById("homeinsurance").value);	
	var hometax=parseFloat(document.getElementById("hometax").value);	
	var homehoa=parseFloat(document.getElementById("homehoa").value);	
	//var homepmi=document.getElementById("homepmi");
	var armEnabled=false;
	if(loantypevalue === 30.5){
		armEnabled=true;	
		loantypevalue=30;
	}
	
	var monthlyInsurance=homeinsurance/12;
	var monthlyTax=hometax/12;
	var results=document.getElementById("zMortgagePaymentResults");	
	arrT=[];
	var totalPayments=(loantypevalue*12); 
	var originalLoanBalance=homeprice-(homeprice*(percentdown/100)); 
	
	var monthlyInterestRate=(currentrate/100)/12;
	var payment = (monthlyInterestRate * originalLoanBalance*Math.pow(1 + monthlyInterestRate,totalPayments)) / (Math.pow(1 + monthlyInterestRate, totalPayments)-1);
	var interest=originalLoanBalance*monthlyInterestRate;
	var interestFormatted=zFormatDollar(Math.round(interest*100)/100);
	var principalFormatted=zFormatDollar(Math.round((payment-interest)*100)/100);
	
	var principalAndInterestFormatted=zFormatDollar(Math.round(payment*100)/100);
	
	var monthlyHoa=homehoa/12;
	var monthlyHoaFormatted=zFormatDollar(Math.round(monthlyHoa*100)/100);
	var monthlyInsuranceFormatted=zFormatDollar(Math.round(monthlyInsurance*100)/100);
	var monthlyTaxFormatted=zFormatDollar(Math.round(monthlyTax*100)/100);
	var loanToValue=originalLoanBalance/homeprice;
	var monthlyPMI=0;
	if(loanToValue>0.8){
		var pmiRate=zGetPMIRate(loantypevalue, loanToValue);
		if(pmiRate===0){
			alert("Loan to value must be 97% or less");	
			results.value="";
			return;
		}else if(pmiRate===100){
			monthlyPMI=0;
			var monthlyPMIFormatted="$0.00";
		}else{
			monthlyPMI=(originalLoanBalance*(pmiRate/100))/12;
			var monthlyPMIFormatted=zFormatDollar(Math.round(monthlyPMI*100)/100);
		}					
	}
	var paymentFormatted=zFormatDollar(Math.round((monthlyHoa+monthlyPMI+monthlyInsurance+monthlyTax+payment)*100)/100);
	arrHTML=['<span class="zMorgagePaymentTextTotal">'+paymentFormatted+"/month</span> (Principal+Interest+Tax+Insurance+PMI)<hr />"+principalAndInterestFormatted+" principal & interest<br />"+monthlyInsuranceFormatted+" Insurance<br />"+monthlyTaxFormatted+" Taxes<br />"+monthlyHoaFormatted+" HOA dues<br />"];
	if(loanToValue>0.8){
		arrHTML.push(monthlyPMIFormatted+" PMI");
	}
	results.innerHTML=arrHTML.join("");
}
