
var zlsHoverBox={
	box: false,
	boxPosition:false,
	panelPosition:false,
	button:{},
	displayType:"detail",
	firstLoad:true,
	changeDisplayType: function(g, g2){
		if(zlsHoverBox.button.grid.id===g.target.id){
			zlsHoverBox.displayType="grid";
			zlsHoverBox.button.grid.className=g.target.id+"-selected";
			zlsHoverBox.button.map.className="";
			zlsHoverBox.button.detail.className="";
			zlsHoverBox.button.list.className="";
			if(!zFunctionLoadStarted){
				document.getElementById('search_result_layout').selectedIndex=2;
				document.zMLSSearchForm.submit();
			}
		}else if(zlsHoverBox.button.list.id===g.target.id){
			zlsHoverBox.displayType="list";
			zlsHoverBox.button.list.className=g.target.id+"-selected";
			zlsHoverBox.button.map.className="";
			zlsHoverBox.button.detail.className="";
			zlsHoverBox.button.grid.className="";
			if(!zFunctionLoadStarted){
				document.getElementById('search_result_layout').selectedIndex=1;
				document.zMLSSearchForm.submit();
			}
		}else if(zlsHoverBox.button.map.id===g.target.id){
			zlsHoverBox.displayType="map";
			zlsHoverBox.button.map.className=g.target.id+"-selected";
			zlsHoverBox.button.detail.className="";
			zlsHoverBox.button.grid.className="";
			zlsHoverBox.button.list.className="";
		}else if(zlsHoverBox.button.detail.id===g.target.id){
			zlsHoverBox.displayType="detail";
			zlsHoverBox.button.map.className="";
			zlsHoverBox.button.detail.className=g.target.id+"-selected";
			zlsHoverBox.button.grid.className="";
			zlsHoverBox.button.list.className="";
			if(!zFunctionLoadStarted){
				document.getElementById('search_result_layout').selectedIndex=0;
				document.zMLSSearchForm.submit();
			}
		}
		//zSetCookie({key:"zlsHoverBoxDisplayType",value:zlsHoverBox.displayType,futureSeconds:60*60*7});
		//zlsHoverBox.showListings();
		return false;
	},
	showListings: function(){
		zScrollApp.appDisabled=false;
		zListingResetSearch();
		zlsHoverBox.closePanel();
		//zlsHoverBox.button.refine.innerText="Refine Search";
	}
};
zlsHoverBox.load=function(){
	var d=document.getElementById('zlsHoverBoxDisplayType');
	if(d === null){ return;}
	zlsHoverBox.displayType=d.value;
	zlsHoverBox.loaded=true;
	zlsHoverBox.debugInput=document.getElementById('dt21');
	zlsHoverBox.box=document.getElementById("zls-hover-box");
	zlsHoverBox.panel=document.getElementById("zls-hover-box-panel");
	zlsHoverBox.panelInner=document.getElementById("zls-hover-box-panel-inner");
	//zlsHoverBox.button.refine=document.getElementById("zls-hover-box-refine-button");
	zlsHoverBox.button.grid=document.getElementById("zls-hover-box-grid-button");
	zlsHoverBox.button.list=document.getElementById("zls-hover-box-list-button");
	zlsHoverBox.button.detail=document.getElementById("zls-hover-box-detail-button");
	zlsHoverBox.button.map=document.getElementById("zls-hover-box-map-button");
	//zlsHoverBox.button.refine.onclick=zlsHoverBox.togglePanel;
	zlsHoverBox.button.grid.onclick=function(){zlsHoverBox.changeDisplayType({target:zlsHoverBox.button.grid}); return false;};
	zlsHoverBox.button.list.onclick=function(){zlsHoverBox.changeDisplayType({target:zlsHoverBox.button.list}); return false;};
	zlsHoverBox.button.detail.onclick=function(){zlsHoverBox.changeDisplayType({target:zlsHoverBox.button.detail}); return false;};
	zlsHoverBox.button.map.onclick=function(){zlsHoverBox.changeDisplayType({target:zlsHoverBox.button.map}); return false;};
	zlsHoverBox.changeDisplayType({target:zlsHoverBox.button[zlsHoverBox.displayType]});
};
zArrLoadFunctions.push({functionName:zlsHoverBox.load});





