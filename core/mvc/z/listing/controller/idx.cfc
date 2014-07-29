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
			where listing_id like #db.param('#form.mls_id#-%')# and 
			listing_track_deleted = #db.param(0)#
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
		WHERE mls_status=#db.param('1')# and 
		mls_deleted = #db.param(0)#
		ORDER BY mls_update_date ASC ";
		qMLS=db.execute("qMLS"); 
		this.optionstruct.filePath=false;
		for(row in qMLS){
			this.optionstruct.mls_id=row.mls_id;
			this.optionstruct.delimiter=row.mls_delimiter;
			this.optionstruct.csvquote=row.mls_csvquote;
			this.optionstruct.first_line_columns=row.mls_first_line_columns;
			this.optionstruct.row=row;
			this.optionstruct.mlsProviderCom=createobject("component","zcorerootmapping.mvc.z.listing.mls-provider.#row.mls_com#");
			this.optionstruct.mlsproviderCom.setMLS(this.optionstruct.mls_id); 
			if(row.mls_current_file_path NEQ "" and fileexists(request.zos.sharedPath&row.mls_current_file_path)){
				this.optionstruct.filePath=replace(trim(row.mls_current_file_path),"\","/","ALL");
				this.optionstruct.skipBytes=row.mls_skip_bytes;
				break;
			}else{
				nextFile=replace(trim(this.optionstruct.mlsProviderCom.getImportFilePath(this.optionstruct)),"\","/","ALL");
				if(nextFile EQ false){
					continue;
				}else{
					this.optionstruct.filePath=nextFile;
					this.optionstruct.skipBytes=0;
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
			where site_id <> #db.param(-1)# and 
			content_deleted = #db.param(0)#";
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
				listing_deleted = #db.param(0)# and 
				content_deleted = #db.param(0)# and 
				content.content_price_update_datetime<#db.param(nd222)#";
				qP=db.execute("qP");
				for (x=1; x LTE qP.recordcount; x++) {
					 db.sql="UPDATE #db.table("content", request.zos.zcoreDatasource)# content 
					 SET content_price=#db.param(qP.listing_price[x])#, 
					 content_updated_datetime=#db.param(request.zos.mysqlnow)# ,
					 content_price_update_datetime=#db.param(nd222)# 
					 WHERE site_id <> #db.param(-1)# and 
					 content_deleted = #db.param(0)# and 
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
			fileSkipBytes(variables.fileHandle, this.optionStruct.skipBytes-10); 
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
		currentOffset=0;
		loopcount=0;
		stillParsing=true;
		addRowFailCount=0;
		structdelete(application.zcore, 'abortIdxImport');
		while(gettickcount()-startTime LTE this.optionstruct.timeLimitInSeconds*1000){// and stillParsing){
			for(i2=1;i2 LTE this.optionstruct.loopRowCount;i2++){
				if(structkeyexists(application.zcore, 'abortIdxImport')){
					throw("Aborting IDX Import due to manual cancellation");
				}
				application.zcore.idxImportStatus="Bytes read: "&this.optionStruct.skipBytes&" of "&request.zos.sharedPath&this.optionstruct.filepath;
				loopcount++;
				if(fileIsEOF(variables.fileHandle) or (this.optionstruct.limitTestServer and request.zos.istestserver and loopcount GT 500)){
					fileComplete=true;
					break;	
				}
				line=fileReadLine(variables.fileHandle);
				this.optionstruct.skipBytes+=len(line)+1;
				line=variables.csvParser.parseLineIntoArray(line);  
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
				
			} 
		}
	}catch(Any local.e){
		if(structkeyexists(variables, 'fileHandle')){
			fileClose(variables.fileHandle);
		}
		rethrow;
	}
	writeoutput('last usable offset:'&this.optionstruct.skipBytes&"<br />");
	
	db.sql="UPDATE #db.table("mls", request.zos.zcoreDatasource)# mls 
	SET mls_current_file_path=#db.param(this.optionstruct.filePath)#, 
	mls_error_sent=#db.param('0')#, 
	mls_updated_datetime=#db.param(request.zos.mysqlnow)# ,
	mls_skip_bytes=#db.param(this.optionstruct.skipBytes)# ";
	if(this.optionstruct.filePath EQ ""){
		db.sql&=" , mls_update_date = #db.param(request.zos.mysqlnow)# ";
	}
	db.sql&=" where mls_id = #db.param(this.optionstruct.mls_id)#";
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
	ts.hasListing=false;
	ts.hasListing2=false;
	ts.update=true;
	ts.listing_mls_id=this.optionstruct.mls_id;
	try{
		if(arraylen(ts.arrData) LT request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset){
			request.addRowErrorMessage="This row was not long enough to contain the listing_id column: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.arrRow,chr(10)))&". Reverted to previous day's file to avoid data loss. ";
			return false;
		}
		ts.listing_id=this.optionstruct.mls_id&'-'&ts.arrData[request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset];
		
		if(right(ts.listing_id,1) EQ "-"){
			request.addRowErrorMessage="Invalid listing id. The field was empty.  Review the corrupt file starting with the current file path: "&this.optionstruct.filePath&". Reverted to previous day's file to avoid data loss.";
			return false;	
		}
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
	db.sql="select listing_track.*, if(listing.listing_id IS NULL, #db.param(0)#, #db.param(1)#) hasListing 
	, if(#this.optionstruct.mlsProviderCom.getPropertyListingIdSQL()# IS NULL, #db.param(0)#, #db.param(1)#) hasListing2 
	from #db.table("listing_track", request.zos.zcoreDatasource)# listing_track 
	LEFT JOIN #db.table("listing")# listing ON listing.listing_id = listing_track.listing_id 
	#this.optionstruct.mlsProviderCom.getJoinSQL("LEFT")#
	where listing_track.listing_id IN (#db.trustedSQL(sqllist)#) and 
	listing_track_deleted = #db.param(0)#";
	qT=db.execute("qT"); 
	</cfscript>
    <cfloop query="qT">
    	<cfscript>
		this.datastruct[qT.listing_id].listing_track_id=qT.listing_track_id;
		this.datastruct[qT.listing_id].listing_track_price=qT.listing_track_price;
		this.datastruct[qT.listing_id].listing_track_datetime=dateformat(qT.listing_track_datetime,"yyyy-mm-dd")&" "&timeformat(qT.listing_track_datetime,"HH:mm:ss");
		this.datastruct[qT.listing_id].listing_track_updated_datetime=dateformat(qT.listing_track_updated_datetime,"yyyy-mm-dd")&" "&timeformat(qT.listing_track_updated_datetime,"HH:mm:ss");
		this.datastruct[qT.listing_id].new=false;
		if(qT.hasListing2 EQ 1){
			this.datastruct[qT.listing_id].hasListing2=true;
		}
		if(qT.hasListing EQ 1){
			this.datastruct[qT.listing_id].hasListing=true;
		}
		if(this.datastruct[qT.listing_id].hash EQ qT.listing_track_hash){
			this.datastruct[qT.listing_id].update=false;
		}
		</cfscript>
    </cfloop>
</cffunction>

    
<cffunction name="import" localmode="modern" access="public" returntype="any">
	<cfscript>
	var db=request.zos.queryObject;

	for(i in this.datastruct){
		arrayClear(request.zos.arrQueryLog);
		if(this.datastruct[i].update EQ false){
			db.sql="update #db.table("listing_track", request.zos.zcoreDatasource)# listing_track 
			set listing_track_processed_datetime = #db.param(this.nowDate)#, 
			listing_track_updated_datetime=#db.param(request.zos.mysqlnow)#  
			WHERE listing_id = #db.param(i)# and 
			listing_track_deleted = #db.param(0)#";
			db.execute("q"); 	
		}else{
			if(this.datastruct[i].new){
				this.datastruct[i].listing_track_datetime=this.nowDate;
			}
			this.datastruct[i].listing_track_updated_datetime=this.nowDate;
			rs2=this.optionstruct.mlsProviderCom.parseRawData(this.datastruct[i], this.optionstruct);
			rs=rs2.listingData;
			
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
				rs.listing_track_inactive='0';
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
				rs.listing_track_inactive='0';
				rs.listing_track_datetime=this.datastruct[i].listing_track_datetime;
				rs.listing_track_updated_datetime=this.datastruct[i].listing_track_updated_datetime;
				rs.listing_track_processed_datetime=this.nowDate;
			}
			rs.mls_id=this.optionStruct.mls_id;

			ts2={
				debug:true,
				datasource:request.zos.zcoreDatasource,
				table:"listing",
				struct:rs
			};
			ts2.struct.listing_deleted='0';
			ts3={
				debug:true,
				datasource:request.zos.zcoreDatasource,
				table:"listing_data",
				struct:rs
			};
			ts3.struct.listing_data_deleted='0';
			ts4={
				debug:true,
				datasource:request.zos.zcoreDatasource,
				table:"listing_track",
				struct:rs
			};
			ts4.struct.listing_track_deleted='0';
			ts5={
				debug:true,
				datasource:request.zos.zcoreDatasource,
				table:request.zos.ramtableprefix&"listing",
				struct:rs
			};
			ts5.struct.listing_deleted='0';
			if(structkeyexists(rs2, 'columnIndex')){
				ts1={
					debug:true,
					datasource:request.zos.zcoreDatasource,
					table:request.zos.listing.mlsStruct[rs.mls_id].sharedStruct.lookupStruct.table,
					struct:{}
				};
				for(i2 in rs2.columnIndex){
					ts1.struct[i2]=rs2.arrData[rs2.columnIndex[i2]];
				}
			}

			transaction action="begin"{
				try{
					if(structkeyexists(rs2, 'columnIndex')){
						if(not this.datastruct[i].hasListing2){
							try{
								application.zcore.functions.zInsert(ts1);
							}catch(Any e){
								ts1.forceWhereFields=lcase(this.optionstruct.mlsProviderCom.getListingIdField());
								// later uncomment this when field exists: 
								//ts1.forceWhereFields&=","&ts1.table&"_deleted";
								// ts1.struct[ts1.table&"_deleted"]=0;

								ts1.struct[lcase(ts1.forceWhereFields)]=rs.listing_id;
								application.zcore.functions.zUpdate(ts1);
							}
						}else{
							ts1.forceWhereFields=lcase(this.optionstruct.mlsProviderCom.getListingIdField());
							// later uncomment this when field exists: 
							//ts1.forceWhereFields&=","&ts1.table&"_deleted";
							// ts1.struct[ts1.table&"_deleted"]=0;

							ts1.struct[lcase(ts1.forceWhereFields)]=rs.listing_id;
							application.zcore.functions.zUpdate(ts1);
						}
					}
					if(this.datastruct[i].new){
						application.zcore.functions.zInsert(ts4);
					}else{
						ts4.forceWhereFields="listing_id,listing_track_deleted";
						application.zcore.functions.zUpdate(ts4);
					}
					if(this.datastruct[i].hasListing){
						ts2.forceWhereFields="listing_id,listing_deleted";
						application.zcore.functions.zUpdate(ts2);
						ts5.forceWhereFields="listing_id,listing_deleted";
						application.zcore.functions.zUpdate(ts5);
						ts3.forceWhereFields="listing_id,listing_data_deleted";
						application.zcore.functions.zUpdate(ts3); // TODO: myisam table is not actually transaction here - it will be innodb after mariadb 10 upgrade
					}else{
						application.zcore.functions.zInsert(ts2); 
						application.zcore.functions.zInsert(ts3); // TODO: myisam table is not actually transaction here - it will be innodb after mariadb 10 upgrade 
						structdelete(ts5.struct, 'listing_unique_id');
						application.zcore.functions.zInsert(ts5);
					}
					transaction action="commit";
				}catch(Any e){
					transaction action="rollback";
					rethrow;
				}
			}
		}
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
	
	application.zcore.idxImportStatus="cleanInactive executed";

	db.sql="SELECT group_concat(listing.listing_id SEPARATOR #db.param("','")#) idlist 
	FROM #db.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)# listing 
	LEFT JOIN #db.table("listing_track", request.zos.zcoreDatasource)# listing_track ON 
	listing_track.listing_id= listing.listing_id   and 
	listing_track_deleted = #db.param(0)# 
	WHERE listing_track.listing_id IS NULL and 
	listing_deleted = #db.param(0)#";
	qDeadListings=db.execute("qDeadListings"); 
	if(qDeadListings.recordcount NEQ 0 and qDeadListings.idlist NEQ ""){
		writeoutput('dead listings:'&qDeadListings.idlist&'<br />');
		db.sql="DELETE FROM #db.table("listing", request.zos.zcoreDatasource)#  
		WHERE listing_id IN (#db.trustedSQL("'#qDeadListings.idlist#'")#) and 
		listing_deleted = #db.param(0)# ";	
		db.execute("q"); 
		db.sql="DELETE FROM #db.table("listing_data", request.zos.zcoreDatasource)#  
		WHERE listing_id IN (#db.trustedSQL("'#qDeadListings.idlist#'")#) and 
		listing_deleted = #db.param(0)# ";	
		db.execute("q"); 
		 db.sql="DELETE FROM #db.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)#  
		 WHERE listing_id IN (#db.trustedSQL("'#qDeadListings.idlist#'")#) and 
		 listing_deleted = #db.param(0)# ";	
		 db.execute("q");
	}else{
		writeoutput('no dead listings<br />');	
	}
	
	db.sql="select * from #db.table("mls", request.zos.zcoreDatasource)# mls 
	where mls_status=#db.param('1')# and 
	(mls_update_date <#db.param(dateformat(oneDayAgo,"yyyy-mm-dd"))# or 
	mls_cleaned_date <#db.param(dateformat(oneDayAgo,"yyyy-mm-dd"))#) and 
	mls_error_sent=#db.param('0')# and 
	mls_deleted = #db.param(0)#";
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
			 SET mls_error_sent=#db.param('1')#, 
			 mls_updated_datetime=#db.param(request.zos.mysqlnow)#  
			 where mls_id = #db.param(qTwoDaysAgo.mls_id)# and 
			 mls_deleted=#db.param(0)#";
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
	mls_cleaned_date< #db.param(dateformat(todayDate,'yyyy-mm-dd'))# and 
	mls_deleted = #db.param(0)#";
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
			db2.sql="INSERT INTO listing_delete (listing_id, listing_delete_updated_datetime) 
			SELECT listing_id, #db2.param(request.zos.mysqlnow)# 
			FROM #db2.table("listing_track", request.zos.zcoreDatasource)# 
			where listing_track_deleted=#db2.param('0')# and 
	   		listing_track.listing_track_inactive=#db2.param('1')# and 
			listing_track_processed_datetime < #db2.param(oneDayAgo)#  and 
			(#db2.trustedSQL(arrayToList(local.arrMLSClean, ' or '))# )
			#db2.trustedSQL(mlsPSQL)#";
			db2.execute("qInsert");

			offset=1;
			while(true){
				db.sql="select group_concat(listing_id SEPARATOR #db.param("','")#) idlist FROM 
				#db.table("listing_delete", request.zos.zcoreDatasource)# WHERE 
				listing_delete_id BETWEEN #db.param(offset)# and #db.param(offset+5)#  and 
				listing_delete_deleted = #db.param(0)# ";
				qIdList=db.execute("qIdList");
				offset+=5;
				if(qIdList.idlist EQ ""){
					break;
				}
				db2.sql="DELETE FROM #db2.table("listing", request.zos.zcoreDatasource)#  
				WHERE listing_id IN ('#qIdList.idlist#') and listing_deleted = #db.param(0)# ";
				db2.execute("qDelete");
				db2.sql="DELETE FROM #db2.table("listing_data", request.zos.zcoreDatasource)#  
				WHERE listing_id IN ('#qIdList.idlist#') and listing_deleted = #db.param(0)# ";
				db2.execute("qDelete");
				db2.sql="DELETE FROM #db2.table("#request.zos.ramtableprefix#listing", request.zos.zcoreDatasource)#  
				WHERE listing_id IN ('#qIdList.idlist#') and listing_deleted = #db.param(0)# ";
				db2.execute("qDelete");
				db2.sql="UPDATE #db2.table("listing_track", request.zos.zcoreDatasource)# listing_track 
				SET listing_track_hash=#db2.param('')#, 
				listing_track_inactive=#db2.param(1)#, 
				listing_track_updated_datetime=#db2.param(request.zos.mysqlnow)#  
				WHERE listing_id IN ('#qIdList.idlist#') and 
				listing_track_deleted = #db2.param(0)#";
				db2.execute("qDelete");
			}

			oneMonthAgo=dateformat(oneMonthAgo,'yyyy-mm-dd')&' '&timeformat(oneMonthAgo,'HH:mm:ss');
			db2.sql="TRUNCATE TABLE #db2.table("listing_delete", request.zos.zcoreDatasource)# ";
			db2.execute("qTruncate");
			db2.sql="INSERT INTO #db2.table("listing_delete", request.zos.zcoreDatasource)# (listing_id, listing_delete_updated_datetime) 
			SELECT listing_id, #db2.param(request.zos.mysqlnow)# FROM #db2.table("listing_track", request.zos.zcoreDatasource)# 
			where listing_track_processed_datetime < #db2.param(oneMonthAgo)#  and 
			listing_track_deleted = #db.param(0)# and 
			(#db2.trustedSQL(arrayToList(local.arrMLSClean, ' or '))# )
			#db2.trustedSQL(mlsPSQL)#";
			db2.execute("qInsert");
			offset=1;
			while(true){
				db.sql="select group_concat(listing_id SEPARATOR #db.param("','")#) idlist FROM 
				#db.table("listing_delete", request.zos.zcoreDatasource)# WHERE 
				listing_delete_deleted = #db.param(0)# and 
				listing_delete_id BETWEEN #db.param(offset)# and #db.param(offset+5)# ";
				qIdList=db.execute("qIdList");
				offset+=5;
				if(qIdList.idlist EQ ""){
					break;
				}
				db2.sql="DELETE FROM #db2.table("listing_track", request.zos.zcoreDatasource)#  
				WHERE listing_id IN ('#qIdList.idlist#') and 
				listing_track_deleted = #db2.param(0)# ";
				db2.execute("qDelete");
			}
			db.sql="update #db.table("mls", request.zos.zcoreDatasource)# mls 
			set mls_cleaned_date=#db.param(dateformat(now(),'yyyy-mm-dd'))#, 
			mls_updated_datetime=#db.param(request.zos.mysqlnow)#  
			WHERE mls_id IN (#db.trustedSQL(mlsIdPSQL)#) and 
			mls_deleted = #db.param(0)# ";
			db.execute("q"); 
			writeoutput('<br />#listlen(qIdList.idlist, ",")# Inactive listings were removed.');	
		}else{
			writeoutput('<br />No inactive listings were removed.');	
			
		} 
	}
	</cfscript> 
</cffunction>

</cfoutput>
</cfcomponent>