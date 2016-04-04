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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
  ADD COLUMN `inquiries_reminder_sent_datetime` DATETIME NOT NULL AFTER `inquiries_target_price`,
  ADD COLUMN `inquiries_reminder_count` INT(11) UNSIGNED DEFAULT 0  NOT NULL AFTER `inquiries_reminder_sent_datetime` ")){
		return false;
	}     
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
  DROP COLUMN `inquiries_c_card4digit`, 
  DROP COLUMN `inquiries_c_name`, 
  DROP COLUMN `inquiries_c_address`, 
  DROP COLUMN `inquiries_c_address2`, 
  DROP COLUMN `inquiries_c_city`, 
  DROP COLUMN `inquiries_c_country`, 
  DROP COLUMN `inquiries_c_state`, 
  DROP COLUMN `inquiries_c_zip`, 
  DROP COLUMN `inquiries_c_response`, 
  DROP COLUMN `inquiries_check_number`, 
  DROP COLUMN `inquiries_cash`, 
  DROP COLUMN `inquiries_nights_total`, 
  DROP COLUMN `inquiries_night_breakdown`, 
  DROP COLUMN `inquiries_tax`, 
  DROP COLUMN `inquiries_discount`, 
  DROP COLUMN `inquiries_discount_desc`, 
  DROP COLUMN `inquiries_cleaning`, 
  DROP COLUMN `inquiries_addl_guest`, 
  DROP COLUMN `inquiries_addl_cleaning`, 
  DROP COLUMN `inquiries_addl_rate`, 
  DROP COLUMN `inquiries_subtotal`, 
  DROP COLUMN `inquiries_total`, 
  DROP COLUMN `inquiries_deposit`, 
  DROP COLUMN `inquiries_checkin_amount`, 
  DROP COLUMN `inquiries_balance_due`, 
  DROP COLUMN `inquiries_coupon_code`, 
  DROP COLUMN `inquiries_children_age`, 
  DROP COLUMN `inquiries_pets`, 
  DROP COLUMN `inquiries_pet_total_fee`, 
  DROP COLUMN `inquiries_order`, 
  DROP COLUMN `inquiries_order_processed`, 
  DROP COLUMN `inquiries_order_description`, 
  DROP COLUMN `inquiries_order_shipping`, 
  DROP COLUMN `inquiries_order_shipping_service`, 
  DROP COLUMN `inquiries_order_subtotal`, 
  DROP COLUMN `inquiries_order_tax`, 
  DROP COLUMN `inquiries_order_total`, 
  DROP COLUMN `inquiries_order_discount`, 
  DROP COLUMN `inquiries_ship_name`, 
  DROP COLUMN `inquiries_ship_address`, 
  DROP COLUMN `inquiries_ship_address2`, 
  DROP COLUMN `inquiries_ship_city`, 
  DROP COLUMN `inquiries_ship_zip`, 
  DROP COLUMN `inquiries_ship_country`, 
  drop column `inquiries_ship_state`, 
  drop column `inquiries_payment_total`, 
  drop column `inquiries_payment_response`")){
		return false;
	}     
	

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>