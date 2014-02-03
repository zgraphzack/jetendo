<cfcomponent>
<cfoutput>

  <!--- text=application.zcore.functions.zCleanSearchText(text); --->
 <cffunction name="zCleanSearchText" localmode="modern" output="yes" returntype="any">
		<cfargument name="text" type="string" required="yes">
		<cfargument name="nolinks" type="boolean" required="no" default="#false#">
		<cfscript>
	var links="";
	var badTagList="style|link|head|script|embed|base|input|textarea|button|object|iframe|form";
	arguments.text=lcase(arguments.text);
	// remove tags that have useless contents nested in them
	arguments.text=rereplacenocase(arguments.text,"<(#badTagList#)[^>]*?>.*?</\1>", " ", 'ALL');			
	if(arguments.nolinks EQ false){
		links=replace(arguments.text,chr(9),' ','ALL');		
		links=replace(links,chr(10),' ','ALL');		
		links=replace(links,chr(13),' ','ALL');
		
		// extract links with or without quotes
		links=rereplacenocase(links,"[^>^<]*<(area|a)\s[^>]*\s?href\s*=\s*(""|'|)([^\2^\s]*)\2\s*?[^>]*>.*?</\1>[^>^<]*",chr(9)&'\3'&chr(9),'ALL');
		
		if(find(chr(9),links) EQ 0) links="";
		// remove everything but the links
		links=rereplacenocase(links,"[^\t]*?\t([^\t]*)\t?[^\t]*", "\1 ", 'ALL');
		// put links at the top
		arguments.text=links&arguments.text;
	}
	// remove all html tags
	arguments.text=rereplacenocase(arguments.text,"<.*?>", " ", 'ALL');
	// remove html entities
	arguments.text=rereplacenocase(arguments.text,"&[^\s]*?;", " ", 'ALL');
	
	// remove http
	arguments.text=rereplacenocase(arguments.text,"(http\:|https\:|mailto\:|www\.|\b(\S\S|\S)\b|[^a-z0-9@]|\s)", " ", 'ALL');
	// remove consequtive spaces
	arguments.text=rereplacenocase(arguments.text,"\s*(\S*)", " \1", 'ALL');
	// trim and return
	arguments.text=trim(arguments.text);
	return arguments.text;
	</cfscript>
</cffunction>

<cffunction name="zViewQueryError" localmode="modern" output="yes" returntype="any">
    <cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var local=structnew();
    if(arguments.ss.cfcatch.message CONTAINS "No value specified for parameter"){
        writeoutput('<div style="border:1px solid ##CCC; background-color:##EFEFEF; padding:20px; color:##000; font-size:18px;"><p style="color:##000;font-weight:bold; font-size:24px; line-height:30px;">Jetendo CMS Database Error Help</p><p style="font-size:18px; line-height:24px; color:##000;">This error occurs when the data type for one of the parameters doesn''t match the cfsqltype value in the &lt;cfqueryparam&gt; tag.</p>');
		local.pos=listgetat(arguments.ss.cfcatch.message,listlen(arguments.ss.cfcatch.message," ")," ");
		if(local.pos LTE arraylen(arguments.ss.arrOrder)){
			writeoutput('<p style="font-size:18px; line-height:24px; color:##000;">Incorrect Data Type for "'&arguments.ss.arrOrder[local.pos]&'". The current value is "'&arguments.ss.arguments[arguments.ss.arrOrder[local.pos]]&'" and it should be corrected to be this type: "'&arguments.ss.arrFieldType[local.pos]&'"</p>');	
		}
		writeoutput('</div>');
    }
	application.zcore.functions.zdump(arguments.ss.cfcatch);
	application.zcore.functions.zabort();
    </cfscript>
</cffunction>
 
<!--- application.zcore.functions.zAppendSiteTableDefaults(); --->
<cffunction name="zAppendSiteTableDefaults" localmode="modern" returntype="struct" access="public" output="no">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfscript> 
	structappend(arguments.dataStruct, application.zcore.siteTableColumns, false);
	return arguments.dataStruct;
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zAppendTableDefaults(dataStruct, request.zos.zcoreDatasource, "table"); --->
<cffunction name="zAppendTableDefaults" localmode="modern" returntype="struct" access="public" output="no">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="database" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfscript>
	if(structkeyexists(application.zcore.tableColumns, arguments.database&"."&arguments.table)){
		structappend(arguments.dataStruct, application.zcore.tableColumns[arguments.database&"."&arguments.table], false);
	}else{
		throw("database.table, #arguments.database#.#arguments.table# doesn't exist", "exception");
	}
	return arguments.dataStruct;
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zGetSiteIdTypeSQL("siteIdTypeFieldName"); --->
<cffunction name="zGetSiteIdTypeSQL" localmode="modern" output="no" returntype="any">
	<cfargument name="siteIdTypeFieldName" type="string" required="yes">
    <cfscript>
	/*
	1 is current site
	2 is parent site
	3 is admin site
	4 is zero site
	*/
	return " if("&arguments.siteIdTypeFieldName&" = 1, "&request.zos.globals.id&", if("&arguments.siteIdTypeFieldName&"= 2, "&request.zos.globals.parentId&", if("&arguments.siteIdTypeFieldName&" = 3, "&request.zos.globals.serverId&", if("&arguments.siteIdTypeFieldName&" = 4, 0, "&request.zos.globals.id&")))) ";
	</cfscript>
</cffunction>


<!--- application.zcore.functions.zGetSiteIdSQL("siteIdFieldName"); --->
<cffunction name="zGetSiteIdSQL" localmode="modern" output="no" returntype="any">
	<cfargument name="siteIdFieldName" type="string" required="yes">
    <cfscript>
	/*
	1 is current site
	2 is parent site
	3 is admin site
	4 is zero site
	*/
	return " if("&arguments.siteIdFieldName&" = #request.zos.globals.id#, 1, if("&arguments.siteIdFieldName&"= 0, 4, if("&arguments.siteIdFieldName&" = #request.zos.globals.serverId#, 3, if("&arguments.siteIdFieldName&" =  #request.zos.globals.parentId#, 2, 1)))) ";
	</cfscript>
</cffunction>
<cffunction name="zGetSiteIdType" localmode="modern" output="no" returntype="any">
	<cfargument name="siteId" type="string" required="yes">
    <cfscript>
	/*
	1 is current site
	2 is parent site
	3 is admin site
	4 is zero site
	*/
	if(arguments.siteId EQ request.zos.globals.id){
		return 1;
	}else if(arguments.siteId EQ request.zos.globals.parentid){
		return 2;
	}else if(arguments.siteId EQ request.zos.globals.serverid){
		return 3;
	}else{
		return 4;
	}
	</cfscript>
</cffunction>
<cffunction name="zGetSiteIdFromSiteIdType" localmode="modern" output="no" returntype="any">
	<cfargument name="siteIdType" type="string" required="yes">
    <cfscript>
	/*
	1 is current site
	2 is parent site
	3 is admin site
	4 is zero site
	*/
	if(arguments.siteIdType EQ 1){
		return request.zos.globals.id;
	}else if(arguments.siteIdType EQ 2){
		return request.zos.globals.parentid;
	}else if(arguments.siteIdType EQ 3){
		return request.zos.globals.serverid;
	}else if(arguments.siteIdType EQ 4){
		return 0;
	}
	</cfscript>
</cffunction>
    
<!--- application.zcore.functions.zGetLastDatabaseError(); --->
<cffunction name="zGetLastDatabaseError" localmode="modern" output="no" returntype="any">
    <cfscript>
    return request.zos.arrRequestQueries[arraylen(request.zos.arrRequestQueries)];
    </cfscript>
</cffunction>

<!--- 
ts=structnew();
ts.sql="insert or update sql here";
ts.datasource=request.zos.zcoredatasource;
application.zcore.functions.zQueueQuery(ts);
 --->
<cffunction name="zQueueQuery" localmode="modern" output="no" returntype="any">
    <cfargument name="ss" type="component" required="yes" hint="pass in an instance of dbQuery.cfc">
    <cfscript>
	arguments.ss.queryComplete=false;
    arrayappend(request.zos.arrQueryQueue, arguments.ss);
    </cfscript>
</cffunction>

