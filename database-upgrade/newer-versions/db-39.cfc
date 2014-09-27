<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>

	query name="qKey" datasource="#this.datasource#"{
		echo("SELECT * FROM information_schema.columns WHERE table_schema = '#this.datasource#' AND column_name LIKE '%_deleted' AND data_type LIKE 'char' ");
	}
	for(row in qKey){
		if(structkeyexists(application.zcore.tableConventionExceptionStruct, row.table_name) and structkeyexists(application.zcore.tableConventionExceptionStruct[row.table_name], 'deleted')){
			deletedField=application.zcore.tableConventionExceptionStruct[row.table_name].deleted;
		}else{
			deletedField="#row.table_name#_deleted";
		}
		sql="ALTER TABLE `#row.table_name#`
		CHANGE `#deletedField#` `#deletedField#` INT(11) UNSIGNED DEFAULT 0  NOT NULL";
		echo(sql&";<br><br>");
		query name="qAlter" datasource="#this.datasource#"{
			echo(sql);
		}

	}
 
	query name="qKey" datasource="#this.datasource#"{
		echo("SELECT * FROM information_schema.TABLE_CONSTRAINTS, information_schema.KEY_COLUMN_USAGE WHERE 
	TABLE_CONSTRAINTS.constraint_name <> 'PRIMARY' AND 
	KEY_COLUMN_USAGE.table_name = TABLE_CONSTRAINTS.table_name AND 
	KEY_COLUMN_USAGE.table_schema = TABLE_CONSTRAINTS.table_schema AND 
	KEY_COLUMN_USAGE.constraint_name = TABLE_CONSTRAINTS.constraint_name AND 
	TABLE_CONSTRAINTS.table_schema = '#this.datasource#' ORDER BY 
	TABLE_CONSTRAINTS.TABLE_NAME ASC, KEY_COLUMN_USAGE.ORDINAL_POSITION ASC ");
	}
	keyStruct={};
	for(row in qkey){
		if(not structkeyexists(keyStruct, row.table_name)){
			keyStruct[row.table_name]={};
		}
		if(not structkeyexists(keyStruct[row.table_name], row.constraint_name)){
			keyStruct[row.table_name][row.constraint_name]=[];
		}
		arrayAppend(keyStruct[row.table_name][row.constraint_name], row.column_name);
	}

	for(table in keyStruct){
		arrAlter=["ALTER TABLE `#table#` "];
		if(structkeyexists(application.zcore.tableConventionExceptionStruct, table) and structkeyexists(application.zcore.tableConventionExceptionStruct[table], 'deleted')){
			deletedField=application.zcore.tableConventionExceptionStruct[table].deleted;
		}else{
			deletedField="#table#_deleted";
		}
		query name="qDeleteCheck" datasource="#this.datasource#"{
			echo("SHOW FIELDS IN `#this.datasource#`.`#table#` LIKE '#deletedField#' ");
		};
		if(qDeleteCheck.recordcount EQ 0){
			echo('skipping table: #table#<br /><br />');
			continue;
		}
		arrayAppend(arrAlter, " CHANGE `#deletedField#` `#deletedField#` INT(11) UNSIGNED DEFAULT 0  NOT NULL");
		for(index in keyStruct[table]){
			arrColumn=keyStruct[table][index];
			arrayAppend(arrColumn, deletedField);
			// build alter table with _deleted INT(11) NOT NULL DEFAULT '0'  and the new indicies with _deleted in them.
			arrayAppend(arrAlter, ", DROP INDEX  `#index#`, ");
			arrayAppend(arrAlter, "ADD UNIQUE INDEX `#index#` (`"&arrayToList(arrColumn, "`, `")&"`)");
		}
		sql=arrayToList(arrAlter, " ");
		echo(sql&"; <br><br>");
		
		query name="qAlter" datasource="#this.datasource#"{
			echo(sql);
		} 
	}

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>