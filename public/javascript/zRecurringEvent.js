
(function($, window, document, undefined){
	"use strict";
	var zRecurringEvent=function(options){
		var self=this;
		var recurType="Daily";
		var lastPreviewColumnCount=0;
		var arrExclude=[];
		var calendarWidth=160; 
		var calendarColumns=0;
		var arrMarked=[];
		var calendarRows=5;
		var disableFormOnChange=false;
		if(typeof options === undefined){
			options={};
		}
		var monthNames = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ];
		
		// force defaults
		options.ruleObj=zso(options, 'ruleObj', false, {});
		options.arrExclude=zso(options, 'arrExclude', false, []);
		function init(options){
			//$cartDiv=$(".zcart."+options.name);
			self.buildMonthlyCalendar();
			for(var i=0;i<options.arrExclude.length;i++){
				var d=new Date(Date.parse(options.arrExclude[i]));
				arrExclude[d.getTime()]=d;
			}

			self.setFormFromRules(options.ruleObj, true);

			recurType=$("#zRecurTypeSelect").val();
			$("#zRecurType"+recurType).show();
			$("#zRecurTypeSelect").bind("change", function(){
				recurType=$(this).val();
				$(".zRecurType").hide();
				$("#zRecurType"+recurType).show();
			});

			$("#zRecurTypeRangeDate").datepicker();
			$("#zRecurTypeExcludeDate").datepicker();
			zArrResizeFunctions.push(function(){

				calendarColumns=Math.floor((($(".zRecurPreviewBox").width()))/calendarWidth);
				if(lastPreviewColumnCount== calendarColumns){
					return;
				}
				lastPreviewColumnCount=calendarColumns;
				arrMarked=self.getMarkedDates();
				self.drawPreviewCalendars();
			});

			self.drawExcludedDates();
			$("#zRecurTypeExcludeDateButton").bind("click", function(){
				try{
					var date=new Date(Date.parse($("#zRecurTypeExcludeDate").val()));
				}catch(e){
					alert("You must specify a valid date first.");
					return false;
				}
				self.addExcludeDate(date);
				return false;
			});
			$("#event_start_datetime_date").bind("change", function(){
				self.drawPreviewCalendars();
				$("#zRecurTypeExcludeDate").val($(this).val());
				$("#event_end_datetime_date").val($(this).val());

			});
			$("#event_start_datetime_time").bind("change", function(){
				$("#event_end_datetime_time").val($(this).val());

			});
			$('.zRecurEventBox :input').bind("change", function () { 
				if(disableFormOnChange){
					return false;
				}
				arrMarked=self.getMarkedDates();

				self.drawPreviewCalendars();
			}); 
			setTimeout(function(){ 

				calendarColumns=Math.floor((($(".zRecurPreviewBox").width()))/calendarWidth);
				lastPreviewColumnCount=calendarColumns;
				arrMarked=self.getMarkedDates();
				self.drawPreviewCalendars();
			}, 200);
		};
		self.buildMonthlyCalendar=function(){
			var arrHTML=[];
			arrHTML.push('<div style="width:100%; float:left;">');
			for(var i=1;i<=31;i++){
				arrHTML.push('<span class="zRecurDayButton" style="width:36px;margin-bottom:3px;"><span style="width:15px; float:left;"><input type="checkbox" name="zRecurTypeMonthlyCalendarDay" class="zRecurTypeMonthlyCalendarDay" id="zRecurTypeMonthlyCalendarDay'+i+'" value="'+i+'" /></span> <label for="zRecurTypeMonthlyCalendarDay'+i+'" style="display:block; float:left;width:21px;">'+i+'</label></span></span>');
				if(i % 7 == 0){
					arrHTML.push('</div><div style="width:100%; float:left;">');
				}
			}
			arrHTML.push('<span class="zRecurDayButton" style="width:70px;margin-bottom:3px;"><span style="width:15px;display:block; float:left;"><input type="checkbox" name="zRecurTypeMonthlyCalendarDay" class="zRecurTypeMonthlyCalendarDay" id="zRecurTypeMonthlyCalendarDay0" value="0" /></span> <label for="zRecurTypeMonthlyCalendarDay0" style="display:block; float:left;width:52px;">Last Day</label></span></span>');
			arrHTML.push('</div>');
			$("#zRecurTypeMonthlyCalendar").html(arrHTML.join(""));
		};
		self.drawPreviewCalendars=function(){ 
			var $calendarDiv=$("#zRecurPreviewCalendars");
			var arrHTML=[];
			var count=0;

			calendarColumns=Math.floor((($(".zRecurPreviewBox").width()))/calendarWidth);
			var startDate=$("#event_start_datetime_date").val();
			if(startDate == ""){
				return;
			}
			try{
				var currentDate=new Date(Date.parse(startDate));
			}catch(e){
				return;
			}
			for(var i=0;i<calendarRows;i++){
				arrHTML.push('<div style="width:100%; float:left;">');
				for(var n=0;n<calendarColumns;n++){
					// currentDate + 1 month
					var newDate=new Date(currentDate.getTime());
					newDate.setMonth(newDate.getMonth()+count);
					newDate.setDate(1);
					arrHTML.push('<div class="zRecurCalendarContainer">'+self.buildCalendarHTML(newDate)+'</div>');
					count++;
				}
				arrHTML.push('</div>');
			}
			$calendarDiv.html(arrHTML.join(""));
			$(".zRecurCalendarDayMarked").bind("click", function(){
				var e=$(this).hasClass("zRecurCalendarDayExcluded");
				var date=new Date(parseInt($(this).attr("data-date")));
				if(e!=""){
					self.removeExcludedDate(date);
					$(this).removeClass("zRecurCalendarDayExcluded");
				}else{
					self.addExcludeDate(date);
					$(this).addClass("zRecurCalendarDayExcluded");
				}
			});
		};
		self.buildCalendarHTML=function(date){
			// 6 rows to make them all the same
			var month=monthNames[date.getMonth()]+" "+date.getFullYear();
			var arrHTML=['<div class="zRecurCalendarMonth">'+month+'</div><div class="zRecurCalendar">'];
			arrHTML.push('<div class="zRecurCalendarDayLabels">');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Su</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Mo</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Tu</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">We</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Th</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Fr</div>');
			arrHTML.push('<div class="zRecurCalendarDayLabel">Sa</div>');
			arrHTML.push('</div>');


			var monthString=monthNames[date.getMonth()];
			var firstDayOfWeek=date.getDay();
			var currentMonth=date.getMonth();
			date.setDate(date.getDate()-firstDayOfWeek);
			var day=date;
			for(var i=0;i<6;i++){
				arrHTML.push('<div class="zRecurCalendarWeek">');
				for(var n=0;n<7;n++){
					var dayMonth=day.getMonth();
					var currentDate=day.getDate();
					if(dayMonth != currentMonth){
						arrHTML.push('<div class="zRecurCalendarDayOtherMonth">'+currentDate+'</div>');
					}else{
						var markedCSS='';

						if(typeof arrMarked[day.getTime()] != "undefined"){
							markedCSS+=' zRecurCalendarDayMarked';
							if(typeof arrExclude[day.getTime()] != "undefined"){
								markedCSS+=' zRecurCalendarDayExcluded';
							}
						}
						var dateAsString=(day.getMonth()+1)+"/"+day.getDate()+"/"+day.getFullYear();
						arrHTML.push('<div class="zRecurCalendarDay'+markedCSS+'" id="zRecurCalendarDay'+day.getTime()+'" data-date="'+day.getTime()+'">'+currentDate+'</div>');
					}
					day.setDate(day.getDate()+1);
				}
				arrHTML.push('</div>');
			}
			arrHTML.push('</div>');
			return arrHTML.join("");
		}
		self.addExcludeDate=function(date){
			arrExclude[date.getTime()]=date;
			self.drawExcludedDates();
		};
		self.removeExcludedDate=function(date){
			var arrNew=[];
			var t=date.getTime();
			for(var i in arrExclude){
				if(i!=t){
					arrNew[i]=arrExclude[i];
				}
			}
			arrExclude=arrNew;
			self.drawExcludedDates();
		};
		self.drawExcludedDates=function(){
			var arrSort=[];
			for(var i in arrExclude){
				arrSort.push(parseInt(i));
			}
			arrSort.sort();
			var arrHTML=[];
			for(var i=0;i<arrSort.length;i++){
				var day=new Date(arrSort[i]);
				var dateAsString=(day.getMonth()+1)+"/"+day.getDate()+"/"+day.getFullYear();
				arrHTML.push('<div class="zRecurExcludedDay" data-date="'+day.getTime()+'">'+dateAsString+' <div class="zRecurExcludedDayDeleteButton">X</div></div>');
			}
			if(arrSort.length == 0){
				arrHTML.push('No dates are excluded');
			}
			$("#zRecurExcludedDates").html(arrHTML.join(""));
			$(".zRecurExcludedDay").bind("click", function(){
				var date=new Date(parseInt($(this).attr("data-date")));
				self.removeExcludedDate(date);
				$("#zRecurCalendarDay"+date.getTime()).removeClass("zRecurCalendarDayExcluded");
				return false;
			});
			self.drawPreviewCalendars();
		};
		self.setFormFromRules=function(ruleObj, disablePreviewUpdate){
			var defaultRuleObj={
				recurType:"Daily",
				noEndDate:false,
				everyWeekday:false,
				skipDays:1,
				recurLimit:0,
				endDate:false,
				skipWeeks:1,
				skipMonths:1,
				skipYears:1,
				arrWeeklyDays:[],
				monthlyWhich:"",
				monthlyDay:"",
				arrMonthlyCalendarDay:[],
				annuallyWhich:"",
				annuallyDay:"",
				annuallyMonth:"",
			};
			for(var i in defaultRuleObj){
				if(typeof ruleObj[i] == "undefined"){
					ruleObj[i]=defaultRuleObj[i];
				}
			}
			disableFormOnChange=true;
			$("#zRecurTypeSelect").val(ruleObj.recurType);

			if(ruleObj.recurType == "Daily"){
				if(!ruleObj.everyWeekday){
					$("#zRecurTypeDailyRadio1").prop("checked", true);
					$("#zRecurTypeDailyDays").val(ruleObj.skipDays);
				}else{	
					$("#zRecurTypeDailyRadio2").prop("checked", true);
					ruleObj.everyWeekday=true;
				}

			}else if(ruleObj.recurType == "Weekly"){
				$("#zRecurTypeWeeklyWeeks").val(ruleObj.skipWeeks);
				var arrC=[];
				for(var i=0;i<ruleObj.arrWeeklyDays.length;i++){
					arrC[ruleObj.arrWeeklyDays[i]]=true;
				}
				$(".zRecurTypeWeeklyDay").each(function(){
					if(typeof arrC[this.value] != "undefined"){
						this.checked=true;
					}
				});

			}else if(ruleObj.recurType == "Monthly"){
				$("#zRecurTypeMonthlyDays").val(ruleObj.skipMonths);
				if(ruleObj.arrMonthlyCalendarDay.length == 0){
					$("#zRecurTypeMonthlyType1").prop("checked", true);

					$("#zRecurTypeMonthlyWhich").val(ruleObj.monthlyWhich);
					$("#zRecurTypeMonthlyDay").val(ruleObj.monthlyDay);
				}else{
					
					$("#zRecurTypeMonthlyType2").prop("checked", true);
					var arrC=[];
					for(var i=0;i<ruleObj.arrMonthlyCalendarDay.length;i++){
						arrC[ruleObj.arrMonthlyCalendarDay[i]]=true;
					}
					$(".zRecurTypeMonthlyCalendarDay").each(function(){
						if(typeof arrC[this.value] != "undefined"){
							this.checked=true;
						}
					});
				}
			}else if(ruleObj.recurType == "Annually"){
				$("#zRecurTypeAnnuallyDays").val(ruleObj.skipYears);
				if(ruleObj.annuallyDay == ""){
					$("#zRecurTypeAnnuallyType1").prop("checked", true);
					$("#zRecurTypeAnnuallyWhich").val(ruleObj.annuallyWhich);
					$("#zRecurTypeAnnuallyMonth").val(ruleObj.annuallyMonth);
				}else{
					$("#zRecurTypeAnnuallyType2").prop("checked", true);
					$("#zRecurTypeAnnuallyWhich2").val(ruleObj.annuallyWhich);
					$("#zRecurTypeAnnuallyDay2").val(ruleObj.annuallyDay);
					$("#zRecurTypeAnnuallyMonth2").val(ruleObj.annuallyMonth);
				}
			}
			if(typeof ruleObj.endDate != "boolean"){
				$("#zRecurTypeRangeRadio3").prop("checked", true);
				ruleObj.endDate=new Date(Date.parse(ruleObj.endDate));
				var dateAsString=(ruleObj.endDate.getMonth()+1)+"/"+ruleObj.endDate.getDate()+"/"+ruleObj.endDate.getFullYear();
				$("#zRecurTypeRangeDate").val(dateAsString);
			}else if(ruleObj.recurLimit != 0){
				$("#zRecurTypeRangeDays").val(ruleObj.recurLimit);
				$("#zRecurTypeRangeRadio2").prop("checked", true);
			}else{
				$("#zRecurTypeRangeRadio1").prop("checked", true);
			}
			disableFormOnChange=false; 
			if(typeof disablePreviewUpdate == "undefined"){
				disablePreviewUpdate=false;
			}
			if(!disablePreviewUpdate){
				arrMarked=self.getMarkedDates();
				self.drawPreviewCalendars();
			}
		}
		self.getRulesFromForm=function(){
			var ruleObj={};
			ruleObj.recurType="Daily";
			ruleObj.noEndDate=false;
			ruleObj.everyWeekday=false;
			ruleObj.skipDays=1;
			ruleObj.recurLimit=0;
			ruleObj.endDate=false;
			ruleObj.skipWeeks=1;
			ruleObj.skipMonths=1;
			ruleObj.skipYears=1;
			ruleObj.arrWeeklyDays=[];
			ruleObj.monthlyWhich="";
			ruleObj.monthlyDay="";
			ruleObj.arrMonthlyCalendarDay=[];
			ruleObj.annuallyWhich="";
			ruleObj.annuallyDay="";
			ruleObj.annuallyMonth="";

			ruleObj.recurType=$("#zRecurTypeSelect").val();

			if(ruleObj.recurType == "Daily"){
				if($("#zRecurTypeDailyRadio1").prop("checked")){	
					try{
						ruleObj.skipDays=parseInt($("#zRecurTypeDailyDays").val());
					}catch(e){
						alert("X must be a valid number for the Every X Day(s) field.");
						$("#zRecurTypeDailyDays").val(1);
					}

				}else if($("#zRecurTypeDailyRadio2").prop("checked")){	
					ruleObj.everyWeekday=true;
				}

			}else if(ruleObj.recurType == "Weekly"){
					try{
						ruleObj.skipWeeks=parseInt($("#zRecurTypeWeeklyWeeks").val());
					}catch(e){
						alert("X must be a valid number for the Every X Week(s) field.");
						$("#zRecurTypeWeeklyWeeks").val(1);
					}
					
					$(".zRecurTypeWeeklyDay").each(function(){
						if(this.checked){
							ruleObj.arrWeeklyDays.push(this.value);
						}
					});

			}else if(ruleObj.recurType == "Monthly"){
				try{
					ruleObj.skipMonths=parseInt($("#zRecurTypeMonthlyDays").val());
				}catch(e){
					alert("X must be a valid number for the Every X Month(s) field.");
					$("#zRecurTypeMonthlyDays").val(1);
				}
				if($("#zRecurTypeMonthlyType1").prop("checked")){
					ruleObj.monthlyWhich=$("#zRecurTypeMonthlyWhich").val();
					ruleObj.monthlyDay=$("#zRecurTypeMonthlyDay").val();
				}else if($("#zRecurTypeMonthlyType2").prop("checked")){
					
					$(".zRecurTypeMonthlyCalendarDay").each(function(){
						if(this.checked){
							ruleObj.arrMonthlyCalendarDay.push(parseInt(this.value));
						}
					});
				}
			}else if(ruleObj.recurType == "Annually"){
				try{
					ruleObj.skipYears=parseInt($("#zRecurTypeAnnuallyDays").val());
				}catch(e){
					alert("X must be a valid number for the Every X Year(s) field.");
					$("#zRecurTypeAnnuallyDays").val(1);
				}
				if($("#zRecurTypeAnnuallyType1").prop("checked")){
					ruleObj.annuallyWhich=$("#zRecurTypeAnnuallyWhich").val();
					ruleObj.annuallyMonth=$("#zRecurTypeAnnuallyMonth").val();


				}else if($("#zRecurTypeAnnuallyType2").prop("checked")){
					ruleObj.annuallyWhich=$("#zRecurTypeAnnuallyWhich2").val();
					ruleObj.annuallyDay=$("#zRecurTypeAnnuallyDay2").val();
					ruleObj.annuallyMonth=$("#zRecurTypeAnnuallyMonth2").val();
				}
			}

			if($("#zRecurTypeRangeRadio1").prop("checked")){
				// do nothing
			}else if($("#zRecurTypeRangeRadio2").prop("checked")){
				try{
					ruleObj.recurLimit=parseInt($("#zRecurTypeRangeDays").val());
				}catch(e){

				}
			}else if($("#zRecurTypeRangeRadio3").prop("checked")){
				try{
					ruleObj.endDate=new Date(Date.parse($("#zRecurTypeRangeDate").val()));
				}catch(e){
					alert("Invalid end date");
					$("#zRecurTypeRangeDate").val("");
				}
			}
			return ruleObj;
		}
		self.getDaysInMonth=function(date){
			var newDate=new Date(date.getTime());
			newDate.setMonth(newDate.getMonth()+1);
			newDate.setDate(0);
			return newDate.getDate();
		};
		self.getProjectedDateCount=function(startDate){
			var projectedDateCount=0;
			var monthCount=Math.floor($(".zRecurPreviewBox").width()/calendarWidth)*calendarRows;
			var d=new Date(startDate.getTime());
			for(var i=0;i<monthCount;i++){
				var daysInMonth=self.getDaysInMonth(d);
				projectedDateCount+=daysInMonth;
				d.setMonth(d.getMonth()+1);
			}
			return projectedDateCount;
		};
		self.lastDayOfWeekOfMonth=function(date, day){
			var month = date.getMonth();
			var year = date.getFullYear(); 
			var d = new Date(year,month+1,0);
			if(day==-1){
				return d;
			}
			while (d.getDay() != day) {
				d.setDate(d.getDate() -1);
			}
			return d;
		};
		self.getMarkedDates=function(){
			var arrDate=[];
			var startDate=$("#event_start_datetime_date").val();
			if(startDate == ""){
				return arrDate;
			}
			try{
				var currentDate=new Date(Date.parse(startDate));
			}catch(e){
				return arrDate;
			}
			var startTime=currentDate.getTime();
			currentDate.setDate(1);
			var projectedDateCount=self.getProjectedDateCount(currentDate);

			var ruleObj=self.getRulesFromForm();

			console.log("projectedDateCount:"+projectedDateCount);
			var arrDebugDate=[];
			var recurCount=0;
			console.log(ruleObj);


			var lastDate=new Date(currentDate.getTime());
			lastDate.setDate(lastDate.getDate()+projectedDateCount);
			var lastTime=lastDate.getTime();

			// weekly fields
			var arrWeeklyDayLookup={
				0:false,
				1:false,
				2:false,
				3:false,
				4:false,
				5:false,
				6:false
			};
			var weeklyLookupCount=ruleObj.arrWeeklyDays.length;
			var weeklyEventCount=0;
			for(var i=0;i<ruleObj.arrWeeklyDays.length;i++){
				arrWeeklyDayLookup[ruleObj.arrWeeklyDays[i]]=true;
			}

			// year fields
			var monthLookup={
				"January":0, 
				"February":1, 
				"March":2, 
				"April":3, 
				"May":4, 
				"June":5,
				"July":6,
				"August":7, 
				"September":8, 
				"October":9, 
				"November":10, 
				"December":11
			};

			// month fields
			var dayLookup={
				"Sunday":0,
				"Monday":1,
				"Tuesday":2,
				"Wednesday":3,
				"Thursday":4,
				"Friday":5,
				"Saturday":6,
				"Day":-1
			};
			var monthlyDayLookup=[];
			for(var i=0;i<ruleObj.arrMonthlyCalendarDay.length;i++){
				monthlyDayLookup[ruleObj.arrMonthlyCalendarDay[i]]=true;
			}
			var monthDayCount=0;
			var monthDayCountMonth=-1;
			var monthlyLastDayOfWeekMatch=0;

			try{
				var d=dayLookup[ruleObj.monthlyDay];
			}catch(e){
				alert("Invalid value for ruleObj.monthlyDay: "+ruleObj.monthlyDay);
				return arrDate;
			}
			try{
				var d=dayLookup[ruleObj.monthlyDay];
			}catch(e){
				alert("Invalid value for ruleObj.monthlyDay: "+ruleObj.monthlyDay);
				return arrDate;
			}
			var lastDayOfMonth=0;
			var wasLastDayOfMonth=false;
			var firstMonth=true;
			var totalMonthCount=0;
			for(var i=0;i<projectedDateCount;i++){
				if(monthDayCountMonth != currentDate.getMonth()){
					totalMonthCount++;
					if(ruleObj.recurType == "Monthly"){
						if(!firstMonth && currentDate.getDate() == 1 && ruleObj.skipMonths-1){
							currentDate.setMonth(currentDate.getMonth()+(ruleObj.skipMonths-1));
							//continue;
						}
						firstMonth=false;
					}else if(ruleObj.recurType == "Annually"){
						if(totalMonthCount ==12 && ruleObj.skipYears-1){
							totalMonthCount=0;
							currentDate.setFullYear(currentDate.getFullYear()+(ruleObj.skipYears-1));
							console.log('yearChange:'+currentDate.getFullYear());
						}
					}
					monthDayCount=0;
					monthDayCountMonth=currentDate.getMonth();
					lastDayOfMonth=new Date(currentDate);
					lastDayOfMonth.setMonth(lastDayOfMonth.getMonth()+1);
					lastDayOfMonth.setDate(0);
					var lastDayOfMonthTime=lastDayOfMonth.getTime();
					if(ruleObj.monthlyDay != ""){
						monthlyLastDayOfWeekMatch=self.lastDayOfWeekOfMonth(currentDate, dayLookup[ruleObj.monthlyDay]);
					}
					if(ruleObj.annuallyDay != ""){
						monthlyLastDayOfWeekMatch=self.lastDayOfWeekOfMonth(currentDate, dayLookup[ruleObj.annuallyDay]);
					}
				}
				var day=currentDate.getDay();
				var debugDate=new Date(currentDate.getTime());
				var currentTime=currentDate.getTime();
				var isEvent=false;
				var disableEvent=false;
				if(!ruleObj.noEndDate && typeof ruleObj.endDate != "boolean"){
					if(currentTime > ruleObj.endDate.getTime()){
						break;
					}
				}
				if(typeof arrExclude[currentTime] != "undefined"){
				//	disableEvent=true;
				}
				if(ruleObj.recurType == "Daily"){
					if(ruleObj.everyWeekday){
						if(day != 0 && day != 6){
							isEvent=true;
						}
					}else{
						isEvent=true;
						if(ruleObj.skipDays-1){
							currentDate.setDate(currentDate.getDate()+(ruleObj.skipDays-1));
						}
					}
				}else if(ruleObj.recurType == "Weekly"){
					if(weeklyEventCount==weeklyLookupCount){
						// the weekly offset doesn't start from the start, or even january 1, it starts way back according to ical standard - must read docs: http://www.kanzaki.com/docs/ical/rrule.html
						if(ruleObj.skipWeeks-1){
							currentDate.setDate(currentDate.getDate()+((ruleObj.skipWeeks-1)*7));
							weeklyEventCount=0;
							continue;
						}
					}
					if(arrWeeklyDayLookup[day]){
						isEvent=true;
					}
				}else if(ruleObj.recurType == "Monthly"){
					if(ruleObj.arrMonthlyCalendarDay.length){
						if(typeof monthlyDayLookup[0] != "undefined" && currentTime == lastDayOfMonthTime){
							isEvent=true;
						}
						if(typeof monthlyDayLookup[currentDate.getDate()] != "undefined"){
							isEvent=true;
						}
					}else{
						if(ruleObj.monthlyDay != ""){
							var dayMatch=false;
							if(ruleObj.monthlyDay == "Day"){
								monthDayCount++;	
								dayMatch=true;
							}else if(day == dayLookup[ruleObj.monthlyDay]){
								monthDayCount++;	
								dayMatch=true;
							}
							if(ruleObj.monthlyWhich == "Every"){
								if(dayMatch){
									isEvent=true;
								}
							}else if(ruleObj.monthlyWhich == "The First"){
								if(dayMatch && monthDayCount == 1){
									isEvent=true;
								}
							}else if(ruleObj.monthlyWhich == "The Second"){
								if(dayMatch && monthDayCount == 2){
									isEvent=true;
								}
							}else if(ruleObj.monthlyWhich == "The Third"){
								if(dayMatch && monthDayCount == 3){
									isEvent=true;
								}
							}else if(ruleObj.monthlyWhich == "The Fourth"){
								if(dayMatch && monthDayCount == 4){
									isEvent=true;
								}
							}else if(ruleObj.monthlyWhich == "The Fifth"){
								if(dayMatch && monthDayCount == 5){
									isEvent=true;
								}
							}else if(ruleObj.monthlyWhich == "The Last"){
								if(dayMatch && currentDate.getDate() == monthlyLastDayOfWeekMatch.getDate()){
									isEvent=true;
								}
							}
						}
					}
				}else if(ruleObj.recurType == "Annually"){

					if(currentDate.getMonth() == ruleObj.annuallyMonth){

						if(ruleObj.annuallyDay != ""){
							var dayMatch=false;
							if(ruleObj.annuallyDay == "Day"){
								monthDayCount++;	
								dayMatch=true;
							}else if(day == dayLookup[ruleObj.annuallyDay]){
								monthDayCount++;	
								dayMatch=true;
							}
							if(ruleObj.annuallyWhich == "Every"){
								if(dayMatch){
									isEvent=true;
								}
							}else if(ruleObj.annuallyWhich == "The First"){
								if(dayMatch && monthDayCount == 1){
									isEvent=true;
								}
							}else if(ruleObj.annuallyWhich == "The Second"){
								if(dayMatch && monthDayCount == 2){
									isEvent=true;
								}
							}else if(ruleObj.annuallyWhich == "The Third"){
								if(dayMatch && monthDayCount == 3){
									isEvent=true;
								}
							}else if(ruleObj.annuallyWhich == "The Fourth"){
								if(dayMatch && monthDayCount == 4){
									isEvent=true;
								}
							}else if(ruleObj.annuallyWhich == "The Fifth"){
								if(dayMatch && monthDayCount == 5){
									isEvent=true;
								}
							}else if(ruleObj.annuallyWhich == "The Last"){
								if(dayMatch && currentDate.getDate() == monthlyLastDayOfWeekMatch.getDate()){
									isEvent=true;
								}
							}
						}else{
							if(ruleObj.annuallyWhich == currentDate.getDate()){
								isEvent=true;
							}
						}
					}
				}
				if(currentTime==startTime){
					isEvent=true;
				}
				currentDate.setDate(currentDate.getDate()+1);
				if(isEvent){
					if(!disableEvent && currentTime>=startTime && currentTime<=lastTime){
						arrDate[currentTime]=true;
						arrDebugDate.push(debugDate.toGMTString());
						recurCount++;
						weeklyEventCount++;
					}
				}
				if(ruleObj.recurLimit != 0 && recurCount==ruleObj.recurLimit+1){
					break;
				}
			}
			console.log(arrDebugDate);
			return arrDate;
		}
		init(options);
		return this;
	}; 
	window.zRecurringEvent=zRecurringEvent;
})(jQuery, window, document, "undefined"); 