<!--- application.zcore.functions.zProcessQueryQueue(); --->
<cffunction name="zProcessQueryQueue" localmode="modern" output="no" returntype="any">
    <cfscript>
    var i=1;
    
		if(isDefined('request.zos.arrQueryQueue')){
			for(i=1;i LTE arraylen(request.zos.arrQueryQueue);i++){
				if(request.zos.arrQueryQueue[i].queryComplete EQ false){
					request.zos.arrQueryQueue[i].result=request.zos.arrQueryQueue[i].execute();
					request.zos.arrQueryQueue[i].queryComplete=true;
				}
			}
		}
        </cfscript>
</cffunction>

<cffunction name="zNewRecord" localmode="modern" output="no" returntype="struct">
	<cfargument name="database" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfscript>
	if(structkeyexists(application.zcore.tableColumns, arguments.database&"."&request.zos.zcoreDatasourcePrefix&arguments.table) EQ false){
		application.zcore.template.fail("database table, """&arguments.database&"."&request.zos.zcoreDatasourcePrefix&arguments.table&""", doesn't exist.");	
	}
	return duplicate(application.zcore.tableColumns[arguments.database&"."&request.zos.zcoreDatasourcePrefix&arguments.table]);
	</cfscript>
</cffunction>


<!--- application.zcore.functions.zProcessQueryQueueThreaded(); --->
<cffunction name="zProcessQueryQueueThreaded" localmode="modern" output="no" returntype="any">
    <cfscript>
    var i=1;
	var ts=0;
		var db=request.zos.queryObject;
	var arrQueue=0;
	//var thread=0;
	request.zos.queryQueueThreadIndex++;
	if(structkeyexists(request.zos,'arrQueryQueue') EQ false){
		request.zos.arrQueryQueue=[];
		/* or arraylen(request.zos.arrQueryQueue) EQ 0){
		return;*/
	}
	if(arraylen(request.zos.arrQueryQueue) EQ 0){
		return;
	}
    </cfscript>
    <cfthread action="run" name="zcoreasyncquerythread#request.zos.queryQueueThreadIndex#" timeout="30" arrQueue="#request.zos.arrQueryQueue#"><!---  --->
         <cfscript>
		 thread.arrComplete=arraynew(1);
		// arrQueue=request.zos.arrQueryQueue;
		for(i=1;i LTE arraylen(arrQueue);i++){
			if(arrQueue[i].queryComplete EQ false){
				ts=structnew();
				ts.result=application.zcore.functions.zexecutesql(arrQueue[i].sql, arrQueue[i].datasource); 
				ts.queryComplete=true;
				//arrayappend(thread.arrComplete, ts);
			}
		}
        </cfscript>
    </cfthread><!---  --->
</cffunction>


<!--- application.zcore.functions.zTableSQL(name, alias, datasource); --->
<cffunction name="zTableSQL" localmode="modern" output="no" returntype="string" hint="This function is deprecated, use dbQuery.cfc table()">
	<cfargument name="name" type="string" required="yes" hint="Table name">
	<cfargument name="alias" type="any" required="no" default="" hint="Set to false to disable the alias.">
	<cfargument name="datasource" type="string" required="no" default="" hint="Set the datasource the table is in. Datasource must match database name.">
    <cfscript>
	var dbname=replace(replace(arguments.name,"\","\\","ALL"),"'","\'","ALL");
	var aliasSQL="";
	var zt="";
	if(arguments.alias NEQ "" and arguments.alias NEQ false){
		aliasSQL=" as `"&arguments.name&"`";
		if(arguments.alias NEQ ""){
			aliasSQL=" as `"&arguments.alias&"`";
		}
	}
	if(request.zos.isdeveloper and isDefined('session.zos.verifyQueries') and session.zos.verifyQueries){
		zt=":ztablesql:";	
	}
	/*if(structkeyexists(application.zcore.sharedTables, arguments.name)){
		if(arguments.datasource NEQ ""){
			return "`"&arguments.datasource&"`.`"&request.zos.zcoreDatasourcePrefix&dbname&"` #aliasSQL#";
		}else{
			return "`"&application.zcore.serverGlobals.datasource&"`.`"&request.zos.zcoreDatasourcePrefix&dbname&"` #aliasSQL#";
		}
	}else{*/
		if(arguments.datasource NEQ ""){
			return "`"&arguments.datasource&"`.`"&zt&request.zos.zcoreDatasourcePrefix&replace(replace(arguments.name,"\","\\","ALL"),"'","\'","ALL")&"` #aliasSQL#";
		}else{
			return "`"&request.zos.globals.datasource&"`.`"&zt&request.zos.zcoreDatasourcePrefix&replace(replace(arguments.name,"\","\\","ALL"),"'","\'","ALL")&"` #aliasSQL#";
		}
	//}
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zGetUUID(1)[1]; --->
<cffunction name="zGetUUID" localmode="modern" output="no" returntype="array" hint="Grab one bigint primary key id for mysql inserts from the server scope.  If none are available, get a new batch of them.">
	<cfargument name="count" type="numeric" required="no" default="#1#" hint="A number between 0 and 200">
	<cfscript>
	var curId=0;
	var arrId=arraynew(1);
	var i=0;
	var m=0;
	var k=0;
	var g=0;
	var c=0;
	var done=false;
	arrayresize(arrId,arguments.count);
	</cfscript> 
    <cflock name="server_zcore_zGetUUID" type="exclusive" throwontimeout="yes" timeout="60">
		<cfscript>
		while(true){
			k=structcount(application.zcore.uuidCacheStruct);
			if(k LT arguments.count){
				application.zcore.functions.zGetUUIDFromDatabase();
				k +=40;
			}
			if(arguments.count EQ 1){
				for(i in application.zcore.uuidCacheStruct){
					arrId[1]=application.zcore.uuidCacheStruct[i];
					structdelete(application.zcore.uuidCacheStruct, i);
					return arrId;
				}
			}else{
				for(i in application.zcore.uuidCacheStruct){
					c++; 
					arrId[c]=application.zcore.uuidCacheStruct[i];
					structdelete(application.zcore.uuidCacheStruct, i);
					if(c EQ arguments.count){
						return arrId;
					}
				}
			}
			g++;
			if(g EQ 51){
				application.zcore.template.fail("Infinite loop in zGetUUID");	
			}
		}
		return arrId;
        </cfscript>
    </cflock>
</cffunction>


<!--- sql=application.zcore.functions.zDisplayResultSQL(result); --->
<cffunction name="zDisplayResultSQL" localmode="modern" returntype="any" output="true">
	<cfargument name="result" type="struct" required="yes" hint="This should be the result structure from a successfully run CFQUERY tag.">
    <cfscript>
	var i=0;
	var arrS=listtoarray(arguments.result.sql,"?",true);
	var arrR=arraynew(1);
	for(i=1;i LTE arraylen(arrS);i++){
		arrayappend(arrR, arrS[i]);
		if(i LTE arraylen(arguments.result.sqlparameters)){
			arrayappend(arrR, arguments.result.sqlparameters[i]);
		}
	}
	return arraytolist(arrR, "");
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zGetUUIDFromDatabase(); --->
<cffunction name="zGetUUIDFromDatabase" localmode="modern" output="no" returntype="any" hint="Pregenerate primary key ids for mysql's bigint columns and store then in server scope.">
    <cfscript> 
	var q331=0;
	var ts=structnew();
    </cfscript>
    <cfquery blockfactor="1" name="q331" datasource="#request.zos.globals.datasource#">
    SELECT SQL_NO_CACHE cast(UUID_SHORT() as char) auuid1, cast(UUID_SHORT() as char) auuid2, cast(UUID_SHORT() as char) auuid3, cast(UUID_SHORT() as char) auuid4, cast(UUID_SHORT() as char) auuid5, cast(UUID_SHORT() as char) auuid6, cast(UUID_SHORT() as char) auuid7, cast(UUID_SHORT() as char) auuid8, cast(UUID_SHORT() as char) auuid9, cast(UUID_SHORT() as char) auuid10 , 
    cast(UUID_SHORT() as char) a2uuid1, cast(UUID_SHORT() as char) a2uuid2, cast(UUID_SHORT() as char) a2uuid3, cast(UUID_SHORT() as char) a2uuid4, cast(UUID_SHORT() as char) a2uuid5, cast(UUID_SHORT() as char) a2uuid6, cast(UUID_SHORT() as char) a2uuid7, cast(UUID_SHORT() as char) a2uuid8, cast(UUID_SHORT() as char) a2uuid9, cast(UUID_SHORT() as char) a2uuid10 ,
cast(UUID_SHORT() as char) a3uuid1, cast(UUID_SHORT() as char) a3uuid2, cast(UUID_SHORT() as char) a3uuid3, cast(UUID_SHORT() as char) a3uuid4, cast(UUID_SHORT() as char) a3uuid5, cast(UUID_SHORT() as char) a3uuid6, cast(UUID_SHORT() as char) a3uuid7, cast(UUID_SHORT() as char) a3uuid8, cast(UUID_SHORT() as char) a3uuid9, cast(UUID_SHORT() as char) a3uuid10 ,
cast(UUID_SHORT() as char) a4uuid1, cast(UUID_SHORT() as char) a4uuid2, cast(UUID_SHORT() as char) a4uuid3, cast(UUID_SHORT() as char) a4uuid4, cast(UUID_SHORT() as char) a4uuid5, cast(UUID_SHORT() as char) a4uuid6, cast(UUID_SHORT() as char) a4uuid7, cast(UUID_SHORT() as char) a4uuid8, cast(UUID_SHORT() as char) a4uuid9, cast(UUID_SHORT() as char) a4uuid10 
    </cfquery> 
	<cfscript>
	structappend(application.zcore.uuidCacheStruct, q331,true);  
    </cfscript> 
</cffunction>


<!--- 
// required
inputStruct = StructNew();
inputStruct.table = "table";
// optional
inputStruct.enableReplace=false;
inputStruct.datasource = datasource;
inputStruct.struct = variables; // use another struct when inside functions
inputStruct.debug = false; // debug=true rethrows coldfusion errors
inputStruct.enumerate = 2; // send currentrow to insert enumerated fields
inputStruct.fieldsWithNoEnumeration = false; // list: forces function to ignore enumeration for the fields in this list.
inputStruct.overrideFields = ""; 
inputStruct.forcePrimaryInsert={};
inputStruct.enableTableFieldCache=true;
// insert
table_id = application.zcore.functions.zInsert(inputStruct); 
if(table_id EQ false){
	// failed, on duplicate key or sql error
	// exact syntax used can be found in the request.zos.arrQueryLog struct (turn on page debugging)
}else{
	// success
}
--->
<cffunction name="zInsert" localmode="modern" returntype="any" output="true">
	<cfargument name="inputStruct" type="struct" required="yes">
	<cfscript>	
	var arrInsert = ArrayNew(1);
	var qInsert = "";
	var qId = "";
	var sqlInsert = "";
	var i=0;
	var newId=0;
	var cfquery=0;
	var fields="";
	var cfcatch=0;
	var currentField = "";
	var primary_key = "";
	var tempStruct={
		enableTableFieldCache: true,
		debug: false,
		enableReplace: false,
		noRequestSQL:false,
		datasource:"",
		enumerate: "",
		fieldsWithNoEnumeration: false,
		forcePrimaryInsert={}
	}
	if(structkeyexists(Request.zOS, 'globals') and structkeyexists(Request.zOS.globals, 'datasource')){
		tempStruct.datasource = Request.zOS.globals.datasource;
	}
	var ss = "";
	// set defaults
	// override defaults
	StructAppend(arguments.inputStruct, tempStruct, false);
	ss = arguments.inputStruct; // less typing
	if(structkeyexists(arguments.inputStruct, 'table') EQ false){
		throw("Error: FUNCTION: zInsert: inputStruct.table is required.", "exception");
	}
	if(request.zos.istestserver and structkeyexists(arguments.inputStruct, 'struct') EQ false){
		throw("Error: FUNCTION: zInsert: inputStruct.struct must be set.", "exception");
	}
	</cfscript>
    <cfif ss.enableTableFieldCache or structkeyexists(request.zos.tableFieldsCache, ss.datasource&" "&ss.table) EQ false>
        <cfquery name="fields" datasource="#ss.datasource#">
        SHOW FIELDS FROM `#request.zos.zcoreDatasourcePrefix##ss.table#`
        </cfquery>
	<cfif ss.enableTableFieldCache>
    		<cfset request.zos.tableFieldsCache[ss.datasource&" "&ss.table]=fields>
	</cfif>
    <cfelse>
    	<cfset fields=request.zos.tableFieldsCache[ss.datasource&" "&ss.table]>
    </cfif>
	<cfset arrInsert = ArrayNew(1)>
	<cfset i = 1>
	<cfloop query="fields">
		<cfscript>
		if(ss.enableReplace or fields.Key NEQ "PRI" or structkeyexists(arguments.inputStruct.forcePrimaryInsert, fields.field) or (fields.field EQ "site_id" and ss.datasource&"."&ss.table NEQ request.zos.zcoredatasource&".site")){
			if(ss.fieldsWithNoEnumeration NEQ false and ListFindNoCase(ss.fieldsWithNoEnumeration, fields.Field) NEQ 0){
				currentField = fields.Field;
			}else if(structkeyexists(ss,'struct') and StructKeyExists(ss.struct, fields.Field&ss.enumerate)){
				currentField = fields.Field&ss.enumerate;
			}else if(structkeyexists(ss,'struct') EQ false and isDefined(fields.Field&ss.enumerate)){
				currentField = fields.Field&ss.enumerate;
			}else{
				currentField = fields.Field;
			}
			if(structkeyexists(ss,'struct') and StructKeyExists(ss.struct, currentField)){
				arrInsert[i] = "`"&fields.Field & "` = '" & replace(replace(ss.struct[currentField], "\",   "\\", "ALL"), "'", "''", "ALL") & "'";
				i = i + 1;
			}else if(structkeyexists(ss,'struct') EQ false and isDefined(currentField)){
				arrInsert[i] = "`"&fields.Field & "` = '" & replace(replace(evaluate(currentField), "\",   "\\", "ALL"), "'", "''", "ALL") & "'";
				i = i + 1;
			}
		}else{
			primary_key = fields.Field;
		}
		</cfscript>
	</cfloop>
	<cfscript>
	if(ss.enableReplace){
		sqlInsert="REPLACE";
	}else{
		sqlInsert="INSERT";
	}
	sqlInsert = sqlInsert&" INTO " & request.zos.noVerifyQueryObject.table(ss.table, ss.datasource) & " SET " & arrayToList(arrInsert);
	
	if(request.zos.isdeveloper){
		if(isDefined('session.zos.verifyQueries') and session.zos.verifyQueries){
			sqlInsert=application.zcore.functions.zVerifySiteIdsInQuery(sqlInsert, ss.datasource);	
		}else{
			sqlInsert=replace(sqlInsert, ":ztablesql:", "", "all");
		}
	}
	if(ss.norequestsql EQ false){
		if(not structkeyexists(Request.zos,'arrQueryLog')){
			request.zos.arrQueryLog =[];
		}
		ArrayAppend(request.zos.arrQueryLog, sqlInsert);
	}
	</cfscript>
	<cftry>
		<cfquery name="qInsert" datasource="#ss.datasource#">
		#preserveSingleQuotes(sqlInsert)#
		</cfquery>
		<cfif ss.enableReplace>
			<cfreturn true>
		</cfif>
		<cfquery name="qId" datasource="#ss.datasource#">
		SELECT @zLastInsertId id2, LAST_INSERT_ID() as id
		</cfquery>
        <cfscript>
		if(structkeyexists(application.zcore, 'tablesWithSiteIdStruct') and structkeyexists(application.zcore.tablesWithSiteIdStruct, ss.datasource&"."&ss.table) and ss.datasource&"."&ss.table NEQ request.zos.zcoredatasource&".site"){
			newId=qId.id2;
		}else{
			newId=qId.id;
		}
		</cfscript>
		<cfcatch type="database">
			<cfscript>
			if(ss.norequestsql EQ false){
				ArrayAppend(request.zos.arrQueryLog, "Query ##"& ArrayLen(request.zos.arrQueryLog)&" failed to execute for datasource, #ss.datasource#. Mysql Error:"&cfcatch.Message);
			}
			</cfscript>
			<cfif ss.debug>
				<cfrethrow>
			</cfif>
			<cfreturn false>
		</cfcatch>
        <cfcatch type="any"><cfrethrow></cfcatch>
	</cftry>
	<cfreturn newId>
</cffunction>





<!--- 
// note this function will always add site_id to the sql where clause for a table that has a site_id column to ensure isolation between sites
// required
inputStruct = StructNew();
inputStruct.table = "table";
// optional
inputStruct.datasource = datasource;
inputStruct.struct = variables; // use another struct when inside functions
inputStruct.debug = false; // debug=true rethrows coldfusion errors
inputStruct.enumerate = 2; // send currentrow to update enumerated fields
inputStruct.forceWhereFields = ""; // list: forces function to use one or more fields for the where statement.
inputStruct.enableTableFieldCache=true;
// insert
if(application.zcore.functions.zUpdate(inputStruct) EQ false){
	// failed, on duplicate key or sql error
	// exact syntax used can be found in the request.zos.arrQueryLog struct (turn on page debugging)
}else{
	// success
}
--->
<cffunction name="zUpdate" localmode="modern" returntype="any" output="true">
	<cfargument name="inputStruct" type="struct" required="yes">
	<cfscript>	
	var sqlUpdate = "";
	var qupdate=0;
	var sqlWhere = "";
	var arrUpdate = ArrayNew(1);
	var arrWhere = ArrayNew(1);
	var fields = "";
	var FieldValue = "";
	var currentField = "";
	var listPosition = "";
	var forceError = false;
	var cfcatch=0;
	var keyError = true;
	var n=0;
	var tempStruct = "";
	var hasSiteId=false;
	var cfquery=0;
	var ss = "";
	// set defaults
	tempStruct = StructNew();
	tempStruct.enableTableFieldCache=true;
	tempStruct.debug = false;
	tempStruct.noRequestSQL=false;
	if(structkeyexists(Request.zOS, 'globals') and structkeyexists(Request.zOS.globals, 'datasource')){
		tempStruct.datasource = Request.zOS.globals.datasource;
	}
	tempStruct.enumerate = ""; 
	tempStruct.forceWhereFields = ""; // list
	// override defaults
	StructAppend(arguments.inputStruct, tempStruct, false);
	ss = arguments.inputStruct; // less typing
	if(structkeyexists(application.zcore, 'tablesWithSiteIdStruct') and structkeyexists(application.zcore.tablesWithSiteIdStruct, ss.datasource&"."&ss.table)){
		hasSiteId=true;
		
	}
	if(structkeyexists(arguments.inputStruct, 'table') EQ false){
		throw("Error: FUNCTION: zInsert: inputStruct.table is required.", "exception");
	}
	if(request.zos.istestserver and structkeyexists(arguments.inputStruct, 'struct') EQ false){
		throw("Error: FUNCTION: zInsert: inputStruct.struct must be set.", "exception");
	}
	</cfscript>
    <cfif ss.enableTableFieldCache or structkeyexists(request.zos.tableFieldsCache, ss.datasource&" "&ss.table) EQ false>
	<cfquery name="fields" datasource="#ss.datasource#">
	SHOW FIELDS FROM `#request.zos.zcoreDatasourcePrefix##ss.table#`
	</cfquery>
	<cfif ss.enableTableFieldCache>
    		<cfset request.zos.tableFieldsCache[ss.datasource&" "&ss.table]=fields>
	</cfif>
    <cfelse>
    	<cfset fields=request.zos.tableFieldsCache[ss.datasource&" "&ss.table]>
    </cfif>
	<cfloop query="fields">
		<cfscript>
		if(structkeyexists(ss,'struct') and StructKeyExists(ss.struct, fields.Field&ss.enumerate)){
			FieldValue = fields.Field & ss.enumerate;
		}else if(structkeyexists(ss,'struct') EQ false and isDefined(fields.Field&ss.enumerate)){
			FieldValue = fields.Field & ss.enumerate;
		}else{
			FieldValue = fields.Field;
		}
		listPosition = listFind(ss.forceWhereFields, fields.Field);
		if(fields.field EQ "site_id"){
			if(structkeyexists(ss,'struct')){
				if(StructKeyExists(ss.struct, FieldValue) EQ false){
					arrayappend(arrWhere, "`site_id` = '" & request.zos.globals.id & "'");
				}else{
					arrayappend(arrWhere, "`site_id` = '" & replace(replace(ss.struct[FieldValue], "\",   "\\", "ALL"), "'", "''", "ALL") & "'");
				}
			}else{
				if(isDefined(FieldValue) EQ false){
					arrayappend(arrWhere, "`site_id` = '" & request.zos.globals.id & "'");
				}else{
					arrayappend(arrWhere, "`site_id` = '" & replace(replace(evaluate(FieldValue), "\",   "\\", "ALL"), "'", "''", "ALL") & "'");
				}
			}
		}else if(fields.Key NEQ "PRI" and ss.forceWhereFields NEQ false and listPosition NEQ 0){
			currentField = ListGetAt(ss.forceWhereFields, listPosition);
			if(structkeyexists(ss,'struct')){
				if(StructKeyExists(ss.struct, FieldValue) EQ false){
					forceError = true;
				}else{
					arrayappend(arrWhere, "`"&currentField & "` = '" & replace(replace(ss.struct[FieldValue], "\",   "\\", "ALL"), "'", "''", "ALL") & "'");
				}
			}else{
				if(isDefined(FieldValue) EQ false){
					forceError = true;
				}else{
					arrayappend(arrWhere, "`"&currentField & "` = '" & replace(replace(evaluate(FieldValue), "\",   "\\", "ALL"), "'", "''", "ALL") & "'");
				}
			}
		}else if(structkeyexists(ss,'struct') and StructKeyExists(ss.struct, FieldValue)){
			if(fields.Key NEQ "PRI"){
				ArrayAppend(arrUpdate, "`"&fields.Field & "` = '" & replace(replace(ss.struct[FieldValue], "\",   "\\", "ALL"), "'", "''", "ALL") & "'");
			}else{
				keyError = false;
				arrayappend(arrWhere, "`"&fields.Field & "` = '" & replace(replace(ss.struct[FieldValue], "\",   "\\", "ALL"), "'", "''", "ALL") & "'");
			}
		}else if(structkeyexists(ss,'struct') EQ false and isDefined(FieldValue)){
			if(fields.Key NEQ "PRI"){
				ArrayAppend(arrUpdate, "`"&fields.Field & "` = '" & replace(replace(evaluate(FieldValue), "\",   "\\", "ALL"), "'", "''", "ALL") & "'");
			}else{
				keyError = false;
				arrayappend(arrWhere, "`"&fields.Field & "` = '" & replace(replace(evaluate(FieldValue), "\",   "\\", "ALL"), "'", "''", "ALL") & "'");
			}
		}
		</cfscript>
	</cfloop>
	<cfset sqlWhere = " WHERE " & ArrayToList(arrWhere, " and ")>
	<cfset sqlUpdate = "UPDATE " & request.zos.noVerifyQueryObject.table(ss.table, ss.datasource) & " SET " & arrayToList(arrUpdate) & sqlWhere>
	<cfif ArrayLen(arrWhere) EQ 0 or forceError>
		<cftry><cfthrow message="Error: FUNCTION: zUpdate: Missing one or more required fields(#ss.forceWhereFields#) of WHERE statement.">
			<cfcatch type="any">
				<cfscript>
				if(ss.norequestsql EQ false){
					ArrayAppend(request.zos.arrQueryLog, "Query is missing one or more required fields of WHERE statement. Error:"&cfcatch.Message&" SQL: "&sqlUpdate);
				}
				</cfscript>
				<cfif ss.debug>
					<cfrethrow>
				</cfif>
				<cfreturn false>
			</cfcatch>
		</cftry>
	<cfelse>
		<cftry>
        	<cfscript>
			if(request.zos.isdeveloper){
				if(isDefined('session.zos.verifyQueries') and session.zos.verifyQueries){
					sqlUpdate=application.zcore.functions.zVerifySiteIdsInQuery(sqlUpdate, ss.datasource);	
				}else{
					sqlUpdate=replace(sqlUpdate, ":ztablesql:", "", "all");
				}
			}
            if(ss.norequestsql EQ false){
                ArrayAppend(request.zos.arrQueryLog, sqlUpdate);
            }
            </cfscript>
			<cfquery name="qUpdate" datasource="#ss.datasource#">
			#preserveSingleQuotes(sqlUpdate)#
			</cfquery>
			<cfcatch type="any">
            	<cfif cfcatch.Message CONTAINS "Duplicate entry">
					<cfscript>				
                    if(ss.norequestsql EQ false){
                        ArrayAppend(request.zos.arrQueryLog, "Query ##"& ArrayLen(request.zos.arrQueryLog)&" failed to execute for datasource, #ss.datasource#.");
                    }
                    </cfscript>
					<cfif ss.debug>
                        <cfrethrow>
                    </cfif>
                	<cfreturn false>
                <cfelse>
					<cfrethrow>
				</cfif>
			</cfcatch>
		</cftry>
		<cfreturn true>
	</cfif>
</cffunction>


<cffunction name="zVerifySiteIdsInDBCFCQuery" localmode="modern" access="public" returntype="struct">
    <cfargument name="parsedSQLStruct" type="struct" required="yes">
    <cfscript>
    var local=structnew();
    var ps=arguments.parsedSQLStruct;
    for(local.i2=1;local.i2 LTE arraylen(ps.arrLeftJoin);local.i2++){
        if(structkeyexists(application, 'zcore') and structkeyexists(application.zcore, 'tablesWithSiteIdStruct') and structkeyexists(application.zcore.tablesWithSiteIdStruct, ps.arrLeftJoin[local.i2].table)){
            // search for reference to tableAlias.site_id in onstatement OR wherestatement
            if(ps.arrLeftJoin[local.i2].onstatement DOES NOT CONTAIN ps.arrLeftJoin[local.i2].tableAlias&".site_id" and ps.whereStatement DOES NOT CONTAIN ps.arrLeftJoin[local.i2].tableAlias&".site_id"){
                arrayappend(ps.arrError, ps.arrLeftJoin[local.i2].tableAlias&".site_id must be in the WHERE STATEMENT or the ON statement of LEFT JOIN "&ps.arrLeftJoin[local.i2].tableAlias);
            }
        }
    }
    for(local.i2=1;local.i2 LTE arraylen(ps.arrTable);local.i2++){
        if(structkeyexists(application, 'zcore') and structkeyexists(application.zcore, 'tablesWithSiteIdStruct') and structkeyexists(application.zcore.tablesWithSiteIdStruct, ps.arrTable[local.i2].table)){
            // search for reference to tableAlias.site_id in onstatement OR wherestatement
            if(ps.valuesPos and (ps.insertPos or ps.replacePos)){
                local.c43=mid(c, ps.intoPos+6, ps.valuesPos-(ps.intoPos+6));
                if(local.c43 DOES NOT CONTAIN "site_id"){
                    arrayappend(ps.arrError, "site_id must be in the COLUMN LIST.");
                }
            }
            if(ps.intoPos){
                if(ps.selectPos){
                    if(ps.whereStatement NEQ "" and ps.arrTable[local.i2].type EQ "into"){
                        if((arraylen(ps.arrTable) GT 1 or arraylen(ps.arrLeftJoin) NEQ 0) and ps.whereStatement DOES NOT CONTAIN ps.arrTable[local.i2].tableAlias&".site_id"){
                            arrayappend(ps.arrError, ps.arrTable[local.i2].tableAlias&".site_id must be in the WHERE STATEMENT.1");
                        }else if(arraylen(ps.arrTable) EQ 1 and arraylen(ps.arrLeftJoin) EQ 0 and ps.whereStatement DOES NOT CONTAIN "site_id"){
                            arrayappend(ps.arrError, ps.arrTable[local.i2].tableAlias&".site_id must be in the WHERE STATEMENT.2");
                        }
                    }
                }
            }else{
                if(ps.setPos){
                    if(ps.setStatement DOES NOT CONTAIN "site_id"){
                        arrayappend(ps.arrError, "site_id must be in the SET STATEMENT.3");
                    }
                    if(ps.wherePos and ps.whereStatement NEQ ""){
                        if(arraylen(ps.arrTable) EQ 1){
                            if(ps.whereStatement DOES NOT CONTAIN "site_id"){
                                arrayappend(ps.arrError, "site_id must be in the WHERE STATEMENT.4");
                            }
                        }else{
                            if(ps.whereStatement DOES NOT CONTAIN ps.arrTable[local.i2].tableAlias&".site_id"){
                                arrayappend(ps.arrError, "site_id must be in the WHERE STATEMENT.5");
                            }
                        }
                    }
                    
                }else if(ps.whereStatement NEQ "" and ps.arrTable[local.i2].type EQ "from"){
                    if((arraylen(ps.arrTable) GT 1 or arraylen(ps.arrLeftJoin) NEQ 0) and ps.whereStatement DOES NOT CONTAIN ps.arrTable[local.i2].tableAlias&".site_id"){
                        arrayappend(ps.arrError, ps.arrTable[local.i2].tableAlias&".site_id must be in the WHERE STATEMENT.6");
			writedump(ps);
			abort;
                    }else if(arraylen(ps.arrTable) EQ 1 and arraylen(ps.arrLeftJoin) EQ 0 and ps.whereStatement DOES NOT CONTAIN "site_id"){
                        arrayappend(ps.arrError, ps.arrTable[local.i2].tableAlias&".site_id must be in the WHERE STATEMENT.7");
                    }
                }
            }
        }
    }
    return ps;
    </cfscript>
</cffunction>


<!--- zVerifySiteIdsInQuery(sqlString, defaultDatabaseName) --->
<cffunction name="zVerifySiteIdsInQuery" localmode="modern" output="yes" returntype="any">
	<cfargument name="sqlString" type="string" required="yes">
    <cfargument name="defaultDatabaseName" type="string" required="yes">
    <cfscript>
	var local=structnew();
	var c=arguments.sqlString;
	local.arrError=arraynew(1);
	local.arrTable=arraynew(1);
	local.c=replace(replace(replace(replace(replace(local.c,chr(10)," ","all"),chr(9)," ","all"),chr(13)," ","all"),")"," ) ","all"),"("," ( ","all");
	local.c=" "&rereplace(replace(replace(replace(lcase(local.c),"\\"," ","all"),"\'"," ","all"),'\"'," ","all"), "/\*.*?\*/"," ", "all")&" ";
	local.c=rereplace(local.c,"'[^']*?'","''","all");
	local.c=rereplace(local.c,'"[^"]*?"',"''","all");
	
	local.wherePos=findnocase(" where ",local.c);
	local.setPos=findnocase(" set ",local.c);
	local.valuesPos=refindnocase("\)\s*values",local.c);
	local.fromPos=findnocase(" from ",local.c);
	local.selectPos=findnocase(" select ",local.c);
	local.insertPos=findnocase(" insert ",local.c);
	local.replacePos=findnocase(" replace ",local.c);
	local.intoPos=findnocase(" into ",local.c);
	local.limitPos=findnocase(" limit ",local.c);
	local.groupByPos=findnocase(" group by ",local.c);
	local.orderByPos=findnocase(" order by ",local.c);
	local.havingPos=findnocase(" having ",local.c);
	local.firstLeftJoinPos=findnocase(" left join ",local.c);
	local.firstParenthesisPos=findnocase(" ( ",local.c);
	local.firstWHEREPos=len(local.c);
	if(left(trim(local.c), 5) EQ "show "){
		if(local.fromPos EQ 0){
			return arguments.sqlString;
		}
	}
	if(local.wherePos){
		local.firstWHEREPos=local.wherePos;
	}else if(local.groupByPos){
		local.firstWHEREPos=local.groupByPos;
	}else if(local.orderByPos){
		local.firstWHEREPos=local.orderByPos;
	}else if(local.orderByPos){
		local.firstWHEREPos=local.orderByPos;
	}else if(local.havingPos){
		local.firstWHEREPos=local.havingPos;
	}else if(local.limitPos){
		local.firstWHEREPos=local.limitPos;
	}
	local.lastWHEREPos=len(local.c);
	if(local.groupByPos){
		local.lastWHEREPos=local.groupByPos;
	}else if(local.orderByPos){
		local.lastWHEREPos=local.orderByPos;
	}else if(local.havingPos){
		local.lastWHEREPos=local.havingPos;
	}else if(local.limitPos){
		local.lastWHEREPos=local.limitPos;
	}
	local.setStatement="";
	if(local.setPos){
		if(local.wherePos){
			local.setStatement=mid(local.c, local.setPos+5, local.wherePos-(local.setPos+5));
		}else{
			local.setStatement=mid(local.c, local.setPos+5, len(local.c)-(local.setPos+5));
		}
	}
	if(local.wherePos){
		local.whereStatement=mid(local.c, local.wherePos+6, local.lastWHEREPos-(local.wherePos+6));
	}else{
		local.whereStatement="";
	}
	local.arrLeftJoin=arraynew(1);
	local.matching=true;
	local.curPos=1;
	while(local.matching){
		local.t9=structnew();
		local.t9.leftJoinPos=findnocase(" left join ",local.c, local.curPos);
		if(local.t9.leftJoinPos EQ 0) break;
		local.t9.onPos=findnocase(" on ",local.c, local.t9.leftJoinPos+1);
		if(local.t9.onPos EQ 0 or local.t9.onPos GT local.firstWHEREPos){
			local.t9.onPos=local.firstWHEREPos;
		}
		local.t9.table=trim(replace(mid(local.c, local.t9.leftJoinPos+11, local.t9.onPos-(local.t9.leftJoinPos+11)),"`","","all"));
		if(local.t9.table CONTAINS " as "){
			local.pos=findnocase(" as ",local.t9.table);
			local.t9.tableAlias=trim(mid(local.t9.table, local.pos+4, len(local.t9.table)-(local.pos+3)));
			local.t9.table=trim(left(local.t9.table,local.pos-1));
		}else if(local.t9.table CONTAINS " "){
			local.pos=findnocase(" ",local.t9.table);
			local.t9.tableAlias=trim(mid(local.t9.table, local.pos+1, len(local.t9.table)-(local.pos)));
			local.t9.table=trim(left(local.t9.table,local.pos-1));
		}else{
			local.t9.table=trim(local.t9.table);
			local.t9.tableAlias=trim(local.t9.table);
		}
		if(findnocase(":ztablesql:",local.t9.table) EQ 0){
			arrayappend(local.arrError, "All tables in queries must be generated with dbQuery.table(table, datasource); function. This table wasn't: "&local.t9.table);
		}else{
			local.t9.table=replacenocase(local.t9.table,":ztablesql:","");	
		}
		local.t9.onstatement="";
		if(local.t9.table DOES NOT CONTAIN "."){
			local.t9.table=arguments.defaultDatabaseName&"."&local.t9.table;
		}else{
			if(local.t9.tableAlias CONTAINS "."){
				local.t9.tableAlias=trim(listgetat(local.t9.tableAlias,2,"."));
			}
		}
		local.curPos=local.t9.onPos+1;
		arrayappend(local.arrLeftJoin, local.t9);
		// must check on statement for table.site_id in a left join to ensure it is strictly following conventions
	}
	for(local.i2=1;local.i2 LTE arraylen(local.arrLeftJoin);local.i2++){
		if(local.i2 EQ arraylen(local.arrLeftJoin)){
			local.np=local.firstWHEREPos;
		}else{
			local.np=local.arrLeftJoin[local.i2+1].leftJoinPos;
		}
		if(local.np NEQ local.arrLeftJoin[local.i2].onPos){
			local.arrLeftJoin[local.i2].onstatement=mid(local.c, local.arrLeftJoin[local.i2].onPos+4, local.np-(local.arrLeftJoin[local.i2].onPos+4));
		}
		if(structkeyexists(application, 'zcore') and structkeyexists(application.zcore, 'tablesWithSiteIdStruct') and structkeyexists(application.zcore.tablesWithSiteIdStruct, local.arrLeftJoin[local.i2].table)){
			// search for reference to tableAlias.site_id in onstatement OR wherestatement
			if(local.arrLeftJoin[local.i2].onstatement DOES NOT CONTAIN local.arrLeftJoin[local.i2].tableAlias&".site_id" and local.whereStatement DOES NOT CONTAIN local.arrLeftJoin[local.i2].tableAlias&".site_id"){
				arrayappend(local.arrError, local.arrLeftJoin[local.i2].tableAlias&".site_id must be in the WHERE STATEMENT or the ON statement of LEFT JOIN "&local.arrLeftJoin[local.i2].tableAlias);
			}
		}
	}
	
	if(local.firstLeftJoinPos){
		local.endOfFromPos=local.firstLeftJoinPos;
	}else if(local.firstWHEREPos){
		local.endOfFromPos=local.firstWHEREPos;
	}else{
		local.endOfFromPos=len(local.c);
	}
	
	if(local.intoPos and (local.selectPos EQ 0 or local.selectPos GT local.intoPos)){
		if(local.setPos){
			local.t9=structnew();
			local.t9.type="into";
			local.t9.table=mid(local.c, local.intoPos+5, local.setPos-(local.intoPos+5));
			local.t9.tableAlias=local.t9.table;
			arrayappend(local.arrTable, local.t9);
		}else if(local.firstParenthesisPos){
			local.t9=structnew();
			local.t9.type="into";
			local.t9.table=mid(local.c, local.intoPos+5, local.firstParenthesisPos-(local.intoPos+5));
			local.t9.tableAlias=local.t9.table;
			arrayappend(local.arrTable, local.t9);
		}else{
			if(local.selectPos){
				local.t9=structnew();
				local.t9.type="into";
				local.t9.table=mid(local.c, local.intoPos+5, local.selectPos-(local.intoPos+5));
				local.t9.tableAlias=local.t9.table;
				arrayappend(local.arrTable, local.t9);
			}
		}
	}
	if(local.fromPos){
		
		local.c2=mid(local.c, local.fromPos+5, local.endOfFromPos-(local.fromPos+5))
		
		local.c2=replacenocase(replacenocase(replacenocase(replacenocase(replace(replace(local.c2,")"," ","all"),"("," ","all"), " STRAIGHT_JOIN ", " , ","all"), " CROSS JOIN ", " , ","all"), " INNER JOIN ", " , ","all"), " JOIN ", " , ","all");
		local.arrT2=listtoarray(local.c2, ",");
		for(local.i2=1;local.i2 LTE arraylen(local.arrT2);local.i2++){
			local.arrT2[local.i2]=trim(local.arrT2[local.i2]);
			local.t9=structnew();
			local.t9.type="from";
			if(local.arrT2[local.i2] CONTAINS " as "){
				local.pos=findnocase(" as ", local.arrT2[local.i2]);
				local.t9.tableAlias=trim(mid(local.arrT2[local.i2], local.pos+4, len(local.arrT2[local.i2])-(local.pos+3)));
				local.t9.table=trim(left(local.arrT2[local.i2],local.pos-1));
			}else if(local.arrT2[local.i2] CONTAINS " "){
				local.pos=findnocase(" ", local.arrT2[local.i2]);
				local.t9.tableAlias=trim(mid(local.arrT2[local.i2], local.pos+1, len(local.arrT2[local.i2])-(local.pos)));
				local.t9.table=trim(left(local.arrT2[local.i2],local.pos-1));
			}else{
				local.t9.table=trim(local.arrT2[local.i2]);
				local.t9.tableAlias=trim(local.arrT2[local.i2]);
			}
			if(findnocase(":ztablesql:",local.t9.table) EQ 0){
				arrayappend(local.arrError, "All tables in queries must be generated with dbQuery.table(table, datasource); function. This table wasn't: "&local.t9.table);
			}else{
				local.t9.table=replacenocase(local.t9.table,":ztablesql:","`");	
			}
			arrayappend(local.arrTable, local.t9);
		}
	}
	arguments.sqlString=replace(arguments.sqlString, ":ztablesql:","","all");
	
	for(local.i2=1;local.i2 LTE arraylen(local.arrTable);local.i2++){
		local.arrTable[local.i2].table=trim(replace(local.arrTable[local.i2].table,"`","","all"));
		local.arrTable[local.i2].tableAlias=trim(replace(local.arrTable[local.i2].tableAlias,"`","","all"));
		if(local.arrTable[local.i2].table DOES NOT CONTAIN "."){
			local.arrTable[local.i2].table=arguments.defaultDatabaseName&"."&local.arrTable[local.i2].table;
		}else{
			if(local.arrTable[local.i2].tableAlias CONTAINS "."){
				local.arrTable[local.i2].tableAlias=trim(listgetat(local.arrTable[local.i2].tableAlias,2,"."));
			}
		}
		if(structkeyexists(application, 'zcore') and structkeyexists(application.zcore, 'tablesWithSiteIdStruct') and structkeyexists(application.zcore.tablesWithSiteIdStruct, local.arrTable[local.i2].table)){
			// search for reference to tableAlias.site_id in onstatement OR wherestatement
			if(valuesPos and (insertPos or replacePos)){
				local.c43=mid(c, intoPos+6, valuesPos-(intoPos+6));
				if(local.c43 DOES NOT CONTAIN "site_id"){
					arrayappend(local.arrError, "site_id must be in the COLUMN LIST.");
				}
			}
			if(intoPos){
				if(selectPos){
					if(local.whereStatement NEQ "" and local.arrTable[local.i2].type EQ "into"){
						if((arraylen(local.arrTable) GT 1 or arraylen(local.arrLeftJoin) NEQ 0) and local.whereStatement DOES NOT CONTAIN local.arrTable[local.i2].tableAlias&".site_id"){
							arrayappend(local.arrError, local.arrTable[local.i2].tableAlias&".site_id must be in the WHERE STATEMENT.1");
						}else if(arraylen(local.arrTable) EQ 1 and arraylen(local.arrLeftJoin) EQ 0 and local.whereStatement DOES NOT CONTAIN "site_id"){
							arrayappend(local.arrError, local.arrTable[local.i2].tableAlias&".site_id must be in the WHERE STATEMENT.2");
						}
					}
				}
			}else{
				if(setPos){
					if(setStatement DOES NOT CONTAIN "site_id"){
						arrayappend(local.arrError, "site_id must be in the SET STATEMENT.3");
					}
					if(wherePos and whereStatement NEQ ""){
						if(arraylen(local.arrTable) EQ 1){
							if(whereStatement DOES NOT CONTAIN "site_id"){
								arrayappend(local.arrError, "site_id must be in the WHERE STATEMENT.4");
							}
						}else{
							if(whereStatement DOES NOT CONTAIN local.arrTable[local.i2].tableAlias&".site_id"){
								arrayappend(local.arrError, "site_id must be in the WHERE STATEMENT.5");
							}
						}
					}
					
				}else if(local.whereStatement NEQ "" and local.arrTable[local.i2].type EQ "from"){
					if((arraylen(local.arrTable) GT 1 or arraylen(local.arrLeftJoin) NEQ 0) and local.whereStatement DOES NOT CONTAIN local.arrTable[local.i2].tableAlias&".site_id"){
						arrayappend(local.arrError, local.arrTable[local.i2].tableAlias&".site_id must be in the WHERE STATEMENT.6");
					}else if(arraylen(local.arrTable) EQ 1 and arraylen(local.arrLeftJoin) EQ 0 and local.whereStatement DOES NOT CONTAIN "site_id"){
						arrayappend(local.arrError, local.arrTable[local.i2].tableAlias&".site_id must be in the WHERE STATEMENT.7");
					}
				}
			}
		}
	}
	//writedump(local.arrTable);
	if(arraylen(local.arrError) NEQ 0){
		application.zcore.functions.zError("The following query is missing site_id columns which are required for this system to function correctly.  The code for this query is probably occurring in the file below database.cfc in the error stack trace below.<br />"&arguments.sqlString&";<br />Errors:<br />"&arraytolist(local.arrError, "<br />"));
	}
	return arguments.sqlString;
	</cfscript>
</cffunction>




<!--- zDeleteRecord(tableName, whereList, datasource); --->
<cffunction name="zDeleteRecord" localmode="modern" returntype="any" output="true">
	<cfargument name="tableName" type="string" required="yes">
	<cfargument name="whereList" type="string" required="yes">
	<cfargument name="alternateDatasource" type="string" required="no" default="#request.zos.globals.datasource#">
	<cfscript>
	var arrWhere = ArrayNew(1);
	var i = 1;
	for(i=1;i LTE listLen(arguments.whereList);i=i+1){
		if(structkeyexists(form, listGetAt(arguments.whereList,i)) EQ false){
			return false;
		}else{
			ArrayAppend(arrWhere, listGetAt(arguments.whereList, i)& " = '"&application.zcore.functions.zEscape(form[listGetAt(arguments.whereList,i)])&"'");
		}
	}
	if(arrayLen(arrWhere) EQ 0){
		return false;
	}
	request.zos.queryObject.sql = "DELETE FROM "& request.zos.queryObject.table(arguments.tableName, arguments.alternateDatasource) &" WHERE "&request.zos.queryObject.trustedSQL(arrayToList(arrWhere, " and "));
	request.zos.queryObject.execute("qDelete");
	return true;
	</cfscript>
</cffunction>




<!--- zExecuteSQL(sql,datasource,debug); --->
<cffunction name="zExecuteSQL" localmode="modern" returntype="any" output="true" hint="Depecated.  Required for legacy application compatibility.  Use db.cfc instead.">
	<cfargument name="sql" type="string" required="yes">
	<cfargument name="datasource" type="any" required="no">
	<cfargument name="debug" type="boolean" required="no" default="#false#">
    <cfargument name="cacheTimeSpan" type="any" required="no" default="#createtimespan(0,0,0,0)#">
    <cfargument name="disableSiteIdVerification" type="any" required="no" default="#false#">
    <cfargument name="lazy" type="any" required="no" default="#false#">
	<cfscript>
	var cfcatch=0;
	var qQuery = true;
	var qId=0;
	var newId=0;
	var cfquery=0;
	var success=false;
	var hashCode=0;
	var isSelect=false;
	var zeroTimeSpan=createtimespan(0,0,0,0);
	var tempCacheEnabled=false;
	var curDate=now();
	var curDate2=0;
	var cacheEnabled=false;
	if(arguments.cacheTimeSpan NEQ zeroTimeSpan and not isDefined('session.zos.user')){
		cacheEnabled=true;
	}
	</cfscript>
	<cfif isDefined('arguments.datasource') EQ false or arguments.datasource EQ false>
		<cfset arguments.datasource = request.zos.globals.datasource>
	</cfif>
	<cfscript>
	if(request.zos.isdeveloper){
		if(isDefined('session.zos.verifyQueries') and session.zos.verifyQueries and arguments.disableSiteIdVerification EQ false){
			arguments.sql=trim(application.zcore.functions.zVerifySiteIdsInQuery(arguments.sql, arguments.datasource));	
		}else{
			arguments.sql=trim(replace(arguments.sql, ":ztablesql:", "", "all"));
		}
	}else{
		arguments.sql=trim(arguments.sql);
	}
	ArrayAppend(request.zos.arrQueryLog, (arguments.sql));
	
	if(cacheEnabled and left(arguments.sql, 7) EQ "SELECT "){
		isSelect=true;
		hashCode=hash("sql="&arguments.sql&chr(10)&"datasource="&arguments.datasource&"lazy="&arguments.lazy&chr(10)&"cacheTimeSpan="&arguments.cacheTimeSpan&chr(10),"sha-256");
		if(structkeyexists(application.zcore.queryCache, hashCode)){
			curDate2=application.zcore.queryCache[hashCode].date+arguments.cacheTimeSpan;
			curDate2=createOdbcDateTime(dateFormat(curDate2, "yyyy-mm-dd") & " " & timeformat(curDate2, "HH:MM:SS"));
			if(datecompare(curDate2, curDate) GTE 0){
				return application.zcore.queryCache[hashCode].result;
			}else{
				structdelete(application.zcore.queryCache, hashCode);
			}
		}
	}
	
	</cfscript>
	<cftry><!--- lazy="#arguments.lazy#" blockfactor="1"  cachedwithin="#arguments.cacheTimeSpan#"---> 
		<cfquery  name="qQuery" datasource="#arguments.datasource#" >
			#PreserveSingleQuotes(arguments.sql)#
		</cfquery>
        <cfset success=true>
        <cfscript>
		if(left(arguments.sql, 7) EQ "INSERT "){
			return true;	
		}
		</cfscript>
		<cfcatch type="database">
        	<cfif left(arguments.sql, 7) NEQ "INSERT "><cfrethrow></cfif>
			<cfscript>
			ArrayAppend(request.zos.arrQueryLog, "Query ##"& ArrayLen(request.zos.arrQueryLog)&" failed to execute for datasource, #arguments.datasource#.<br />CFcatch.message: "&CFcatch.message&"<br />cfcatch.detail: "&cfcatch.detail);
			</cfscript>
			<cfif arguments.debug EQ true>
				
				An Error has occurred.<br /><br />
				#PreserveSingleQuotes(arguments.sql)#<br /><br />
				
			</cfif>
			<cfreturn false>
		</cfcatch>
        <cfcatch type="any"><cfrethrow></cfcatch>
	</cftry>
	<cfif success>
    	<cfscript>
		if(cacheEnabled and isSelect){
			application.zcore.queryCache[hashCode]={date:curDate, result:qQuery};
		}
		return qQuery;
		</cfscript>
	<cfelse>
		<cfreturn true>
	</cfif>
</cffunction>


<cffunction name="zSP" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qResult=0;
	var __i383n=0;
	var arrD=arraynew(1);
	var ts=structnew();
	ts.datasource=request.zos.globals.datasource;
	structappend(arguments.ss, ts, false);
	if(isDefined('request.zos.arrQueryLog') EQ false){
		arrayClear(request.zos.arrQueryLog);
	}
    arrayappend(request.zos.arrQueryLog, "zSP ##"& ArrayLen(request.zos.arrQueryLog)&' PROCEDURE=#arguments.ss.procedure# DATASOURCE=#arguments.ss.datasource# VALUELIST=#arraytolist(arguments.ss.arrValue)#');
	</cfscript>
	<cftry>
        <CFSTOREDPROC PROCEDURE="#arguments.ss.procedure#" DATASOURCE="#arguments.ss.datasource#">
            <cfloop from="1" to="#arraylen(arguments.ss.arrValue)#" index="__i383n">
                <CFPROCPARAM VALUE="#arguments.ss.arrValue[__i383n]#" CFSQLTYPE="cf_sql_varchar">
          </cfloop>
          <CFPROCRESULT NAME="qResult">
        </CFSTOREDPROC>
		<cfcatch type="any">
			<cfscript>
			ArrayAppend(request.zos.arrQueryLog, "zSP ##"& ArrayLen(request.zos.arrQueryLog)&" failed to execute for datasource, #arguments.ss.datasource#.");
			</cfscript>
			<cfreturn false>
		</cfcatch>
	</cftry>
    <cfreturn qResult>
</cffunction>


<!--- zEscape(string); --->
<cffunction name="zEscape" localmode="modern" returntype="any" output="false">
	<cfargument name="string" type="string" required="yes">
	<cfreturn replace(replace(arguments.string, "\", "\\", "ALL"), "'", "''", "ALL")>
</cffunction>

<!--- zQueryToStruct(queryName, structScope, overrideFields, currentRow); --->
<cffunction name="zQueryToStruct" localmode="modern" returntype="any" output="true">
	<cfargument name="queryName" type="query" required="yes">
	<cfargument name="structScope" type="struct" required="no" default="#form#">
	<cfargument name="overrideFields" type="string" required="no" default="">
	<cfargument name="currentRow" type="numeric" required="no" default="1">
	<cfargument name="errors" type="boolean" required="no" default="#false#">
	<cfscript>
	var fields = "";
	var n = 0;
	var columnName = "";
	var overridden = "";
	var struct = "";
	var arrColumn=listtoarray(arguments.queryName.columnList,",");
	var columnCount=arraylen(arrColumn);
	struct=arguments.structScope;
	if(arguments.errors){
		for(n=1;n LTE columnCount;n++){
			columnName=arrColumn[n];
			overridden = false;
			if(","&arguments.overrideFields&"," CONTAINS ","&columnName&arguments.currentRow&","){
				overridden = true;
			}	
			if(overridden EQ false){
				if(arguments.currentRow GT arguments.queryName.recordcount){
					StructInsert(struct, columnName&arguments.currentRow, "", true);
				}else{
					StructInsert(struct, columnName&arguments.currentRow, arguments.queryName[columnName][arguments.currentRow], true);
				}
			}
		}
	}else{
		for(n=1;n LTE columnCount;n++){
			columnName=arrColumn[n];
			overridden = false;
			if(","&arguments.overrideFields&"," CONTAINS ","&columnName&","){
				overridden = true;
			}
			if(overridden EQ false){
				if(arguments.currentRow GT arguments.queryName.recordcount){
					StructInsert(struct, columnName, "", true);
				}else{
					StructInsert(struct, columnName, arguments.queryName[columnName][arguments.currentRow], true);
				}
			}
		}
	}
	</cfscript>
</cffunction> 


<cffunction name="zGetDatabaseStructure" localmode="modern" output="no" returntype="any">
	<cfargument name="ds" type="string" required="yes" hint="Database name">
	<cfargument name="rs" type="struct" required="no" default="#structnew()#" hint="Send in an existing struct to add this database to it.">
	<cfscript>
	var db=request.zos.noverifyQueryObject;
	var local=structnew();
	var rs=structnew();
	var db2=0;
	if(structcount(arguments.rs) EQ 0){
		arguments.rs.allTableStruct=structnew();
		arguments.rs.fieldStruct=structnew();
		arguments.rs.keyStruct=structnew();
		arguments.rs.triggerStruct=structnew();
		arguments.rs.globalTableStruct=structnew();
		arguments.rs.siteTableStruct=structnew();
		arguments.rs.tableStruct=structnew();
	}
	db2=request.zos.noVerifyQueryObject;
	db2.sql="show tables from `#arguments.ds#`";
	local.q2=db.execute("q2");
	arguments.rs.allTableStruct[arguments.ds]=structnew();
	arguments.rs.globalTableStruct[arguments.ds]=structnew();
	arguments.rs.siteTableStruct[arguments.ds]=structnew();
	db2.sql="SHOW TABLE STATUS FROM `"&arguments.ds&"` WHERE ENGINE IS NOT NULL";
	local.qC5=db2.execute("qC5");
	db2.sql="SELECT t.table_name, CCSA.character_set_name FROM information_schema.`TABLES` t, 
	information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` CCSA 
	WHERE CCSA.collation_name = t.table_collation  AND t.table_schema = '"&arguments.ds&"'";
	local.qC6=db2.execute("qC6");
	for(local.n2=1;local.n2 LTE local.qC5.recordcount;local.n2++){
		arguments.rs.fieldStruct[arguments.ds&"."&local.qC5.name[local.n2]]={};
		arguments.rs.keyStruct[arguments.ds&"."&local.qC5.name[local.n2]]={};
		arguments.rs.triggerStruct[arguments.ds&"."&local.qC5.name[local.n2]]={};
		arguments.rs.tableStruct[arguments.ds&"."&local.qC5.name[local.n2]]={engine=local.qC5.engine[local.n2],create_options=local.qC5.create_options[local.n2],collation=local.qC5.collation[local.n2],charset=""};
	}
	for(local.n2=1;local.n2 LTE local.qC6.recordcount;local.n2++){
		arguments.rs.tableStruct[arguments.ds&"."&local.qC6.table_name[local.n2]].charset=local.qC6.character_set_name[local.n2];
	}
	db2.sql="SHOW TRIGGERS FROM "&arguments.ds;
	local.qT=db2.execute("qT");
	arguments.rs.triggerStruct[arguments.ds]=structnew();
	for(local.i=1;local.i LTE local.qT.recordcount;local.i++){
		arguments.rs.triggerStruct[arguments.ds&"."&local.qT.table[local.i]][local.qT.trigger[local.i]]={event=local.qT.event[local.i],statement=local.qT.statement[local.i],timing=local.qT.timing[local.i]};
	}
	for(local.row in local.q2){
		local.matchSiteId=false;
		local.tableName=local.row['Tables_in_'&arguments.ds];
		db2.sql="show fields from "&request.zos.noVerifyQueryObject.table(local.tableName, arguments.ds);
		local.qC2=db2.execute("qC2");
		arguments.rs.fieldArrayStruct[arguments.ds&"."&local.tableName]=[];
		for(local.n2=1;local.n2 LTE local.qC2.recordcount;local.n2++){
			if(local.qC2.field[local.n2] EQ "site_id"){
				local.matchSiteId=true;
				arguments.rs.siteTableStruct[arguments.ds][local.tableName]=true;
			}
			arrayAppend(arguments.rs.fieldArrayStruct[arguments.ds&"."&local.tableName], local.qc2.field[local.n2]);
			arguments.rs.fieldStruct[arguments.ds&"."&local.tableName][local.qc2.field[local.n2]]={
				type:local.qc2.type[local.n2],
				null:local.qc2.null[local.n2],key=local.qc2.key[local.n2], 
				default:local.qc2.default[local.n2],
				extra:local.qc2.extra[local.n2],
				columnIndex:local.n2
			};
		}
		db2.sql="show keys from `"&arguments.ds&"`.`"&local.tableName&"`";
		local.qC3=db2.execute("qC3");
		for(local.n2=1;local.n2 LTE local.qC3.recordcount;local.n2++){
			if(not structkeyexists(arguments.rs.keyStruct[arguments.ds&"."&local.tableName], local.qc3.key_name[local.n2])){
				arguments.rs.keyStruct[arguments.ds&"."&local.tableName][local.qc3.key_name[local.n2]]=[];
			}
			arrayAppend(arguments.rs.keyStruct[arguments.ds&"."&local.tableName][local.qc3.key_name[local.n2]], {
				non_unique=local.qc3.non_unique[local.n2], 
				seq_in_index=local.qc3.seq_in_index[local.n2],
				column_name=local.qc3.column_name[local.n2], 
				index_type=local.qc3.index_type[local.n2]
			});
		}
		if(local.matchSiteId EQ false){
			arguments.rs.globalTableStruct[arguments.ds][local.tableName]=true;
		}
		arguments.rs.allTableStruct[arguments.ds][local.tableName]=true;
	}
	return arguments.rs;
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>