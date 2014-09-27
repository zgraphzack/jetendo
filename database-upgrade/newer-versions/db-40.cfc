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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `listing_delete`   
  	ADD  INDEX `NewIndex1` (`listing_id`, `listing_delete_deleted`)")){
		return false;
	} 

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `listing_track`   
	ADD COLUMN `listing_track_inactive` CHAR(1) DEFAULT '0'   NOT NULL AFTER `listing_track_processed_datetime`,
	DROP INDEX `NewIndex1`,
	ADD  UNIQUE INDEX `NewIndex1` (`listing_id`, `listing_track_inactive`, `listing_track_deleted`")){
		return false;
	} 

	query name="qCheck" datasource="#this.datasource#"{
		echo("show tables in `#this.datasource#` LIKE '#request.zos.ramtableprefix#listing' ");
	};
	if(qCheck.recordcount NEQ 0){
		if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.ramTablePrefix#listing`   
	 	 CHANGE `listing_unique_id` `listing_unique_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")){
			return false;
		} 
	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>