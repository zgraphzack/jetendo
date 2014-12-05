<cfcomponent displayname="Skinning System Loop Generator" output="no">
	<cfoutput><!--- each tag in a skin must have a unique name --->
	
	
	<!--- get recordcount for query limit statement --->
	<cffunction name="getRecordcount" localmode="modern" returntype="any" output="false">
		<cfargument name="xmlDoc" type="any" required="yes">
		<cfargument name="xmlNode" type="any" required="yes">
		<cfscript>
		return arguments.xmlNode.xmlattributes.rowspan;
		</cfscript>
	</cffunction>
	
	
	<!--- get options + component initialization --->
	<cffunction name="getInit" localmode="modern" returntype="any" output="false">
		<cfargument name="xmlDoc" type="any" required="yes">
		<cfargument name="xmlNode" type="any" required="yes">
		<cfscript>
		var tempStruct = StructNew();
		var optionString = "";
		tempStruct.name = arguments.xmlNode.xmlattributes.name;
		tempStruct.colspan = arguments.xmlNode.xmlattributes.colspan;
		tempStruct.rowspan = arguments.xmlNode.xmlattributes.rowspan;
		tempStruct.colstart = arguments.xmlNode.xmlattributes.colstart;
		tempStruct.colend = arguments.xmlNode.xmlattributes.colend;
		tempStruct.rowstart = arguments.xmlNode.xmlattributes.rowstart;
		tempStruct.rowend = arguments.xmlNode.xmlattributes.rowend;
		tempStruct.rowspan = arguments.xmlNode.xmlattributes.rowspan;
		
		optionString = application.zcore.functions.zStructToString("inputStruct", tempStruct)&chr(10);
		optionString = optionString&"<cfscript>"&chr(10);
		// append component init function call.
		optionString = optionString&this.name&' = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.loopOutput");'&chr(10);
		optionString = optionString&this.name&'.init(inputStruct);'&chr(10);
		optionString = optionString&"</cfscript>"&chr(10);
		// convert tempStruct into a string
		return optionString;
		</cfscript>
	</cffunction>
	
	<!--- get beginning of loop code --->
	<cffunction name="getBegin" localmode="modern" returntype="any" output="false">
		<cfargument name="xmlNode" type="any" required="yes">
		<cfscript>
		return '<cfscript>'&this.name&'.check(currentRow);</cfscript>'&chr(10);
		</cfscript>
	</cffunction>
	<!--- get groups --->
	
	<!--- get variables --->
	
	<!--- get end of loop code --->
	<cffunction name="getEnd" localmode="modern" returntype="any" output="false">
		<cfargument name="xmlNode" type="any" required="yes">
		<cfscript>
		return '<cfscript>'&this.name&'.ifLastRow(currentRow);</cfscript>'&chr(10);
		</cfscript>
	</cffunction>
	
	<cffunction name="createSkin" localmode="modern" returntype="any" output="false">
		<cfreturn "">
	</cffunction>
	</cfoutput>
</cfcomponent>