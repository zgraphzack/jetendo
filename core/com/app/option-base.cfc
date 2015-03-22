<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="public" output="no">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="siteType" type="string" required="yes">
	<cfscript>
	variables.type=arguments.type;
	variables.siteType=arguments.siteType;
	if(variables.type EQ "site"){
		variables.siteStorageKey="soGroupData";
		variables.typeStorageKey="soGroupData";
	}else if(variables.type EQ "theme"){
		variables.siteStorageKey="themeData";
		variables.typeStorageKey="themeTypeData";
	}else if(variables.type EQ "widget"){
		variables.siteStorageKey="widgetData";
		variables.typeStorageKey="widgetTypeData";
	}

	</cfscript>
</cffunction>

<cffunction name="getTypeCFCStruct" returntype="struct" localmode="modern" access="public">
	<cfscript>
	return application.zcore[variables.typeStorageKey].optionTypeStruct;
	</cfscript>
</cffunction>
	

<cffunction name="getTypeCFC" returntype="struct" localmode="modern" access="public">
	<cfargument name="typeId" type="string" required="yes" hint="site_id, theme_id or widget_id">
	<cfscript>
	return application.zcore[variables.typeStorageKey].optionTypeStruct[arguments.typeID];
	</cfscript>
</cffunction>

<cffunction name="getSiteData" returntype="struct" localmode="modern" access="public">
	<cfargument name="key" type="string" required="yes" hint="site_id, theme_id or widget_id">
	<cfscript>
	return application.siteStruct[arguments.key].globals[variables.siteStorageKey];
	</cfscript>
</cffunction>

<cffunction name="getTypeData" returntype="struct" localmode="modern" access="public">
	<cfargument name="key" type="string" required="yes" hint="site_id, theme_id or widget_id">
	<cfscript>
	return application.zcore[variables.typeStorageKey][arguments.key];
	</cfscript>
</cffunction>

<cffunction name="getOptionTypeCFCs" returntype="struct" localmode="modern" access="public">
	<cfscript>
	ts={
		"0": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.textOptionType"),
		"1": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.textareaOptionType"),
		"2": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.htmlEditorOptionType"),
		"3": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.imageOptionType"),
		"4": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.dateTimeOptionType"),
		"5": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.dateOptionType"),
		"6": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.timeOptionType"),
		"7": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.selectMenuOptionType"),
		"8": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.checkboxOptionType"),
		"9": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.fileOptionType"),
		"10": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.emailOptionType"),
		"11": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.htmlSeparatorOptionType"),
		"12": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.hiddenOptionType"),
		"13": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.mapPickerOptionType"),
		"14": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.radioOptionType"),
		"15": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.urlOptionType"),
		"16": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.userPickerOptionType"),
		"17": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.numberOptionType"),
		"18": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.colorOptionType"),
		"19": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.stateOptionType"),
		"20": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.countryOptionType"),
		"21": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.listingSavedSearchOptionType")
	};
	return ts;
	</cfscript>
</cffunction>

<cffunction name="processSearchGroupSQL" access="private" output="no" returntype="string" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="field" type="string" required="yes">
	<cfargument name="multipleValues" type="boolean" required="yes">
	<cfargument name="delimiter" type="string" required="yes">
	<cfargument name="concatAppendPrepend" type="string" required="yes">
	<cfscript>
	arrValue=arguments.struct.arrValue;
	length=arrayLen(arrValue);
	type=arguments.struct.type;
	match=true;
	arrSQL=[];
	field=arguments.field;
	if(arguments.concatAppendPrepend NEQ ""){
		arguments.concatAppendPrepend=application.zcore.functions.zescape(arguments.concatAppendPrepend);
		field="concat('#arguments.concatAppendPrepend#', #field#, '#arguments.concatAppendPrepend#')";
	}
	multipleError="arguments.multipleValues EQ true isn't supported by processSearchGroupSQL.  Only non-sql in-memory searches can have multiple values.";
	if(type EQ "="){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]=arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend;
					arrayAppend(arrSQL2, field&" = '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" = '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "<>"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]=arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend;
					arrayAppend(arrSQL2, field&" <> '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " and ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" <> '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "between"){
		if(arguments.multipleValues){
			throw(multipleError);
		}
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		arrayAppend(arrSQL, field&" BETWEEN '"&application.zcore.functions.zescape(arrValue[1])&"' and '"&application.zcore.functions.zescape(arrValue[2])&"' ");
	}else if(type EQ "not between"){
		if(arguments.multipleValues){
			throw(multipleError);
		}
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		arrayAppend(arrSQL, field&" NOT BETWEEN '"&application.zcore.functions.zescape(arrValue[1])&"' and '"&application.zcore.functions.zescape(arrValue[2])&"' ");
	}else if(type EQ ">"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" > '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" > '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ ">="){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" >= '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" >= '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "<"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" = '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " < "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" < '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "<="){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" <= '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" <= '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "like"){
		for(g=1;g LTE length;g++){ 
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]='%'&arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend&'%';
					arrayAppend(arrSQL2, field&" LIKE '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" LIKE '%"&application.zcore.functions.zescape(arrValue[g])&"%' ");
			}
		}
	}else if(type EQ "not like"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]='%'&arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend&'%';
					arrayAppend(arrSQL2, field&" = '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " and ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" NOT LIKE '%"&application.zcore.functions.zescape(arrValue[g])&"%' ");
			}
		}
	}else{
		throw("Invalid field type, ""#type#"".  Valid types are =, <>, <, <=, >, >=, between, not between, like, not like");
	}
	return " ( "&arrayToList(arrSQL, " or ")&" ) ";
	</cfscript>
