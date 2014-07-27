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
	db=request.zos.queryObject;
	query name="qCheck" datasource="#this.datasource#"{
		echo("show tables in `#this.datasource#` LIKE '#request.zos.zcoreDatasourcePrefix##request.zos.ramtableprefix#listing' ");
	};
	if(qCheck.recordcount NEQ 0){
		if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix##request.zos.ramtableprefix#listing`   
		  ADD COLUMN `listing_unique_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
		  DROP PRIMARY KEY,
		  ADD PRIMARY KEY (`listing_unique_id`),
		  ADD  UNIQUE INDEX `NewIndex1` (`listing_id`)")){
			return false;
		} 
	}
	query name="qCheck" datasource="#this.datasource#"{
		echo("show tables in `#this.datasource#` LIKE '#request.zos.zcoreDatasourcePrefix##request.zos.ramtableprefix#city_distance' ");
	};
	if(qCheck.recordcount NEQ 0){
		if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix##request.zos.ramtableprefix#city_distance`   
		  ADD COLUMN `city_distance_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
		  DROP PRIMARY KEY,
		  ADD PRIMARY KEY (`city_distance_id`),
		  ADD  UNIQUE INDEX `newindex1` (`city_parent_id`, `city_id`)")){
			return false;
		}
	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#listing`   
	  ADD COLUMN `listing_unique_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
	  DROP PRIMARY KEY,
	  ADD PRIMARY KEY (`listing_unique_id`),
	  ADD  UNIQUE INDEX `NewIndex1` (`listing_id`)
	  ")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#listing_data`   
	  ADD COLUMN `listing_data_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
	  DROP PRIMARY KEY,
	  ADD PRIMARY KEY (`listing_data_id`),
	  ADD  UNIQUE INDEX `NewIndex2` (`listing_id`)")){
		return false;
	} 

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#city_distance`   
	  ADD COLUMN `city_distance_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
	  DROP PRIMARY KEY,
	  ADD PRIMARY KEY (`city_distance_id`),
	  ADD  UNIQUE INDEX `newindex1` (`city_parent_id`, `city_id`)")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#city_distance_safe_update`   
	  ADD COLUMN `city_distance_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
	  DROP PRIMARY KEY,
	  ADD PRIMARY KEY (`city_distance_id`),
	  ADD  UNIQUE INDEX `newindex1` (`city_parent_id`, `city_id`)")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#city_x_mls`   
	  ADD COLUMN `city_x_mls_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
	  DROP PRIMARY KEY,
	  ADD PRIMARY KEY (`city_x_mls_id`),
	  ADD UNIQUE INDEX (`city_id`, `listing_mls_id`)")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#far_feature`   
	  ADD COLUMN `far_feature_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST,   
	  DROP PRIMARY KEY,
	  ADD PRIMARY KEY (`far_feature_id`),
	  ADD  UNIQUE INDEX `NewIndex1` (`far_feature_code`)")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#mls_image_hash`   
	  ADD COLUMN `mls_image_hash_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
	  ADD PRIMARY KEY (`mls_image_hash_id`)")){
		return false;
	} 

	query name="qCheck" datasource="#this.datasource#"{
		echo("show tables in `#this.datasource#` LIKE '#request.zos.zcoreDatasourcePrefix#far' ");
	};
	if(qCheck.recordcount NEQ 0){
		if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#far`   
		  ADD COLUMN `far_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
		  ADD PRIMARY KEY (`far_id`)")){
			return false;
		} 
	}
	query name="qCheck" datasource="#this.datasource#"{
		echo("show tables in `#this.datasource#` LIKE '#request.zos.zcoreDatasourcePrefix#ngm' ");
	};
	if(qCheck.recordcount NEQ 0){
		if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#ngm`   
		  ADD COLUMN `ngm_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
		  ADD PRIMARY KEY (`ngm_id`)")){
			return false;
		} 
	}
	query name="qCheck" datasource="#this.datasource#"{
		echo("show tables in `#this.datasource#` LIKE '#request.zos.zcoreDatasourcePrefix#rets14_activeagent' ");
	};
	if(qCheck.recordcount NEQ 0){
		if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#rets14_activeagent`   
		  ADD COLUMN `rets14_activeagent_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
		  ADD PRIMARY KEY (`rets14_activeagent_id`)")){
			return false;
		} 
	}
	

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#state`   
	  ADD COLUMN `state_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
	  DROP PRIMARY KEY,
	  ADD PRIMARY KEY (`state_id`),
	  ADD  UNIQUE INDEX `NewIndex1` (`state_code`)")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `#request.zos.zcoreDatasourcePrefix#country`   
	  ADD COLUMN `country_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT FIRST, 
	  DROP PRIMARY KEY,
	  ADD PRIMARY KEY (`country_id`),
	  ADD  UNIQUE INDEX `NewIndex1` (`country_code`)")){
		return false;
	} 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>