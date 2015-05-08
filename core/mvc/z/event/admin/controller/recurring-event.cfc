<cfcomponent>
<cfoutput>
	<!--- 

					// read docs: http://www.kanzaki.com/docs/ical/rrule.html
					http://www.kanzaki.com/docs/ical/rrule.html

	consider using this for RRULE I/O
		https://www.npmjs.org/package/rrule
		https://raw.githubusercontent.com/jakubroztocil/rrule/master/lib/rrule.js
	 --->
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.zRequireJqueryUI();
	application.zcore.skin.includeJs("/z/javascript/rrule/lib/rrule.js", '', 1);
	application.zcore.skin.includeJs("/z/javascript/rrule/lib/nlp.js", '', 2);
	application.zcore.skin.includeJs("/z/javascript/jetendo/zRecurringEvent.js");

	application.zcore.template.setPlainTemplate();
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
	<!---
	function testRules(){
		// might have to remove RRULE: from beginning of rules.
		var r='FREQ=YEARLY;BYMONTH=2;BYMONTHDAY=2';
		r='FREQ=MONTHLY;UNTIL=20151224T000000Z;BYDAY=1FR'; // first friday every month
		r='FREQ=MONTHLY;UNTIL=20151224T000000Z;BYDAY=FR'; // fridays every month
		r='FREQ=YEARLY;UNTIL=20151224T000000Z;BYMONTH=2;BYDAY=FR'; // march fridays
		//r='FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13'; // friday the 13 forever
		r='FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=-1SU'; // first and last sunday - limit to 10 - every other // 1SU,

		//daily
		r='COUNT=0;FREQ=DAILY;INTERVAL=2;UNTIL=20171224T000000Z';

		//r='BYDAY=MO,TU,WE,TH,FR;COUNT=0;FREQ=DAILY;INTERVAL=1';

		// weekly
		//r='BYDAY=MO,WE,FR;COUNT=0;FREQ=WEEKLY;INTERVAL=2';
		//monthly
		//r='BYDAY=SU;COUNT=0;FREQ=MONTHLY;INTERVAL=1';
		//r='BYDAY=+1SU;COUNT=0;FREQ=MONTHLY;INTERVAL=1';
		//r='BYDAY=-1SU;COUNT=0;FREQ=MONTHLY;INTERVAL=1';
		//r='BYMONTHDAY=-1;COUNT=0;FREQ=MONTHLY;INTERVAL=1';
		//r='BYDAY=MO,TU,WE,TH,FR,SA,SU;COUNT=0;FREQ=MONTHLY;INTERVAL=1';
		//r='BYMONTHDAY=2;COUNT=0;FREQ=MONTHLY;INTERVAL=1';

		//annually
		//r='BYMONTH=3;BYMONTHDAY=3;COUNT=0;FREQ=YEARLY;INTERVAL=1';
		//r='BYMONTH=3;BYDAY=+1SU;COUNT=0;FREQ=YEARLY;INTERVAL=1';
		//r='BYMONTH=3;BYDAY=-1FR;COUNT=0;FREQ=YEARLY;INTERVAL=1';
		//r='BYMONTH=4;BYDAY=SU;COUNT=0;FREQ=YEARLY;INTERVAL=1';
		r='#form.event_recur_ical_rules#';
		var options={ 
			//ruleObj:ruleObj,
			//arrExclude:arrExclude
		};
		var recur=new zRecurringEvent(options);
		var ruleObj=recur.convertFromRRuleToRecurringEvent(r);
		console.log(ruleObj);
		recur.setFormFromRules(ruleObj, false); 

		var rule=recur.convertFromRecurringEventToRRule(ruleObj);

		if($("##event_recur_ical_rules", window.parent.document).length){
			$("##event_recur_ical_rules", window.parent.document).val(rule);
		}
		/*var rule = RRule.fromString(r);
		rule.options.count=3;
		console.log(rule);
		console.log(rule.toString());
		console.log(rule.all());
		console.log(rule.between(new Date(2014, 7, 1), new Date(2015, 8, 1)));
		*/
	}--->

	function initRules(){

		var r='#form.event_recur_ical_rules#'; 
		var options={ 
			//ruleObj:ruleObj,
			//arrExclude:arrExclude
		};

		var recur=new zRecurringEvent(options); 
		var ruleObj=recur.convertFromRRuleToRecurringEvent(r);
		console.log(ruleObj);
		console.log('---');
		recur.setFormFromRules(ruleObj, false); 
		var arrExclude=#excludeJson#;
		for(var i=0;i<arrExclude.length;i++){
			var date=new Date(arrExclude[i]);
			console.log(date);
			recur.addExcludeDate(date);
		}

		var rule=recur.convertFromRecurringEventToRRule(ruleObj);

		if($("##event_recur_ical_rules", window.parent.document).length){
			$("##event_recur_ical_rules", window.parent.document).val(rule);
		}
	}

	zArrDeferredFunctions.push(function(){
		//testRules();return

		initRules();
		return;

		/*
		var ruleObj={};
		ruleObj.recurType="Weekly";
		ruleObj.noEndDate=false;
		ruleObj.everyWeekday=true;
		ruleObj.skipDays=3;
		ruleObj.recurLimit=5;
		ruleObj.endDate=false;
		//ruleObj.endDate="12/20/2014";
		ruleObj.skipWeeks=1;
		ruleObj.skipMonths=2;
		ruleObj.skipYears=2;
		ruleObj.arrWeeklyDays=[6];
		ruleObj.monthlyWhich="Every";
		ruleObj.monthlyDay="Sunday";
		ruleObj.arrMonthlyCalendarDay=[];//1,10,15,20,21,0];
		ruleObj.annuallyWhich="Every";
		ruleObj.annuallyDay="Saturday";
		ruleObj.annuallyMonth=6;
		var arrExclude=[];
		arrExclude.push("8/21/2014");
		arrExclude.push("10/1/2014");
		arrExclude.push("1/1/2015");
		var options={ 
			//ruleObj:ruleObj,
			//arrExclude:arrExclude
		};
		var recur=new zRecurringEvent(options);
		//recur.setFormFromRules(ruleObj);
		*/
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
			<p>Start date: #dateformat(form.event_start_datetime, 'm/d/yyyy')# <input type="hidden" id="event_start_datetime_date" name="event_start_datetime_date" value="#htmleditformat(form.event_start_datetime)#"></p>
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