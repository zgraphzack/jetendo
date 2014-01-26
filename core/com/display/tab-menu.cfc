<cfcomponent>
	<cfoutput>
	<cfscript>
	variables.fieldSetOpen=false;
	variables.tabStruct=structnew();
	if(structkeyexists(request.zos, 'displayManagerTabsIndex') EQ false){
		request.zos.displayManagerTabsIndex=1;
		application.zcore.functions.zRequireJqueryUI();
		application.zcore.functions.zRequireJqueryCookie();
	}else{
		request.zos.displayManagerTabsIndex++;
	}
	variables.tabMenuIndex=request.zos.displayManagerTabsIndex;
	variables.tabMenuOpen=false;
	variables.verticalMenu=false;
	variables.saveButtons=false;
	variables.cancelURL="";
	</cfscript>
	<cffunction name="setTabs" localmode="modern" output="no">
        <cfargument name="arrTab" type="array" required="yes">
        <cfscript>
        variables.arrTab=arguments.arrTab;
        </cfscript>
    </cffunction>
	<cffunction name="setMenuName" localmode="modern" output="no">
        <cfargument name="menuName" type="string" required="yes">
        <cfscript>
        variables.menuName=application.zcore.functions.zURLEncode(arguments.menuName,"-");
        </cfscript>
    </cffunction>
	<cffunction name="setCancelURL" localmode="modern" output="no">
        <cfargument name="theURL" type="string" required="yes">
        <cfscript>
        variables.cancelURL=arguments.theURL;
        </cfscript>
    </cffunction>
    
    <cffunction name="enableSaveButtons" localmode="modern" output="no">
    	<cfscript>
		variables.saveButtons=true;
		</cfscript>
    </cffunction>
    
    <cffunction name="enableVertical" localmode="modern" output="no">
    	<cfscript>
		variables.verticalMenu=true;
		</cfscript>
    </cffunction>
    
    <cffunction name="beginTabMenu" localmode="modern" output="no" returntype="string">
        <cfscript>
        var local=structnew();
		variables.tabMenuOpen=true;
		if(structkeyexists(variables,'arrTab') EQ false){
			application.zcore.functions.zError("tab-menu.cfc error: You must call setTabs() first.");	
		}
		if(structkeyexists(variables,'menuName') EQ false){
			application.zcore.functions.zError("tab-menu.cfc error: You must call setMenuName() first.");	
		}
        </cfscript>
        <cfsavecontent variable="local.theScript">
        <script type="text/javascript">
        /* <![CDATA[ */
		zArrDeferredFunctions.push(function(){
			$(".zmember-tabs#variables.tabMenuIndex#-1").show();
            var user_tabs = $("##zmember-tabs#variables.tabMenuIndex#").tabs({
                show: function(event, ui) {
                    if (ui.index == #arraylen(variables.arrTab)#) {
                        $("fieldset[id^='zmember-tabs#variables.tabMenuIndex#-']").removeClass('ui-tabs-hide');
                        $("fieldset[id='zmember-tabs#variables.tabMenuIndex#-#arraylen(variables.arrTab)+1#']").addClass('ui-tabs-hide');
                    } 
                },
				cookie: {
					expires: 3000,
       				name: "zmember-tabs#variables.tabMenuIndex#-#variables.menuName#"
				}
            })<cfif variables.verticalMenu>.addClass( "zmember-tabs-vertical ui-helper-clearfix" );</cfif>;
        });
		/* ]]> */
        </script>
        </cfsavecontent>
        <cfsavecontent variable="local.theHTML">
        <div class="zmember-tabs" id="zmember-tabs#variables.tabMenuIndex#">
        	<div style="width:100%; float:left; height:40px;">
           <ul class="zmember-tabs#variables.tabMenuIndex#-1" style="display:none;">
            <li><a style="cursor:default;">Show Options:</a></li>
            <cfscript> 
            for(local.i=1;local.i LTE arraylen(variables.arrTab);local.i++){
				variables.tabStruct[variables.arrTab[local.i]]=local.i;
                writeoutput('<li><a href="##zmember-tabs#variables.tabMenuIndex#-'&local.i&'">'&htmleditformat(variables.arrTab[local.i])&'</a></li>');
            }
            </cfscript>
			<cfif arraylen(variables.arrTab) GT 1>
           <li><a href="##zmember-tabs#variables.tabMenuIndex#-#local.i#">All</a></li>
		   </cfif>
           <cfif variables.saveButtons>
           <li class="zmember-tabs-buttons">
           <button type="button" style="display:none;" name="tabSubmitForm#variables.tabMenuIndex#-1-2" id="tabSubmitForm#variables.tabMenuIndex#-1-2">Please Wait</button>
           <button type="submit" onclick="this.style.display='none';document.getElementById('tabSubmitForm#variables.tabMenuIndex#-1-2').style.display='block'" name="tabSubmitForm#variables.tabMenuIndex#-1">Save</button>
           <button type="button" onclick="window.location.href='#jsstringformat(variables.cancelURL)#';" name="tabSubmitForm#variables.tabMenuIndex#-1">Cancel</button>
           </li>
           </cfif>
           </ul>
           </div>
            <cfscript>
                application.zcore.template.appendTag("scripts", local.theScript);
        	</cfscript>
        </cfsavecontent>
        <cfreturn local.theHTML>
    </cffunction>
    
    <cffunction name="beginFieldSet" localmode="modern" output="no" returntype="string">
    	<cfargument name="tabName" type="string" required="yes">
        <cfscript>
		if(variables.tabMenuOpen EQ false){
			application.zcore.functions.zError("tab-menu.cfc error: You must call beginTabMenu() before calling beginFieldSet().");
		}
		if(structkeyexists(variables.tabStruct, arguments.tabName) EQ false){
			application.zcore.functions.zError("tab-menu.cfc error: arguments.tabName, """&arguments.tabName&""", doesn't match any of the tabs: "&arraytolist(variables.arrTab, ", ")&".");
		}
		variables.fieldSetOpen=true;
		</cfscript>
        <cfreturn '<fieldset id="zmember-tabs#variables.tabMenuIndex#-#variables.tabStruct[arguments.tabName]#">'>
    </cffunction>
    <cffunction name="endFieldSet" localmode="modern" output="no" returntype="string">
    	<cfscript>
		if(variables.tabMenuOpen EQ false){
			application.zcore.functions.zError("tab-menu.cfc error: You must call beginTabMenu() first.");
		}
		if(variables.fieldSetOpen EQ false){
			application.zcore.functions.zError("tab-menu.cfc error: You must call beginFieldSet() before endFieldSet().");
		}
		variables.fieldSetOpen=false;
		return '</fieldset>';
		</cfscript>
    </cffunction>
    <cffunction name="endTabMenu" localmode="modern" output="no" returntype="string">
    	<cfscript>
		var returnValue="";
		if(variables.tabMenuOpen EQ false){
			application.zcore.functions.zError("tab-menu.cfc error: You must call beginTabMenu() before calling endTabMenu().");
		}
		if(variables.fieldSetOpen){
			application.zcore.functions.zError("tab-menu.cfc error: You must call the last endFieldSet() before calling endTabMenu().");
		}
		variables.tabMenuOpen=false;
		variables.fieldSetOpen=false;
		returnValue='<fieldset id="zmember-tabs'&variables.tabMenuIndex&'-'&(arraylen(variables.arrTab)+1)&'"></fieldset>';
		if(variables.saveButtons){
           returnValue&='<fieldset class="zmember-tabs-buttons-bottom">
           <button type="button" style="display:none;" name="tabSubmitForm#variables.tabMenuIndex#-1-2" id="tabSubmitForm#variables.tabMenuIndex#-2-2">Please Wait</button>
           <button type="submit" onclick="this.style.display=''none'';document.getElementById(''tabSubmitForm#variables.tabMenuIndex#-2-2'').style.display=''block''" name="tabSubmitForm#variables.tabMenuIndex#-2">Save</button>
           <button type="button" onclick="window.location.href='''&jsstringformat(variables.cancelURL)&''';" name="tabSubmitForm'&variables.tabMenuIndex&'-2">Cancel</button>
           </fieldset>';
        }
		return returnValue&'</div>';
		</cfscript>
    </cffunction>
    </cfoutput>
</cfcomponent>