<cfcomponent>
<cfoutput>
<cffunction name="saveDashboard" localmode="modern" access="remote" roles="member">
	<!--- 
	whitelabel_id
	whitelabel_user_id
	whitelabel_site_id
	whitelabel_login_image_320
	whitelabel_dashboard_menu
	whitelabel_dashboard_sidebar_html
	whitelabel_dashboard_footer_html
	whitelabel_dashboard_header_html
	whitelabel_dashboard_button_json
	whitelabel_login_header_image_960
	whitelabel_login_header_image_640
	whitelabel_login_header_image_320
	whitelabel_public_button_json
	
	whitelabel_button
	whitelabel_button_id
	whitelabel_button_type
	site_id

	 --->
</cffunction>
	

<cffunction name="editDefaultDashboard" localmode="modern" access="remote" roles="member">
	
</cffunction>
	

<cffunction name="editDashboard" localmode="modern" access="remote" roles="member">

</cffunction>

	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<!--- 
	let user edit it?

	set site default

	avoid errors when system links change

	allow sorting the button

	allow advertising on right and bottom

	allow statistics on bottom right
		Unassigned leads 
		Open leads


The CMS menu system is different for each user / group because the security configuration can hide some of the menu options.

I will allow setting a default configuration for the site, but the security of that layout will still be enforced, so it will hide things if it needs to.  If you hardcode something that is disabled for them, some CMS users may see a security warning.

The manager is meant to be responsive and most of it already is, but not for phones.   The new dashboard should be able to be responsive too, so we should not try to hardcode any images there that are wider then 310 pixels because of margin.

The interface will allow manual sorting of the quick links that are added.

I will plan and/or make some statistics features that link to the report view for that which can be turned on/off in bottom right or in the main content area.   This will vary based on the features of the site, and the level of integration they have.   Like real estate vs ecommerce.  This is likely to be the last thing I build and it's hardly useful with current features.

The right sidebar will be a tinymce field for you to edit.  

I will allow the dashboard to be inherited from the parent site_id, thus, configuring the parent site will update all the child sites at once.   Perhaps this field will show above the site specific sidebar html, so you can manage both and display both.  I could allow turning off the parent site_id inheritance at the site level.

In addition to letting it have built-in system link buttons, I could allow you to type in text, url, and image for each button widget to allow creating something I don't have or that is an external link.

None of this will impact people who login to the web site without CMS member privileges.   However, I could consider allowing similar editing of the general public user dashboard links and button widgets, though of course display web developer contact info and such would be wrong in that case, so it would need to be completely site-specific for that.

Customizing the Site Manager login screen.     I will make it responsive, and allow editing the header image at 3 breakpoints, allow tinymce field for top content and bottom content and footer links.   No sidebar area because of openid.  I'll have to allow this to inherit from parent site until overridden.  We should make header image that is 320 wide, 640 wide and 960 wide.
	 --->
	
</cffunction>
	
</cfoutput>
</cfcomponent>