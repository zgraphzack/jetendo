
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
	function setupPagination(rs){

		var options={
			id:"zEventListCalendarNav",
			count: rs.count,
			perpage: rs.perpage, 
			offset: rs.offset,
			loadFunction: function(options){
				var link=zURLAppend(calendarConfig.jsonListLink, "offset="+options.offset);

				var tempObj={};
				tempObj.id="zListCalendar";
				tempObj.url=link;
				tempObj.callback=listViewCallback;
				tempObj.cache=false;
				zAjax(tempObj);
			}
		}
		var p=new zPagination(options);
		zJumpToId("zCalendarTab_List");
	}
	function listViewCallback(r){
		var rs=eval("("+r+")");
		if(rs.success){
			$("#zCalendarTab_List").html(rs.html);
			setupPagination(rs);
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



	function zEventSearchCallback(r){
		var r2=eval('(' + r + ')');
		if(r2.success){
			$("#zEventSearchResultsDiv").html(r2.html);
		}
	}
	function zEventSearchGetData(){
		var startdate=$("#zEventSearchStartDate").val();
		var enddate=$("#zEventSearchEndDate").val();
		var keyword=$("#zEventSearchKeyword").val();
		var arr=[];
		$(".zEventSearchCategory").each(function(){
			if(this.checked){
				arr.push(this.value);
			}
		});
		var categories=arr.join(",");
		var arr=[];
		$(".zEventSearchCalendar").each(function(){
			if(this.checked){
				arr.push(this.value);
			}
		});
		var calendarids=arr.join(",");
		
		var searchString="startdate="+escape(startdate)+"&enddate="+escape(enddate)+"&keyword="+escape(keyword)+"&categories="+escape(categories)+"&calendarids="+escape(calendarids);
		if(window.location.href.indexOf("/z/event/event-search/index") == -1){
			window.location.href="/z/event/event-search/index?"+searchString;
			return;
		}
		var tempObj={};
		tempObj.id="zAjaxEventSearch";
		tempObj.url="/z/event/event-search/ajaxEventSearch?"+searchString;
		tempObj.cache=false;
		tempObj.callback=zEventSearchCallback;
		tempObj.ignoreOldRequests=true;
		zAjax(tempObj);
	}

	function zEventSearchSetupForm(){
		$( "#zEventSearchStartDate" ).datepicker({ 
			minDate: -20, 
			maxDate: "+1Y",
			numberOfMonths:3,
			onClose: function( selectedDate ) {
				if($( "#zEventSearchEndDate" ).val() != ''){
					return;
				}
				$( "#zEventSearchEndDate" ).datepicker( "option", "minDate", selectedDate );
				$( "#zEventSearchEndDate" ).datepicker( "option", "maxDate", "+1Y");//selectedDate );
				var newdate=new Date(selectedDate);
				newdate.setDate(newdate.getDate() + 30);
				
				var year = String(newdate.getFullYear());
				var month = String(newdate.getMonth() + 1);
				if (month.length == 1) {
				    month = "0" + month;
				}
				var day = String(newdate.getDate());
				if (day.length == 1) {
				    day = "0" + day;
				}
				document.getElementById("zEventSearchEndDate").value=month+"/"+day+"/"+year;
			}
		});
		$( "#zEventSearchEndDate" ).datepicker({ 
			minDate: -20, 
			maxDate: "+1Y",
			numberOfMonths:3,
			onClose: function( selectedDate ) {
			//	$( "#startdate" ).datepicker( "option", "maxDate", selectedDate );
			} 
		});
		$( "#zEventSearchStartDate" ).bind("change", zEventSearchGetData);
		$( "#zEventSearchEndDate" ).bind("change", zEventSearchGetData);
		$( ".zEventSearchCategory" ).bind("click", zEventSearchGetData);
		$( ".zEventSearchCalendar" ).bind("click", zEventSearchGetData);

	}
	window.zEventSearchSetupForm=zEventSearchSetupForm;
	window.zDisplayEventCalendar=zDisplayEventCalendar;
})(jQuery, window, document, "undefined"); 
