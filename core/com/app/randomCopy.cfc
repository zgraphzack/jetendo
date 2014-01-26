<cfcomponent>
<cfoutput>	<cfscript>
	this.vardata=structnew();
	</cfscript>
<!--- 
at the moment, randomCopy.cfc is not used on any of the sites - it may not be safe / compatible anymore.  The sentence table is not tested to be using site_id correctly for all queries.


the spaces between words is still wrong
need to make sure # pounds are properly escaped
when adding a word that is only # - it breaks the system
 --->
	<cffunction name="typeConfirmDelete" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		sentence_type_id=application.zcore.functions.zo('sentence_type_id');
		</cfscript>
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence_type WHERE sentence_type_id = #db.param(sentence_type_id)# 
        </cfsavecontent><cfscript>qType=db.execute("qType");
		if(qType.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid,"Sentence Type no longer exists.");
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=typeList&zsid=#request.zsid#");
		}
		</cfscript>
        Are you sure you want to delete this sentence type?<br />
        <br />
        #qtype.sentence_type_name#<br />
        <br />

        <a href="#request.cgi_script_name#?method=typeDelete&sentence_type_id=#sentence_type_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="#request.cgi_script_name#?method=typeList">No</a>
    </cffunction>
    
	<cffunction name="typeDelete" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		</cfscript>
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence_type WHERE sentence_type_id = #db.param(form.sentence_type_id)# 
        </cfsavecontent><cfscript>qType=db.execute("qType");
		if(qType.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid,"Sentence Type no longer exists.");
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=typeList&zsid=#request.zsid#");
		}
		
		application.zcore.functions.zdeleterecord("sentence_type","sentence_type_id", request.zos.zcoreDatasource);
		application.zcore.status.setStatus(request.zsid,"Sentence Type deleted.");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=typeList&zsid=#request.zsid#");
		</cfscript>
    </cffunction>
    
	<cffunction name="typeSave" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfscript>
		ts=StructNew();
		ts.table="sentence_type";
		ts.datasource="#request.zos.zcoreDatasource#";
		sentence_type_name=trim(sentence_type_name);
		if(sentence_type_name EQ ''){
			application.zcore.status.setStatus(request.zsid,"Type name is required.",form,true);
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=typeForm&sentence_type_id=#sentence_type_id#&zsid=#request.zsid#");
		}
		if(sentence_type_id NEQ ''){
			if(application.zcore.functions.zUpdate(ts) EQ false){
				application.zcore.status.setStatus(request.zsid,"Failed to update sentence type.",form,true);
				application.zcore.functions.zRedirect(request.cgi_script_name&"?method=typeForm&sentence_type_id=#sentence_type_id#&zsid=#request.zsid#");
			}
		}else{
			sentence_id=application.zcore.functions.zInsert(ts);
			if(sentence_id EQ false){
				application.zcore.status.setStatus(request.zsid,"This sentence type already exists.  Please type a unique type name.",form,true);
				application.zcore.functions.zRedirect(request.cgi_script_name&"?method=typeForm&zsid=#request.zsid#");
			}
		}
		application.zcore.status.setStatus(request.zsid,"Sentence type saved.");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=typeList&zsid=#request.zsid#");
		</cfscript>
    </cffunction>
    
    <cffunction name="typeForm" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		sentence_type_id=application.zcore.functions.zo('sentence_type_id');
		</cfscript>
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence_type WHERE sentence_type_id = #db.param(sentence_type_id)# 
        </cfsavecontent><cfscript>qType=db.execute("qType");
		application.zcore.functions.zquerytostruct(qtype);
		application.zcore.functions.zStatusHandler(request.zsid,true);
		</cfscript>
        <table style="width:100%; border-spacing:0px;" class="table-white">
          <tr>
            <td>
            <a href="#request.cgi_SCRIPT_NAME#?method=sentenceList">Sentence Templates</a> / <a href="#request.cgi_SCRIPT_NAME#?method=typeList">Sentence Types</a> /<br /><br />
            <span class="large"><cfif sentence_type_id NEQ ''>Edit<cfelse>Add</cfif> Sentence Types</span>
              </td>
          </tr>
        </table>
        <form action="#request.cgi_script_name#?method=typeSave&sentence_type_id=#sentence_type_id#" method="post">
        <table style="border-spacing:0px;">
        <tr>
        <th>Type Name:</th>
        <td><input type="text" name="sentence_type_name" value="#sentence_type_name#" size="80"></td>
        </tr>
        <tr>
        <th>&nbsp;</th>
        <td><input type="submit" name="submitForm2" value="Save Type"> <input type="button" name="cancel" value="cancel" onclick="window.location.href='#request.cgi_script_name#?method=typeList';"></td>
        </tr>
        </table>
        </form>
    </cffunction>
    
    
	<cffunction name="typeList" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		</cfscript>
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence_type ORDER BY sentence_type_name ASC
        </cfsavecontent><cfscript>qTypes=db.execute("qTypes");</cfscript>
        <table style="width:100%; border-spacing:0px;" class="table-white">
          <tr>
            <td>
            <a href="#request.cgi_SCRIPT_NAME#?method=sentenceList">Sentence Templates</a> /<br /><br />
            <span class="large">Sentence Types</span> | <a href="#request.cgi_SCRIPT_NAME#?method=typeForm">Add Sentence Type</a>
              </td>
          </tr>
        </table>
        <table style="border-spacing:0px;">
        <tr>
        <th>Type</th>
        <th>Admin</th>
        </tr>
        <cfloop query="qTypes">
        <tr>
        <td>#sentence_type_name#</td>
        <td><a href="#request.cgi_script_name#?method=typeForm&sentence_type_id=#sentence_type_id#">Edit</a> | 
        <a href="#request.cgi_script_name#?method=typeConfirmDelete&sentence_type_id=#sentence_type_id#">Delete</a></td>
        </tr>
        </cfloop>
        </table>
    </cffunction>
    
    
	<cffunction name="sentenceConfirmDelete" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		sentence_id=application.zcore.functions.zo('sentence_id');
		</cfscript>
        sentence delete is not working because of site_id
        <cfscript>application.zcore.functions.zabort();</cfscript>
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence WHERE sentence_id = #db.param(sentence_id)# 
        </cfsavecontent><cfscript>qSentence=db.execute("qSentence");
		if(qSentence.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid,"Sentence no longer exists.");
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=sentenceList&zsid=#request.zsid#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#");
		}
		</cfscript>
        Are you sure you want to delete this sentence?<br />
        <br />
        #qsentence.sentence_text#<br />
        <br />

        <a href="#request.cgi_script_name#?method=sentenceDelete&sentence_id=#sentence_id#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="#request.cgi_script_name#?method=sentenceList&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#">No</a>
    </cffunction>
	<cffunction name="sentenceDelete" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence WHERE sentence_id = #db.param(form.sentence_id)# 
        </cfsavecontent><cfscript>qSentence=db.execute("qSentence");
		if(qSentence.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid,"Sentence no longer exists.");
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=sentenceList&zsid=#request.zsid#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#");
		}
		
		form.site_id=request.zos.globals.id;
		application.zcore.functions.zdeletefile(request.zos.globals.serverprivatehomedir&'_cache/scripts/sentenceData/#sentence_id#.cfm');
		application.zcore.functions.zdeleterecord("sentence","sentence_id,site_id", request.zos.zcoreDatasource);
		application.zcore.status.setStatus(request.zsid,"Sentence deleted.");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=sentenceList&zsid=#request.zsid#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#");
		</cfscript>
    </cffunction>
    
    
    
    
    
    
	<!--- 
	ts=StructNew();
	ts.arrType=arraynew(1);
	ts2.id=1;
	ts2.count=5;
	arrayappend(ts.arrType,ts2);
	rCom=randomCopyCom.getRandomParagraph(ts);
	 --->
    <cffunction name="getRandomParagraph" localmode="modern" access="public" returntype="string" output="yes">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var arrReturn=arraynew(1);
		var r="";
		var local=structnew();
		var ts=StructNew();
		var i=0;
		var db=request.zos.queryObject;
		var g=0;
		var qsentence=0;
		ts.arrType=arraynew(1); // sentence_type_id and count is number of sentences to random pull
		structappend(arguments.ss,ts,false);
		if(arraylen(arguments.ss.arrType) EQ 0){
        	application.zcore.template.fail("arguments.ss.arrType is required.");
		}
		this.setVariables();
		</cfscript>
        <!--- 
		can't pull duplicate sentences.
		 --->
        <cfloop from="1" to="#arraylen(arguments.ss.arrType)#" index="i">
            <cfsavecontent variable="db.sql">
            SELECT * FROM sentence WHERE sentence_type_id = #db.param(arguments.ss.arrType[i].id)# 
			ORDER BY rand() 
			LIMIT #db.param(0)#,#db.param(arguments.ss.arrType[i].count)#
            </cfsavecontent><cfscript>qSentence=db.execute("qSentence");</cfscript>

           <!---  #qsentence.sentence_text#<br />
    <br />
                <cfscript>
                </cfscript> --->
            <cfloop query="qSentence">
				<cfif fileexists(request.zos.globals.serverprivatehomedir&'_cache/scripts/sentenceData/#sentence_id#.cfm')>
                    <cfinclude template="/zcorecachemapping/scripts/sentenceData/#sentence_id#.cfm">
                    <cfscript>
                    for(i=1;i LTE arraylen(request.zos.tempSentenceData.arrWords);i++){
                        r=randRange(1,arraylen(request.zos.tempSentenceData.arrWords[i]));
                        arrayAppend(arrReturn,request.zos.tempSentenceData.arrWords[i][r]);
                    }
			 		arrayAppend(arrReturn,' ');
                    </cfscript>
                <cfelse>
                    <cfscript>
                    application.zcore.template.fail("Error: Sentence data is missing.");
                    </cfscript>
                </cfif>
             </cfloop>
		</cfloop>
        <cfscript>
		return trim(arraytolist(arrReturn,""));
		</cfscript>
    </cffunction>
    
    <!--- 
	there needs to be a sentence_document table
	and sentence_document_id in sentence
	
	there is no sentence_type_id for a document's sentence - force a zero to work everywhere...
	allow sorting of the sentences in a document (allows new ones to be added and then pushed to the right spot)
	
	<cffunction name="sentenceDocumentList" localmode="modern" access="remote" returntype="void" output="yes">
	</cffunction>
	
	<cffunction name="sentenceDocumentForm" localmode="modern" access="remote" returntype="void" output="yes">
	</cffunction>
	<cffunction name="sentenceDocumentAdd" localmode="modern" access="remote" returntype="void" output="yes">
		<!--- adding document needs to generate same code as a submission of sentenceForm
		test performance of a long sentence on live server...
	 --->
	</cffunction>
	 --->
    <!---  --->
    
    
	<cffunction name="sentenceHTMLForm" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		sentence_id=application.zcore.functions.zo('sentence_id');
		</cfscript>
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence WHERE sentence_id = #db.param(sentence_id)# 
        </cfsavecontent><cfscript>qSentence=db.execute("qSentence");
		application.zcore.functions.zQueryToStruct(qSentence);
		application.zcore.functions.zStatusHandler(request.zsid,true);
		if(structkeyexists(form, 'sentence_type_id')){
			sentence_type_id=form.sentence_type_id;
		}
		</cfscript>
		<cfsavecontent variable="db.sql">
        SELECT * FROM sentence_type WHERE sentence_type_id = #db.param(sentence_type_id)# ORDER BY sentence_type_name ASC
        </cfsavecontent><cfscript>qType=db.execute("qType");
		if(qtype.recordcount eq 0){
			application.zcore.status.setStatus(request.zsid,"You must select a sentence type.",form,true);
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=sentenceList&zsid=#request.zsid#");
		}
		
		sentence_type_id=qType.sentence_type_id;
		if(sentence_text EQ ''){
			if(application.zcore.functions.zo('theSentence2') NEQ ""){
				sentence_text=application.zcore.functions.zo('theSentence2');
			}else{
				sentence_text=application.zcore.functions.zo('theSentence');
			}
		}
		</cfscript>
        <h2>Edit HTML</h2>
        <p>TODO</p>
        <p>Make parseSentence an external .js</p>
        <p>after parsing all the words, put a container span around everything with the unique id.</p>
        <p>onsubmit, remove the containers and put it back to the normal format that we use when submitting method=sentenceForm</p>
        <p>Do all this with javascript only.</p>
        <form name="myForm" action="#request.cgi_script_name#?method=sentenceSave&sentence_id=#sentence_id#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#" method="post">
    <cfscript>
            
            htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "sentence_text";
            htmlEditor.value			= application.zcore.functions.zo('sentence_text');
            if(request.zos.istestserver){
                htmlEditor.basePath		= '/';
            }else{
                htmlEditor.basePath		= '/z/a/htmlEditor/';
            }
            htmlEditor.width			= "100%";
            htmlEditor.height		= 300;
            htmlEditor.config.EditorAreaCSS=request.zos.globals.editorStylesheet;
            htmlEditor.create();
            </cfscript>
        <input type="button" name="submitForm" value="Save" onclick="saveData();"> 
        <input type="button" name="cancel" value="Cancel" onclick="window.location.href='#request.cgi_script_name#?method=sentenceList&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#';">
        </form>
    </cffunction>
    
	<cffunction name="sentenceList" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var local=structnew();
		echo("disabled");
		abort;
		if(structkeyexists(form, 'zRandomPID') EQ false){
			form.zRandomPID=application.zcore.status.getNewId();
		}
		if(structkeyexists(form, 'zIndex')){
			application.zcore.status.setField(form.zRandomPID, "zIndex", form.zIndex);
		}else{
			form.zIndex = application.zcore.status.getField(form.zRandomPID, "zIndex");
			if(form.zIndex EQ ""){
				form.zIndex = 1;
			}
		}
		Request.zScriptName = request.cgi_script_name&"?zRandomPID=#form.zRandomPID#&method=sentenceList";
		</cfscript>
    	<cfsavecontent variable="db.sql">
        SELECT count(sentence_id) count FROM sentence 
        </cfsavecontent><cfscript>qCount=db.execute("qCount");</cfscript>
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence 
        LEFT JOIN sentence_type ON sentence_type.sentence_type_id = sentence.sentence_type_id 
        LEFT JOIN #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site ON 
		sentence.site_id = site.site_id 
        ORDER BY sentence.sentence_id DESC 
			LIMIT #db.param((form.zIndex-1)*20)#,#db.param(20)#
        </cfsavecontent><cfscript>qSentences=db.execute("qSentences");
		application.zcore.functions.zStatusHandler(request.zsid,true);
		</cfscript>
        <table style="width:100%; border-spacing:0px;" class="table-white">
          <tr>
            <td><span class="large">Sentence Templates</span> | <a href="#request.cgi_SCRIPT_NAME#?method=typeList">Sentence Types</a>
              </td>
          </tr>
        </table>
        <form action="#request.cgi_script_name#?method=sentenceForm" method="post">
        <table style="width:950px; border-spacing:0px;">
        <tr>
        <th style="width:1%;">Type a sentence:</th>
        <td><input type="text" name="theSentence2" value="#application.zcore.functions.zo('theSentence2')#" size="80"></td>
        </tr>
        <tr>
        <th>Sentence Type:</th>
        <td><cfsavecontent variable="db.sql">
                SELECT * FROM sentence_type ORDER BY sentence_type_name ASC
                </cfsavecontent><cfscript>qTypes=db.execute("qTypes");
                    selectStruct = StructNew();
                    selectStruct.name = "sentence_type_id";
                    selectStruct.query=qTypes;
                    selectStruct.queryLabelField = "sentence_type_name";
                    selectStruct.queryValueField = "sentence_type_id";
                    application.zcore.functions.zInputSelectBox(selectStruct);
                    </cfscript></td>
        </tr>
        <tr>
        <th>&nbsp;</th>
        <td><input type="submit" name="submitForm2" value="Add Sentence"></td>
        </tr>
        </table>
        </form>
        <p>Newest sentences appear at top.</p>
        <cfscript>
        
			searchStruct = StructNew();
			searchStruct.count = qCount.count;
			searchStruct.index = form.zIndex;
			searchStruct.showString = "Results ";
			searchStruct.url = Request.zScriptName;
			searchStruct.indexName = "zIndex";
			searchStruct.buttons = 5;
			searchStruct.perpage = 20;
			/*// stylesheet overriding
			searchStruct.tableStyle = "table-searchresults";
			searchStruct.linkStyle = "small-hover";
			searchStruct.textStyle = "small";
			searchStruct.highlightStyle = "highlight";
			*/
			if(searchStruct.count LTE searchStruct.perpage){
				searchNav="";
			}else{
				searchNav = ''&application.zcore.functions.zSearchResultsNav(searchStruct)&'<br />';
			}
			</cfscript>
			#searchNav#
        <table style="border-spacing:0px;" class="table-white">
        <cfif qSentences.recordcount NEQ 0>
        <tr>
        <th>Sentence</th>
        <th>Type</th>
        <th>Status</th>
        <th>Replaced<br />Word Count</th>
        <th>Admin</th>
        </tr>
        </cfif>
        <cfloop query="qSentences">
        
        <tr <cfif qSentences.currentrow MOD 2 EQ 1>style="background-color:##F2F2F2;"</cfif>>
        <td>#left(rereplace(qSentences.sentence_text,"<.*?>","","ALL"),50)#...</td>
        <td>#qSentences.sentence_type_name#</td>
        <td><cfif qSentences.sentence_active EQ 1>Active<cfelse>Inactive</cfif></td>
        <td>#qSentences.sentence_word_replace_count#</td>
        <td><a href="#request.cgi_script_name#?method=sentenceForm&sentence_id=#qSentences.sentence_id#&sentence_type_id=#qSentences.sentence_type_id#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#">Edit</a> |<!--- 
        <a href="#request.cgi_script_name#?method=sentenceHTMLForm&sentence_id=#sentence_id#&sentence_type_id=#sentence_type_id#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#">Edit HTML</a> | --->
        <a href="#request.cgi_script_name#?method=sentenceTest&sentence_id=#qSentences.sentence_id#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#">Test</a> | <a href="#request.cgi_script_name#?method=sentenceConfirmDelete&sentence_id=#qSentences.sentence_id#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#">Delete</a></td>
        </tr>
        </cfloop>
        </table> 
        <br />
			#searchNav#
        <!--- 
       <cfscript>
		writeoutput('Random:<br />');
		ts=StructNew();
		ts.arrType=arraynew(1);
		ts2=StructNew();
		ts2.id=getTypeId("golf");
		ts2.count=1;
		arrayappend(ts.arrType,ts2);
		ts2=StructNew();
		ts2.id=getTypeId("golf2");
		ts2.count=1;
		arrayappend(ts.arrType,ts2);
		result=this.getRandomParagraph(ts);
		writeoutput(result);
		</cfscript>  --->
    </cffunction>
    
    
    
	<cffunction name="sentenceSave" localmode="modern" access="remote" returntype="void" output="yes">
    <cfscript>
	sentence_id=application.zcore.functions.zo('sentence_id');
	if(isDefined('sentenceData') EQ false){
		application.zcore.status.setStatus(request.zsid,"Failed to save sentence",form,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=sentenceForm&sentence_id=#sentence_id#&sentence_type_id=#application.zcore.functions.zo('sentence_type_id')#&zsid=#request.zsid#");
	}
	sentenceData=replace(sentenceData,chr(13),"","all");
	variableData=replace(variableData,chr(13),"","all");
	arrD=listtoarray(sentenceData,chr(10),true);
	arrVariables=listtoarray(variableData,chr(10));	
	sentence_text=trim(arrD[1]);
	site_id=form.sid;
	form.theSentence=sentence_text;
	/*writeoutput(sentence_text&"<br />");
	writeoutput('<table style="border-spacing:0px;"><tr>');
    writeoutput('</tr><tr>');
	for(i=2;i LTE arraylen(arrD);i++){
		writeoutput('<td style="vertical-align:top;">'&replace(arrD[i],chr(9),"<br />","ALL")&'</td>');
	}
	writeoutput('</tr></table>');*/
	/*application.zcore.functions.zdump(form);
	application.zcore.functions.zdump(variableData);
	application.zcore.functions.zabort();*/
	
	ts2=StructNew();
	//sentence_text=replace(sentence_text,"##","####","ALL");
	for(i=1;i LTE arraylen(arrVariables);i++){
		arrVariables[i]="variables['#arrVariables[i]#']=application.zcore.functions.zo('#arrVariables[i]#',false,'#####arrVariables[i]#####');";
		sentence_text=replace(sentence_text,"#####arrVariables[i]#####","###arrVariables[i]###","ALL");
	}
	ts2.arrWords=arraynew(1);
	for(i=2;i LTE arraylen(arrD);i++){
		arrayappend(ts2.arrWords, listtoarray(arrD[i],chr(9)));
	}
	sentence_word_replace_count=0;
	for(i=1;i LTE arraylen(ts2.arrWords);i++){
		sentence_word_replace_count+=arraylen(ts2.arrWords[i])-1;
		for(n=1;n LTE arraylen(ts2.arrWords[i]);n++){
			//if(arraylen(listtoarray(ts2.arrWords[i][n],"##",true)) neq 3){
				ts2.arrWords[i][n]=replace(ts2.arrWords[i][n],"##","####","ALL");
			//}
		}
	}
	ts=StructNew();
	ts.table="sentence";
	ts.datasource="#request.zos.zcoreDatasource#";
	if(sentence_id NEQ ''){
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid,"Failed to save sentence",form,true);
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=sentenceForm&sentence_id=#sentence_id#&sentence_type_id=#application.zcore.functions.zo('sentence_type_id')#&zsid=#request.zsid#");
		}
	}else{
		user_id=session.zos.user.id;
		sentence_id=application.zcore.functions.zInsert(ts);
		if(sentence_id EQ false){
			application.zcore.status.setStatus(request.zsid,"Failed to create sentence.",form,true);
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=sentenceForm&sentence_id=&sentence_type_id=#application.zcore.functions.zo('sentence_type_id')#&zsid=#request.zsid#");
		}
	}
	application.zcore.functions.zwritefile(request.zos.globals.serverprivatehomedir&"_cache/scripts/sentenceData/#sentence_id#.cfm",'<cfscript>request.zos.tempSentenceData=structnew();request.zos.tempSentenceData.arrWords=arraynew(2);'&arraytolist(arrVariables,chr(10))&application.zcore.functions.zstructtostring("request.zos.tempSentenceData",ts2)&'</cfscript>');
	application.zcore.functions.zClearCFMLTemplateCache();
	//application.zcore.functions.zdump(ts);
	application.zcore.status.setStatus(request.zsid,"Sentence Saved at #timeformat(now(),'h:mm:ss tt')#.");
	if(application.zcore.functions.zo('saveAndContinue') EQ '1'){
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=sentenceForm&sentence_id=#sentence_id#&sentence_type_id=#sentence_type_id#&zsid=#request.zsid#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#");
	}else{
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=sentenceList&sentence_type_id=#sentence_type_id#&zsid=#request.zsid#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#");
	}
	</cfscript>
    </cffunction>
    
    <cffunction name="sentenceTest" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		sentence_id=application.zcore.functions.zo('sentence_id');
		</cfscript>
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence WHERE sentence_id = #db.param(sentence_id)# 
        </cfsavecontent><cfscript>qSentence=db.execute("qSentence");</cfscript>
        
        <cfif form.method EQ "sentenceTest">
        <p><a href="#request.cgi_script_name#?method=sentenceList&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#">Back to Sentences</a> /</p>
        <h2 style="display:inline;">Randomized Sentence | </h2> 
        <a href="#request.cgi_script_name#?method=sentenceForm&sentence_id=#sentence_id#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#">Edit</a> <br /><br />
        <cfelse>
        
        </cfif>
        #qsentence.sentence_text#<br />
