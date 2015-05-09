<cfcomponent>
<cfoutput>
	<!--- 

To test all recurring rule types, open the browser console and run this URL on your domain:
/z/event/admin/recurring-event/index?runTests=1
	 --->
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.zRequireJqueryUI();
	application.zcore.skin.includeJs("/z/javascript/rrule/lib/rrule.js", '', 1);
	application.zcore.skin.includeJs("/z/javascript/rrule/lib/nlp.js", '', 2);
	application.zcore.skin.includeJs("/z/javascript/jetendo/zRecurringEvent.js");

	application.zcore.template.setPlainTemplate();
	form.runTests=application.zcore.functions.zso(form, 'runTests', true, 0);
	form.event_start_datetime=application.zcore.functions.zso(form, 'event_start_datetime', false, now());
	//form.event_end_datetime=application.zcore.functions.zso(form, 'event_end_datetime', false, '');
	form.event_recur_ical_rules=application.zcore.functions.zso(form, 'event_recur_ical_rules');
	form.event_excluded_date_list=application.zcore.functions.zso(form, 'event_excluded_date_list');

	if(form.event_excluded_date_list EQ ""){
		excludeJson="[]";
	}else{
		excludeJson=serializeJson(listToArray(form.event_excluded_date_list,","));
	}

	</cfscript>
	<script type="text/javascript">

	function initRules(){

		var r='#form.event_recur_ical_rules#'; 
		arrExclude=#excludeJson#;
		runRule(r, arrExclude);
	}

	function runRule(r, arrExclude, options){
		if(typeof options == "undefined"){
			options={};
		}
		var recur=new zRecurringEvent(options); 
		var ruleObj=recur.convertFromRRuleToRecurringEvent(r);
		console.log(ruleObj);
		console.log('---');
		recur.setFormFromRules(ruleObj, false); 

		for(var i=0;i<arrExclude.length;i++){
			var date=new Date(arrExclude[i]);
			console.log(date);
			recur.addExcludeDate(date);
		}

		var rule=recur.convertFromRecurringEventToRRule(ruleObj);

		if($("##event_recur_ical_rules", window.parent.document).length){
			$("##event_recur_ical_rules", window.parent.document).val(rule);
		}
		return recur;
	}
	function loadTestCallback(r){
		var myObj=eval('('+r+')');
		if(myObj.success){
			console.log(myObj);
			for(var i=0;i<myObj.arrTest.length;i++){
				var t=myObj.arrTest[i];
				console.clear();
				console.log('Run test id:'+t.id);
				var arrExclude="";
				if(t.excludeDayList !=""){
					arrExclude=t.excludeDayList.split(",");
				}
				$("##event_start_datetime_date").val(t.startDate);
				$("##startDateLabel").html(t.startDate);

				var options={
					renderingEnabled:false
				}
				var recur=runRule(t.rule, arrExclude, options);

				var arrMarked=recur.getMarkedDates();

				var arrError=[];
				var arrMarked2=[];
				var arrMarked3=[];
				for(var n in arrMarked){
					var d=new Date();
					d.setTime(n);
					var m=d.getMonth()+1;
					if(m<10){
						m="0"+m;
					}
					var d2=d.getDate();
					if(d2<10){
						d2="0"+d2;
					}
					d=d.getFullYear()+"-"+(m)+"-"+d2;
					arrMarked2[d]=true;
					arrMarked3.push(d);
				}
				for(var n=0;n<t.arrCorrectDates.length;n++){
					if(typeof arrMarked2[t.arrCorrectDates[n]] == "undefined"){
						arrError.push("Date expected but not matched: "+t.arrCorrectDates[n]);
					}else{
						delete arrMarked2[t.arrCorrectDates[n]];
					}
				}
				for(var n in arrMarked2){
					arrError.push("Extra date returned that isn't correct: "+n);
				}
				if(arrError.length){
					console.log("Rule:");
					console.log(t);
					console.log("Marked:");
					console.log(arrMarked3.join("\n"));

					console.log("Errors:");
					console.log(arrError.join("\n"));
					throw("Invalid rule: "+t.id);
					break;
				}
			}
			console.log('All Tests Passed');
		}
	}

	function loadTests(){
		
		var tempObj={};
		tempObj.id="zLoadTests";
		tempObj.url="/z/event/event/getTestJson";
		tempObj.callback=loadTestCallback;
		tempObj.cache=false;
		zAjax(tempObj);
	}
	zArrDeferredFunctions.push(function(){
		//testRules();return
		<cfif form.runTests>
	
			loadTests();
			return;
		<cfelse>
			initRules();
			return;
		</cfif>
	});
	</script>
	<style type="text/css">