var zlsHoverBoxNew={
	box: false,
	boxPosition:false,
	panelPosition:false,
	button:{},
	displayType:"grid",
	changeDisplayType: function(g, g2){
		if(zlsHoverBoxNew.button.grid.id===g.target.id){
			zlsHoverBoxNew.displayType="grid";
			zlsHoverBoxNew.button.grid.className=g.target.id+"-selected";
			//zlsHoverBoxNew.button.map.className="";
			//zlsHoverBoxNew.button.list.className="";
		}else if(zlsHoverBoxNew.button.list.id===g.target.id){
			zlsHoverBoxNew.displayType="list";
			//zlsHoverBoxNew.button.list.className=g.target.id+"-selected";
			//zlsHoverBoxNew.button.map.className="";
			zlsHoverBoxNew.button.grid.className="";
		}else if(zlsHoverBoxNew.button.map.id===g.target.id){
			zlsHoverBoxNew.displayType="map";
			//zlsHoverBoxNew.button.map.className=g.target.id+"-selected";
			zlsHoverBoxNew.button.grid.className="";
			//zlsHoverBoxNew.button.list.className="";
		}
		var futureSeconds=3600*7;
		zSetCookie({key:"zlsHoverBoxNewDisplayType",value:zlsHoverBoxNew.displayType,futureSeconds:futureSeconds});
		if(!zScrollApp.disableFirstAjaxLoad){
			zlsHoverBoxNew.showListings();
		}
		return false;
	},
	loaded:false,
	debugInput:false,
	load:function(){
		if(zlsHoverBoxNew.loaded) return;
		zlsHoverBoxNew.loaded=true;
		zlsHoverBoxNew.debugInput=document.getElementById('dt21');
		zlsHoverBoxNew.box=document.getElementById("zls-hover-box");
		zlsHoverBoxNew.panel=document.getElementById("zls-hover-box-panel");
		zlsHoverBoxNew.panelInner=document.getElementById("zls-hover-box-panel-inner");
		zlsHoverBoxNew.button.refine=document.getElementById("zls-hover-box-refine-button");
		zlsHoverBoxNew.button.grid=document.getElementById("zls-hover-box-grid-button");
		//zlsHoverBoxNew.button.list=document.getElementById("zls-hover-box-list-button");
		//zlsHoverBoxNew.button.map=document.getElementById("zls-hover-box-map-button");
		zlsHoverBoxNew.button.refine.onclick=zlsHoverBoxNew.togglePanel;
		//zlsHoverBoxNew.button.grid.onclick=zlsHoverBoxNew.changeDisplayType;
		//zlsHoverBoxNew.button.list.onclick=zlsHoverBoxNew.changeDisplayType;
		//zlsHoverBoxNew.button.map.onclick=zlsHoverBoxNew.changeDisplayType;
		var t=zGetCookie("zlsHoverBoxNewDisplayType");
		if(t !== ""){
		zlsHoverBoxNew.displayType=t;
		}
		zlsHoverBoxNew.debugInput.value="";
		//zlsHoverBoxNew.debugInput.value+="CookieDisplayType:"+zGetCookie("zlsHoverBoxNewDisplayType")+"\n";
		zlsHoverBoxNew.changeDisplayType({target:zlsHoverBoxNew.button[zlsHoverBoxNew.displayType]});
	},
	showListings: function(){
		zScrollApp.firstAjaxRequest=true;
		zScrollApp.appDisabled=false;
		zlsHoverBoxNew.closePanel();
		zlsHoverBoxNew.button.refine.innerHTML="Refine Search";
		zListingResetSearch();
	},
	closePanel: function(){
		if(zlsHoverBoxNew.panel.style.display==="block"){
			//zScrollApp.forceSmallHeight=50000;
			//drawVisibleRows(0,0);
			zScrollApp.scrollAreaDiv2.style.display="block";
			document.getElementById('zMapCanvas').style.display="block";
			document.getElementById('zMapCanvas3').style.display="block";
			var tempObj={'margin-top':-(zlsHoverBoxNew.panelPosition.height)+zlsHoverBoxNew.boxPosition.height};
			$(zlsHoverBoxNew.panel).animate(tempObj,'fast','easeInExpo', function(){zlsHoverBoxNew.panel.style.display="none"; });
		}
	},
	togglePanel: function(){
		if(zlsHoverBoxNew.panel.style.display==="block" && !zScrollApp.disableFirstAjaxLoad){
			zlsHoverBoxNew.showListings();
		}else{
			if(zIsTouchscreen()){
				zlsHoverBoxNew.box.style.top="0px";	
			}
			zlsHoverBoxNew.button.refine.innerHTML="Show Listings";
			zlsHoverBoxNew.panel.style.display="block";
			zlsHoverBoxNew.resizePanel();
			
			// disable the listing display
			zScrollApp.appDisabled=true;
			zScrollApp.scrollAreaDiv2.style.display="none";
			document.getElementById('zMapCanvas').style.display="none";
			document.getElementById('zMapCanvas3').style.display="none";
			
			//zScrollApp.forceSmallHeight=zWindowSize.height-zlsHoverBoxNew.boxPosition.height-30;
			//drawVisibleRows(0,0);
			
			if(zIsTouchscreen() || zScrollApp.disableFirstAjaxLoad){
				zlsHoverBoxNew.panel.style.marginTop=zlsHoverBoxNew.boxPosition.height+"px";
				window.scrollTo(0,1);
			}else{
				zlsHoverBoxNew.panel.style.marginTop=(-(zlsHoverBoxNew.panelPosition.height)+zlsHoverBoxNew.boxPosition.height)+"px";
				$(zlsHoverBoxNew.panel).animate({"margin-top":zlsHoverBoxNew.boxPosition.height},'fast','easeInExpo');
			}
		}
		return false;
	},
	lastBoxHeight:0,
	resizePanel: function(){
		if(!zlsHoverBoxNew.loaded) zlsHoverBoxNew.load();
		var nw=zWindowSize.width-10;
		var w=Math.min(1100,nw);
		var newLeft=Math.round((nw-w)/2);
		if(w>=1100){
			zlsHoverBoxNew.box.style.width=w+"px";
			zlsHoverBoxNew.box.style.marginLeft="-"+Math.floor(w/2)+"px";
		}else{
			zlsHoverBoxNew.box.style.width="97%";
			zlsHoverBoxNew.box.style.marginLeft="-49%";
		}
		//zlsHoverBoxNew.box.style.width=w+"px";
		zlsHoverBoxNew.box.style.display="block";
		zlsHoverBoxNew.boxPosition=zGetAbsPosition(zlsHoverBoxNew.box);
		if(zlsHoverBoxNew.panel.style.display==="block"){
			var nw=zWindowSize.width-10;
			var w=Math.min(1100,nw);
			var newLeft=Math.round((nw-w)/2);
			if(w>=1100){
				if(zlsHoverBoxNew.panel.style.width !== "1100px"){
					zlsHoverBoxNew.panel.style.width=w+"px";
					zlsHoverBoxNew.panel.style.marginLeft="-"+Math.floor(w/2)+"px";
				}
			}else{
				zlsHoverBoxNew.panel.style.width="97%";
				zlsHoverBoxNew.panel.style.marginLeft="-49%";
			}
			zlsHoverBoxNew.panelPosition=zGetAbsPosition(zlsHoverBoxNew.panel);
			//zlsHoverBoxNew.panelInnerPosition=zGetAbsPosition(zlsHoverBoxNew.panel);
			//var h=Math.min(zlsHoverBoxNew.panelInnerPosition.height,zWindowSize.height-zlsHoverBoxNew.boxPosition.height-30);
			if(zIsTouchscreen()){
				if(zIsAppleIOS()){
					zlsHoverBoxNew.box.style.position="absolute";
				}
				zlsHoverBoxNew.panel.style.position="absolute";
				zlsHoverBoxNew.panel.style.height="auto";
			}else{
				zlsHoverBoxNew.panel.style.height="90%";//h+"px";
			}
			if(zlsHoverBoxNew.lastBoxHeight !== 0 && zlsHoverBoxNew.lastBoxHeight !== zlsHoverBoxNew.boxPosition.height){
				zlsHoverBoxNew.panel.style.marginTop=(zlsHoverBoxNew.boxPosition.height)+"px";
			}
			zlsHoverBoxNew.lastBoxHeight=zlsHoverBoxNew.boxPosition.height;
				
			//alert(zlsHoverBoxNew.panelPosition.height+":"+zlsHoverBoxNew.boxPosition.height+":"+zlsHoverBoxNew.panel.style.marginTop);
		}
	}
};