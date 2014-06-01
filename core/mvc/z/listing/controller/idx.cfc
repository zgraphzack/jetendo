<cfcomponent>
    <cfoutput>
	<cfscript>
	this.nowDate=request.zos.mysqlnow;
	this.dataStruct=structnew();
	this.optionstruct=structnew();
	this.optionstruct.limitTestServer=true;
	this.inited=false;
	</cfscript>
    <cffunction name="reimport" localmode="modern" access="remote" returntype="any" output="yes">
    	<cfscript>
	var qDir=0;
	var p=0;
	var qT=0;
		var db=request.zos.queryObject;
		var local=structnew();
		if(request.zos.istestserver){
			p="#request.zos.sharedPath#mls-data/";	
		}else{
			p="#request.zos.sharedPath#mls-data/";
		}
		</cfscript>
    	<cfif application.zcore.functions.zso(form, 'mls_id',true) NEQ 0>
	    	<cfdirectory action="list" directory="#p&form.mls_id#" name="qDir">
            <cfloop query="qDir">
            	<cfif qdir.name contains "-imported">
	            	<cffile action="rename" source="#p&form.mls_id#/#qdir.name#" destination="#p&form.mls_id#/#replacenocase(qdir.name,'-imported','','all')#">
                
                </cfif>
				<cfscript>
				local.pos=findnocase("-corrupt", qdir.name);
				</cfscript>
            	<cfif local.pos>
	            	<cffile action="rename" source="#p&form.mls_id#/#qdir.name#" destination="#p&form.mls_id#/#left(qdir.name,local.pos-1)#">
                
                </cfif>
            </cfloop>
        	<cfsavecontent variable="db.sql">
            UPDATE #db.table("listing_track", request.zos.zcoreDatasource)# listing_track 
			set listing_track_hash = #db.param('')# 
			where listing_id like #db.param('#form.mls_id#-%')#
            </cfsavecontent><cfscript>qT=db.execute("qT");</cfscript>Done
            <cfelse>Denied
        </cfif>
        <cfscript>application.zcore.functions.zabort();</cfscript>
    </cffunction>
    
    <cffunction name="init" localmode="modern" access="public" returntype="any">
        <cfscript>
		var qmls=0;
		var f=0;
		var nd222=0;
		var qp2=0;
		var firstline=0;
		var arrcolumns=0;
		var qp=0;
		var x=0;
		var db=request.zos.queryObject;
		var qu=0;
		var starttime=0;
		this.inited=true;
		application.zcore.listingCom=application.zcore.listingStruct.configCom;
		
		this.optionstruct.loopRowCount=40;
		if(request.zos.istestserver){
			this.optionstruct.delaybetweenloops=0;
		}else{
			this.optionstruct.delaybetweenloops=0; // 30
		}
		this.optionstruct.timeLimitInSeconds=75; // 75
		// process the mls provider that is the most out of date first
		db.sql="SELECT * FROM #db.table("mls", request.zos.zcoreDatasource)# mls 
		WHERE mls_status=#db.param('1')# 
		ORDER BY mls_update_date ASC ";
		qMLS=db.execute("qMLS"); 
		for(f=1;f LTE qMLS.recordcount;f++){
			this.optionstruct.mls_id=qMLS.mls_id[f];
			request.zos.importMlsStruct[this.optionstruct.mls_id].arrImportListingRows=arraynew(1);
			request.zos.importMlsStruct[this.optionstruct.mls_id].arrImportListingDataRows=arraynew(1);
			request.zos.importMlsStruct[this.optionstruct.mls_id].arrImportListingTrackRows=arraynew(1);
			this.optionstruct.delimiter=qMLS.mls_delimiter[f];
			this.optionstruct.csvquote=qMLS.mls_csvquote[f];
			this.optionstruct.first_line_columns=qMLS.mls_first_line_columns[f];
			this.optionstruct.qMLS=qMLS;
			this.optionstruct.query_row=f;
			this.optionstruct.mlsProviderCom=createobject("component","zcorerootmapping.mvc.z.listing.mls-provider.#qMLS.mls_com[f]#");
			this.optionstruct.mlsproviderCom.setMLS(this.optionstruct.mls_id); 
			if(qMLS.mls_current_file_path[f] NEQ "" and fileexists(qMLS.mls_current_file_path[f])){
				this.optionstruct.filePath=replace(trim(qMLS.mls_current_file_path[f]),"\","/","ALL");
				this.optionstruct.skipBytes=qMLS.mls_skip_bytes[f];
				break;
			}else{
				this.optionstruct.filePath=replace(trim(this.optionstruct.mlsProviderCom.getImportFilePath(this.optionstruct)),"\","/","ALL");
				this.optionstruct.skipBytes=0;
				if(this.optionstruct.filePath NEQ false){
					break;
				}
			}
		}
		if(this.optionstruct.filePath EQ false){
			writeoutput('All files are complete.');
			this.cleanInactive();
			
			// update price only once each day
			db.sql="select max(content_price_update_datetime) mdate 
			FROM #db.table("content", request.zos.zcoreDatasource)# content 
			where site_id <> #db.param(-1)#";
			qP2=db.execute("qP2"); 
			nd222=dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(),'HH:00:00');
			if(dateformat(qP2.mdate,'yyyy-mm-dd')&' '&timeformat(qP2.mdate,'HH:00:00') NEQ nd222){
				db.sql="select content.content_id, listing.listing_price from 
				#db.table("content", request.zos.zcoreDatasource)# content, 
				#db.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)# listing 
				where content.site_id <> #db.param(-1)# and 
				listing.listing_id = content.content_mls_number and 
				content.content_mls_number<>#db.param('')# and 
				content.content_mls_price=#db.param('1')# and 
				content.content_price_update_datetime<#db.param(nd222)#";
				qP=db.execute("qP");
				for (x=1; x LTE qP.recordcount; x++) {
					 db.sql="UPDATE #db.table("content", request.zos.zcoreDatasource)# content 
					 SET content_price=#db.param(qP.listing_price[x])#, 
					 content_price_update_datetime=#db.param(nd222)# 
					 WHERE site_id <> #db.param(-1)# and 
					 content_id = #db.param(qP.content_id[x])#";
					 qU = db.execute("qU");
				}
			}
			return true;
		}
		
		request.zos.listing=application.zcore.listingStruct;
		if(this.optionstruct.first_line_columns EQ 1){
			f=fileopen(request.zos.sharedPath&this.optionstruct.filePath,"read", "windows-1252");
			try{
				firstline=lcase(filereadline(f));
			}catch(Any excpt){
				fileclose(f);
				application.zcore.template.fail("firstline=lcase(filereadline(f)); failed | #request.zos.sharedPath&this.optionstruct.filepath#.");
			}
			fileclose(f);
			arrColumns=listtoarray(replace(firstline," ","","ALL"), this.optionstruct.delimiter);
			this.optionstruct.mlsproviderCom.setColumns(arrColumns);
			this.optionstruct.arrColumns=arrColumns;
		}else if(structkeyexists(this.optionstruct,"arrColumns")){
			this.optionstruct.mlsProviderCom.setColumns(this.optionstruct.arrColumns); 
		}else{
		//	throw("failed to set columns for mls_id = #this.optionStruct.mls_id#");
		} 
		this.optionstruct.mlsproviderCom.initImport("property", application.zcore.listingStruct.mlsStruct[this.optionstruct.mls_id].sharedStruct);
		if(structkeyexists(request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct,"arrColumns")){
			this.optionstruct.arrColumns=request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.arrColumns;
		}
		return false;
		</cfscript>
    </cffunction>
	
<cffunction name="process" localmode="modern" access="public" returntype="any"> 
    	<cfscript>
	var r22=0;
	var jfis=0;
	var r1="";
	var db=request.zos.queryObject;
	var csvParser=0;
	var line2=0;
	var fieldComplete=0;
	var oldOffset=0;
	var currentOffset=0;
	var loopCount=0;
	var stillParsing=0;
	var addRowFailCount=0;
	var i2=0;
	var line=0;
	var fileComplete=0;
	var p=0;
	var startTime=gettickcount();
	var mlsUpdateDate=0;
	var r=0;
	try{
		if(this.optionstruct.delimiter EQ ""){
			application.zcore.template.fail("The delimiter for mls_id, "&this.optionstruct.mls_id&", can't be an empty string.");	
		}
		// idea for higher performance initial insert:
			// instead of reading the file from disk, import the csv into a temporary mysql table based on first row size
			// have to use first line for columns - some mls don't have that, they use the hardcoded column list in the mls-provider
			
			// once table exists, it will act as a queue.  the records will be removed as they are processed.
			// select * from recordcount
				// consider allowing threads= (CPU cores / 2)  to process these tables simultaneously
					// figure out how to do that.
		 
		request.zTempIDXFilePath=request.zos.sharedPath&this.optionstruct.filePath;
		
		variables.fileHandle=fileOpen("#request.zos.sharedPath&this.optionstruct.filePath#", 'read', "windows-1252");
		 
		if(this.optionstruct.skipBytes NEQ 0){
			fileSkipBytes(variables.fileHandle, this.optionStruct.skipBytes); 
		}
		writeoutput(request.zos.sharedPath&this.optionstruct.filePath&'<br />');
		
		
		variables.csvParser=createObject("component", "zcorerootmapping.com.app.csvParser");
		variables.csvParser.pathToOstermillerCSVParserJar=application.zcore.railowebinfpath&"lib/ostermillerutils.jar";
		variables.csvParser.enableJava=request.zos.isJavaEnabled;
		variables.csvParser.arrColumn=this.optionstruct.arrColumns;
		variables.csvParser.separator=this.optionStruct.delimiter;
		variables.csvParser.textQualifier=this.optionstruct.csvquote;
		variables.csvParser.init();
		if(this.optionstruct.skipBytes NEQ 0){
			// skip the partially read line
			line2=fileReadLine(variables.fileHandle);
		}else if(this.optionstruct.first_line_columns EQ 1){
			line2=fileReadLine(variables.fileHandle); // ignore columns since they were already read
		}else{
			line2="ignore";	
		}
		fileComplete=false;
		oldOffset=0;
		currentOffset=0;
		loopcount=0;
		stillParsing=true;
		addRowFailCount=0;
		while(gettickcount()-startTime LTE this.optionstruct.timeLimitInSeconds*1000){// and stillParsing){
			for(i2=1;i2 LTE this.optionstruct.loopRowCount;i2++){
				loopcount++;
				if(fileIsEOF(variables.fileHandle) or (this.optionstruct.limitTestServer and request.zos.istestserver and loopcount GT 500)){
					fileComplete=true;
					break;	
				}
				line=variables.csvParser.parseLineIntoArray(fileReadLine(variables.fileHandle));  
				request.curline=line;
				r1=this.addRow(line);
				if(r1 EQ false){
					addRowFailCount++;
					if(addRowFailCount GTE 10){
						fileClose(variables.fileHandle);
						application.zcore.functions.zRenameFile(request.zos.sharedPath&this.optionstruct.filepath, request.zos.sharedPath&this.optionstruct.filepath&"-corrupt-"&dateformat(now(),'yyyy-mm-dd')&'-'&timeformat(now(),'HH-mm-ss'));	
						if(fileexists(request.zos.sharedPath&this.optionstruct.filepath&"-imported")){
							application.zcore.functions.zCopyFile(request.zos.sharedPath&this.optionstruct.filepath&"-imported", request.zos.sharedPath&this.optionstruct.filepath);	
						}
						application.zcore.template.fail(request.addRowErrorMessage);
					}
				}
			}
			this.checkDuplicates();
			r22=this.import();
			if(r22 EQ false){
				break;	
			}
			if(this.optionstruct.delaybetweenloops NEQ 0){
				sleep(this.optionstruct.delaybetweenloops);
			}
			if(fileComplete){
				break;
			}
		}
		
		fileClose(variables.fileHandle);
		mlsUpdateDate="";
		if(fileComplete){
			writeoutput('File import, "#request.zos.sharedPath&this.optionstruct.filepath#",  is complete<br />');
			application.zcore.functions.zDeleteFile(request.zos.sharedPath&this.optionstruct.filepath&"-imported");	
			r=application.zcore.functions.zRenameFile(request.zos.sharedPath&this.optionstruct.filepath, request.zos.sharedPath&this.optionstruct.filepath&"-imported");			
			this.optionstruct.skipBytes=0;
			this.optionstruct.filePath=replace(trim(this.optionstruct.mlsProviderCom.getImportFilePath(this.optionstruct)),"\","/","ALL");
			if(this.optionstruct.filePath EQ false){
				this.optionstruct.filePath="";
				mlsUpdateDate=" , mls_update_date = '#request.zos.mysqlnow#' ";
			}
		}else{
			this.optionstruct.skipBytes=oldOffset;	
		}
	}catch(Any local.e){
		if(structkeyexists(variables, 'fileHandle')){
			fileClose(variables.fileHandle);
		}
		rethrow;
	}
	writeoutput('last usable offset:'&oldOffset&"<br />");
	
	db.sql="UPDATE #db.table("mls", request.zos.zcoreDatasource)# mls 
	SET mls_current_file_path=#db.param(this.optionstruct.filePath)#, 
	mls_error_sent=#db.param('0')#, 
	mls_skip_bytes=#db.param(this.optionstruct.skipBytes)# #db.trustedSQL(mlsUpdateDate)# 
	where mls_id = #db.param(this.optionstruct.mls_id)#";
	db.execute("q"); 
	
	if(gettickcount()-startTime LT this.optionstruct.timeLimitInSeconds*1000){
		writeoutput('Completed in #(gettickcount()-startTime)/1000# seconds');
	}else{
		writeoutput('Stopped after #this.optionstruct.timeLimitInSeconds# seconds');
	}
	</cfscript>
</cffunction>
    
	<cffunction name="addRow" localmode="modern" access="public" returntype="any">
		<cfargument name="arrRow" type="array" required="yes">
        <cfscript>
		var ts=structnew();
		if(this.inited EQ false){
			request.addRowErrorMessage="zcorerootmapping.com.apps.idx requires init() to be called before addRow(). Reverted to previous day's file to avoid data loss.";
			return false;
		}
		ts.hash=hash(arraytolist(arguments.arrRow,chr(10)));
		ts.arrData=arguments.arrRow;
		ts.new=true;
		ts.update=true;
		ts.listing_mls_id=this.optionstruct.mls_id;
		//writedump(ts); 
		try{
			if(arraylen(ts.arrData) LT request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset){
				request.addRowErrorMessage="This row was not long enough to contain the listing_id column: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.arrRow,chr(10)))&". Reverted to previous day's file to avoid data loss. ";
				return false;
	//				application.zcore.template.fail("This row was not long enough to contain the listing_id column: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.arrRow,chr(10)))&"");
			}
			ts.listing_id=this.optionstruct.mls_id&'-'&ts.arrData[request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset];
			
			if(right(ts.listing_id,1) EQ "-"){
				request.addRowErrorMessage="Invalid listing id. The field was empty.  Review the corrupt file starting with the current file path: "&this.optionstruct.filePath&". Reverted to previous day's file to avoid data loss.";
				return false;	
			}
			/*if(ts.listing_id EQ "11-WBPR"){
				//writedump(ts.arrData);
			}*/
			ts.arrData[request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset]=ts.listing_id;
		}catch(Any excpt){
			request.addRowErrorMessage="MLS Import Add Row failed for mls_id, "&this.optionstruct.mls_id&". Length: #arraylen(ts.arrData)# | ID Offset: #request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset# | The column header row might be missing. Current file path: "&this.optionstruct.filePath&". Reverted to previous day's file to avoid data loss.";
				return false;
				
		}
		
		this.dataStruct[ts.listing_id]=ts; 
		return true;
		</cfscript>
	</cffunction>
    <cffunction name="checkDuplicates" localmode="modern" access="public" returntype="any">
    	<cfscript>
		var sqllist=0;
		var db=request.zos.queryObject;
		var qt=0;
		if(structcount(this.datastruct) EQ 0) return;
		sqllist="'"&structkeylist(this.datastruct,"','")&"'";
		db.sql="select * from #db.table("listing_track", request.zos.zcoreDatasource)# listing_track 
		where listing_id IN (#db.trustedSQL(sqllist)#)";
		qT=db.execute("qT"); 
		</cfscript>
        <cfloop query="qT">
        	<cfscript>
			this.datastruct[qT.listing_id].listing_track_id=qT.listing_track_id;
			this.datastruct[qT.listing_id].listing_track_price=qT.listing_track_price;
			this.datastruct[qT.listing_id].listing_track_datetime=dateformat(qT.listing_track_datetime,"yyyy-mm-dd")&" "&timeformat(qT.listing_track_datetime,"HH:mm:ss");
			this.datastruct[qT.listing_id].listing_track_updated_datetime=dateformat(qT.listing_track_updated_datetime,"yyyy-mm-dd")&" "&timeformat(qT.listing_track_updated_datetime,"HH:mm:ss");
			this.datastruct[qT.listing_id].new=false;
			if(this.datastruct[qT.listing_id].hash EQ qT.listing_track_hash){
				this.datastruct[qT.listing_id].update=false;
			}
			</cfscript>
        </cfloop>
    </cffunction>
    
    <cffunction name="processListingTableStruct" localmode="modern" access="public">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
	var n=0;
	var rs=arguments.ss;
	local.arrTemp=[];
	local.arrColumn=request.zos.listing.mlsStruct[rs.mls_id].sharedStruct.lookupStruct.arrlistingcolumns;
	local.columnCount=request.zos.listing.mlsStruct[rs.mls_id].sharedStruct.lookupStruct.arrlistingcolumns;
	local.arrDataColumn=request.zos.listing.mlsStruct[rs.mls_id].sharedStruct.lookupStruct.arrlistingdatacolumns;
	local.dataColumnCount=request.zos.listing.mlsStruct[rs.mls_id].sharedStruct.lookupStruct.arrlistingdatacolumns;
	local.arrTrackColumn=request.zos.listing.mlsStruct[rs.mls_id].sharedStruct.lookupStruct.arrlistingtrackcolumns;
	local.trackColumnCount=request.zos.listing.mlsStruct[rs.mls_id].sharedStruct.lookupStruct.arrlistingtrackcolumns;
	for(n=1;n LTE arraylen(local.columnCount);n++){
		if(structkeyexists(rs, local.arrColumn[n])){
			arrayappend(local.arrTemp, "'"&application.zcore.functions.zescape(rs[local.arrColumn[n]])&"'");
		}else{
			arrayappend(local.arrTemp, "''");
		}
	}
	arrayappend(request.zos.importMlsStruct[rs.mls_id].arrImportListingRows, "("&arraytolist(local.arrTemp, ",")&") ");
	
	local.arrTemp=[];
	for(n=1;n LTE arraylen(local.dataColumnCount);n++){
		if(structkeyexists(rs, local.arrDataColumn[n])){
			arrayappend(local.arrTemp, "'"&application.zcore.functions.zescape(rs[local.arrDataColumn[n]])&"'");
		}else{
			arrayappend(local.arrTemp, "''");
		}
	}
	arrayappend(request.zos.importMlsStruct[rs.mls_id].arrImportListingDataRows, "("&arraytolist(local.arrTemp, ",")&") ");
	
	local.arrTemp=[];
	for(n=1;n LTE arraylen(local.trackColumnCount);n++){
		if(structkeyexists(rs, local.arrTrackColumn[n])){
			if(rs[local.arrTrackColumn[n]] EQ "null"){
				arrayappend(local.arrTemp, "null");
			}else{
				arrayappend(local.arrTemp, "'"&application.zcore.functions.zescape(rs[local.arrTrackColumn[n]])&"'");
			}
		}else{
			arrayappend(local.arrTemp, "''");
		}
	}
	arrayappend(request.zos.importMlsStruct[rs.mls_id].arrImportListingTrackRows, "("&arraytolist(local.arrTemp, ",")&") ");
    	</cfscript>
    </cffunction>
    
    <cffunction name="import" localmode="modern" access="public" returntype="any">
    	<cfscript>
		var i=0;
		var values=0;
		var ts=0;
		var db=request.zos.queryObject;
		var listing_track_id=0;
		var sql=0;
		var r1=0;
		var rs=0;
		var n=0;
		var arrP=arraynew(1);
		var arrD=arraynew(1);
		
		
		
		for(i in this.datastruct){
			arrayClear(request.zos.arrQueryLog);
			if(this.datastruct[i].update EQ false){
				arrayappend(arrP, i);		
			}else{
				arrayappend(arrD, i);	
				if(this.datastruct[i].new){
					this.datastruct[i].listing_track_datetime=this.nowDate;
				}
				this.datastruct[i].listing_track_updated_datetime=this.nowDate;
				rs=this.optionstruct.mlsProviderCom.parseRawData(this.datastruct[i], this.optionstruct);
				
				
				if(this.datastruct[i].new){
					if(structkeyexists(this.datastruct[i], 'listing_track_price') EQ false){
						this.datastruct[i].listing_track_price=this.optionstruct.mlsProviderCom.price;
					}
					if(structkeyexists(this.datastruct[i], 'listing_track_price_change') EQ false){
						this.datastruct[i].listing_track_price_change=this.optionstruct.mlsProviderCom.price;
					}
				}else{
					if(structkeyexists(this.datastruct[i], 'listing_track_price_change') EQ false){
						this.datastruct[i].listing_track_price_change=this.optionstruct.mlsProviderCom.price;
					}
				}
				if(this.datastruct[i].new){
					rs.listing_track_id="null";
					rs.listing_id=i;
					rs.listing_track_price=this.datastruct[i].listing_track_price;
					rs.listing_track_price_change=this.datastruct[i].listing_track_price_change;
					rs.listing_track_hash=this.datastruct[i].hash;
					rs.listing_track_deleted="0";
					rs.listing_track_datetime=this.datastruct[i].listing_track_datetime
					rs.listing_track_updated_datetime=this.datastruct[i].listing_track_updated_datetime;
					rs.listing_track_processed_datetime=this.nowDate;
				}else{
					rs.listing_track_id=this.datastruct[i].listing_track_id;
					rs.listing_id=i;
					if(this.datastruct[i].listing_track_price GT 1000 and this.optionstruct.mlsProviderCom.price LT 200){
						rs.listing_track_price=this.datastruct[i].listing_track_price;
						rs.listing_track_price_change=this.datastruct[i].listing_track_price_change;
					}else{
						rs.listing_track_price=this.datastruct[i].listing_track_price;
						rs.listing_track_price_change=this.optionstruct.mlsProviderCom.price;
					}
					rs.listing_track_hash=this.datastruct[i].hash;
					rs.listing_track_deleted="0";
					rs.listing_track_datetime=this.datastruct[i].listing_track_datetime;
					rs.listing_track_updated_datetime=this.datastruct[i].listing_track_updated_datetime;
					rs.listing_track_processed_datetime=this.nowDate;
				}
				rs.mls_id=this.optionStruct.mls_id;
				this.processListingTableStruct(rs);
			}
         } 
		this.optionstruct.mlsProviderCom.processImport();
		this.optionstruct.mlsProviderCom.baseProcessImport();
		
		 if(arraylen(arrP) NEQ 0){
		 	sql="'"&arraytolist(arrP,"','")&"'";
			db.sql="update #db.table("listing_track", request.zos.zcoreDatasource)# listing_track 
			set listing_track_processed_datetime = #db.param(this.nowDate)# 
			WHERE listing_id IN (#db.trustedSQL(sql)#)";
			db.execute("q"); 
		 }
		arrayClear(request.zos.arrQueryLog);
		 this.datastruct=structnew();
		 return true;
         </cfscript>
    </cffunction>
    
    <cffunction name="cleanInactive" localmode="modern" access="remote" output="yes" returntype="any">
    	<cfscript>
		var f=0;
		var qId=0;
		var qid2=0;
		var mpcom=0;
		var arrSQL=0;
		var i=0;
		var foundCount=0;
		var db=request.zos.queryObject;
		var found1=false;
		var qd=0;
		var qmls=0;
		var n2=0;
		var arrFilelist=0;
		var qmls2=0;
		var arrTable=0;
		var newTickTime=getTickCount();
		var arrFound=0;
		var arrFound2=0;
		var arrTick=arraynew(1);
		var nowTime=gettickcount();
		var oneMonthAgo=dateadd("m",-2,now());
		var oneDayAgo=dateadd("h",-55,now());
		var todayDate=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
		var arrMLSOnly=arraynew(1);
		var arrMLSIdOnly=arraynew(1);
		var mlsPSQL=0;
		var arrErr2=0;
		var mlsIdPSQL=0;
		var qDeadListings=0;
		var n=0;
		var qtwodaysago=0;
		var db2=request.zos.noVerifyQueryObject;
		oneDayAgo=dateformat(oneDayAgo,'yyyy-mm-dd')&' '&timeformat(oneDayAgo,'HH:mm:ss');
		
		db.sql="SELECT group_concat(listing.listing_id SEPARATOR #db.param("','")#) idlist 
		FROM #db.table("zram##listing", request.zos.zcoreDatasource)# listing 
		LEFT JOIN #db.table("listing_track", request.zos.zcoreDatasource)# listing_track ON 
		listing_track.listing_id= listing.listing_id  
		WHERE listing_track.listing_id IS NULL";
		qDeadListings=db.execute("qDeadListings"); 
		if(qDeadListings.recordcount NEQ 0 and qDeadListings.idlist NEQ ""){
			writeoutput('dead listings:'&qDeadListings.idlist&'<br />');
			db.sql="DELETE FROM #db.table("listing", request.zos.zcoreDatasource)#  WHERE listing_id IN (#db.trustedSQL("'#qDeadListings.idlist#'")#)";	
			db.execute("q"); 
			db.sql="DELETE FROM #db.table("listing_data", request.zos.zcoreDatasource)#  WHERE listing_id IN (#db.trustedSQL("'#qDeadListings.idlist#'")#)";	
			db.execute("q"); 
			 db.sql="DELETE FROM #db.table("zram##listing", request.zos.zcoreDatasource)#  WHERE listing_id IN (#db.trustedSQL("'#qDeadListings.idlist#'")#)";	
			 db.execute("q");
		}else{
			writeoutput('no dead listings<br />');	
		}
		
		db.sql="select * from #db.table("mls", request.zos.zcoreDatasource)# mls 
		where mls_status=#db.param('1')# and 
		(mls_update_date <#db.param(dateformat(oneDayAgo,"yyyy-mm-dd"))# or 
		mls_cleaned_date <#db.param(dateformat(oneDayAgo,"yyyy-mm-dd"))#) and 
		mls_error_sent=#db.param('0')#";
		qTwoDaysAgo=db.execute("qTwoDaysAgo"); 
		</cfscript>
        <cfif qTwoDaysAgo.recordcount NEQ 0>
        <cfmail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="MLS database(s) failed to update." type="html">
#application.zcore.functions.zHTMLDoctype()#
<head>
<meta charset="utf-8" />
<title>MLS Error</title>
</head>

<body>
<span style="font-family:Verdana, Geneva, sans-serif; font-size:12px;">
<h2>The following mls providers have not been updated for more than 48 hours.</h2>
<table style="border-spacing:0px;">
<tr><td>ID</td><td>Name</td><td>Last Updated</td></tr>
<cfloop query="qTwoDaysAgo">
	<tr><td>#qTwoDaysAgo.mls_id#</td><td>#qTwoDaysAgo.mls_name#</td><td>#dateformat(qTwoDaysAgo.mls_update_date,"m/d/yyyy")#</td></tr>
	<cfscript>
	 db.sql="update #db.table("mls", request.zos.zcoreDatasource)# mls 
	 SET mls_error_sent=#db.param('1')# 
	 where mls_id = #db.param(qTwoDaysAgo.mls_id)# ";
	 db.execute("q");
	</cfscript>
</cfloop>
</table>
</span>
</body>
</html>
</cfmail>
</cfif>
   		<cfscript>
		db.sql="select * from #db.table("mls", request.zos.zcoreDatasource)# mls 
		where mls_status=#db.param('1')# and 
		mls_update_date >#db.param(todayDate)# and 
		mls_cleaned_date< #db.param(dateformat(todayDate,'yyyy-mm-dd'))#";
		qMLS2=db.execute("qMLS2");  
		local.arrMLSClean=[];
		</cfscript>
        <cfloop from="1" to="#qmls2.recordcount#" index="n">
        	<cfscript>
		arrayAppend(local.arrMLSClean, " listing_id like '"&qMls2.mls_id[n]&"-%' ");
		arrFileList=listtoarray(qmls2.mls_filelist[n],",");
		foundCount=0;
		arrFound=arraynew(1);
		arrFound2=arraynew(1);
		</cfscript>
        	<cfdirectory action="list" directory="#request.zos.sharedPath#mls-data/#qmls2.mls_id[n]#/" filter="*-imported" name="qd">
		<cfloop query="qd">
			<cfscript>
			found1=false;
			for(n2=1;n2 LTE arraylen(arrFileList);n2++){
				if(arrFileList[n2]&"-imported" EQ qd.name){	
					if(dateformat(qd.datelastmodified,"yyyy-mm-dd") EQ dateformat(now(),"yyyy-mm-dd")){
						foundCount++;
						found1=true;
						arrayappend(arrFound, qd.name);
						break;	
					}
				}
			}
			if(found1 EQ false){
				arrayappend(arrFound2, qd.name);
			}
			</cfscript>
		</cfloop>
		<cfif foundCount EQ arraylen(arrFilelist)>
			<cfscript>
			arrayappend(arrMLSOnly," listing_id like '#qMLS2.mls_id[n]#-%' ");
			arrayappend(arrMLSIdOnly,"'#qMLS2.mls_id[n]#'");
			</cfscript>
		<cfelse>
			<cfscript>
			writeoutput(qMLS2.mls_id[n]&" was updated but not completed. Imported file list: <br /><br />"&arraytolist(arrFound)&"<br />Required File list: <br />"&arraytolist(arrFileList)&"<br /><br />Required Files that were missing: <br />"&arraytolist(arrFound2)&"<br /><br />");
			</cfscript>
		</cfif>
	</cfloop>
        <cfscript> 
	if(arraylen(local.arrMLSClean)){
		if(arraylen(arrMLSOnly) NEQ 0){
			mlsPSQL=" and ("&arraytolist(arrMLSOnly, " or ")&")";
			mlsIdPSQL=arraytolist(arrMLSIdOnly, ",");

			db2.sql="TRUNCATE TABLE #db2.table("listing_delete", request.zos.zcoreDatasource)# ";
			db2.execute("qTruncate");
			db2.sql="INSERT INTO listing_delete (listing_id) SELECT listing_id FROM #db2.table("listing_track", request.zos.zcoreDatasource)# 
			where listing_track_deleted=#db2.param('0')# and 
			listing_track_processed_datetime < #db2.param(oneDayAgo)#  and 
			(#db2.trustedSQL(arrayToList(local.arrMLSClean, ' or '))# )
			#db2.trustedSQL(mlsPSQL)#";
			db2.execute("qInsert");

			offset=1;
			while(true){
				db.sql="select group_concat(listing_id SEPARATOR #db.param("','")#) idlist FROM 
				#db.table("listing_delete", request.zos.zcoreDatasource)# WHERE 
				listing_delete_id BETWEEN #db.param(offset)# and #db.param(offset+30)# ";
				qIdList=db.execute("qIdList");
				offset+=30;
				if(qId.idlist EQ ""){
					break;
				}
				db2.sql="DELETE FROM #db2.table("listing", request.zos.zcoreDatasource)#  
				WHERE listing_id IN ('#qId.idlist#')";
				db2.execute("qDelete");
				db2.sql="DELETE FROM #db2.table("listing_data", request.zos.zcoreDatasource)#  
				WHERE listing_id IN ('#qId.idlist#')";
				db2.execute("qDelete");
				db2.sql="DELETE FROM #db2.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)#  
				WHERE listing_id IN ('#qId.idlist#')";
				db2.execute("qDelete");
				db2.sql="UPDATE #db2.table("listing_track", request.zos.zcoreDatasource)# listing_track 
				SET listing_track_hash=#db2.param('')#, 
				listing_track_deleted=#db2.param(1)# 
				WHERE listing_id IN ('#qId.idlist#')";
				db2.execute("qDelete");
			}

			oneMonthAgo=dateformat(oneMonthAgo,'yyyy-mm-dd')&' '&timeformat(oneMonthAgo,'HH:mm:ss');
			db2.sql="TRUNCATE TABLE #db2.table("listing_delete", request.zos.zcoreDatasource)# ";
			db2.execute("qTruncate");
			db2.sql="INSERT INTO #db2.table("listing_delete", request.zos.zcoreDatasource)# (listing_id) 
			SELECT listing_id FROM #db2.table("listing_track", request.zos.zcoreDatasource)# 
			where listing_track_processed_datetime < #db2.param(oneMonthAgo)#  and 
			(#db2.trustedSQL(arrayToList(local.arrMLSClean, ' or '))# )
			#db2.trustedSQL(mlsPSQL)#";
			db2.execute("qInsert");
			offset=1;
			while(true){
				db.sql="select group_concat(listing_id SEPARATOR #db.param("','")#) idlist FROM 
				#db.table("listing_delete", request.zos.zcoreDatasource)# WHERE 
				listing_delete_id BETWEEN #db.param(offset)# and #db.param(offset+30)# ";
				qIdList=db.execute("qIdList");
				offset+=30;
				if(qId.idlist EQ ""){
					break;
				}
				db2.sql="DELETE FROM #db2.table("listing_track", request.zos.zcoreDatasource)# listing_track 
				WHERE listing_id IN ('#qId.idlist#')";
				db2.execute("qDelete");
			}
			db.sql="update #db.table("mls", request.zos.zcoreDatasource)# mls 
			set mls_cleaned_date=#db.param(dateformat(now(),'yyyy-mm-dd'))# 
			WHERE mls_id IN (#db.trustedSQL(mlsIdPSQL)#)";
			db.execute("q"); 
			writeoutput('<br />#qId.count# Inactive listings were removed.');	
		}else{
			writeoutput('<br />No inactive listings were removed.');	
			
		} 
	}
	</cfscript> 
    </cffunction>
    
    </cfoutput>
</cfcomponent>