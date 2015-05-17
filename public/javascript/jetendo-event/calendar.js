
(function($, window, document, undefined){
	"use strict";
	var calendarConfig={};

	function setupFullCalendar(){

		$('#zCalendarFullPageDiv').fullCalendar({
		    eventClick: function(calEvent, jsEvent, view) {
				if(typeof calEvent.link != "undefined"){
					window.location.href=calEvent.link;
				}
				return;
		    },
			header: {
				left: 'prev,next today',
				center: 'title',
				right: 'month,basicWeek,basicDay'
			},
			eventRender: function(event, element) { 
				//element.find('.fc-event-title').append("<br/>" + event.location); 
				element.find('.fc-event-time').hide();
			},
			defaultDate: calendarConfig.defaultDate,
			editable: false,
			eventSources: [{
				url: calendarConfig.jsonFullLink,
				type: 'GET',
				data: {},
				error: function () {
					alert('There was an error while fetching events!');
				}
			}]
		});
		if(navigator.userAgent.indexOf("MSIE 7.0") != -1){
			$(".fc-icon-left-single-arrow").html("&lt;");
			$(".fc-icon-right-single-arrow").html("&gt;");
		}
	}
	function listViewCallback(r){
		var rs=eval("("+r+")");
		if(rs.success){
			$("#zCalendarTab_List").html(rs.html);
		}
	}
	function setupListView(){

		var tempObj={};
		tempObj.id="zListCalendar";
		tempObj.url=calendarConfig.jsonListLink;
		tempObj.callback=listViewCallback;
		tempObj.cache=false;
		zAjax(tempObj);
	}
	function zDisplayEventCalendar(s){
		calendarConfig=s;
		if(calendarConfig.hasListView){
		
			if(calendarConfig.activeTab == 0){
				var activeTab=0;
				setupListView();
			}else{
				var activeTab=1;
				setTimeout(setupFullCalendar, 100);
			}
			$("#zCalendarHomeTabs").tabs({
				active:activeTab,
				activate:function(e, e2){ 
					if(e2.newPanel[0].id == "zCalendarTab_Calendar"){
						setTimeout(setupFullCalendar, 100);
					}else if(e2.newPanel[0].id == "zCalendarTab_List"){
						setTimeout(setupListView, 100);
					}
				}
			});
		}else{
			setTimeout(setupFullCalendar, 100);
		}
		
	}
	window.zDisplayEventCalendar=zDisplayEventCalendar;
})(jQuery, window, document, "undefined"); 