<br />
			<cfscript>
			this.setVariables();
			</cfscript>
    	<cfif fileexists(request.zos.globals.serverprivatehomedir&'_cache/scripts/sentenceData/#sentence_id#.cfm')>
        <cfinclude template="/zcorecachemapping/scripts/sentenceData/#sentence_id#.cfm">
        <cfscript>
		writeoutput('<table style="width:100%; border-spacing:0px;" class="table-white">');
        for(g=1;g LTE 30;g++){
        	writeoutput('<tr ');
        if(g MOD 2 EQ 0){ writeoutput(' style="background-color:##F3F3F3"'); }
        	writeoutput('><td>');
            for(i=1;i LTE arraylen(request.zos.tempSentenceData.arrWords);i++){
                r=randRange(1,arraylen(request.zos.tempSentenceData.arrWords[i]));
                writeoutput(request.zos.tempSentenceData.arrWords[i][r]);
            }
            writeoutput('</td></tr>');
        }
		writeoutput('</table>');
        </cfscript>
        <cfelse>
        	Error: Sentence data is missing.
        </cfif>
    </cffunction>
    
    <cffunction name="getTypeId" localmode="modern" access="public" returntype="string" output="no">
    	<cfargument name="sentence_type_name" type="string" required="yes">
        <cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		</cfscript>
        <cfsavecontent variable="db.sql">
        SELECT * FROM sentence_type WHERE sentence_type_name=#db.param(sentence_type_name)# 
        </cfsavecontent><cfscript>qType=db.execute("qType");
		if(qtype.recordcount EQ 0){
			application.zcore.template.fail("sentence_type_name doesn't exist");
		}
		return qtype.sentence_type_id;
		</cfscript>
    </cffunction>
    
    <cffunction name="getTypeName" localmode="modern" access="public" returntype="string" output="no">
    	<cfargument name="sentence_type_id" type="numeric" required="yes">
        <cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		</cfscript>
        <cfsavecontent variable="db.sql">
        SELECT * FROM sentence_type WHERE sentence_type_id=#db.param(sentence_type_id)# 
        </cfsavecontent><cfscript>qType=db.execute("qType");
		if(qtype.recordcount EQ 0){
			application.zcore.template.fail("sentence_type_id doesn't exist");
		}
		return qtype.sentence_type_name;
		</cfscript>
    </cffunction>
    
    
    
	<cffunction name="sentenceForm" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var local=structnew();
		sentence_id=application.zcore.functions.zo('sentence_id');
		</cfscript>
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence WHERE sentence_id = #db.param(sentence_id)# 
        </cfsavecontent><cfscript>qSentence=db.execute("qSentence");
		application.zcore.functions.zQueryToStruct(qSentence);
		application.zcore.functions.zStatusHandler(request.zsid,true);
		if(structkeyexists(form, 'sentence_type_id')){
			sentence_type_id=form.sentence_type_id;
		}
		</cfscript>
		<cfsavecontent variable="db.sql">
        SELECT * FROM sentence_type WHERE sentence_type_id = #db.param(sentence_type_id)# ORDER BY sentence_type_name ASC
        </cfsavecontent><cfscript>qType=db.execute("qType");
		if(qtype.recordcount eq 0){
			application.zcore.status.setStatus(request.zsid,"You must select a sentence type.",form,true);
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=sentenceList&zsid=#request.zsid#");
		}
		
		sentence_type_id=qType.sentence_type_id;
		if(sentence_text EQ ''){
			if(application.zcore.functions.zo('theSentence2') NEQ ""){
				sentence_text=application.zcore.functions.zo('theSentence2');
			}else{
				sentence_text=application.zcore.functions.zo('theSentence');
			}
		}
		</cfscript>
       <!---  <link rel="stylesheet" href="#request.zos.globals.editorStylesheet#" type="text/css"> --->
        <script type="text/javascript">/* <![CDATA[ */

