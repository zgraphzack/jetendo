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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`   
  ADD COLUMN `site_enable_lead_reminder_disable_cc` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_custom_create_account_url`,
  ADD COLUMN `site_enable_lead_user_reminder` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_enable_lead_reminder_disable_cc`,
  ADD COLUMN `site_enable_lead_admin_reminder` CHAR(1) DEFAULT '0'  NOT NULL AFTER `site_enable_lead_user_reminder`,
  ADD COLUMN `site_lead_reminder_email1_delay_minutes` INT(11) DEFAULT 0  NOT NULL AFTER `site_enable_lead_admin_reminder`,
  ADD COLUMN `site_lead_reminder_email2_delay_minutes` INT(11) DEFAULT 0  NOT NULL AFTER `site_lead_reminder_email1_delay_minutes`,
  ADD COLUMN `site_lead_reminder_email3_delay_minutes` INT(11) DEFAULT 0  NOT NULL AFTER `site_lead_reminder_email2_delay_minutes`")){
		return false;
	}    
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `user`   
  CHANGE `user_alternate_email` `user_alternate_email` VARCHAR(255) CHARSET utf8 COLLATE utf8_general_ci NOT NULL")){
		return false;
	}     
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO inquiries_status SET inquiries_status_id='7', inquiries_status_name='Spam/Fake', inquiries_status_updated_datetime='#request.zos.mysqlnow#', inquiries_status_deleted='0' ")){
		return false;
	}     
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>