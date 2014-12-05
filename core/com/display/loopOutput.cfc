<cfcomponent displayname="Loop Output" hint="Helps to create perfect multi-column table output. Vertical or Horizontal layout.  Overriding the default options would allow you to output other formats such as CSV or XML." output="no">
	<cfoutput><cfscript>
	this.comName = "zcorerootmapping.com.display.loopOutput.cfc";
	this.default = true;
	this.colstart="<td>";
	this.colend="</td>";
	this.rowstart="<tr>";
	this.rowend="</tr>";
	this.defaultValues = StructNew();
	this.defaultValues.colstart="<td>";
	this.defaultValues.colend="</td>";
	this.defaultValues.rowstart="<tr>";
	this.defaultValues.rowend="</tr>";
	this.colspan = 1;
	this.vertical = true;
	this.divoutput=false;
	this.currentColumn = 1;
	this.minWidth="";
	</cfscript>
	
	<!--- 	
	<cfscript>	
	inputStruct = StructNew();
	inputStruct.colspan = 3;
	inputStruct.rowspan = 10;
	inputStruct.vertical = true;
	myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
	myColumnOutput.init(inputStruct);
	</cfscript>
	 --->
	<cffunction name="init" localmode="modern" returntype="any" output="true">
		<cfargument name="inputStruct" type="struct" required="yes">
		<cfscript>
		var ss = "";
		StructAppend(this, arguments.inputStruct, true);
		if(this.minWidth NEQ ""){
			this.minWidth=" min-width:"&this.minWidth&"px;";
		}
		if(isDefined('this.rowspan') EQ false){
			application.zcore.template.fail("#this.comName#: init: inputStruct.rowspan is required.",true);
		}
		if(this.colstart NEQ this.defaultValues.colstart or this.colend NEQ this.defaultValues.colend or this.rowstart NEQ this.defaultValues.rowstart or this.rowend NEQ this.defaultValues.rowend){
			this.default = false;
		}else{
			if(this.divoutput){
				if(this.vertical){
					writeoutput('<div style="vertical-align:top;float:left;#this.getColumnWidth()#" >');
				}else{
					writeoutput('<div>');
				}
			}else{
				if(this.vertical){
					writeoutput('<tr><td style="vertical-align:top;#this.getColumnWidth()#" >');
				}else{
					writeoutput('<tr>');
				}
			}
		}
		</cfscript>		
	</cffunction>
	
	
	<!--- myColumnOutput.getColumnWidth(); --->
	<cffunction name="getColumnWidth" localmode="modern" returntype="any" output="false">
		<cfscript>
		if(this.default){
			return ' width:'&int(100 / this.colspan)&'%;'&this.minWidth;
		}else{
			return '';
		}
		</cfscript>
	</cffunction>
	
	<!--- myColumnOutput.check(currentRow); --->
	<cffunction name="check" localmode="modern" returntype="any" output="false">
		<cfargument name="currentRow" required="yes" type="numeric">
		<cfscript>
		if(this.vertical){
			if(this.currentColumn LT this.colspan and Ceiling(this.currentColumn*Ceiling(this.rowspan / this.colspan)) LT arguments.currentRow){
				this.currentColumn = this.currentColumn + 1;
				if(this.divoutput){
					return '</div><div style="vertical-align:top;float:left; #this.getColumnWidth()#" >';
				}else if(this.default){
					return '</td><td style="vertical-align:top; #this.getColumnWidth()#" >';
				}else{
					return this.colend&this.colstart;
				}
				
			}
		}else{
			if(this.divoutput){
				return '<div style="vertical-align:top;float:left; #this.getColumnWidth()#" >';
			}else if(this.default){
				return '<td style="vertical-align:top; #this.getColumnWidth()#" >';
			}else{
				return this.colstart;
			}
		}
		</cfscript>
	</cffunction>
	
	<!--- myColumnOutput.ifLastRow(currentRow); --->
	<cffunction name="ifLastRow" localmode="modern" returntype="any" output="false">
		<cfargument name="currentRow" required="yes" type="numeric">
		<cfscript>
		var output = "";
		var i=0;
		if(this.vertical EQ false){
			if(this.divoutput){
				output = output&'</div>';
			}else if(this.default){
				output = output&'</td>';
			}else{
				output = output&this.colend;
			}
			if(this.currentColumn LTE this.colspan and arguments.currentRow MOD this.colspan EQ 0){
				this.currentColumn = this.currentColumn + 1;
				if(this.divoutput){
					output = output&'</div><div style="float:left; vertical-align:top;">';
				}else if(this.default){
					output = output&'</tr><tr>';
				}else{
					output = output&this.rowend&this.rowstart;
				}
			}
		}
		if(arguments.currentRow EQ this.rowspan){
			if(this.vertical){
				for(i=1;i LTE this.colspan - this.currentColumn;i=i+1){
					if(this.divoutput){
						output = output&'</div><div style="float:left;vertical-align:top;#this.getColumnWidth()#" >&nbsp;';
					}else if(this.default){
						output = output&'</td><td style="vertical-align:top;#this.getColumnWidth()#" >&nbsp;';
					}else{
						output = output&this.colend&this.colstart;
					}
				}
				if(this.divoutput){
					output = output&'</div>';
				}else if(this.default){
					output = output&'</td>';
				}else{
					output = output&this.colend;
				}
			}else{
				for(i=1;i LTE this.colspan-(arguments.currentRow MOD this.colspan);i=i+1){
					if(this.divoutput){
						output = output&'<div style="float:left;vertical-align:top">&nbsp;</div>';
					}else if(this.default){
						output = output&'<td style="vertical-align:top;">&nbsp;</td>';
					}else{
						output = output&this.colstart&" "&this.colend;
					}
				}
			}
			if(this.divoutput){
				output = output&'';
			}else if(this.default){
				output = output&'</tr>';
			}else{
				output = output&this.rowend;
			}
		}
		return output;
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>