// Detect if the browser is IE or not.
// If it is not IE, we assume that the browser is NS.
var IE = document.all?true:false

// If NS -- that is, !IE -- then set up for mouse capture
if (!IE) document.captureEvents(Event.MOUSEMOVE)

// Set-up to use getMouseXY function onMouseMove
document.onmousemove = getMouseXY;

// Temporary variables to hold mouse x-y pos.s
var mouseX = 0
var tempY = 0

// Main function to retrieve mouse x-y pos.s

function getMouseXY(e) {
  if (IE) { // grab the x-y pos.s if browser is IE
    mouseX = event.clientX + document.body.scrollLeft
    mouseY = event.clientY + document.body.scrollTop
  } else {  // grab the x-y pos.s if browser is NS
    mouseX = e.pageX
    mouseY = e.pageY
  }  
  if (mouseX < 0){mouseX = 0}
  if (mouseY < 0){mouseY = 0}  
  return true;
}

// Copyright (c)2005-2007 Matt Kruse (javascripttoolbox.com)
var Position = (function(){
  var pos = {};
  pos.$VERSION = 1.0;
  pos.get = function(o){
    var fixBrowserQuirks = true;
    var left = 0;
    var top = 0;
    var width = 0;
    var height = 0;
    var parentNode = null;
    var offsetParent = null;
    offsetParent = o.offsetParent;
    var originalObject = o;
    var el = o; 
    while (el.parentNode!=null){
      el = el.parentNode;
      if (el.offsetParent==null){
      }else{
        var considerScroll = true;
        if (fixBrowserQuirks && window.opera){
          if (el==originalObject.parentNode || el.nodeName=="TR"){
            considerScroll = false;
          }
        }
        if (considerScroll){
          if (el.scrollTop && el.scrollTop>0){
            top -= el.scrollTop;
          }
          if (el.scrollLeft && el.scrollLeft>0){
            left -= el.scrollLeft;
          }
        }
      }
      if (el == offsetParent){
        left += o.offsetLeft;
		
        if (el.clientLeft && el.nodeName!="TABLE"){ 
          left += el.clientLeft;
        }
        top += o.offsetTop;
        if (el.clientTop && el.nodeName!="TABLE"){
          top += el.clientTop;
        }
        o = el;
        if (o.offsetParent==null){
          if (o.offsetLeft){
            left += o.offsetLeft;
          }
          if (o.offsetTop){
            top += o.offsetTop;
          }
        }
        offsetParent = o.offsetParent;
      }
    }
    if (originalObject.offsetWidth){
      width = originalObject.offsetWidth;
    }
    if (originalObject.offsetHeight){
      height = originalObject.offsetHeight;
    }
    return [left, top, width, height];
  };
  return pos;
})();

