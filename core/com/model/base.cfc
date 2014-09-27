<!--- 
TODO:
	// handle date formating on json conversion
	objectArrayToJSON
	objectToJSON
	JSONToObject
	JSONToObjectArray
	
	make a wrapper component for the new objects
		track data changes so that update only touches some of the fields
		make json ajax post able to detect only what has changed for sending over the network
		
	need a way to override the default values of new objects
	need a way to provide processing/formatting beforeDatabaseUpdate and afterDatabaseUpdate for specific fields
	
	figure out how JavascriptMVC connects with this.
	
	saveObjectArray
		loop calling saveObject(), but have an option to ignore errors or return immediately.  Return success/error status in an array of error messages.
	
	deleteById
	delete
	
		
		

 --->
<cfcomponent output="yes">
<cfoutput>
	<cfscript>
	variables._table="";
	variables._zNewRecord=true;
	variables._primaryKey="";
	variables._hasSiteId=false;
	variables._fieldType=structnew();
	variables._comName=replace(replace(replace(replace(getcurrenttemplatepath(),"\","/","all"),request.zos.globals.homedir,""),request.zos.globals.serverhomedir,"zcorerootmapping/"),"/",".","all");
	</cfscript>
     
    <cffunction name="_generateModels" localmode="modern" access="public" output="no" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		var qT="";
		var ts=0;
		</cfscript>
        <cfsavecontent variable="db.sql">
        SHOW TABLES FROM `#request.zos.globals.datasource#`
        </cfsavecontent><cfscript>qT=db.execute("qT");</cfscript>
        <cfloop query="qT">
        	<cfscript>
			ts=structnew();
			ts.table=qT["Tables_in_"&request.zos.globals.datasource][qT.currentrow];
			ts.enableCaching=false;
			ts.datasource=request.zos.globals.datasource;
			ts.cacheStruct=arguments.ss;
			this._getModelData(ts);
			</cfscript>
        </cfloop>
        <cfif request.zos.globals.datasource NEQ request.zos.globals.serverdatasource>
            <cfsavecontent variable="db.sql">
        	SHOW TABLES FROM `#request.zos.globals.serverdatasource#`
            </cfsavecontent><cfscript>qT=db.execute("qT");</cfscript>
            <cfloop query="qT">
                <cfscript>
                ts=structnew();
                ts.table=qT["Tables_in_"&request.zos.globals.serverdatasource][qT.currentrow];
				ts.enableCaching=false;
                ts.datasource=request.zos.globals.serverdatasource;
				ts.cacheStruct=arguments.ss;
                this._getModelData(ts);
                </cfscript>
            </cfloop>
        </cfif>
    </cffunction>
    
    <!--- 
    <cffunction name="getVariables" localmode="modern" access="public" output="no" returntype="any">
    	<cfscript>
		return variables;
		</cfscript>
    </cffunction>
    
    <cffunction name="setVariables" localmode="modern" access="public" output="no" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var local=structnew();
		structappend(variables, arguments.ss, true);
		for(local.i in arguments.ss){
			if(isstruct(arguments.ss[local.i])){
				local.t=arguments.ss[local.i];
				variables[local.i]=structnew();
				structappend(variables[local.i], duplicate(local.t),true);
			}
		}
		</cfscript>
    </cffunction> --->
     
	<!--- <cffunction name="_init" localmode="modern" access="public" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
    	<cfscript>
		var local=structnew();
		if(structcount(arguments.ss) EQ 0){
			local.ts=structnew();
			local.ts.table=this._table;
			local.ts.datasource=application.zcore.functions.zTableDatasource(this._table);
			this._ds=this._getModelData(local.ts);
		}else{
			this._table=arguments.ss.tableName;
			this._ds=arguments.ss;
		}
		</cfscript>
    </cffunction> --->
    
    
     <!--- 
	 ts=structnew();
	 // required
	 ts.table="user";
	 // optional
	 ts.enableCaching=true;
	 ts.datasource="";
	 this._getModelData(ts); --->
     <cffunction name="_getModelData" localmode="modern" access="private" output="yes" returntype="struct">
        <cfargument name="ss" type="struct" required="yes">
        <cfscript>
		var local=structnew();
		var qT=0;
		var ctype=0;
		var cfsqltype=0;
		var output="";
		var componentOutput="";
		var t9=structnew();
		var ts=structnew();
		var db=request.zos.queryObject;
		t9.table="";
		t9.datasource="";
		t9.enableCaching=true;
		t9.cacheStruct=application.sitestruct[request.zos.globals.id];
		structappend(arguments.ss,t9,false);
		if(arguments.ss.table EQ ""){
			application.zcore.template.fail("arguments.table is required.");	
		}
		/*if(arguments.ss.datasource EQ ""){
			ts.datasource=application.zcore.functions.zTableDatasource(arguments.ss.table);
		}else{*/
			ts.datasource=arguments.ss.datasource;
		//}
		ts.tableName=arguments.ss.table;
		</cfscript>
		<cfif structkeyexists(form, 'zregeneratemodelcache') EQ false and arguments.ss.enableCaching and structkeyexists(arguments.ss.cacheStruct.modelDataCache.tableCache,arguments.ss.table&" "&arguments.ss.datasource)>
        	<!--- #arguments.ss.table# Cached<br /> --->
			<cfreturn arguments.ss.cacheStruct.modelDataCache.tableCache[arguments.ss.table&" "&arguments.ss.datasource]>
        <cfelse>
        	<!--- #arguments.ss.table# Not Cached<br /> --->
        	<!--- 13ms to build data up from an average size table --->
        	<cfscript>
			/*if(arguments.ss.table EQ this._table){
				if(structkeyexists(arguments.ss.cacheStruct.modelDataCache.tableCache,arguments.ss.table&" "&arguments.ss.datasource)){
					ts=arguments.ss.cacheStruct.modelDataCache.tableCache[arguments.ss.table&" "&arguments.ss.datasource];
					return ts;
				}
				return ts;
			}*/
			ts.arrSecuritySQL=arraynew(1);
			ts.primaryKey="";
			ts.hasSiteId=false;
			ts.tableAlias=arguments.ss.table;
			ts.table=db.table(arguments.ss.table, arguments.ss.datasource)&" as `"&arguments.ss.table&"`";
			ts.tableNoAlias=db.table(arguments.ss.table, arguments.ss.datasource);
			ts.componentName=ts.datasource&"."&trim(replace(ts.tableAlias,"`","","all"));
			ts.componentPath="_cache.model."&ts.componentName;
			ts.arrFieldOrder=arraynew(1);
			ts.fieldSelectPrependSQL=structnew();
			ts.fieldSelectAppendSQL=structnew();
			ts.fieldUpdatePrependSQL=structnew();
			ts.fieldUpdateAppendSQL=structnew();
			ts.fieldSelectAliasRequired=structnew();
			ts.fieldType=structnew();
			ts.defaultValue=structnew();
			
            local.absComponentPath=request.zos.globals.homedir&'_cache/model/'&replace(ts.componentName,".","/","one")&'.cfc';
			local.buildModel=true;
			</cfscript>
            <!--- <cfif structkeyexists(form, 'zregeneratemodelcache') EQ false and fileexists(local.absComponentPath)>
				<cfscript>
                if(fileexists(local.absComponentPath)){
	                arguments.ss.cacheStruct.modelDataCache.modelComponentCache[ts.componentPath]=createobject("component",ts.componentPath);  
					local.buildModel=false;
                }
                </cfscript>
            </cfif>
            <cfif local.buildModel> --->
                <cfsavecontent variable="db.sql">
                SHOW FIELDS FROM #db.table(ts.tableNoAlias, ts.datasource)#
                </cfsavecontent><cfscript>qT=db.execute("qT"); 
                ts.arrInsert=arraynew(1);
                ts.arrInsertColumns=arraynew(1);
                ts.arrInsertValues=arraynew(1);
                ts.arrUpdate=arraynew(1);
                ts.arrReplace=arraynew(1);
                ts.arrDelete=arraynew(1);
                ts.arrSelectById=arraynew(1);
                
                ts.functionPrepend1='
	<cffunction name="_';
				ts.functionPrepend2='" localmode="modern" access="private" output="no" returntype="any">
		<cfargument name="ss" type="struct" required="yes">
		<cfscript>
		var local=structnew();
		local.rs=structnew();
		local.arrFieldType=arraynew(1);
		local.arrOrder=arraynew(1);
		local.rs.success=true;
		</cfscript>
		<cftry>
			<cfsavecontent variable="db.sql">
			';
			ts.functionAppend1='
			</cfsavecontent><cfscript>local.rs.query=db.execute("query");
			structdelete(local.rs,"arrFieldType");
			structdelete(local.rs,"arrOrder");
			</cfscript>
			<cfreturn local.rs>
		<cfcatch type="database">
			<cfif structkeyexists(arguments.ss, "debug") and arguments.ss.debug>
				<cfrethrow>
			<cfelse>
				<cfscript>
				';
			ts.functionAppend2='
				local.rs.arrFieldType=local.arrFieldType;
				local.rs.arrOrder=arrOrder;
				local.rs.success=false;
				local.rs.cfcatch=cfcatch;
				local.rs.arguments=arguments.ss;
				return local.rs;
				</cfscript>
			</cfif>
		</cfcatch>
		</cftry>
	</cffunction>
';
                ts.insertPrepend= 'INSERT INTO #ts.tableNoAlias# ';
                ts.updatePrepend='UPDATE #ts.tableNoAlias# ';
                ts.replacePrepend='REPLACE INTO #ts.tableNoAlias# ';
                ts.deletePrepend='DELETE FROM #ts.tableNoAlias#';
                ts.selectPrepend='SELECT * FROM #ts.tableNoAlias#';
                ts.arrWhere=arraynew(1);
                ts.indentSpace="			";
				local.arrDefault=arraynew(1);
				local.arrFieldType=arraynew(1);
                </cfscript>
                
                <cfloop query="qT">
                    <cfscript>
					local.escapedField=replace(field,"##","####","all");
                    arrayappend(ts.arrFieldOrder,field);
					if(Key EQ "PRI" and field NEQ "site_id"){
                        ts.primaryKey=local.escapedField;
                    }
                    if(field EQ "site_id"){
                        ts.hasSiteId=true;
                        arrayappend(ts.arrSecuritySQL,"site_id=#db.param(request.zos.globals.id)#");
                    }
                    ctype=listgetat(type,1,'(');
                    if(type CONTAINS "unsigned"){
                        ctype&="_unsigned";	
                    }
                    cfsqltype=application.zcore.mysqlDataTypeStruct[ctype];
                    ts.fieldUpdatePrependSQL[field]="`"&field&"`='";
                    ts.fieldUpdateAppendSQL[field]="'";
                    if(left(Type,6) EQ "bigint"){
                        ts.fieldSelectPrependSQL[field]="cast(";
                        ts.fieldSelectAppendSQL[field]=" as char)";
                        ts.fieldSelectAliasRequired[field]=true;
                    }else{
                        ts.fieldSelectPrependSQL[field]="";
                        ts.fieldSelectAppendSQL[field]="";
                        ts.fieldSelectAliasRequired[field]=false;
                    }
                    if(field EQ "site_id"){
                        // force site_id security on every query
                        curValue=request.zos.globals.id;
                        arrayappend(ts.arrInsertColumns, '`'&field&'`');
                        arrayappend(ts.arrInsertValues,request.zos.globals.id); 
                        arrayappend(ts.arrInsert, '`'&field&'`='&request.zos.globals.id); 
                        arrayappend(ts.arrReplace, '`'&field&'`='&request.zos.globals.id);
                        arrayappend(ts.arrWhere, '`'&field&'`='&request.zos.globals.id);
						arrayappend(local.arrDefault, "this['"&local.escapedField&"']=#request.zos.globals.id#;");
                    }else{
                        curValue='##arguments.ss['''&local.escapedField&''']##';
                        arrayappend(ts.arrInsertColumns, '`'&local.escapedField&'`');
                        arrayappend(ts.arrInsertValues,'<cfqueryparam cfsqltype="'&cfsqltype&'" value="'&curValue&'"><cfscript>arrayappend(local.arrOrder, "'&local.escapedField&'");'&"arrayappend(local.arrFieldType, '"&cfsqltype&"');</cfscript>"); 
                        t='`'&local.escapedField&'`=<cfqueryparam cfsqltype="'&cfsqltype&'" value="'&curValue&'"><cfscript>arrayappend(local.arrOrder, "'&local.escapedField&'");'&"arrayappend(local.arrFieldType, '"&cfsqltype&"');</cfscript>";
                        arrayappend(ts.arrInsert, t); 
                        if(Key EQ "PRI"){
                            arrayappend(ts.arrReplace, t);
                            arrayappend(ts.arrWhere, t); // this intentionally makes it impossible to change the primary key id value.
                            if(ts.hasSiteId){
                                // force site_id security on every query
                                arrayappend(ts.arrWhere, '`'&local.escapedField&'`='&request.zos.globals.id);
                            }
                        }else{
                            arrayappend(ts.arrReplace, t);
                            arrayappend(ts.arrUpdate, '<cfif structkeyexists(arguments.ss, '''&local.escapedField&''')>'&chr(10)&ts.indentSpace&t&chr(10)&ts.indentSpace&'</cfif>');
                        }
						arrayappend(local.arrDefault, "this['"&local.escapedField&"']="""&replace(replace(default,"##","####","all"),'"','""','all')&""";");
                    }
                    ts.fieldType[field]=type;
					arrayAppend(local.arrFieldType, "variables._fieldType['"&local.escapedField&"']="""&cfsqltype&'";');
					
                    ts.defaultValue[field]=default;
                    </cfscript>
                </cfloop>
                <cfscript> 
                arrOutput=arraynew(1);
                
                // insert multiple
                arrayappend(arrOutput, ts.functionPrepend1&'modelInsertMultiple'&ts.functionPrepend2);
                arrayappend(arrOutput, replace(ts.insertPrepend,"##","####","all")&" (");
                arrayappend(arrOutput, replace(arraytolist(ts.arrInsertColumns,", "),"##","####","all")&") VALUES");
                arrayappend(arrOutput, '<cfloop from="1" to="##arraylen(arguments.ss.arrObject)##" index="i"><cfif i NEQ 1>, </cfif>'&chr(10)&ts.indentSpace&'(');
                arrayappend(arrOutput, arraytolist(ts.arrInsertValues,", "&chr(10)&ts.indentSpace));
                arrayappend(arrOutput, ') </cfloop>');
                arrayappend(arrOutput, ts.functionAppend1&ts.functionAppend2&chr(10)&chr(10));
                
                // insert
                arrayappend(arrOutput, ts.functionPrepend1&'modelInsert'&ts.functionPrepend2);
                arrayappend(arrOutput, replace(ts.insertPrepend,"##","####","all")&" SET ");
                arrayappend(arrOutput, arraytolist(ts.arrInsert,", "&chr(10)&ts.indentSpace));
                arrayappend(arrOutput, ts.functionAppend1&ts.functionAppend2&chr(10)&chr(10));
                
                // update
                arrayappend(arrOutput, ts.functionPrepend1&'modelUpdate'&ts.functionPrepend2);
                arrayappend(arrOutput, replace(ts.updatePrepend,"##","####","all")&" SET ");
                arrayappend(arrOutput, arraytolist(ts.arrUpdate,", "&chr(10)&ts.indentSpace));
                arrayappend(arrOutput, " 
WHERE "&chr(10)&ts.indentSpace&arraytolist(ts.arrWhere," and "&chr(10)&ts.indentSpace));
                arrayappend(arrOutput, ts.functionAppend1&ts.functionAppend2&chr(10)&chr(10));
                
                // replace
                arrayappend(arrOutput, ts.functionPrepend1&'modelReplace'&ts.functionPrepend2);
                arrayappend(arrOutput, replace(ts.replacePrepend,"##","####","all")&" SET ");
                arrayappend(arrOutput, arraytolist(ts.arrReplace,", "&chr(10)&ts.indentSpace));
                arrayappend(arrOutput, ts.functionAppend1&ts.functionAppend2&chr(10)&chr(10));
                
                // deleteById
                arrayappend(arrOutput, ts.functionPrepend1&'modelDeleteById'&ts.functionPrepend2);
                arrayappend(arrOutput, replace(ts.deletePrepend,"##","####","all")&" ");
                arrayappend(arrOutput, " 
WHERE "&chr(10)&ts.indentSpace&arraytolist(ts.arrWhere," and "&chr(10)&ts.indentSpace));
                arrayappend(arrOutput, ts.functionAppend1&ts.functionAppend2&chr(10)&chr(10));
				
                // selectById
                arrayappend(arrOutput, ts.functionPrepend1&'modelSelectById'&ts.functionPrepend2);
                arrayappend(arrOutput, replace(ts.selectPrepend,"##","####","all")&" ");
                arrayappend(arrOutput, " 
WHERE "&chr(10)&ts.indentSpace&arraytolist(ts.arrWhere," and "&chr(10)&ts.indentSpace));
                arrayappend(arrOutput, ts.functionAppend1&ts.functionAppend2&chr(10)&chr(10));
                
                output=arraytolist(arrOutput, chr(10)&ts.indentSpace);
                componentOutput='<cfcomponent output="no" extends="zcorerootmapping.com.model.base" hint="WARNING: THIS FILE IS AUTO-GENERATED BY THE ORM SYSTEM. DO NOT EDIT.">
	<cfscript>
	variables._table="'&replace(arguments.ss.table,"##","####","all")&'";
	variables._zNewRecord=true;
	variables._comName=replace(replace(replace(replace(getcurrenttemplatepath(),"\","/","all"),request.zos.globals.homedir,""),request.zos.globals.serverhomedir,"zcorerootmapping/"),"/",".","all");
	variables._primaryKey="'&ts.primaryKey&'";
    variables._fieldType=structnew();
	'&arraytolist(local.arrFieldType,chr(10)&"	")&'
    variables._hasSiteId='&ts.hasSiteId&';
	'&arraytolist(local.arrDefault,chr(10)&"	")&'
	</cfscript>'&chr(10)&output&chr(10)&'</cfcomponent>';
                //writeoutput('<pre>'&htmleditformat(componentOutput)&'</pre>');
                //application.zcore.functions.zdump(ts);
                application.zcore.functions.zcreatedirectory(request.zos.globals.privatehomedir&"_cache/model/"&ts.datasource);
                r=application.zcore.functions.zdeletefile(local.absComponentPath); 
                application.zcore.functions.zwritefile(local.absComponentPath, componentOutput); 
            	arguments.ss.cacheStruct.modelDataCache.tableCache[arguments.ss.table&" "&arguments.ss.datasource]=ts;
				if(request.zos.zreset NEQ "all" and request.zos.zreset NEQ "site"){
					arguments.ss.cacheStruct.modelDataCache.modelComponentCache[ts.componentPath]=createobject("component",ts.componentPath);
				}
				return arguments.ss.cacheStruct.modelDataCache.tableCache[arguments.ss.table&" "&arguments.ss.datasource];  
				</cfscript>
            <!--- </cfif> --->
            <cfscript>
            arguments.ss.cacheStruct.modelDataCache.tableCache[arguments.ss.table&" "&arguments.ss.datasource]=ts;
			return arguments.ss.cacheStruct.modelDataCache.tableCache[arguments.ss.table&" "&arguments.ss.datasource];
			</cfscript>
        </cfif>
    </cffunction>
    
    <cffunction name="_getSelect" localmode="modern" access="private" output="no" returntype="any" hint="Retrieves a compiled select query component object or a new select object so you can build a compiled query.">
    	<cfargument name="name" type="string" required="yes" hint="Name of the select query. It must be unique from all other select query names in the current model component.">
    	<!--- <cfargument name="ss" type="struct" required="no" default="#structnew()#" hint="The parameters to send to the query."> --->
    	<cfscript>
		var rs=structnew();
		var curName=application.zcore.functions.zurlencode(variables._comName&" "&trim(arguments.name),"-");
		var curPath=request.zos.globals.privatehomedir&"_cache/model/select/"&curName;
		var enableCaching=true;
		if(request.zos.disableSystemCaching or request.zos.zreset EQ "all" or request.zos.zreset EQ "site"){
			enableCaching=false;
		}
		// find existing cached query
		if(enableCaching and structkeyexists(application.sitestruct[request.zos.globals.id].modelDataCache.selectComponentCache, curName)){
			return application.sitestruct[request.zos.globals.id].modelDataCache.selectComponentCache[curName];
		}else if(enableCaching and fileexists(curPath)){
			application.sitestruct[request.zos.globals.id].modelDataCache.selectComponentCache[curName]=createobject("component",request.zRootSecureCFCPath&"_cache.model.select."&curName);
			return application.sitestruct[request.zos.globals.id].modelDataCache.selectComponentCache[curName];
		}else{
			// otherwise work on a new one
			rs=duplicate(application.sitestruct[request.zos.globals.id].modelDataCache.selectComponent);
			for(i in rs){
				if(isstruct(rs[i])){
					rs[i]=structnew();
					structappend(rs[i],duplicate(application.sitestruct[request.zos.globals.id].modelDataCache.selectComponent[i]), true);
				}
			}
			rs.selectName=arguments.name;
			rs.selectComponentName=curName;
			return rs;
		}
		</cfscript>
    </cffunction>
    
    
    <!--- work in progress --->
    
    <!--- this._compile(selectObject, selectArguments); --->
    <cffunction name="_compile" localmode="modern" access="private" output="no" returntype="any" hint="Compiles the select component, runs the query and returns the result.">
    	<cfargument name="selectObject" type="zcorerootmapping.com.model.select" required="yes" hint="A select component that has been fully initialized.">
    	<cfargument name="selectArguments" type="struct" required="no" default="#structnew()#" hint="A struct of the named query parameters">
    	<cfscript>
		var i=0;
		var curHash=0;
		var t9=0;
		var modelData=0;
		var rs=0;
		var sql=0;
		var c1=0;
		var n=0;
		var arrSQL=0;
		var curHash=0;
		var arrNew=arraynew(1);
		var arrNew2=arraynew(1);
		var arrParameter=arraynew(1);
		var componentOutput="";
		var output="";
		var sql2=0;
		var sql3=0;
		var enableCaching=true;
		var c3=0;
		var arrNew3=arraynew(1);
		var rs2=structnew();
		if(arraylen(arguments.selectObject.selectStruct.arrFrom) EQ 0){
			application.zcore.template.fail("#request.zos.zcorerootmapping#.com.model.select.cfc error: You must call the from() function before the query can be compiled.");	
		}else{
			arguments.selectObject.selectStruct.datasource=arguments.selectObject.selectStruct.arrFrom[1].datasource;//application.zcore.functions.zTableDatasource(arguments.selectObject.selectStruct.arrFrom[1].table);	
		}
		for(i=2;i LTE arraylen(arguments.selectObject.parameterStruct.selectFields);i++){
			arrayAppend(arrParameter, arguments.selectObject.parameterStruct.selectFields[i]);
		}
		for(i=1;i LTE arraylen(arguments.selectObject.parameterStruct.arrLeftJoin);i++){
			for(n=5;n LTE arraylen(arguments.selectObject.parameterStruct.arrLeftJoin[i]);n++){
				arrayAppend(arrParameter, arguments.selectObject.parameterStruct.arrLeftJoin[i][n]);
			}
		}
		for(i=2;i LTE arraylen(arguments.selectObject.parameterStruct.where);i++){
			arrayAppend(arrParameter, arguments.selectObject.parameterStruct.where[i]);
		} 
		for(i=2;i LTE arraylen(arguments.selectObject.parameterStruct.groupby);i++){
			arrayAppend(arrParameter, arguments.selectObject.parameterStruct.groupby[i]);
		}
		for(i=2;i LTE arraylen(arguments.selectObject.parameterStruct.having);i++){
			arrayAppend(arrParameter, arguments.selectObject.parameterStruct.having[i]);
		}
		for(i=2;i LTE arraylen(arguments.selectObject.parameterStruct.orderby);i++){
			arrayAppend(arrParameter, arguments.selectObject.parameterStruct.orderby[i]);
		}
		for(i=2;i LTE arraylen(arguments.selectObject.parameterStruct.offset);i++){
			arrayAppend(arrParameter, arguments.selectObject.parameterStruct.offset[i]);
		}
		for(i=2;i LTE arraylen(arguments.selectObject.parameterStruct.count);i++){
			arrayAppend(arrParameter, arguments.selectObject.parameterStruct.count[i]);
		}
		if(request.zos.zreset EQ "all" or request.zos.zreset EQ "site"){
			enableCaching=false;
		}
		arguments.selectObject.selectStruct.returnSQLOnly=true;
		arguments.selectObject.selectStruct.selectFields=arguments.selectObject.selectStruct.selectFields;
		sql=this._getSelectSQL(arguments.selectObject.selectStruct);
		sql=replace(sql,"##","####","all");
		sql2=sql;
		arrSQL=listtoarray(sql,"?",true);
		c1=arraylen(arrSQL)-1;
		
		arrNew4=arraynew(1);
		arrNew5=arraynew(1);
		// determine parameter data type and replace ? with cfqueryparam
		for(i=1;i LTE arraylen(arrParameter);i++){
			arrayappend(arrNew, arrSQL[i]);
			arrayappend(arrNew5, arrSQL[i]);
			if(isstruct(arrParameter[i])){
				c2=arrParameter[i].type;
				arrParameter[i]=arrParameter[i].field;
			}else if(isBinary(arguments.selectArguments[arrParameter[i]])){
				c2= "cf_sql_longvarbinary";
			}else{
				c2= "cf_sql_longvarchar";
			}
			c3=replace(arrParameter[i],"##","####","all");
			//arrayappend(arrNew4,'this.stat.addParam(name="'&c3&'", value=arguments.ss['''&c3&'''], cfsqltype="'&c2&'");');
			arrayappend(arrNew,'<cfqueryparam cfsqltype="'&c2&'" value="##arguments.ss['''&c3&''']##">');
			//arrayappend(arrNew5, ':'&c3);
			arrayappend(arrNew2,'"'&c3&'"=""');
			arrayappend(arrNew3,'arrayappend(local.rs.arrOrder, "'&c3&'");  arrayappend(local.rs.arrFieldType, "'&c2&'");');
		}
		arrayappend(arrNew, arrSQL[c1+1]);
		//arrayappend(arrNew5, arrSQL[c1+1]);
		sql=arraytolist(arrNew,"");
		//sql3=arraytolist(arrNew5,"");
		
		sql2=application.zcore.functions.zVerifySiteIdsInQuery(replace(sql2,'"','""','all'), arguments.selectObject.selectStruct.datasource);	
		// write compiled query to disk as a component
		output='
		<cfscript>
		this.compiled=true;
		this.default={
		'&arraytolist(arrNew2,","&chr(10))&'
		}
		//this.stat=new query(sql="'&replace(replace(sql3,":ztablesql:","","all"),'"','""','all')&'", datasource="'&arguments.selectObject.selectStruct.datasource&'");
		</cfscript>
		<!--- <cffunction name="selectNew" localmode="modern" output="no" returntype="any">
			<cfargument name="ss" type="struct" required="no" default="##structnew()##">
			<cfscript>
			var local=structnew();
			local.rs=structnew();
			local.rs.success=true;
			structappend(arguments.ss, this.default, false);
			//this.stat.clearParams();
			'&arraytolist(arrNew4,chr(10))&'
			</cfscript>
			<cftry>
				<cfscript>
				local.rs.query=this.stat.execute().getResult();
				</cfscript>
				<cfreturn rs>
				<cfcatch type="database">
					<cfscript>
					local.rs.arrFieldType=arraynew(1);
					local.rs.arrOrder=arraynew(1);
					'&arraytolist(arrNew3," ")&'
					local.rs.arguments=arguments.ss;
					local.rs.success=false;
					local.rs.cfcatch=cfcatch;
					return local.rs;
					</cfscript>
				</cfcatch>
			</cftry>
		</cffunction> --->
		<cffunction name="select" localmode="modern" output="no" returntype="any">
			<cfargument name="ss" type="struct" required="no" default="##structnew()##">
			<cfscript>
			var local=structnew();
			local.rs=structnew();
			local.rs.success=true;
			structappend(arguments.ss, this.default, false);
			</cfscript>
			<cftry>
				<cfquery name="local.rs.query" result="local.rs.result" datasource="'&arguments.selectObject.selectStruct.datasource&'">
				'&replace(sql,chr(10),chr(10)&"					","all")&'
				</cfquery>
				<cfreturn rs>
				<cfcatch type="database">
					<cfscript>
					local.rs.arrFieldType=arraynew(1);
					local.rs.arrOrder=arraynew(1);
					'&arraytolist(arrNew3," ")&'
					local.rs.arguments=arguments.ss;
					local.rs.success=false;
					local.rs.cfcatch=cfcatch;
					return local.rs;
					</cfscript>
				</cfcatch>
			</cftry>
		</cffunction>
		';
		componentOutput='<cfcomponent output="no" hint="WARNING: THIS FILE IS AUTO-GENERATED BY THE ORM SYSTEM. DO NOT EDIT.">'&chr(10)&output&chr(10)&'</cfcomponent>';
		
		application.zcore.functions.zcreatedirectory(request.zos.globals.privatehomedir&"_cache/model/select");
		application.zcore.functions.zwritefile(request.zos.globals.privatehomedir&'_cache/model/select/'&arguments.selectObject.selectComponentName&'.cfc', componentOutput); 
		application.zcore.functions.zClearCFMLTemplateCache();
		application.sitestruct[request.zos.globals.id].modelDataCache.selectComponentCache[arguments.selectObject.selectComponentName]=createobject("component",request.zRootSecureCFCPath&"_cache.model.select."&arguments.selectObject.selectComponentName);
		rs2=application.sitestruct[request.zos.globals.id].modelDataCache.selectComponentCache[arguments.selectObject.selectComponentName];
			
		// run the query
		return rs2.select(arguments.selectArguments);
		</cfscript>
    </cffunction>
    
    <!--- 
	ts=structnew();
	ts.primaryKeyField="12384181238213";
	rs=this.selectById(ts);
	if(rs.success EQ false){
		// use rs.query
		application.zcore.functions.zdump(rs);
	}else{
		application.zcore.functions.zdump(rs);
	}
	 --->
    <cffunction name="selectById" localmode="modern" access="public" output="no" returntype="struct">
    	<cfargument name="id" type="string" required="yes">
    	<cfscript>
		var local=structnew();
		local.ss=structnew();
		local.ss[variables._primaryKey]=arguments.id;
		return this._modelSelectById(local.ss);
		</cfscript>
    </cffunction>
    
    <!--- 
	ts=structnew();
	ts.primaryKeyField="12384181238213";
	rs=this.delete(ts);
	if(rs.success EQ false){
		// use rs.query
		application.zcore.functions.zdump(rs);
	}else{
		application.zcore.functions.zdump(rs);
	}
	 --->
    <cffunction name="deleteById" localmode="modern" access="public" output="yes" returntype="struct" hint="Returns false if insert or update failed, otherwise true.">
	    <cfargument name="id" type="string" required="yes">
        <cfscript>
		var local=structnew();
		if(trim(arguments.id) EQ "" or arguments.id EQ "0"){
			application.zcore.template.fail("deleteById() failed on #variables._table#.  arguments.id is required and can't be 0 or an empty string.");
		}
		local.ss=structnew();
		local.ss[variables._primaryKey]=arguments.id;
		return this._modelDeleteById(local.ss);
		</cfscript>
    </cffunction>
    
    <!--- result=this.save(); --->
    <cffunction name="save" localmode="modern" access="public" output="yes" returntype="struct" hint="Returns false if insert or update failed, otherwise true.">
    	<!--- <cfargument name="ss" type="struct" required="yes"> --->
        <cfscript>
		var local=structnew();
		// save using the modelInsert() function of the modelDataCache.?
		if(variables._hasSiteId){
			this.site_id=request.zos.globals.id;
		}
		for(local.i in this){
			if(structkeyexists(variables._fieldType, local.i)){
				curVal=trim(this[local.i]);
				if(variables._fieldType[local.i] EQ "date"){
					if(isdate(curVal) EQ false){
						curVal=request.zos.mysqlnow;//"0000-00-00";	
					}else{
						curVal=dateformat(curVal,"yyyy-mm-dd");
					}
				}else if(variables._fieldType[local.i] EQ "datetime"){
					if(isdate(curVal) EQ false){
						curVal=request.zos.mysqlnow;//"0000-00-00 00:00:00";	
					}else{
						curVal=dateformat(curVal,"yyyy-mm-dd")&" "&timeformat(curVal,"HH:mm:ss");
					}
				}
				this[local.i]=curVal;
			}
		} 
		if(variables._zNewRecord){
			if(structkeyexists(this, variables._primaryKey) EQ false or trim(this[variables._primaryKey]) EQ "" or this[variables._primaryKey] EQ "0"){
				this[variables._primaryKey]=application.zcore.functions.zGetUUID(1)[1]; // create new id before inserting
			}
			local.rs=this._modelInsert(this);
			variables._zNewRecord=false;
		}else{
			if(structkeyexists(this, variables._primaryKey) EQ false or trim(this[variables._primaryKey]) EQ "" or this[variables._primaryKey] EQ "0"){
				local.rs=structnew();
				local.rs.success=false;
				local.rs.errorMessage="save() failed on #variables._table#. The primary key field of the object is invalid or missing.  It must be defined before updating the database.";
				//application.zcore.template.fail("save() failed on #variables._table#. The primary key field of the object is invalid or missing.  It must be defined before updating the database.");
			}
			local.rs=this._modelUpdate(this);
		}
		return local.rs;
		</cfscript>
    </cffunction>
    
    
    
    <!--- 
	ts=structnew();
	// required
	ts.selectFields="track_user.*, user.user_email";
	// optional
	ts.table="track_user";
	ts.tableAlias="t1";
	ts.where="t1.track_user_id = t2.user_id";
	ts.orderby="t1.track_user_id desc";
	ts.groupby="t1.track_user_agent";
	ts.having="";  // the having clause can only see columns in the selectFields expression.
	ts.count="10";
	ts.offset="0";
	// left join support
	ts.arrLeftJoin=arraynew(1);
	t9=structnew();
	t9.table="user";
	t9.tableAlias="t2";
	t9.selectFields="";
	t9.where="user.user_server_administrator='1'"; // The "WHERE SQL" for a left join doesn't have to be in the "ON" clause.  You can put it in the normal "WHERE", by using the ts.where argument instead of t9.where in this example.
	ts.renameDuplicateColumns=false; // detects duplicate columns and create a new column named "tableAlias.columnName".  Use queryVar["tableAlias.columnName"][currentrow] to access it.
	arrayappend(ts.arrLeftJoin,t9);
	qR=this._getSelectSQL(ts);
	 --->
    <cffunction name="_getSelectSQL" localmode="modern" output="yes" access="private" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
        <cfscript>
		var qR=0;
		var ts=structnew();
		var arrSQL=arraynew(1);
		var sql="";
		var i=0;
		var tempModelData=0;
		var t9=0;
		var db=request.zos.queryObject;
		var whereOutput=false;
		var n=0;
		var whereAndRequired=false;
		var primaryDatasource="";
		var limitEnabled=false;
		var arrTempModelCache=arraynew(1);
		var arrTempTableAlias=arraynew(1);
		var arrFrom=arraynew(1);
		ts.table="";
		ts.renameDuplicateColumns=false;
		ts.tableAlias="";
		ts.where="";
		ts.datasource="";
		ts.orderby="";
		ts.groupby="";
		ts.arrLeftJoin=arraynew(1);
		ts.count="";
		ts.returnSQLOnly=false;
		ts.offset="";
		ts.having="";
		ts.selectFields="*";
		throw('base.cfc _getSELECTSQL() not tested');
		structappend(arguments.ss,ts,false);
		if(arraylen(arguments.ss.arrFrom) EQ 0){
			application.zcore.template.fail("arguments.ss.arrForm is required. It must be an array of structs.  Example:<br /><br />ts=structnew();<br />ts.table=""table"";<br />ts.tableAlias=""tableAlias""<br />arrayappend(ss.arrForm, ts);");	
		}
		if(arguments.ss.selectFields EQ ""){
			application.zcore.template.fail("arguments.ss.selectFields is required.");	
		}
		for(i=1;i LTE arraylen(arguments.ss.arrFrom);i++){
			if(arguments.ss.arrFrom[i].tableAlias EQ ""){
				arguments.ss.arrFrom[i].tableAlias =arguments.ss.arrFrom[i].table;
			}
			if(left(arguments.ss.arrFrom[i].tableAlias,1) EQ "`"){
				arguments.ss.arrFrom[i].tableAlias=mid(arguments.ss.arrFrom[i].tableAlias,2,len(arguments.ss.arrFrom[i].tableAlias)-2);
			}
			/*if(structkeyexists(arguments.ss.arrFrom[i],'datasource') EQ false or arguments.ss.arrFrom[i].datasource EQ ""){
				arguments.ss.arrFrom[i].datasource=application.zcore.functions.zTableDatasource(arguments.ss.arrFrom[i].table);	
			}*/
			if(i EQ 1){
				primaryDatasource=arguments.ss.arrFrom[i].datasource;	
			}
			ts=structnew();
			ts.table=arguments.ss.arrFrom[i].table;
			ts.datasource=arguments.ss.arrFrom[i].datasource;
			arguments.ss.arrFrom[i].ds=this._getModelData(ts);
			arrayappend(arrTempModelCache, arguments.ss.arrFrom[i].ds);
			arrayappend(arrTempTableAlias, arguments.ss.arrFrom[i].tableAlias);
			arrayappend(arrFrom, db.table(arguments.ss.arrFrom[i].table, arguments.ss.arrFrom[i].datasource)&" as "&arguments.ss.arrFrom[i].tableAlias&" "&arguments.ss.arrFrom[i].indexHint);
		}
		for(i=1;i LTE arraylen(arguments.ss.arrLeftJoin);i++){
			if(structkeyexists(arguments.ss.arrLeftJoin[i],'tableAlias') EQ false){
				arguments.ss.arrLeftJoin[i].tableAlias=arguments.ss.arrLeftJoin[i].table;
			}
			if(left(arguments.ss.arrLeftJoin[i].tableAlias,1) EQ "`"){
				arguments.ss.arrLeftJoin[i].tableAlias=mid(arguments.ss.arrLeftJoin[i].tableAlias,2,len(arguments.ss.arrLeftJoin[i].tableAlias)-2);
			}
			t9=structnew();
			t9.table=arguments.ss.arrLeftJoin[i].table;
			//if(structkeyexists(arguments.ss.arrLeftJoin[i],'datasource')){
				t9.datasource=arguments.ss.arrLeftJoin[i].datasource;
			/*}else{
				arguments.ss.arrLeftJoin[i].datasource=application.zcore.functions.zTableDatasource(arguments.ss.arrLeftJoin[i].table);
			}*/
			arguments.ss.arrLeftJoin[i].modelDataCache=this._getModelData(t9);
			arrayappend(arrTempModelCache, arguments.ss.arrLeftJoin[i].modelDataCache);
			arrayappend(arrTempTableAlias, arguments.ss.arrLeftJoin[i].tableAlias);
		}
		 
		arguments.ss.selectFields=this._getSelectFieldsSQL(arguments.ss.selectFields, arrTempModelCache, arrTempTableAlias, arguments.ss.renameDuplicateColumns); 
		if(arraylen(arguments.ss.arrLeftJoin) NEQ 0){
			// get select sql for each join table.
			for(i=1;i LTE arraylen(arguments.ss.arrLeftJoin);i++){
				if(arraylen(arguments.ss.arrLeftJoin[i].modelDataCache.arrSecuritySQL) NEQ 0){
					if(arguments.ss.arrLeftJoin[i].where NEQ ""){
						arguments.ss.arrLeftJoin[i].where&=" AND";
					}
					for(n=1;n LTE arraylen(arguments.ss.arrLeftJoin[i].modelDataCache.arrSecuritySQL);n++){
						if(n NEQ 1){
							arguments.ss.arrLeftJoin[i].where&=" AND ";
						}
						arguments.ss.arrLeftJoin[i].where&=" `"&arguments.ss.arrLeftJoin[i].tableAlias&"`."&arguments.ss.arrLeftJoin[i].modelDataCache.arrSecuritySQL[n];
					}
				}
			}
		}
		
		arrayappend(arrSQL,"SELECT "&arguments.ss.selectFields&" FROM ("&arraytolist(arrFrom,", ")&")");
		
		for(i=1;i LTE arraylen(arguments.ss.arrLeftJoin);i++){
			arrayappend(arrSQL,"LEFT JOIN "&db.table(arguments.ss.arrLeftJoin[i].table,arguments.ss.arrLeftJoin[i].datasource)&" "&arguments.ss.arrLeftJoin[i].tableAlias&" ON "&arguments.ss.arrLeftJoin[i].where);
		}
		
		for(n=1;n LTE arraylen(arguments.ss.arrFrom);n++){
			if(arraylen(arguments.ss.arrFrom[n].ds.arrSecuritySQL) NEQ 0){
				if(whereOutput EQ false){
					arrayappend(arrSQL,"WHERE ");
					whereOutput=true;
				}
				for(i=1;i LTE arraylen(arguments.ss.arrFrom[n].ds.arrSecuritySQL);i++){
					if(whereAndRequired){
						arrayappend(arrSQL,"AND");
					}else{
						whereAndRequired=true;
					}
					arrayappend(arrSQL,"`"&arguments.ss.arrFrom[n].tableAlias&"`."&arguments.ss.arrFrom[n].ds.arrSecuritySQL[i]);
				}
			}
		}
		if(arguments.ss.where NEQ ""){
			if(whereOutput EQ false){
				arrayappend(arrSQL,"WHERE ");
				whereOutput=true;
			}
			if(whereAndRequired){
				arrayappend(arrSQL,"AND");
			}
			arrayappend(arrSQL,arguments.ss.where);
		}
		if(arguments.ss.groupby NEQ ""){
			arrayappend(arrSQL,"GROUP BY "&arguments.ss.groupby);
		}
		if(arguments.ss.having NEQ ""){
			arrayappend(arrSQL,"HAVING( "&arguments.ss.having&")");
		}
		if(arguments.ss.orderby NEQ ""){
			arrayappend(arrSQL,"ORDER BY "&arguments.ss.orderby);
		}
		if(isnumeric(arguments.ss.offset) and int(arguments.ss.offset) EQ arguments.ss.offset){
			arrayappend(arrSQL,"LIMIT "&arguments.ss.offset);
			limitEnabled=true;
		}
		if(isnumeric(arguments.ss.count) and int(arguments.ss.count) EQ arguments.ss.count){
			if(limitEnabled){
				arrayappend(arrSQL,", "&arguments.ss.count);	
			}else{
				arrayappend(arrSQL,"LIMIT "&arguments.ss.count);
			}
		}
		sql=arraytolist(arrSQL," "&chr(10));   
		if(arguments.ss.returnSQLOnly EQ false){
			db.sql=sql;
			qR=db.execute("qR");
			if(isQuery(qR) EQ false){
				application.zcore.template.fail("_getSelectSQL() query failed.<br /><br />Error Message:<br /><br />"&application.zcore.functions.zGetLastDatabaseError()&"<br /><br />Invalid SQL:<br /><br />"&sql);
			}
			return qR;
		}else{
			return sql;	
		}
		</cfscript>
    </cffunction>
    
    
    <!--- this.queryToObjectArray(queryVar); --->
    <cffunction name="queryToObjectArray" localmode="modern" output="yes" returntype="any">
    	<cfargument name="queryVar" type="query" required="yes">
    	<cfscript>
		var local=structnew();
		local.ts=0;
		local.arrR=arraynew(1);
		</cfscript>
        <cfloop query="arguments.queryVar">
        	<cfscript>
			local.ts=structnew();
			structappend(local.ts, arguments.queryVar); 
			arrayappend(local.arrR,local.ts);
			</cfscript>
        </cfloop>
        <cfscript>
		return local.arrR;
		</cfscript>
    </cffunction>
    
    <!--- old approach is 0.5ms slower
    <cffunction name="queryToObjectArray2" localmode="modern" output="yes" returntype="any">
    	<cfargument name="queryVar" type="query" required="yes">
    	<cfscript>
		var ts=0;
		var arrR=arraynew(1);
		var arrColumn=listtoarray(arguments.queryVar.columnList,",");
		</cfscript>
        <cfloop query="arguments.queryVar">
        	<cfscript>
			ts=structnew();
			for(i=1;i LTE arraylen(arrColumn);i++){
				ts[arrColumn[i]]=arguments.queryVar[arrColumn[i]][arguments.queryVar.currentrow];
			}
			arrayappend(arrR,ts);
			</cfscript>
        </cfloop>
        <cfscript>
		return arrR;
		</cfscript>
    </cffunction> --->
    
    
    <!--- _getSelectFieldsSQL("user_id as uid,user_group_id,user_username"); --->
    <cffunction name="_getSelectFieldsSQL" localmode="modern" access="private" output="yes" returntype="string">
    	<cfargument name="selectFields" type="string" required="yes">
        <cfargument name="arrModelCacheStruct" type="array" required="no" default="#arraynew(1)#">
    	<cfargument name="arrTableAlias" type="array" required="no" default="#arraynew(1)#">
    	<cfargument name="renameDuplicateColumns" type="boolean" required="no" default="#true#">
        <cfscript>
		var arrF=0;
		var i=0;
		var curAlias=0;
		var pos=0;
		var arrN=0;
		var curN=0;
		var curSearchTable=0;
		var i2=0;
		var n=0;
		var found=false;
		var arrF2=arraynew(1);
		var r="";
		var t="";
		var t2="";
		var selectStartSQL="";
		var selectEndSQL="";
		var selectBeginSQL="";
		var uniqueColumnStruct=structnew();
		if(arraylen(arguments.arrModelCacheStruct) EQ 0){
			arrayappend(arguments.arrModelCacheStruct, this._ds);	
		}
		for(i=1;i LTE arraylen(arguments.arrModelCacheStruct);i++){
			if(arguments.arrTableAlias[i] EQ ""){
				arguments.arrTableAlias[i]=arguments.arrModelCacheStruct[i].tableAlias;
			}
			if(left(arguments.arrTableAlias[i],1) EQ "`"){
				arguments.arrTableAlias[i]=mid(arguments.arrTableAlias[i],2,len(arguments.arrTableAlias[i])-2);
			}
		}
		pos=find(",",arguments.selectFields);
		selectStartSQL=arguments.selectFields;
		if(pos NEQ 0){
			selectStartSQL=left(arguments.selectFields,pos-1);
			selectEndSQL=removeChars(arguments.selectFields,1,pos-1);
		} 
		arrF=listtoarray(trim(replace(replace(selectStartSQL,'/*!',' ','all'),'*/','','all'))," ",false);
		for(i=1;i LTE arraylen(arrF);i++){
			if(structkeyexists(application.zcore.mysqlSelectReservedNames, trim(arrF[i]))){
				selectBeginSQL&=arrF[i]&" ";
			}else{
				arrF2[i]=trim(arrF[i]);
			}
		}
		arguments.selectFields=arraytolist(arrF2," ")&selectEndSQL; 
		
		// might want to use application scope lookup for this since structure never changes.
		arrF=listtoarray(arguments.selectFields,",");
		for(i=1;i LTE arraylen(arrF);i++){
			curF=trim(arrF[i]);
			// curF EQ "*", get all
			
			// curF EQ "something.*", get just that table - loop arrModelCacheStruct to find which one, otherwise throw error
			
			
			if(curF EQ "*"){
				// matched "*"
				// loop all fields and return the full list
				arrN=arraynew(1);
				for(i2=1;i2 LTE arraylen(arguments.arrModelCacheStruct);i2++){
					for(n=1;n LTE arraylen(arguments.arrModelCacheStruct[i2].arrFieldOrder);n++){
						curN=arguments.arrModelCacheStruct[i2].arrFieldOrder[n];
						t=arguments.arrModelCacheStruct[i2].fieldSelectPrependSQL[curN]&"`"&arguments.arrTableAlias[i2]&"`."&curN&arguments.arrModelCacheStruct[i2].fieldSelectAppendSQL[curN];
						if(arguments.renameDuplicateColumns){
							if(structkeyexists(uniqueColumnStruct, curN)){
								t2=t&" as `"&arguments.arrTableAlias[i2]&"."&curN&"`";
								arrayappend(arrN,t2);
							}
							uniqueColumnStruct[curN]=true;
						}
						if(arguments.arrModelCacheStruct[i2].fieldSelectAliasRequired[curN]){
							t&=" as "&curN;	
						}
						arrayappend(arrN,t);
					}
				}
				arrF[i]=arraytolist(arrN,", "); 
				continue;	
			}else if(right(curF,2) EQ ".*"){
				// matched "TABLE.*"
				
				// loop all fields and return the full list
				arrN=arraynew(1);
				curSearchTable=removeChars(curF,len(curF)-1,2);
				if(left(curSearchTable,1) EQ "`"){
					curSearchTable=mid(curSearchTable,2,len(curSearchTable)-2);
				}
				for(i2=1;i2 LTE arraylen(arguments.arrModelCacheStruct);i2++){
					if(curSearchTable EQ arguments.arrTableAlias[i2]){
						for(n=1;n LTE arraylen(arguments.arrModelCacheStruct[i2].arrFieldOrder);n++){
							curN=arguments.arrModelCacheStruct[i2].arrFieldOrder[n];
							t=arguments.arrModelCacheStruct[i2].fieldSelectPrependSQL[curN]&"`"&arguments.arrTableAlias[i2]&"`."&curN&arguments.arrModelCacheStruct[i2].fieldSelectAppendSQL[curN];
							if(arguments.renameDuplicateColumns){
								if(structkeyexists(uniqueColumnStruct, curN)){
									t2=t&" as `"&arguments.arrTableAlias[i2]&"."&curN&"`";
									arrayappend(arrN,t2);
								}
								uniqueColumnStruct[curN]=true;
							}
							if(arguments.arrModelCacheStruct[i2].fieldSelectAliasRequired[curN]){
								t&=" as "&curN;	
							}
							arrayappend(arrN,t);
						}
						break;
					}
				}
				if(arraylen(arrN) EQ 0){
					application.zcore.template.fail("#curSearchTable# doesn't match any of the table aliases provided.  arguments.arrTableAlias contains these aliases: "&arraytolist(arguments.arrTableAlias,", "));
				}
				arrF[i]=arraytolist(arrN,", ");
				continue;	
			}
			pos=findnocase(" as ",curF);
			if(pos NEQ 0){
				curAlias=removeChars(curF,1,pos+3);
				curF=left(curF,pos-1);
			}else{
				curAlias=curF;
			}
			found=false;
			for(i2=1;i2 LTE arraylen(arguments.arrModelCacheStruct);i2++){
				if(structkeyexists(arguments.arrModelCacheStruct[i2].fieldSelectPrependSQL,curF)){
					arrF[i]=arguments.arrModelCacheStruct[i2].fieldSelectPrependSQL[curF]&"`"&arguments.arrTableAlias[i2]&"`."&curF&arguments.arrModelCacheStruct[i2].fieldSelectAppendSQL[curF];
					if(arguments.renameDuplicateColumns){
						if(structkeyexists(uniqueColumnStruct, curF)){
							t2=arrF[i]&" as `"&arguments.arrTableAlias[i2]&"."&curF&"`";
							arrayappend(arrN,t2);
						}
						uniqueColumnStruct[curF]=true;
					}
					if(pos NEQ 0 or arguments.arrModelCacheStruct[i2].fieldSelectAliasRequired[curF]){
						arrF[i]&=" as "&curAlias;	
					}
					found=true;
					break;
				}
			}
			if(found EQ false){
				// use select field sql unaltered. it might fail due to typo or invalid sql, but at least its flexible.
				continue;
				//application.zcore.template.fail('"#curF#" doesn''t exist in #arguments.modelCacheStruct.table#.');
			}
		}
		r=selectBeginSQL&arraytolist(arrF,", ");
		//application.zcore.functions.zdump(r);
		return r;
		</cfscript>
    </cffunction>
    </cfoutput>
</cfcomponent>