</cffunction>


<cffunction name="processSearchGroup" access="private" output="no" returntype="boolean" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="multipleValues" type="boolean" required="yes">
	<cfargument name="delimiter" type="string" required="yes">
	<cfscript>
	arrValue=arguments.struct.arrValue;
	length=arrayLen(arrValue);
	type=arguments.struct.type;
	field=arguments.struct.field;
	if(structkeyexists(arguments.struct, 'delimiter')){
		arguments.delimiter=arguments.struct.delimiter;
	}
	row=arguments.row;
	match=true;
	
	if(arguments.multipleValues){
		arrRowValues=listToArray(row[field], arguments.delimiter);
	}else{
		arrRowValues=[row[field]];
	}
	rowLength=arrayLen(arrRowValues);
	
	if(type EQ "="){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrValue[g] EQ arrRowValues[n]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "<>"){
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrValue[g] EQ arrRowValues[n]){
					match=false;
					break;
				}
			}
		}
	}else if(type EQ "between"){
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		match=false;
		for(n=1;n LTE rowLength;n++){
			if(arrRowValues[n] GTE arrValue[1]  and arrRowValues[n] LTE arrValue[2]){
				match=true; 
				break;
			}
		}
	}else if(type EQ "not between"){
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		match=false;
		for(n=1;n LTE rowLength;n++){
			if(arrRowValues[n] LT arrValue[1] or arrRowValues[n] GT arrValue[2]){
				match=true; 
			}
		}
	}else if(type EQ ">"){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] GT arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ ">="){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] GTE arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "<"){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] LT arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "<="){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] LTE arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "like"){
		match=false;
		for(g=1;g LTE length;g++){ 
			for(n=1;n LTE rowLength;n++){
				if(refindnocase(replace('%'&arrValue[g]&'%', "%", ".*", "all"), arrRowValues[n]) NEQ 0){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "not like"){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(refindnocase(replace('%'&arrValue[g]&'%', "%", ".*", "all"), arrRowValues[n]) EQ 0){
					match=true;
					break;
				}
			}
		}
	}else{
		throw("Invalid field type, ""#type#"".  Valid types are =, <>, <, <=, >, >=, between, not between, like, not like");
	}
	return match;
	</cfscript>
</cffunction>

<!--- 
used to do search for a list of values
 --->
<cffunction name="getSearchListAsArray" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="true">
	<cfargument name="valueList" type="string" required="true">
	<cfargument name="compareOperator" type="string" required="true" hint="Valid values are =, !=, <, <=, >, >=, LIKE, NOT LIKE">
	<cfargument name="groupOperator" type="string" required="true" hint="Valid values are AND or OR">
	<cfscript>
	arrValue=listToArray(arguments.valueList, ',', false);
	count=arrayLen(arrValue);
	arrSearch=[];
	for(i=1;i LTE count;i++){
		t9={
			type=arguments.compareOperator,
			field: arguments.fieldName,
			arrValue:[arrValue[i]]	
		}
		arrayAppend(arrSearch, t9);
		if(i NEQ count){
			arrayAppend(arrSearch, arguments.groupOperator);
		}
	}
	return arrSearch;
	</cfscript>
</cffunction>


<cffunction name="rebuildParentStructData" localmode="modern" access="private">
	<cfargument name="parentStruct" type="struct" required="yes">
	<cfargument name="arrLabel" type="array" required="yes">
	<cfargument name="arrValue" type="array" required="yes">
	<cfargument name="arrCurrent" type="array" required="yes">
	<cfargument name="level" type="numeric" required="yes">
	<cfscript>
	if(arguments.level GT 50){ 
		throw("Possible infinite recursion.  Throwing error to prevent stackoverflow.");
	}
	for(local.f=1;local.f LTE arraylen(arguments.arrCurrent);local.f++){
		if(arguments.level NEQ 0){
			local.pad=replace(ljustify(" ", arguments.level*3), " ", "_", "ALL");
		}else{
			local.pad="";
		}
		arrayappend(arguments.arrLabel, local.pad&arguments.arrCurrent[local.f].label);
		if(structkeyexists(arguments.arrCurrent[local.f], 'idChild')){
			arrayappend(arguments.arrValue, arguments.arrCurrent[local.f].idChild);
		}else{
			arrayappend(arguments.arrValue, arguments.arrCurrent[local.f].id);
		}
		//writeoutput( arguments.arrCurrent[local.f].id&" | "& arguments.arrCurrent[local.f].label);
		if(structkeyexists(arguments.parentStruct, arguments.arrCurrent[local.f].id) and arguments.arrCurrent[local.f].id NEQ 0){ 
			variables.rebuildParentStructData(arguments.parentStruct, arguments.arrLabel, arguments.arrValue, arguments.parentStruct[arguments.arrCurrent[local.f].id], arguments.level+1);
		}
	}
	</cfscript>
</cffunction>


<cffunction name="processSearchArraySQL" access="private" output="no" returntype="string" localmode="modern">
	<cfargument name="arrSearch" type="array" required="yes"> 
	<cfargument name="fieldStruct" type="struct" required="yes">
	<cfargument name="tableCount" type="numeric" required="yes"> 
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript> 
	length=arraylen(arguments.arrSearch);
	lastMatch=true;
	arrSQL=[' ( '];
	t9=getSiteData(request.zos.globals.id);
	for(i=1;i LTE length;i++){
		c=arguments.arrSearch[i]; 
		if(isArray(c)){
			sql=this.processSearchArraySQL(c, arguments.fieldStruct, arguments.tableCount, arguments.option_group_id);
			arrayAppend(arrSQL, sql); 
		}else if(isStruct(c)){
			if(structkeyexists(c, 'subGroup')){
				throw("subGroup, ""#c.subGroup#"", has caching disabled. subGroup search is not supported yet when caching is disabled (i.e. option_group_enable_cache = 0).");
			}else{
				optionId=t9.optionIdLookup[arguments.option_group_id&chr(9)&c.field];
				if(not structkeyexists(arguments.fieldStruct, optionId)){
					arguments.fieldStruct[optionId]=arguments.tableCount;
					arguments.tableCount++;
				} 
				if(application.zcore.functions.zso(t9.optionLookup[optionId].optionStruct,'selectmenu_multipleselection', true, 0) EQ 1){
					multipleValues=true;
					if(t9.optionLookup[optionId].optionStruct.selectmenu_delimiter EQ "|"){
						delimiter=',';
					}else{
						delimiter='|';
					}
				}else{
					multipleValues=false;
					delimiter='';
				}
				if(structkeyexists(c, 'concatAppendPrepend')){
					concatAppendPrepend=c.concatAppendPrepend;
				}else{
					concatAppendPrepend='';
				}
				tableName="sGroup"&arguments.fieldStruct[optionId];
				field='sVal'&optionId;
				currentCFC=getTypeCFC(t9.optionLookup[optionId].type);
				fieldName=currentCFC.getSearchFieldName('s1', tableName, t9.optionLookup[optionId].optionStruct);
				arrayAppend(arrSQL, this.processSearchGroupSQL(c, fieldName, multipleValues, delimiter, concatAppendPrepend));// "`"&tableName&"`.`"&field&"`"));
				if(i NEQ length and not isSimpleValue(arguments.arrSearch[i+1])){
					arrayAppend(arrSQL, ' and ');
				}
			}
		}else if(c EQ "OR"){
			if(i EQ 1 or i EQ length){
				throw("""OR"" must be between an array or struct, not at the beginning or end or the array.");
			}
			arrayAppend(arrSQL, 'or');
		}else if(c EQ "AND"){
			if(i EQ 1 or i EQ length){
				throw("""AND"" must be between an array or struct, not at the beginning or end or the array.");
			}
			arrayAppend(arrSQL, 'and');
		}else{
			savecontent variable="output"{
				writedump(c);
			}
			throw("Invalid data type.  Dump of object:"&c);
		}
	}
	if(arrayLen(arrSQL) EQ 1){
		arrayAppend(arrSQL, "1=1");
	}
	arrayAppend(arrSQL, ' ) ');
	return arrayToList(arrSQL, " ");
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>