function findPos(obj){
	return Position.get(obj);
}

function replaceAll(str, strTarget, strSubString){
	var strText = str;
	var intIndexOfMatch = strText.indexOf( strTarget );
	var c=0;
	while (intIndexOfMatch != -1){
		strText = strText.replace( strTarget, strSubString );
		intIndexOfMatch = strText.indexOf( strTarget );
		c++;
		if(c > 500){
			break;
		}
	}
	return strText;
}


		document.getElementsByClassName = function(cl) {
			var retnode = [];
			var myclass = new RegExp('\\b'+cl+'\\b');
			var elem = this.getElementsByTagName('*');
			for (var i = 0; i < elem.length; i++) {
			var classes = elem[i].className;
			if (myclass.test(classes)) retnode.push(elem[i]);
			}
			return retnode;
		}; 
		
		var mouseOutside=true;
		var curWord="";
		var arrWordData=[];
		var arrBackupWordData=[];
		var selectedWord=null;
		var ignoreClick=false;
		/* beginning doesn't add new words
		end doesn't create a space correctly */
		function editWord(obj){
			var w=parseInt(obj.id.substr(6));
			var r=findPos(obj);
			//alert(arrWordData[w]+":"+w);
			var b=document.getElementById("editBox");
			var b2=document.getElementById("wordBoxTd");
			var b22=document.getElementById("wordBox");
			var b3=document.getElementById("b3");
			var b4=document.getElementById("wordBox1");
			var b6=document.getElementById("wordBox2");
			var b5=document.getElementById("typeBox1");
			b6.style.display="block";
			if(obj.innerHTML=="&nbsp;"){
				b3.style.display="none";
				b2.style.display="none";
				b4.value="";
				b.style.height="80px";
			}else{
				b3.style.display="inline";
				b2.style.display="inline";
				b.style.height="320px";
				b4.value=replaceAll(obj.innerHTML,"&nbsp;"," ");
			}
			if(arrWordType[w]=='var'){
				b5.innerHTML="variable";
				b6.style.display="none";
				b.style.height="110px";
			}else if(arrWordType[w]=='braket'){
				b5.innerHTML="word/phrase";
			}else if(arrWordType[w]=='nonword'){
				b5.innerHTML="punctuation or type new word, phrase or html code";
			}else{
				b5.innerHTML=arrWordType[w];
			}
			mouseOutside=true;
			if(arrWordData[w]==null) arrWordData[w]="";
			b22.value=arrWordData[w];
			arrBackupWordData[w]=arrWordData[w];
			b.style.left=(r[0]-2)+"px";
			b.style.top=((r[1]+r[3])-3)+"px";
			b.style.display="block";
			/* position the word div */
			curWord=w;
			if(selectedWord){
				setNormalWordEvents(selectedWord);
			}
			selectedWord=obj;
			setSelectedWordEvents(obj);
			//alert(curWord+":"+arrWords[curWord]+":data"+arrWordData[w]);
			b4.focus();
		}
		function setWordText(obj){
			arrWordData[curWord]=obj.value;
		}
		var wordChanged=false;
		function setWordText1(){
			wordChanged=true;
		}
		function recreateSentence(){
			if(wordChanged){
				//alert("|"+theSentence+"|");
				var b=document.getElementById("wordBox1");
				var arrW=[];
				arrWords[curWord]=b.value;
				//alert(b.value+"|"+arrWordType[curWord]+"|"+arrWords[curWord]);
				if(arrWordType[curWord]!="nonword"){
					arrWordType[curWord]="bracket";
				}else{
					arrWords[curWord]=" "+b.value+" ";
				}
				arrWords[curWord]=replaceAll(arrWords[curWord]," .",".");
				arrWords[curWord]=replaceAll(arrWords[curWord]," ,",",");
				for(var i=0;i<arrWords.length;i++){
					if(arrWordType[i]=="bracket"){
						arrW[i]="["+arrWords[i]+"]";
					}else{
						arrW[i]=arrWords[i];
					}
				}
				//alert(b.value+":"+curWord);
				wordChanged=false;
				theSentence=arrW.join("");
				//alert("|"+theSentence+"|");
				var c=parseInt(curWord);
				parseSentence();
				var newWordCount=parseInt(arrWords.length-arrW.length);
				var ad=new Array();
				for(i=0;i<arrWordData.length;i++){
					ad[i]=arrWordData[i];
				}
				//alert(arrWordData+"\n"+ad);
				ar=[];
				for(i=c;i<arrW.length;i++){
					if(ad[i] != null){
						arrWordData[i+newWordCount]=ad[i];
					}else{
						arrWordData[i+newWordCount]="";
					}
					ar.push((i)+" to "+(i+newWordCount)+" = "+arrWordData[i+newWordCount]+"\n");
				}
				//alert(ar.join(""));
				//alert(arrWordData+"\n"+ad);
				for(i=c+1;i<c+1+newWordCount;i+=2){
					arrWordData[i]="";
				}
				//alert(c+":"+newWordCount+":"+arrWords.length+":"+arrW.length);
				//return;
			}
			closeBox();
		}
		function resetWordData(){
			var b2=document.getElementById("wordBox");
			if(arrBackupWordData[curWord]){
				arrWordData[curWord]=arrBackupWordData[curWord];
			}else{
				arrWordData[curWord]="";
			}
			b2.value=arrWordData[curWord];
			closeBox();
		}
		function hitTest(obj,x,y){
			var r=findPos(obj);
			if(x>r[0] && x<r[0]+r[2]){
				if(y>r[1] && y<r[1]+r[3]){
					return true;
				}
			}
			return false;
		}
		document.onmousedown=function(){
			var b=document.getElementById("editBox");
			if(selectedWord && !hitTest(b,mouseX,mouseY) && !hitTest(selectedWord,mouseX,mouseY)){
				closeBox();
			}
		}
		function closeBox(){
			var b=document.getElementById("editBox");
			b.style.display="none";
			setNormalWordEvents(selectedWord);
			selectedWord=null;
		}
		function setSelectedWordEvents(obj){
			obj.onmouseover=null;
			obj.onmouseout=null;
			obj.onmouseup=null;
			obj.onmousedown=null;
			obj.className="wordSelected";
		}
		function setNormalWordEvents(obj){
			obj.className="word";
			obj.onmouseover=function(){this.className="wordOver";};
			obj.onmouseout=function(){this.className="wordOut";};
			obj.onmouseup=function(){
				this.className="wordOver";
				editWord(this);
			};
			obj.onmousedown=function(){this.className="wordDown";};
		}
		function deleteWord(offset){
			arrW=new Array();
			var arrWD=new Array();
			//alert(arrWords);
			//alert(curWord+":"+arrWords[curWord+1]+":"+arrWords[curWord]);
			for(i=0;i<arrWords.length;i++){
				if(i!=curWord){
					arrWD.push(arrWordData[i]);
					if(arrWordType[i]=="bracket"){
						arrW.push("["+arrWords[i]+"]");
					}else{
						arrW.push(arrWords[i]);
					}
				}
			}
			//alert(arrW);
			//alert(arrW.join(""));
			arrWordData=arrWD;
			arrBackupWordData=arrWD;
			theSentence=arrW.join("");
			theSentence=theSentence.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
			parseSentence();
			closeBox();
		}
		function saveData(){
			var s=document.getElementById("sentenceData");
			var v=document.getElementById("variableData");
			arrD2=[];
			arrD=[];
			arrD.push(theSentence);
			//alert(arrWordType);
			//arrD.push(arrWords.join("\t"));
			for(var i=1;i<arrWords.length;i++){
				if(arrWordType[i] == "var"){
					arrD2.push(arrWords[i].substr(1,arrWords[i].length-2));
				}
				if(arrWordData[i]==null || arrWordData[i]==""){
					arrD.push(replaceAll(replaceAll(replaceAll(arrWords[i],"\r\n","\t"),"\n","\t"),"\r","\t"));
				}else{
					arrD.push(replaceAll(replaceAll(replaceAll(arrWords[i]+"\t"+arrWordData[i],"\r\n","\t"),"\n","\t"),"\r","\t"));
				}
			}
			d=arrD.join("\n");
			s.value=d;
			d=arrD2.join("\n");
			v.value=d;
			document.myForm.submit();
		}
		
		var arrWords=new Array();
		var arrWordPositions=new Array(); // put the word number here
		var arrWordType=new Array();
		function parseSentence(){
			arrWords=new Array();
			arrWordPositions=new Array();
			arrWordType=new Array();
			theSentence=replaceAll(theSentence,"  "," ");
			theSentence=replaceAll(theSentence," ,",",");
			theSentence=replaceAll(theSentence,"## .","##.");
			//var s=document.getElementById('stb');
			//s.value=theSentence;
			//alert(theSentence);
			// convert to words
			var start=0;
			var inBracket=false;
			var inHTML=false;
			var curWord="";
			var inEmptyTag=false;
			var previousAlphaNumeric=false;
			var inVar=false;
			myregexp = new RegExp(/[0-9A-Za-z\-\[\]]/);
			if(theSentence.substr(i,1).replace(myregexp, "") == ""){
				arrWords.push(" ");
				arrWordPositions.push(arrWords.length-1);
				arrWordType.push("nonword");
			}
			//alert(theSentence);
			myregexp = new RegExp(/[0-9A-Za-z\-]/);
			for(var i=0;i<theSentence.length;i++){
				var letter=theSentence.substr(i,1);
				if(theSentence.length >= i+1){
					var nextletter=theSentence.substr(i+1,1);
				}else{
					var nextletter="";
				}
				if(inHTML){
					if(letter ==">"){
						var cw2=theSentence.substr(start,(i-start)+1);
						var cw3=cw2.substr(2,cw2.length-3);
						if(inEmptyTag && ("</"&arrWords[arrWords.length-1].substr(1) == cw2 || arrWords[arrWords.length-1].substr(1,cw3.length) == cw3 )){
							arrWords.pop();
							arrWordPositions.pop();
							arrWordType.pop();
							if(arrWords[arrWords.length-1]==" "){
								arrWords.pop();
								arrWordPositions.pop();
								arrWordType.pop();
							}
							//alert('empty tag deleted: '+theSentence.substr(start,(i-start)+1));
						}else if(start != i){
							arrWords.push(cw2);
							arrWordPositions.push(arrWords.length-1);
							arrWordType.push("html");
						}
						inHTML=false;
						previousAlphaNumeric=false;
						start=i+1;
						inEmptyTag=false;
					}
				}else if(letter == "<" && nextletter.replace(/^[a-zA-Z/]$/,'') == ""){
					if(previousAlphaNumeric){
						arrWords.push(theSentence.substr(start,i-start));
						arrWordPositions.push(arrWords.length-1);
						arrWordType.push("word");
					}
					if(nextletter=="/" && arrWordType[arrWords.length-1] == "html"){
						inEmptyTag=true;
						//alert('empty tag');
						//alert("empty html tag: "+arrWords[arrWords.length-1]);
					}
					inHTML=true;
					start=i;
					previousAlphaNumeric=false;
				}else if(inBracket){
					/*if(letter == '##'){
						previousAlphaNumeric=false;
						inVar=true;
						start=i+1;
					}else */
					if(letter == ']'){
						if(start != i){
							arrWords.push(theSentence.substr(start,i-start));
							arrWordPositions.push(arrWords.length-1);
							arrWordType.push("bracket");
						}
						inBracket=false;
						previousAlphaNumeric=false;
						start=i+1;
					}
				}else if(inVar){
					if(letter == '##' && nextletter != "##"){
						arrWords.push('##'+theSentence.substr(start,i-start)+'##');
						arrWordPositions.push(arrWords.length-1);
						arrWordType.push("var");
						previousAlphaNumeric=false;
						inVar=false;
						start=i+1;
					}else if(letter.replace(myregexp, "") != ""){
						arrWords.push('##'+theSentence.substr(start,(i-start)));
						arrWordPositions.push(arrWords.length-1);
						arrWordType.push("nonword");
						arrWords.push(' ');
						arrWordPositions.push(arrWords.length-1);
						arrWordType.push("nonword");
						previousAlphaNumeric=false;
						inVar=false;
						start=i+1;
					}
				}else{
					if(letter == '##'){
						if(previousAlphaNumeric){
							arrWords.push(theSentence.substr(start,i-start));
							arrWordPositions.push(arrWords.length-1);
							arrWordType.push("var");
						}
						start=i+1;
						inVar=true;
						previousAlphaNumeric=false;
					}else if(letter == '['){
						if(previousAlphaNumeric){
							arrWords.push(theSentence.substr(start,i-start));
							arrWordPositions.push(arrWords.length-1);
							arrWordType.push("bracket");
						}
						start=i+1;
						inBracket=true;
						previousAlphaNumeric=false;
					}else if(letter.replace(myregexp, "") == ""){
						if(!previousAlphaNumeric){
							start=i;
						}
						previousAlphaNumeric=true;
					}else{
						if(previousAlphaNumeric){
							arrWords.push(theSentence.substr(start,i-start));
							arrWordPositions.push(arrWords.length-1);
							arrWordType.push("bracket");
							arrWords.push(letter);
							arrWordPositions.push(arrWords.length-1);
							arrWordType.push("nonword");
							start=i+1;
						}else{
							if(start==i && (arrWords.length-1<=0 || arrWordType[arrWords.length-1] != "nonword")){
								arrWords.push(letter);
								arrWordPositions.push(arrWords.length-1);
								arrWordType.push("nonword");
							}else{
								start=i+1;
								arrWords[arrWords.length-1]+=letter;			
							}
						}
						previousAlphaNumeric=false;
						// non-alphanumeric
					}
				}
			}
			if(previousAlphaNumeric){
				arrWords.push(theSentence.substr(start,i-start));
				arrWordPositions.push(arrWords.length-1);
				arrWordType.push("bracket");
			}
			if(arrWordType[arrWordType.length-1] != 'nonword'){
				arrWords.push(" ");
				arrWordPositions.push(arrWords.length-1);
				arrWordType.push("nonword");
			}
			var g=0;
			var arrHTML=new Array();
			//arrHTML.push('<span class="word" id="myWord'+g+'">&nbsp;</span>');
			//g++;
			for(i=0;i<arrWords.length;i++){
				if(arrWordType[i] == "html"){
					var tH=replaceAll(arrWords[i],"####","##");
					tH=replaceAll(replaceAll(tH,"<a ","<adisable "),"<\/a>","<\/adisabled>");
					arrHTML.push(tH);
					found=arrWords[i].indexOf("##");
					while(found!=-1){
						arrWords[i]=arrWords[i].substr(0,found)+"##"+arrWords[i].substr(found+1);
						found=arrWords[i].indexOf("##",found+1);
					}
				}else{
					arrHTML.push('<span class="word" id="myWord'+g+'">'+replaceAll(arrWords[i]," ","&nbsp;")+'<\/span>');
				}
				g++;
			}
			if(arrWordType[arrWordType.length-1]!="nonword"){
				arrHTML.push('<span class="word" id="myWord'+g+'">&nbsp;<\/span>');
			}
			arrBackupWordData[i]=arrWordData[i];
			var s=document.getElementById("mySentence");
			//var mt2=document.getElementById("myTextBox22");
			//mt2.value=arrHTML.join("");
			s.innerHTML=arrHTML.join("");
			var arrWord=document.getElementsByClassName("word");
			for(var i=0;i<arrWord.length;i++){
				setNormalWordEvents(arrWord[i]);
			}
		}
		/* ]]> */
		</script>
        <!--- <textarea id="myTextBox22" name="myTextBox22" style="width:500px; height:200px;"></textarea> --->
        <h2>Sentence Randomization Interface</h2>
        <p>Click the words to enter alternate words that fit the sentence. Click the spaces between words to add new words. Enclose phrases with brackets "[" and "]".</p>
        
        <table style="width:750px; border-spacing:0px;">
