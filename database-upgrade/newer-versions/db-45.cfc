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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#whitelabel`(  
  `whitelabel_id` INT(11) NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `user_id` INT(11) NOT NULL DEFAULT 0,
  `whitelabel_dashboard_header_background_color` VARCHAR(6) NOT NULL,
  `whitelabel_dashboard_header_image_960` VARCHAR(100) NOT NULL,
  `whitelabel_dashboard_header_image_640` VARCHAR(100) NOT NULL,
  `whitelabel_dashboard_header_image_320` VARCHAR(100) NOT NULL,
  `whitelabel_dashboard_sidebar_html` LONGTEXT NOT NULL,
  `whitelabel_dashboard_footer_html` LONGTEXT NOT NULL,
  `whitelabel_dashboard_header_html` LONGTEXT NOT NULL,
  `whitelabel_public_dashboard_header_html` LONGTEXT NOT NULL,
  `whitelabel_public_dashboard_footer_html` LONGTEXT NOT NULL,
  `whitelabel_login_header_background_color` VARCHAR(6) NOT NULL,
  `whitelabel_login_header_image_960` VARCHAR(100) NOT NULL,
  `whitelabel_login_header_image_640` VARCHAR(100) NOT NULL,
  `whitelabel_login_header_image_320` VARCHAR(100) NOT NULL,
  `whitelabel_login_sidebar_html` LONGTEXT NOT NULL,
  `whitelabel_login_footer_html` LONGTEXT NOT NULL,
  `whitelabel_login_header_html` LONGTEXT NOT NULL,
  `whitelabel_updated_datetime` DATETIME NOT NULL,
  `whitelabel_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`whitelabel_id`, `site_id`),
  UNIQUE INDEX `NewIndex` (`site_id`, `user_id`, `whitelabel_deleted`)
) ENGINE=INNODB CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `#request.zos.zcoreDatasourcePrefix#whitelabel_button` (
  `whitelabel_button_id` int(11) NOT NULL,
  `whitelabel_button_label` varchar(100) COLLATE utf8_bin NOT NULL,
  `whitelabel_button_url` varchar(255) COLLATE utf8_bin NOT NULL,
  `whitelabel_id` int(11) unsigned NOT NULL,
  `site_id` int(11) unsigned NOT NULL,
  `whitelabel_button_updated_datetime` datetime NOT NULL,
  `whitelabel_button_deleted` int(11) unsigned NOT NULL,
  `whitelabel_button_summary` varchar(255) COLLATE utf8_bin NOT NULL,
   `whitelabel_button_image128` VARCHAR(255) NOT NULL,
   `whitelabel_button_image64` VARCHAR(255) NOT NULL ,
  `whitelabel_button_image32` VARCHAR(255) NOT NULL ,
  `whitelabel_button_target` varchar(10) COLLATE utf8_bin NOT NULL,
  `whitelabel_button_sort` int(11) unsigned NOT NULL DEFAULT '0',
  `whitelabel_button_public` char(1) COLLATE utf8_bin NOT NULL DEFAULT '0',
  `whitelabel_button_builtin` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`whitelabel_button_id`),
  KEY `NewIndex1` (`site_id`,`whitelabel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin")){
		return false;
	} 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>