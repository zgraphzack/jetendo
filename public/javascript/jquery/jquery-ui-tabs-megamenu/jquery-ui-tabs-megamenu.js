
(function($) {
	var jqueryUITabsMegaMenu=function(initObject){
		this.fxDuration=200;
		this.openDelay=200;
		this.closeDelay=400;
		this.infiniteLoopDetectionCount=200;
		var self=this;
		var currentMousePos = { x: -1, y: -1 };
		var tab=$(initObject.container);
		if(!initObject.container || !initObject.container.id || initObject.container.id ===""){
			console.log("The jquery ui tabs megamenu root element must have an unique id attribute specified");
		}
		self.menuClicked=false;
		var timeoutTabId=false;
		var timeoutTabId3=false;
		var currentSelectedTab=false;
		var currentSelectedTabDone=false;
		var buttons=$("li", tab);
		var finalSelected=false;
		var nextTabIndex=-1;
		var check=false;
		var isRelative=true;
		var enableMenu=false;
		var menuOpen=false;
		var menuOpenTimeout=false; 
		var tabSelectedCallback=function(a,b,c){
			if(currentSelectedTab && currentSelectedTab !== b.index){ 
				tab.tabs('option', 'active', currentSelectedTab);
			}else{
			}
		};
		var doSelect=function(){
			clearInterval(timeoutTabId3);
			currentSelectedTab=nextTabIndex;
			//tab.tabs("select", nextTabIndex);
			tab.stop(true, true);
			tab.tabs('option', 'active', currentSelectedTab);
			checkIfMenuShouldClose();
			$(initObject.menuPanelChildClassSelector).fadeIn('fast');
		};
		tab.tabs({
			event:"click",
			//fx:{ opacity: "toggle", height: "toggle",duration:self.fxDuration },
			selected:-1,
			/*hide: {
				effect: "fade",
				duration: 200
			}, */
			collapsible:true,
			show:tabSelectedCallback,
			select:function(a,b,c){
				console.log(currentSelectedTab);
				if(currentSelectedTab === -1 || b.index === currentSelectedTab){
					return true;
				}else{
					clearTimeout(timeoutTabId3);
					nextIndex=b.index;
					timeoutTabId3=setInterval(doSelect, fx.openDelay);
					return false;
				}
			}
		});
		
		var elementFromPoint=function(x,y){
			if(!document.elementFromPoint) return null;
			// have to subtract scrollposition to get the right element.
			x -= $(document).scrollLeft();
			y -= $(document).scrollTop();
			return document.elementFromPoint(x,y);
		};
		$(document).mousemove(function(event) {
			currentMousePos.x = event.pageX;
			currentMousePos.y = event.pageY;
			
		});
		var checkIfMenuShouldClose=function(){
			var e=elementFromPoint(currentMousePos.x, currentMousePos.y);
			var i=0;
			enableMenu=false;	
			while(true){
				if(e && e.id === initObject.container.id){
					enableMenu=true;	
				}
				if(!e || typeof e.parentNode === "undefined" || e.parentNode===null){
					break;
				}
				e=e.parentNode;
				i++;
				if(i === self.infiniteLoopDetectionCount){
					console.log("Possible infinite loop in jqueryUITabsMegaMenu - forcing menu to close.");
					break;
				}
			} 
			if(!enableMenu && typeof menuOpenTimeout === "boolean"){
				menuOpenTimeout=false;
				menuOpenTimeout=setTimeout(function(){
					$(initObject.menuPanelChildClassSelector).hide();
				}, 300);
			}
			if(enableMenu){
				clearTimeout(menuOpenTimeout);
				menuOpenTimeout=false;
			} 
			if(parseInt(tab.tabs("option", "active")) != nextTabIndex && nextTabIndex >=0){ 
				tab.tabs('option', 'active', currentSelectedTab);
			}
		};
		setInterval(checkIfMenuShouldClose, self.closeDelay);
		
		buttons.bind("click", function(){
			self.menuClicked=true;
			finalSelected=parseInt(this.getAttribute("data-panelid"))-1;
			clearTimeout(timeoutTabId3);
			nextTabIndex=finalSelected;
			doSelect();
		});
		buttons.bind("mouseover", function(){
			self.menuClicked=true;
			finalSelected=parseInt(this.getAttribute("data-panelid"))-1;
			if(nextTabIndex !== finalSelected){
				clearTimeout(timeoutTabId3);
				nextTabIndex=finalSelected;
				doSelect();
				timeoutTabId3=setInterval(doSelect, self.openDelay);
			}
		}); 
		tab.mouseenter(function(){
			clearTimeout(timeoutTabId);
		});
		
	};

	 $.fn.jqueryUITabsMegaMenu = function(initObject){
		 return this.each(function(){
			 initObject.container=this;
			 this.jqueryUITabsMegaMenu=new jqueryUITabsMegaMenu(initObject);
		 });
	 };
})(jQuery);