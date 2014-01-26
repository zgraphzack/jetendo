<cfcomponent>
<cfoutput>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
<cfscript>
form.action=application.zcore.functions.zso(form, 'action',false,"list");
com=createobject("component", "zcorerootmapping.mvc.z.server-manager.help.controller.help-home");
com.index();
</cfscript>
<table style="width:100%; border-spacing:0px;">
<tr class="table-white">
<td><span class="large">Application Reference</span></td>
</tr>
</table>
	
	<table style="width:100%; border-spacing:0px;">
	<td style="vertical-align:top; width:130px;">
	
	<!--- list group --->
	<table style="width:100%; border-spacing:0px;">
	<tr class="table-bright">
	<td class="tiny-bold">Applications</td>
	</tr>
	</table>
	
	
	
	
	
	
	
	</td>
	<td style="vertical-align:top;">
		
		
		
		<table style="width:100%; border-spacing:0px;">	
			<tr class="table-list">
			<td colspan="3" class="medium">Applications</td>
			</tr>
			<tr>
			<td colspan="3" class="table-highlight">Coming soon (maybe never).</td>
	</tr>
	</table></td>
	</tr>
	</table>
	</cffunction>
</cfoutput>
</cfcomponent>