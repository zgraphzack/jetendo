<cfcomponent output="no">
	<cfoutput><cfscript>
	this.compiled=false;
	this.selectName="";
	this.selectComponentName="";
	this.allowedStruct=structnew();
	this.allowedStruct.from=true;
	this.allowedStruct.selectFields=true;
	this.allowedStruct.leftJoin=false;
	this.allowedStruct.where=false;
	this.allowedStruct.orderby=false;
	this.allowedStruct.groupby=false;
	this.allowedStruct.having=false;
	this.allowedStruct.count=false;
	this.allowedStruct.offset=false;
	this.selectStruct=structnew();
	this.selectStruct.datasource="";
	this.selectStruct.arrFrom=arraynew(1);
	/*this.selectStruct.tableAlias="";
	this.selectStruct.table="";*/
	this.selectStruct.selectFields="*";
	this.selectStruct.arrLeftJoin=arraynew(1);
	this.selectStruct.where="";
	this.selectStruct.orderby="";
	this.selectStruct.groupby="";
	this.selectStruct.having="";
	this.selectStruct.count="";
	this.selectStruct.offset="";
	this.parameterValueStruct=structnew();
	this.parameterStruct=structnew();
	this.parameterStruct.selectFields=structnew();
	this.parameterStruct.where=structnew();
	this.parameterStruct.orderby=structnew();
	this.parameterStruct.groupby=structnew();
	this.parameterStruct.count=structnew();
	this.parameterStruct.offset=structnew();
	this.parameterStruct.having=structnew();
	this.parameterStruct.arrLeftJoin=arraynew(1);
	</cfscript>
    
    <cffunction name="sequenceError" localmode="modern" access="private" returntype="any">
    	<cfargument name="methodName" type="string" required="yes">
    	<cfscript>
		application.zcore.template.fail("#request.zos.zcorerootmapping#.com.model.select.cfc - #arguments.methodName#() was called out of the allowed sequence. Each method must be called only once in following order except for leftJoin() which can be called multiple times in a row.<br /><br />selectFields().from().leftJoin().where().groupby().having().orderby().offset().count()<br /><br />from() is the only method that is required.");
		</cfscript>
    </cffunction>
    
	<cffunction name="select" localmode="modern" access="public" returntype="any" hint="Enter the normal select expression sql statement with this method.">
		<cfargument name="sql" type="string" required="yes" hint="Use an empty string if you don't want to specify a value.">
        <cfscript>
		if(this.allowedStruct.selectFields EQ false){
			this.sequenceError("selectFields");
		}
		this.allowedStruct.selectFields=false;
		this.selectStruct.selectFields=arguments.sql;
		this.parameterStruct.selectFields=arguments;
		return this;
		</cfscript>
	</cffunction>
    
	<cffunction name="from" localmode="modern" access="public" returntype="any" hint="This method is required in order to set the table you will select from.">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="table" type="string" required="yes" hint="Set the table name.">
		<cfargument name="tableAlias" type="string" required="yes" hint="Set the table alias.">
		<cfargument name="indexHint" type="string" required="no" default="" hint="Optionally set the index hint. This is often used as a performance optimization when mysql chooses the wrong index.">
        <cfscript>
		var ts=structnew();
		if(this.allowedStruct.from EQ false){
			this.sequenceError("from");
		}
		this.allowedStruct.selectFields=false;
		this.allowedStruct.leftJoin=true;
		this.allowedStruct.where=true;
		this.allowedStruct.orderby=true;
		this.allowedStruct.groupby=true;
		this.allowedStruct.having=true;
		this.allowedStruct.count=true;
		this.allowedStruct.offset=true;
		ts.datasource=arguments.datasource;
		ts.table=arguments.table;
		/*if(ts.table CONTAINS "."){
			ts.datasource=listgetat(ts.table,2,".");
			ts.table=listgetat(ts.table,1,".");	
		}*/
		ts.tableAlias=arguments.tableAlias;
		ts.indexHint=arguments.indexHint;
		arrayappend(this.selectStruct.arrFrom, ts);
		return this;
		</cfscript>
	</cffunction>
    
	<cffunction name="leftJoin" localmode="modern" access="public" returntype="any" hint="All joins must be done with the left join function.  You can force a normal inner join by adding to the where() clause code like this: leftJoinTableAlias.id IS NOT NULL">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="table" type="string" required="yes">
		<cfargument name="tableAlias" type="string" required="yes">
		<cfargument name="where" type="string" required="yes">
        <cfscript>
		var ts=structnew();
		if(this.allowedStruct.leftJoin EQ false){
			this.sequenceError("leftJoin");
		}
		this.allowedStruct.from=false;
		ts.table=arguments.table;
		/*if(ts.table CONTAINS "."){
			ts.datasource=listgetat(ts.table,2,".");
			ts.table=listgetat(ts.table,1,".");
		}*/
		ts.datasource=arguments.datasource;
		ts.tableAlias=arguments.tableAlias;
		ts.where=arguments.where;
		if(trim(arguments.where) EQ ""){
			application.zcore.template.fail("zcorerootmapping.com.model.select.cfc error: leftJoin() arguments.where is required.");
		}
		arrayappend(this.selectStruct.arrLeftJoin, ts);
		arrayappend(this.parameterStruct.arrLeftJoin,arguments);
		return this;
		</cfscript>
	</cffunction>
    
	<cffunction name="where" localmode="modern" access="public" returntype="any" hint="Enter all the where expression sql you would normally with this method excluding the ""WHERE"" word.">
		<cfargument name="sql" type="string" required="yes" hint="Use an empty string if you don't want to specify a value.">
        <cfscript>
		if(this.allowedStruct.where EQ false){
			this.sequenceError("where");
		}
		this.allowedStruct.from=false;
		this.allowedStruct.leftJoin=false;
		this.allowedStruct.where=false;
		this.selectStruct.where=arguments.sql; 
		this.parameterStruct.where=arguments;
		structdelete(this.allowedStruct,'where');
		return this;
		</cfscript>
	</cffunction>
    
	<cffunction name="groupby" localmode="modern" access="public" returntype="any" hint="Enter the GROUP BY clause excluding the ""GROUP BY"" words.">
		<cfargument name="sql" type="string" required="yes" hint="Use an empty string if you don't want to specify a value.">
        <cfscript>
		if(this.allowedStruct.groupby EQ false){
			this.sequenceError("groupby");
		}
		this.allowedStruct.from=false;
		this.allowedStruct.leftJoin=false;
		this.allowedStruct.where=false;
		this.allowedStruct.groupby=false;
		this.selectStruct.groupby=arguments.sql;
		this.parameterStruct.groupby=arguments;
		structdelete(this.allowedStruct,'groupby');
		return this;
		</cfscript>
	</cffunction>
    
	<cffunction name="having" localmode="modern" access="public" returntype="any" hint="Enter the GROUP BY clause excluding the ""HAVING"" word.">
		<cfargument name="sql" type="string" required="yes" hint="Use an empty string if you don't want to specify a value.">
        <cfscript>
		if(this.allowedStruct.having EQ false){
			this.sequenceError("having");
		}
		this.allowedStruct.from=false;
		this.allowedStruct.leftJoin=false;
		this.allowedStruct.where=false;
		this.allowedStruct.groupby=false;
		this.allowedStruct.having=false;
		this.selectStruct.having=arguments.sql;
		this.parameterStruct.having=arguments;
		structdelete(this.allowedStruct,'having');
		return this;
		</cfscript>
	</cffunction>
    
	<cffunction name="orderby" localmode="modern" access="public" returntype="any" hint="Enter the ORDER BY clause excluding the ""ORDER BY"" words.">
		<cfargument name="sql" type="string" required="yes" hint="Use an empty string if you don't want to specify a value.">
        <cfscript>
		if(this.allowedStruct.orderby EQ false){
			this.sequenceError("orderby");
		}
		this.allowedStruct.from=false;
		this.allowedStruct.leftJoin=false;
		this.allowedStruct.where=false;
		this.allowedStruct.groupby=false;
		this.allowedStruct.having=false;
		this.allowedStruct.orderby=false;
		this.selectStruct.orderby=arguments.sql;
		this.parameterStruct.orderby=arguments;
		structdelete(this.allowedStruct,'orderby');
		return this;
		</cfscript>
	</cffunction>
    
	<cffunction name="offset" localmode="modern" access="public" returntype="any" hint="Enter the number to offset, a parameter variable or leave it empty to default to 0.">
		<cfargument name="sql" type="string" required="yes" hint="Use an empty string if you don't want to specify a value.">
        <cfscript>
		if(this.allowedStruct.offset EQ false){
			this.sequenceError("offset");
		}
		this.allowedStruct.from=false;
		this.allowedStruct.leftJoin=false;
		this.allowedStruct.where=false;
		this.allowedStruct.orderby=false;
		this.allowedStruct.groupby=false;
		this.allowedStruct.having=false;
		this.allowedStruct.offset=false;
		this.selectStruct.offset=arguments.sql;
		this.parameterStruct.offset=arguments;
		structdelete(this.allowedStruct,'offset');
		return this;
		</cfscript>
	</cffunction>
    
	<cffunction name="count" localmode="modern" access="public" returntype="any" hint="Enter the number of records to return, a parameter variable or leave it empty to default to all records.">
		<cfargument name="sql" type="string" required="yes" hint="Use an empty string if you don't want to specify a value.">
        <cfscript>
		if(this.allowedStruct.count EQ false){
			this.sequenceError("count");
		}
		this.allowedStruct.from=false;
		this.allowedStruct.leftJoin=false;
		this.allowedStruct.where=false;
		this.allowedStruct.orderby=false;
		this.allowedStruct.groupby=false;
		this.allowedStruct.having=false;
		this.allowedStruct.offset=false;
		this.statusStruct.count=false;
		this.selectStruct.count=arguments.sql;
		this.parameterStruct.count=arguments;
		structdelete(this.allowedStruct,'count');
		return this;
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>