.zRecurBoxColumn1{ width:400px;vertical-align:top; display:table-cell; min-width:310px; max-width:372px;  }
.zRecurBoxColumn2{ padding-left:5px;vertical-align:top; display:table-cell;  }
@media only screen and (max-width: 640px) {
	.zRecurBoxColumn1{display:block;width:95%; max-width:95%; min-width:320px;float:left;}
	.zRecurBoxColumn2{display:block;width:95%; max-width:95%;  min-width:320px; padding-left:0px;float:left;}
}
.zRecurBox{ width:95%;border:1px solid ##999; border-radius:5px; padding:2%; float:left; margin-bottom:10px;}
.zRecurCalendarContainer{width:150px;margin:5px; background-color:##FFF; color:##000;float:left; }
.zRecurCalendarMonth{ padding:1px;  font-weight:bold;text-align:center;width:100%; float:left;}
.zRecurCalendar{
	text-align:center; width:150px; display:table; table-layout:fixed; border-spacing:0px;  
}
.zRecurCalendarWeek{display:table-row;}
.zRecurCalendarDayLabels{ padding:1px;  display:table-row;}
.zRecurCalendarDayLabel{ padding:1px; display:table-cell; }
.zRecurCalendarDay, .zRecurCalendarDayOtherMonth{
	display:table-cell; padding:1px; margin:0px; line-height:normal;
}
.zRecurCalendarDayMarked{font-weight:bold; color:##369;cursor:pointer; background-color:##369; color:##FFF;}
.zRecurCalendarDayOtherMonth{ background-color:##EEE; color:##999;}
.zRecurType{display:none;}
.zRecurDayButton{display:block; color:##000;background-color:##F6F6F6;border:1px solid ##CCC; cursor:pointer; border-radius:5px; padding:4px; margin-right:3px; float:left;}
.zRecurDayButton label{ line-height:15px;cursor:pointer;  }
.zRecurDayButton input{margin:0px; cursor:pointer; margin-top:1px;padding:0px;}
.zRecurDayButton:hover{ background-color:##FFF;color:##000;}
.zRecurExcludedDayText{width:75px; float:left;}
.zRecurExcludedDay{width:100px; float:left; margin-right:5px; margin-bottom:5px; color:##000; padding:5px;background-color:##F6F6F6;border:1px solid ##CCC; cursor:pointer; border-radius:5px; }
.zRecurExcludedDay:hover{ background-color:##FFF;color:##000;}
.zRecurExcludedDayDeleteButton{float:right;width:20px; border-radius:5px; text-align:center;background-color:##CCC; color:##000; margin-left:5px;}
.zRecurCalendarDayExcluded{background-color:##900; color:##FFF;cursor:pointer;}
.zRecurEventBox{width:100%; float:left;}
</style>
<div class="zRecurEventBox">
	<div class="zRecurBoxColumn1"> 
		<div class="zRecurBox">
			<h3>Recurrence type &amp; options</h3>
			<p>Start date: <span id="startDateLabel">#dateformat(form.event_start_datetime, 'm/d/yyyy')#</span> <input type="hidden" id="event_start_datetime_date" name="event_start_datetime_date" value="#htmleditformat(form.event_start_datetime)#"></p>
			<p><select size="1" id="zRecurTypeSelect">
				<option value="None">No Recurrence</option>
				<option value="Daily">Daily</option>
				<option value="Weekly">Weekly</option>
				<option value="Monthly">Monthly</option>
				<option value="Annually">Annually</option>
			</select></p>
			<div id="zRecurTypeNone" class="zRecurType">
				Recurrence disabled.
			</div>
			<div id="zRecurTypeDaily" class="zRecurType">
				<p><input type="radio" name="zRecurTypeDailyRadio" id="zRecurTypeDailyRadio1" value="0" checked="checked" /> Every 
				<input type="text" name="zRecurTypeDailyDays" style="width:30px;" id="zRecurTypeDailyDays" value="1" /> Day(s)</p>
				<p><input type="radio" name="zRecurTypeDailyRadio" id="zRecurTypeDailyRadio2" value="1" /> Every Weekday</p>
			</div>
			<div id="zRecurTypeWeekly" class="zRecurType"> 
				<p>Every 
				<input type="text" name="zRecurTypeWeeklyWeeks" style="width:30px;" id="zRecurTypeWeeklyWeeks" value="1" /> Week(s)</p>
				<div style="width:100%; float:left;">On:</div>
				<div style="width:100%; float:left;">
					<span class="zRecurDayButton"><input type="checkbox" name="zRecurTypeWeeklyDay" class="zRecurTypeWeeklyDay" id="zRecurTypeWeeklyDay0" value="0" /> <label for="zRecurTypeWeeklyDay0">Sun</label></span>
					<span class="zRecurDayButton"><input type="checkbox" name="zRecurTypeWeeklyDay" class="zRecurTypeWeeklyDay" id="zRecurTypeWeeklyDay1" value="1" /> <label for="zRecurTypeWeeklyDay1">Mon</label></span>
					<span class="zRecurDayButton"><input type="checkbox" name="zRecurTypeWeeklyDay" class="zRecurTypeWeeklyDay" id="zRecurTypeWeeklyDay2" value="2" /> <label for="zRecurTypeWeeklyDay2">Tue</label></span>
					<span class="zRecurDayButton"><input type="checkbox" name="zRecurTypeWeeklyDay" class="zRecurTypeWeeklyDay" id="zRecurTypeWeeklyDay3" value="3" /> <label for="zRecurTypeWeeklyDay3">Wed</label></span>
					<span class="zRecurDayButton"><input type="checkbox" name="zRecurTypeWeeklyDay" class="zRecurTypeWeeklyDay" id="zRecurTypeWeeklyDay4" value="4" /> <label for="zRecurTypeWeeklyDay4">Thu</label></span>
					<span class="zRecurDayButton"><input type="checkbox" name="zRecurTypeWeeklyDay" class="zRecurTypeWeeklyDay" id="zRecurTypeWeeklyDay5" value="5" /> <label for="zRecurTypeWeeklyDay5">Fri</label></span>
					<span class="zRecurDayButton"><input type="checkbox" name="zRecurTypeWeeklyDay" class="zRecurTypeWeeklyDay" id="zRecurTypeWeeklyDay6" value="6" /> <label for="zRecurTypeWeeklyDay6">Sat</label></span>
				</div>
			</div>
			<div id="zRecurTypeMonthly" class="zRecurType">
				<p>Every 
				<input type="text" name="zRecurTypeMonthlyDays" style="width:30px;" id="zRecurTypeMonthlyDays" value="1" /> Month(s)</p>
				<p>
				<input type="radio" name="zRecurTypeMonthlyType" id="zRecurTypeMonthlyType1" value="0" checked="checked" /> 
					
				<select name="zRecurTypeMonthlyWhich" id="zRecurTypeMonthlyWhich" size="1">
					<option value="Every">Every</option>
					<option value="The First">The First</option>
					<option value="The Second">The Second</option>
					<option value="The Third">The Third</option>
					<option value="The Fourth">The Fourth</option>
					<option value="The Fifth">The Fifth</option>
					<option value="The Last">The Last</option>
				</select>
				<select name="zRecurTypeMonthlyDay" id="zRecurTypeMonthlyDay" size="1">
					<option value="Sunday">Sunday</option>
					<option value="Monday">Monday</option>
					<option value="Tuesday">Tuesday</option>
					<option value="Wednesday">Wednesday</option>
					<option value="Thursday">Thursday</option>
					<option value="Friday">Friday</option>
					<option value="Saturday">Saturday</option>
					<option value="Day">Day of the month</option>
				</select>
				</p>
				<div style="width:100%; float:left;">
				<input type="radio" name="zRecurTypeMonthlyType" id="zRecurTypeMonthlyType2" value="1" /> 
					Recur on day(s):
					<div id="zRecurTypeMonthlyCalendar" style="width:100%; float:left;">
					</div>
				</div>
			</div>
			<div id="zRecurTypeAnnually" class="zRecurType">
				<p>Every 
				<input type="text" name="zRecurTypeAnnuallyDays" style="width:30px;" id="zRecurTypeAnnuallyDays" value="1" /> Year(s)</p>
				<p>
				<input type="radio" name="zRecurTypeAnnuallyType" id="zRecurTypeAnnuallyType1" value="0" checked="checked" /> 
				Every <input type="text" name="zRecurTypeAnnuallyWhich" style="width:30px;" id="zRecurTypeAnnuallyWhich" value="1" /> 
				<select name="zRecurTypeAnnuallyMonth" id="zRecurTypeAnnuallyMonth" size="1">
					<option value="0">January</option>
					<option value="1">February</option>
					<option value="2">March</option>
					<option value="3">April</option>
					<option value="4">May</option>
					<option value="5">June</option>
					<option value="6">July</option>
					<option value="7">August</option>
					<option value="8">September</option>
					<option value="9">October</option>
					<option value="10">November</option>
					<option value="11">December</option>
				</select></p>

				<input type="radio" name="zRecurTypeAnnuallyType" id="zRecurTypeAnnuallyType2" value="1" /> 
				<select name="zRecurTypeAnnuallyWhich2" id="zRecurTypeAnnuallyWhich2" size="1">
					<option value="Every">Every</option>
					<option value="The First">The First</option>
					<option value="The Second">The Second</option>
					<option value="The Third">The Third</option>
					<option value="The Fourth">The Fourth</option>
					<option value="The Fifth">The Fifth</option>
					<option value="The Last">The Last</option>
				</select>
				<select name="zRecurTypeAnnuallyDay2" id="zRecurTypeAnnuallyDay2" size="1">
					<option value="Sunday">Sunday</option>
					<option value="Monday">Monday</option>
					<option value="Tuesday">Tuesday</option>
					<option value="Wednesday">Wednesday</option>
					<option value="Thursday">Thursday</option>
					<option value="Friday">Friday</option>
					<option value="Saturday">Saturday</option>
					<option value="Day">Day of the month</option>
				</select>
				<select name="zRecurTypeAnnuallyMonth2" id="zRecurTypeAnnuallyMonth2" size="1">
					<option value="0">January</option>
					<option value="1">February</option>
					<option value="2">March</option>
					<option value="3">April</option>
					<option value="4">May</option>
					<option value="5">June</option>
					<option value="6">July</option>
					<option value="7">August</option>
					<option value="8">September</option>
					<option value="9">October</option>
					<option value="10">November</option>
					<option value="11">December</option>
				</select>
				</p>
			</div>
		</div>

		<div class="zRecurBox">
			<h3>Recurrence Limit</h3>
			<p><input type="radio" name="zRecurTypeRangeRadio" id="zRecurTypeRangeRadio1" value="0" checked="checked" /> No end date</p>
			<p><input type="radio" name="zRecurTypeRangeRadio" id="zRecurTypeRangeRadio2" value="1" /> Limit to 
			<input type="text" name="zRecurTypeRangeDays" id="zRecurTypeRangeDays" style="width:30px;" value="1" /> recurrences(s)</p>
			<p><input type="radio" name="zRecurTypeRangeRadio" id="zRecurTypeRangeRadio3"  value="2" /> Repeat until 
			<input type="text" name="zRecurTypeRangeDate" id="zRecurTypeRangeDate" style="width:90px;"value="" /></p>
		</div>
		<div class="zRecurBox">
			<h3>Exclude Days</h3>
			<p>Select Date: <input type="text" name="zRecurTypeExcludeDate" id="zRecurTypeExcludeDate" style="width:90px;" value="" /> 
			<input type="button" name="zRecurTypeExcludeDateButton" id="zRecurTypeExcludeDateButton" value="Exclude" /></p>

			<p>Excluded dates listed below. Click them to delete the exclusion.</p>
			<div id="zRecurExcludedDates"></div>

		</div>
	</div>
	<div class="zRecurBoxColumn2">
		<div class="zRecurBox zRecurPreviewBox">
			<h3>Preview</h3>
			<p><span style="background-color:##369; border-radius:5px;color:##FFF; padding:3px;">Blue</span> dates are included.  <span style="padding:3px; color:##FFF; border-radius:5px; background-color:##900;">Red</span> dates are excluded.  Click on a colored date to include or exclude them from the recurrence schedule.</p>
			<div id="zRecurPreviewCalendars"></div>
		</div>
	</div>
</div>
</cffunction>


</cfoutput>
</cfcomponent>