<tr>
<td style="line-height:24px;">
        <cfscript>application.zcore.template.appendTag("meta",'<style type="text/css">
		/* <![CDATA[ */ ##editBox td,##editBox table{ background:none; color:none; }
		body,input,textarea,button { color:##000000; font-family:Arial, Helvetica, sans-serif; font-size:11px; }
		.word, .wordOut,.wordOver,.wordDown,.wordSelected{ cursor:pointer; padding:3px; <!--- --->float:left;  border:1px solid ##EFEFEF;<!--- color:##000000;  background-color:##FFFFFF; ---> }
		.wordOut{ background-color:##FFFFFF; }
		.wordOver{ border:1px solid ##CCCCCC; background-color:##EFEFEF; }
		.wordDown{ background-color:##CCCCCC; }
		.wordSelected{ color:##FFFFFF; background-color:##666666; border:1px solid ##000000; } 
		sup a{ text-decoration:none; padding-left:2px; }
		##editBox{ background-color:##666666; border:1px solid ##000000; padding:5px; white-space:nowrap;  } /* ]]> */
		</style>');</cfscript>
        <div id="mySentence" style="width:600px; background-color:##FFFFFF;">
        </div>
        <div id="editBox" style="position:absolute; left:0px; top:0px; width:220px; height:260px; display:none;">
        <table style=" border-spacing:0px;font-size:11px; color:##FFFFFF;">
        <tr>
        <td id="wordBox1Td">
        <strong>Type: <span id="typeBox1"></span></strong><br />You can change or add words to the original sentence here.<br />
        <input type="text" name="wordBox1" id="wordBox1" value="" onkeyup="setWordText1(this);" style="width:200px;"></td>
        </tr>
        <tr><td id="wordBoxTd"><div id="wordBox2">Type other words and phrases below that read well in the context of this sentence. Press the enter key after each phrase.<br />
        <textarea name="wordBox" id="wordBox" style="width:200px; height:200px;" onMouseOut="mouseOutside=true;" onMouseOver="mouseOutside=false;" onkeyup="setWordText(this);"></textarea></div></td></tr>
        <tr><td><input type="button" name="b1" id="b1" value="OK" onclick="recreateSentence();"> 
        <input type="button" name="b2" id="b2" value="Cancel" onclick="resetWordData();"> 
        <input type="button" name="b3" id="b3" value="Delete" onclick="deleteWord();"></td></tr>
        </table>
        </div><br style="clear:both;" /><br />
        <form name="myForm" action="#request.cgi_script_name#?method=sentenceSave&sentence_id=#sentence_id#&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#" method="post">
        <table style="border-spacing:0px;">
        <tr>
        <th>Site:</th>
        <td><cfsavecontent variable="db.sql">
                SELECT * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site ORDER BY site_domain ASC
                </cfsavecontent><cfscript>qSite=db.execute("qSite");
				sid=site_id;
                selectStruct = StructNew();
                selectStruct.name = "sid";
                selectStruct.query=qSite;
                selectStruct.queryLabelField = "site_domain";
                selectStruct.queryValueField = "site_id";
                application.zcore.functions.zInputSelectBox(selectStruct);
                </cfscript></td>
        </tr>
        <tr><th>Sentence Type:</th>
        <td><cfsavecontent variable="db.sql">
        SELECT * FROM sentence_type ORDER BY sentence_type_name ASC
        </cfsavecontent><cfscript>qTypes=db.execute("qTypes");
        selectStruct = StructNew();
        selectStruct.name = "sentence_type_id";
        selectStruct.query=qTypes;
        selectStruct.queryLabelField = "sentence_type_name";
        selectStruct.queryValueField = "sentence_type_id";
        application.zcore.functions.zInputSelectBox(selectStruct);
        </cfscript></td>
        </tr>
        <tr><th>Active:</th>
        <td><input type="radio" name="sentence_active" value="1" <cfif sentence_active EQ 1 or sentence_active EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> Yes <input type="radio" name="sentence_active" value="0" <cfif sentence_active EQ 0>checked="checked"</cfif> style="border:none; background:none;" /> No</td>
        </tr>
        <tr><th>&nbsp;</th><td>
        <textarea name="sentenceData" id="sentenceData" value="" style="width:500px; height:400px; display:none;"></textarea>
        <textarea name="variableData" id="variableData" value="" style="width:500px; height:400px; display:none;"></textarea>
        <input type="hidden" name="saveAndContinue" value="0">
        <input type="button" name="submitForm2" value="Save and Continue" onclick="document.myForm.saveAndContinue.value='1';saveData();"> 
        <input type="button" name="submitForm" value="Save" onclick="saveData();"> 
        <input type="button" name="cancel" value="Cancel" onclick="window.location.href='#request.cgi_script_name#?method=sentenceList&zRandomPID=#application.zcore.functions.zso(form, 'zRandomPID')#';">
        </td></tr>
        </table>
        </form>
        <script type="text/javascript">
		/* <![CDATA[ */
		<cfscript>
		/*sentence_text="<H2>Choosing the subject of your video</H2>
<p>In addition to distribution, it is also a great idea to feature   self-promotional audio or video in a prominent location of your home page.�� </p>
<p>You'll want to use video for many reasons including:</p>
<UL>
  <LI>Self-promotion/Sales Presentations   
  <LI>Property Tours   
  <LI>Neighborhood and regional tours   
  <LI>Documenting events   
  <LI>Tour of your office / location   
  <LI>Major landmarks &amp; things to do   
  <LI>Biographies of your staff &amp; assistants   
  <LI>Teaching the visitor how to use your web site or software </LI>
</UL>
<H2>Techniques for creating video</H2>";
		sentence_text="<H2>Choosing</H2><p></p> Test";*/
		sentence_text=rereplace(replacenocase(replacenocase(sentence_text,"&nbsp;"," ","ALL"),"&amp;","&","ALL"),">(\n|\r| |\t)<","><","ALL");
		
		writeoutput('var theSentence="'&jsstringformat(sentence_text)&'";');
		</cfscript>
		parseSentence();
			<cfscript>
			this.setVariables();
			</cfscript>
    	<cfif sentence_id NEQ '' and fileexists(request.zos.globals.serverprivatehomedir&'_cache/scripts/sentenceData/#sentence_id#.cfm')>
			<cfinclude template="/zcorecachemapping/scripts/sentenceData/#sentence_id#.cfm">
			<cfscript>
			for(i=1;i LTE arraylen(request.zos.tempSentenceData.arrWords);i++){
				arraydeleteat(request.zos.tempSentenceData.arrWords[i],1);
				for(g=1;g LTE arraylen(request.zos.tempSentenceData.arrWords[i]);g++){
					request.zos.tempSentenceData.arrWords[i][g]=replace(request.zos.tempSentenceData.arrWords[i][g],"'","\'","ALL");
				}
				writeoutput(chr(10)&"arrWordData[#i#]=#db.param(trim(arraytolist(request.zos.tempSentenceData.arrWords[i],"
")))#;"&chr(10));
			}
			</cfscript>
			arrBackupWordData=arrWordData;
		</cfif>
		/* ]]> */
		</script></td>
</tr>
</table>
        <h2>Randomized Examples</h2>
        Note: Click save and continue to see a new set of randomized sentences.
        <hr />
        #this.sentenceTest()#
    </cffunction>
    
    <cffunction name="setVariables" localmode="modern" output="no" returntype="void">
    	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
    	<cfscript>
		structappend(this.vardata,arguments.ss,true);
		structappend(variables,this.vardata, true);
		</cfscript>
    </cffunction>
	<!--- <cffunction name="sentenceForm" localmode="modern" access="remote" returntype="void" output="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var local=structnew();
		sentence_id=application.zcore.functions.zo('sentence_id');
		</cfscript>
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence WHERE sentence_id = #db.param(sentence_id)# 
        </cfsavecontent><cfscript>qSentence=db.execute("qSentence");
		application.zcore.functions.zQueryToStruct(qSentence);
		application.zcore.functions.zStatusHandler(request.zsid,true);
		</cfscript>
        
        <form action="#request.cgi_script_name#?action=sentenceSave&sentence_id=#sentence_id#" method="post">
        <table style="border-spacing:0px;">
        <tr>
        <th>Sentence Type:</th>
        <td>
    	<cfsavecontent variable="db.sql">
        SELECT * FROM sentence_type ORDER BY sentence_type_name ASC
        </cfsavecontent><cfscript>qTypes=db.execute("qTypes");
            selectStruct = StructNew();
            selectStruct.name = "sentence_type_id";
            selectStruct.query=qTypes;
            selectStruct.queryLabelField = "sentence_type_name";
            selectStruct.queryValueField = "sentence_type_id";
            application.zcore.functions.zInputSelectBox(selectStruct);
            </cfscript>
        </td>
        </tr>
        <tr>
        <th>Sentence:</th>
        <td><input type="text" name="sentence_text" value="#sentence_text#"></td>
        </tr>
        <tr>
        <th>&nbsp;</th>
        <td><input type="submit" name="sentenceSubmit" value="Save"> <input type="button" name="cancel" value="Cancel" onclick="window.location.href='#request.cgi_script_name#?method=sentenceList';"></td>
        </tr>
        </table>
        
        </form>
    </cffunction> --->

	<!--- <cffunction name="getSentence" localmode="modern" returntype="any" output="yes">
		<cfargument name="ss" type="struct" required="yes">
        <cfscript>
		var rs=StructNew();
		var db=request.zos.queryObject;
		var local=structnew();
		ts=StructNew();
		rs.sentence="";
		ts.sentence_type_id="";
		StructAppend(arguments.ss, ts,false);
		if(arguments.ss.sentence_type_id EQ ''){
			application.zcore.template.fail("#this.comName#: getSentence(): ss.sentence_type_id is required.");
		}
		</cfscript>
        <cfsavecontent variable="db.sql">
        select count(sentence_id) count from sentence 
		where sentence.sentence_type_id = #db.param(arguments.ss.sentence_type_id)#
        </cfsavecontent><cfscript>qSentenceCount=db.execute("qSentenceCount");</cfscript>
        <cfsavecontent variable="db.sql">
        select * from sentence 
		where sentence.sentence_type_id = #db.param(arguments.ss.sentence_type_id)# 
		limit #db.param(randRange(1,qSentenceCount.count)-1)#,#db.param(1)#
        </cfsavecontent><cfscript>qSentence=db.execute("qSentence");</cfscript>
        <cfset list="'"&replace(application.zcore.functions.zescape(qSentence.sentence_word_list),",","','","ALL")&"'">
        <cfsavecontent variable="db.sql">
        select * from sentence_word WHERE sentence_word.sentence_word_id IN (#db.param(list)#)
        </cfsavecontent><cfscript>qSentenceWord=db.execute("qSentenceWord");
        replaceStruct=StructNew();
        arrWord=listtoarray(qSentence.sentence_word_list);
        arrReplace=listtoarray(qSentence.sentence_replace_list);
        for(i=1;i<=arrayLen(arrWord);i++){
            replaceStruct[arrWord[i]]=arrReplace[i];
        }
		//application.zcore.functions.zdump(replaceStruct);
        //zdump(qsentence);
        theSentence=replace(qSentence.sentence_text,"  "," ","ALL");
        // convert to words
        arrWords=ArrayNew(1);
        arrWordPositions=arraynew(1); // put the word number here
        // split on any nonalphanumeric including spaces
        start=1;
        inBracket=false;
        curWord="";
        previousAlphaNumeric=false;
        for(i=1;i<=len(theSentence);i++){
            letter=mid(theSentence,i,1);
            if(inBracket){
                if(letter EQ ']'){
                    arrayAppend(arrWords,mid(theSentence,start,i-(start)));
                    arrayAppend(arrWordPositions,arrayLen(arrWords));
                    /*arrayAppend(arrWords,letter);*/
                    inBracket=false;
                    previousAlphaNumeric=false;
                }else{
                    // add to word
                    curWord&=letter;
                }
            }else{
                if(letter EQ '['){
                    if(previousAlphaNumeric){
                        arrayAppend(arrWords,mid(theSentence,start,i-(start)));
                        arrayAppend(arrWordPositions,arrayLen(arrWords));
                    }
                    /*arrayAppend(arrWords,letter);*/
                    start=i+1;
                    inBracket=true;
                    previousAlphaNumeric=false;
                }else if(rereplace(letter,'[0-9A-Za-z\-]','') NEQ letter){
                    previousAlphaNumeric=true;
                    //writeoutput(letter&'<br />');
                }else{
                    //writeoutput('here<br />');
                    if(previousAlphaNumeric){
                        arrayAppend(arrWords,mid(theSentence,start,i-(start)));
                        arrayAppend(arrWordPositions,arrayLen(arrWords));
                    }
                    previousAlphaNumeric=false;
                    // non-alphanumeric
                    arrayAppend(arrWords,letter);
                    start=i+1;			
                }
            }
        }
        if(previousAlphaNumeric){
            arrayAppend(arrWords,mid(theSentence,start,i-(start)));
            arrayAppend(arrWordPositions,arrayLen(arrWords));
        }
		/*writeoutput('<table><tr><td style="vertical-align:top;">');
        application.zcore.functions.zdump(arrWords);
		writeoutput('<td style="vertical-align:top;">');
        application.zcore.functions.zdump(arrWordPositions);
		writeoutput('</td></tr></table>');
		*/
        //writeoutput(arraytolist(arrWords,'')&'<br />');
        </cfscript>
        <cfloop query="qSentenceWord">
            <cfscript>
            // word list
            randomWord=listGetAt(sentence_word_text,randRange(1,listLen(sentence_word_text)));
            // word position
            position=replaceStruct[sentence_word_id];
            // replace word
            //writeoutput('replace word ##'&arrWordPositions[position]&' with '&randomWord&'<br />');
            arrWords[arrWordPositions[position]]=randomWord;
            </cfscript>
        </cfloop>
        <cfscript>
		rs.sentence=replacelist(arraytolist(arrWords,''),'[,]',',');
		return rs;
		</cfscript>
        
        <!--- 
		different ways  to arrange sentences
		i could give them a type id and sort the types
		i could specify that it is a continuous article and get the same sentence order all the time
		completely random sentence order
		look at the sentences to see if they can be rearranged
		each paragraph could be swapped probably.
		
		 --->
        
        
        <!--- <cfscript>
        writeoutput('Original Sentence:<br />'&theSentence&'<br /><br />');
        writeoutput('New Sentence:<br />'&arraytolist(arrWords,''));
        </cfscript><!---  --->
        <cfscript>application.zcore.functions.zabort();</cfscript>
        
        data struct for sentences
        how to classify sentences
            intro,closing,criteria type,keyword list,client
        
        sentence_id
        sentence_type_id
        sentence_text
        
        sentence_word_id
        
        
        sentence thing
         <cfscript>application.zcore.functions.zabort();</cfscript> --->
	</cffunction> --->
    
    <cffunction name="getParagraph" localmode="modern" output="no" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		</cfscript>
        <!--- random sentence order --->
    </cffunction>
    
    <!--- 
	
we need to break down the sentences into this criteria, types and subtypes and tag them correctly in the database so we can expand beyond the standard MLS criteria

real estate sentences:
intro & closing sentences
	encourage user to use the site and contact the client
city
	urban
	suburban
	rural
		subtypes (or nearby):
			coastal
			mountain
			river
			bay
			lake
			capital
			historic
			tourism
			port
			university		
property status
	for sale
	for lease
	for rent	
	new construction
	pre construction
	new custom home
	model homes
	remodeled	
	pre-foreclosure
	foreclosure auctions
	short sales
	bank owned foreclosures	
property type
	rental
		apartment
		condo
		house
		townhouse
	land types:
		vacant lot
		gated community lot for sale
		commercial land
		industrial land
		Residential land
		Rural land (farm land)
		ecquestian land
		
		Within residential zones, for example, there may be subclassifications such as R1 (single-family dwellings), R2 (duplex), apartments, condos, and permitted related uses such as home businesses, daycare, schools, churches, and small businesses or public facilities (post office). 
	residential subtypes:
		condominium
		mobile home
		single family home
		townhouse		
		duplex
		Big list of house styles: http://en.wikipedia.org/wiki/List_of_house_types
		A-frame
		Cape Cod
		Cape Dutch
		Castle
		Chalet bungalow
		Colonial house
		Cottage
		Craftsman house 
		Deck House
		Creole cottage
		Detached
		Bungalow
		Backsplit
		Frontsplit
		Sidesplit
		Link-detached
		Triple decker
		Two-story, three-story 
		Ranch
		Lustron house
		Earth sheltered
		Farmhouse
		Faux chateau
		Foursquare house 
		Gambrel
		Geodesic dome
		Igloo
		Indian vernacular 
		Konak
		Linked
		Log cabin
		Mansion
		McMansion
		Manufactured home 
		Mews property
		Microhouse
		Monolithic dome
		Microapartments
		Mudhif
		Octagon house
		Patio home 
		Pole house
		Prefab
		Queenslander
		Roundhouse
		Saltbox
		Split-level house
		Sears house
		Shack
		Shotgun house
		Souterrain
		Stilt houses or pile dwellings
		Snout house a house
		Storybook houses
		Tipi 
		Treehouse
		Tudor
		Mock Tudor
		Vernacular houses
		Underground home
		Victorian house 
		Villa
		Yaodong
	commercial subtypes:
		restaurant
		Multifamily
		Office
		Industrial
		Retail
		Shopping Center
		Land
		Agricultural
		Hotel & Motel
		Senior Housing
		Health Care
		Sport & Entertainment
		Special Purpose
		Residential Income
		property for sale with liquor license
subdivision
	gated
		guard security
		Usually walled or fenced
	subdivisions often include community amenities:
		Pool(s) 
		Tennis courts 
		A Community centre or club house 
		Golf course(s) 
		A marina 
		On-site Dining 
		Playground areas 
		Exercise areas that include exercise machines 
		Spa(s) 
		Sauna(s) 
county 
	lets make a template for each county we have a client in that discusses the major cities, attractions and events.
price
	luxury
	affordable
bedroom
	large (mansion / estate)
	small (cozy / efficient)
bathroom
acres
	large lots
	land with frontage (i.e. ocean,river,mountain,lake)
	undeveloped land
pool
	indoor
	in-ground
	screened / walled / private
	above ground
	community pool
frontage
	ocean,river,lake,mountain,bay,golf course,shopping,dining
fireplace
golf
	links golf course
	driving range
	putting green
	professional golf: lpga (ladies) / pga
	coastal golf course

	 ---></cfoutput>
</cfcomponent>