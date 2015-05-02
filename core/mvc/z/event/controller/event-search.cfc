<cfcomponent>
<cfoutput> 

<cffunction name="index" access="remote">
	<cfscript>
	arr1=application.zcore.functions.zSiteOptionGroupStruct("Event Category");
	arrLabel=[];
	arrValue=[];
	for(i=1;i LTE arraylen(arr1);i++){
		arrayAppend(arrLabel, replace(arr1[i].name, "|", "-", "all"));
		arrayAppend(arrValue, '/calendar/results?startdate=#dateformat(now(), "m/d/yyyy")#&enddate=#dateformat(dateadd("d", 90, now()), "m/d/yyyy")#&categories=#arr1[i].__setId#');
	}
	selectStruct = StructNew();
	selectStruct.name = "event_category_id";
	selectStruct.selectedValues="";
	selectStruct.onchange="";
	selectStruct.listLabels = arrayToList(arrLabel, "|");
	selectStruct.listValues =  arrayToList(arrValue, "|");
	selectStruct.onchange="window.location.href=this.options[this.selectedIndex].value;";
	selectStruct.listLabelsDelimiter = "|"; // tab delimiter
	selectStruct.listValuesDelimiter = "|";
	application.zcore.functions.zInputSelectBox(selectStruct);
	</cfscript>
</div>
<div class="sh-32">
	<input type="submit" name="submit1" value="" onclick="var d=document.getElementById('event_category_id'); var v=d.options[d.selectedIndex].value; window.location.href=v;" style="border:none; background:none;cursor:pointer; width:74px; height:33px; float:left;" />
</div>
</cffunction>
</cfoutput>
</cfcomponent>