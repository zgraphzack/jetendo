<cfcomponent extends="zcorerootmapping.com.zos.controller"> 
<cfoutput>
<cffunction name="getDefaultBreakpointConfig" localmode="modern" access="public">
	<cfscript>
	ts={
		headingScale:1.5,
		textScale:1.5,
		boxPaddingTopPercent:1.5,
		boxPaddingSidePercent:1.5,
		boxPaddingBottomPercent:1.5,
		columnGapSidePercent:2,
		columnGapBottomPercent:2,
		minimumPadding:10,
		headingMinimumFontSize:12,
		textMinimumFontSize:12,
		headingLineHeightScale:1,
		textLineHeightScale:1
	}
	return ts;
	</cfscript>
</cffunction>
<cffunction name="getBreakpointConfig" localmode="modern" access="public">
	<cfscript>
	defaultBreakPoint=getDefaultBreakpointConfig();
	breakStruct={
		arrBreak=["Default","1800","1550","1280","980","768","480"],
		data:{
			"Default":{
				headingScale:1.5,
				textScale:1.5,
				minimumPadding:10,
				minimumFontSize:10
			},
			"1800":{
				headingScale:1.4,
				textScale:1.4
			},
			"1550":{
				headingScale:1.3,
				textScale:1.3
			}, 
			"1280":{
				headingScale:1.2,
				textScale:1.2
			},
			"980":{
				headingScale:1,
				textScale:1
			},
			"768":{
				headingScale:0.836,
				textScale:0.836
			},
			"480":{
				headingScale:0.736,
				textScale:0.736
			}
		},
		minimum_column_width:150,
		css:{}
	}
	lastBreak={};
	for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
		breakpoint=breakStruct.arrBreak[i]; 
		structappend(lastBreak, breakStruct.data[breakpoint], true);
		structappend(breakStruct.data[breakpoint], lastBreak, false);
		structappend(breakStruct.data[breakpoint], defaultBreakPoint, false);
		breakStruct.css[breakpoint]=[];
	}
	return breakStruct;
	</cfscript>
</cffunction>


<cffunction name="saveLayoutInstanceSettings" localmode="modern" access="remote" roles="member">
	<cfscript>

	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	db=request.zos.queryObject;
	db.sql="select * from #db.table("layout_global", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_global_deleted =#db.param(0)#";
	qGlobal=db.execute("qGlobal");
	breakStruct=getBreakpointConfig();

	breakStructNew={
		arrBreak:[],
		data:{},
		css:{},
		minimum_column_width:application.zcore.functions.zso(form, 'minimum_column_width', true, 150)

	}; 
	breakStruct.minimum_column_width=breakStructNew.minimum_column_width;
	for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
		breakpoint=breakStruct.arrBreak[i]; 
		dataStruct=breakStruct.data[breakpoint];
		for(n in dataStruct){
			id=application.zcore.functions.zescape(n, "_")&"_"&breakpoint;
			if(structkeyexists(form, id)){
				dataStruct[n]=form[id];
			}
		}
		if(structkeyexists(form, 'setToDefault')){
			dataStruct["enabled"]=1;
		}else{
			dataStruct["enabled"]=application.zcore.functions.zso(form, "enabled_"&breakpoint, true, 0); 
		}
		if(dataStruct["enabled"] EQ 1){
			arrayAppend(breakstructNew.arrBreak, breakStruct.arrBreak[i]);
			breakStructNew.data[breakpoint]=breakStruct.data[breakpoint];
			breakStructNew.css[breakpoint]=breakStruct.css[breakpoint];
		}
	} 
	ts={
		table:"layout_global",
		datasource:request.zos.zcoreDatasource,
		struct:{
			layout_global_json_data:serializeJson(breakStruct),
			layout_global_updated_datetime:request.zos.mysqlnow,
			layout_global_deleted:0
		}
	};
	if(qGlobal.recordcount EQ 0){
		form.layout_global_id=application.zcore.functions.zInsert(ts);
		if(form.layout_global_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save settings");
			application.zcore.functions.zRedirect("/z/admin/layout-global/index?zsid=#request.zsid#");
		}
	}else{
		ts.struct.layout_global_id=qGlobal.layout_global_id; 
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save settings");
			application.zcore.functions.zRedirect("/z/admin/layout-global/index?zsid=#request.zsid#");
		}
	}
	generateGlobalBreakpointCSS(breakStructNew);

	application.zcore.status.setStatus(request.zsid, "Saved");
	application.zcore.functions.zRedirect("/z/admin/layout-global/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="saveLayoutSettings" localmode="modern" access="remote" roles="member">
	<cfscript>

	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	db=request.zos.queryObject;
	db.sql="select * from #db.table("layout_global", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_global_deleted =#db.param(0)#";
	qGlobal=db.execute("qGlobal");
	breakStruct=getBreakpointConfig();

	breakStructNew={
		arrBreak:[],
		data:{},
		css:{},
		minimum_column_width:application.zcore.functions.zso(form, 'minimum_column_width', true, 150)
	}; 
	for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
		breakpoint=breakStruct.arrBreak[i]; 
		dataStruct=breakStruct.data[breakpoint];
		for(n in dataStruct){
			id=application.zcore.functions.zescape(n, "_")&"_"&breakpoint;
			if(structkeyexists(form, id)){
				dataStruct[n]=form[id];
			}
		}
		if(structkeyexists(form, 'setToDefault')){
			dataStruct["enabled"]=1;
		}else{
			dataStruct["enabled"]=application.zcore.functions.zso(form, "enabled_"&breakpoint, true, 0); 
		}
		if(dataStruct["enabled"] EQ 1){
			arrayAppend(breakstructNew.arrBreak, breakStruct.arrBreak[i]);
			breakStructNew.data[breakpoint]=breakStruct.data[breakpoint];
			breakStructNew.css[breakpoint]=breakStruct.css[breakpoint];
		}
	} 
	breakStruct.minimum_column_width=breakStructNew.minimum_column_width;
	ts={
		table:"layout_global",
		datasource:request.zos.zcoreDatasource,
		struct:{
			layout_global_json_data:serializeJson(breakStruct),
			layout_global_updated_datetime:request.zos.mysqlnow,
			layout_global_deleted:0
		}
	};
	if(qGlobal.recordcount EQ 0){
		form.layout_global_id=application.zcore.functions.zInsert(ts);
		if(form.layout_global_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save settings");
			application.zcore.functions.zRedirect("/z/admin/layout-global/index?zsid=#request.zsid#");
		}
	}else{
		ts.struct.layout_global_id=qGlobal.layout_global_id; 
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save settings");
			application.zcore.functions.zRedirect("/z/admin/layout-global/index?zsid=#request.zsid#");
		}
	}
	generateGlobalBreakpointCSS(breakStructNew);

	application.zcore.status.setStatus(request.zsid, "Saved");
	application.zcore.functions.zRedirect("/z/admin/layout-global/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="generateGlobalBreakpointCSS" localmode="modern" access="public">
	<cfargument name="breakpointConfig" type="struct" required="yes">
	<cfscript>
	/*arrFull=[];
	arr1280=[];
	arr980=[];
	arr768=[];
	arr480=[]; */
	breakStruct=arguments.breakpointConfig;
	startFontSize=12; 
	uniqueStruct={};
	for(i=startFontSize;i<=70;i++){
		for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
			breakpoint=breakStruct.arrBreak[n]; 
			dataStruct=breakStruct.data[breakpoint];
			arrCSS=breakStruct.css[breakpoint];
			tempScaleHeading=max(round(i*dataStruct.headingScale), dataStruct.headingMinimumFontSize);
			tempScaleText=max(round(i*dataStruct.textScale), dataStruct.textMinimumFontSize); 
			v='.z-heading-#i#{font-size:#tempScaleHeading#px; line-height:#numberformat(dataStruct.headingLineHeightScale*1.3, '_._')#; padding-bottom:#round(max(dataStruct.minimumPadding, tempScaleHeading*0.45))#px;}';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS, v);
			}
			v='.z-text-#i#{font-size:#tempScaleText#px; line-height:#numberformat(dataStruct.textLineHeightScale*1.3, '_._')#;}';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS, v);
			} 
			headingEnabled=0;
			if(i EQ "16"){
				v='.z-container p{margin:0px; padding:0px; padding-bottom:#round(max(dataStruct.minimumPadding, tempScaleText*0.45))#px;}';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				} 
			}
			if(i EQ "36"){
				headingEnabled=1;
			}else if(i EQ "30"){
				headingEnabled=2;
			}else if(i EQ "24"){
				headingEnabled=3;
			}else if(i EQ "18"){
				headingEnabled=4;
			}else if(i EQ "14"){
				headingEnabled=5;
			}
			if(headingEnabled NEQ 0){
				v='.z-container h#headingEnabled#{font-size:#tempScaleHeading#px; line-height:#numberformat(dataStruct.headingLineHeightScale*1.3, '_._')#; margin:0px; padding:0px; padding-bottom:#round(max(dataStruct.minimumPadding, tempScaleHeading*0.45))#px;}';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}
			}
	 
			if(i EQ startFontSize){
				v='.z-center-children > *{text-align:left;vertical-align:top; font-size:#round(16*dataStruct.textScale)#px;}';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				} 
				limit=2; 

				for(i2=2;i2<=16;i2++){
					percent=100/limit;
					currentLimit=limit;
					currentIndex=i2;
					isSingleColumn=false;
					nextBreakpoint=breakpoint;
					if(n+1 <= arraylen(breakStruct.arrBreak)){
						nextBreakpoint=breakStruct.arrBreak[n+1];
					}
					if(breakpoint EQ "default"){
						columnWidth=1280*(percent/100);
					}else{
						columnWidth=min(1280, nextBreakpoint)*(percent/100);
					}
					disableFirstLast=false;
					if(limit EQ 4){
						//writedump("acolumnWidth:"&columnWidth&" limit:"&limit&" breakStruct.minimum_column_width:"&breakStruct.minimum_column_width);
					}
					// if the columns will be less then the minimum column width, force them all to 100% at this breakpoint
					if(n==arrayLen(breakStruct.arrBreak)){
						isSingleColumn=true;
						disableFirstLast=true;
					}else if(breakpoint <= 980 and columnWidth < breakStruct.minimum_column_width){
						// find the previous columnWidth that allows more then one column (if any) 
							// breakStruct.arrBreak[n]
							for(i3=i2;i3>=2;i3--){
								tempPercent=100/i3;
								disableFirstLast=true;
								if(breakpoint EQ "default"){
									columnWidth=980*(tempPercent/100);
								}else{
									columnWidth=min(980, nextBreakpoint)*(tempPercent/100);
								}
								if(columnWidth >= breakStruct.minimum_column_width){
									break;
								}
							}
							if(limit EQ 4){
							//	writedump("breakStruct.arrBreak[n+1]:"&breakStruct.arrBreak[n+1]);
								//writedump("tempPercent:"&tempPercent);
								//writedump("columnWidth:"&columnWidth);
								//abort;
							}
							if(columnWidth < breakStruct.minimum_column_width){
								isSingleColumn=true;
								disableFirstLast=true;
							}else{
						if(limit EQ 4){
						//writedump('didi');
						}
								percent=tempPercent;
								currentLimit=i3;
								currentIndex=i3;
							}  
					} 
					for(n2=1;n2<=limit;n2++){
						width=percent*n2;
						if(limit EQ 4){
					//		writedump(width);
						}

						// need to calculate the total margin based on number of columns.  i.e. 3 column with 3% column gap is (3-1)*3
						if(breakpoint > 980){
							columnCount=round(100/percent);
							columnCount=n2;
							margin=dataStruct.columnGapSidePercent/2;  
							marginTemp=dataStruct.columnGapSidePercent;
							if(n2==currentLimit){
								margin=0;  
								marginTemp=dataStruct.columnGapSidePercent;
							}else{
							//	width-=((n2)*dataStruct.columnGapSidePercent);//+(dataStruct.columnGapSidePercent*(columnCount));//margin*(n2);  
							}
								width-=dataStruct.columnGapSidePercent;
							maxWidth=100; 

							// why is 2of3 1.5% wrong
							//width=int(width*100)/100; 
							if(limit EQ 3){
							//	writedump("n2:"&(n2)&" breakpoint:"&breakpoint&" margin:"&margin&" | width:"&width&" columnCount:"&columnCount);
							}
						}else if(breakpoint EQ 980){
							if(percent < 33.34){
								percent=33.33;
								columnCount=1;
							}else if(percent > 66.67){
								percent=100;
								columnCount=3;
							}else{
								percent=66.66;
								columnCount=2;
							}
							disableFirstLast=true;
							width=n2*percent;
							margin=dataStruct.columnGapSidePercent/2; 
							totalMargin=dataStruct.columnGapSidePercent*columnCount;//(currentIndex+1);  
							maxWidth=100-totalMargin;
							percentMargin=(percent/100)*totalMargin;
							width-=percentMargin; 
							width=int(width*100)/100;  
						}else{
							if(percent < 50){
								percent=50;
								columnCount=1;
							}else{
								percent=100;
								columnCount=2;
							}
							disableFirstLast=true;
							width=n2*percent;
							margin=dataStruct.columnGapSidePercent/2; 
							totalMargin=dataStruct.columnGapSidePercent*columnCount;//(currentIndex+1);  
							maxWidth=100-totalMargin;
							percentMargin=(percent/100)*totalMargin;
							width-=percentMargin; 
							width=int(width*100)/100;  
						}
						padding=' padding-left:#dataStruct.boxPaddingSidePercent#%; padding-right:#dataStruct.boxPaddingSidePercent#%; padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%;';
						if(isSingleColumn){//isNumeric(breakpoint) and breakpoint LTE 980){
							v='.z-#n2#of#limit#{  max-width:100%; width:100%; display:block; float:left;  padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%; margin-left:0px; margin-right:0px; padding-left:#dataStruct.boxPaddingSidePercent#%; padding-right:#dataStruct.boxPaddingSidePercent#%; margin-bottom:#numberformat(dataStruct.columnGapBottomPercent, '_.__')#%; } ';
							if(not structkeyexists(uniqueStruct, v)){
								uniqueStruct[v]=true;
								arrayAppend(arrCSS, v);
							}   
						}else{   
							v='.z-#n2#of#limit#{ ';
							if(breakpoint LTE 980){
								v&=" min-width:#breakStruct.minimum_column_width#px;";
							}
							v&=' max-width:#maxWidth#%;  width:#numberformat(width, '_.___')#%; #padding# float:left; margin-left:#numberformat(margin, '_.___')#%; margin-right:#numberformat(margin, '_.___')#%;  margin-bottom:#numberformat(dataStruct.columnGapBottomPercent, '_.__')#%;}';
						
							if(not structkeyexists(uniqueStruct, v)){
								uniqueStruct[v]=true;
								arrayAppend(arrCSS, v);
							}  
						}
					}
					limit++;
				}
			} 
		}
	}
				//	abort;
	savecontent variable="out"{  
	echo('
 	.z-center-children > *{ font-size:#dataStruct.textScale*16# }
 	.z-column{ margin-left:#numberformat(dataStruct.columnGapSidePercent/2, '_.__')#%;  margin-right:#numberformat(dataStruct.columnGapSidePercent/2, '_.__')#%; padding-left:#dataStruct.boxPaddingSidePercent#%; padding-right:#dataStruct.boxPaddingSidePercent#%; padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%; }


 	');
 	/*
	.z-section-10{padding-top:#dataStruct.boxPaddingTopPercent*0.8#%; padding-bottom:#dataStruct.boxPaddingBottomPercent*0.8#%;}
	.z-section-20{padding-top:#dataStruct.boxPaddingTopPercent*1.5#%; padding-bottom:#dataStruct.boxPaddingBottomPercent*1.5#%;}
	.z-section-medium{padding-top:#dataStruct.boxPaddingTopPercent*3#%; padding-bottom:#dataStruct.boxPaddingBottomPercent*3#%;}
	.z-section-large{padding-top:#dataStruct.boxPaddingTopPercent*6#%; padding-bottom:#dataStruct.boxPaddingBottomPercent*6#%;}
	*/
	multiplier=0.4;
 	for(i=1;i<=15;i++){
		echo('.z-section-#i*10#{padding-top:#numberformat(dataStruct.boxPaddingTopPercent*multiplier, '_.__')#%; padding-bottom:#numberformat(dataStruct.boxPaddingBottomPercent*multiplier, '_.__')#%;}'&chr(10));
		multiplier+=0.35;
	}
	for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
		breakpoint=breakStruct.arrBreak[i]; 
		if(breakpoint NEQ 'Default'){
			echo('@media screen and (max-width: #breakpoint#px) {'&chr(10)); 
			echo(chr(9)&arrayToList(breakStruct.css[breakpoint], chr(10)&chr(9))&chr(10)); 
			echo('}'&chr(10));
		}else{
			echo(arrayToList(breakStruct.css[breakpoint], chr(10))&chr(10)); 
		}
	}
	/*
	#arrayToList(arrFull, chr(10))#
	@media screen and (max-width: 1280px) {
	#arrayToList(arr1280, chr(10))#
	}
	@media screen and (max-width: 980px) {
	#arrayToList(arr980, chr(10))# 
	}
	@media screen and (max-width: 768px) {
	#arrayToList(arr768, chr(10))#
	}

	@media screen and (max-width: 480px) {
	#arrayToList(arr480, chr(10))#

	}');*/
	} 
	application.zcore.functions.zWriteFile(request.zos.globals.privateHomeDir&"zupload/layout-global.css", out);
	</cfscript>

</cffunction>

	
<cffunction name="settingsInstance" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	application.zcore.functions.zStatusHandler(request.zsid);
	db=request.zos.queryObject;

breakStruct={}; 

breakStruct=getBreakpointConfig();
db.sql="select * from #db.table("layout_global", request.zos.zcoreDatasource)# WHERE 
site_id = #db.param(request.zos.globals.id)# and 
layout_global_deleted =#db.param(0)# ";
qGlobal=db.execute("qGlobal");
if(qGlobal.recordcount NEQ 0){
	oldBreakStruct=deserializeJson(qGlobal.layout_global_json_data);
	for(i in oldBreakStruct.data){
		if(structkeyexists(breakStruct.data, i)){
			structappend(breakStruct.data[i], oldBreakStruct.data[i], true);
		}
	}
}
echo('<h2>Instance Layout Settings</h2>');

displaySettingsForm(breakStruct);
</cfscript>
</cffunction>

	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	echo('<div style="width:100%; float:left; padding-left:5px; padding-right:5px;">');
	application.zcore.functions.zStatusHandler(request.zsid);
	db=request.zos.queryObject;

breakStruct={}; 

breakStruct=getBreakpointConfig();
db.sql="select * from #db.table("layout_global", request.zos.zcoreDatasource)# WHERE 
site_id = #db.param(request.zos.globals.id)# and 
layout_global_deleted =#db.param(0)# ";
qGlobal=db.execute("qGlobal");
if(qGlobal.recordcount NEQ 0){
	oldBreakStruct=deserializeJson(qGlobal.layout_global_json_data);
	for(i in oldBreakStruct.data){
		if(structkeyexists(breakStruct.data, i)){
			structappend(breakStruct.data[i], oldBreakStruct.data[i], true);
		}
	}
	breakStruct.minimum_column_width=oldBreakStruct.minimum_column_width;
}
echo('<h2>Global Layout Settings</h2>');
echo('</div>');
displaySettingsForm(breakStruct);
</cfscript>
</cffunction>

<cffunction name="displaySettingsForm" localmode="modern" access="public">
	<cfargument name="breakStruct" type="struct" required="yes">
	<cfscript>
	breakStruct=arguments.breakStruct;
defaultBreakPoint=getDefaultBreakpointConfig();
// uncomment to more easily debug css generation
//generateGlobalBreakpointCSS(breakStruct);

labelStruct={
	headingScale:"Heading Scale",
	textScale:"Text Scale",
	boxPaddingTopPercent:"Box Padding Top %",
	boxPaddingSidePercent:"Box Padding Side %",
	boxPaddingBottomPercent:"Box Padding Bottom %",
	columnGapSidePercent:"Column Gap Side %",
	columnGapBottomPercent:"Column Gap Bottom %",
	minimumPadding:"Minimum Padding",
	headingMinimumFontSize:"Heading Minimum Font Size",
	textMinimumFontSize:"Text Minimum Font Size",
	headingLineHeightScale:"Heading Line Height Scale",
	textLineHeightScale:"Text Line Height Scale"
};

if(form.method EQ "index"){
	action="/z/admin/layout-global/saveLayoutSettings";
}else{
	action="/z/admin/layout-global/saveLayoutInstanceSettings";
}
// display form
echo('<div style="width:100%; float:left; padding-left:5px; padding-right:5px;">
	<form action="#action#" method="post">
	<table class="table-list">
	<tr>
	<th>&nbsp;</th>');
for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
	breakpoint=breakStruct.arrBreak[n]; 
	dataStruct=breakStruct.data[breakpoint];
	echo('<th>#breakpoint#</th>');
}
echo('</tr>');
	echo('<tr>');
	echo('<th>Enabled?</th>');
for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
	breakpoint=breakStruct.arrBreak[n]; 
	id="enabled_"&breakpoint;
	dataStruct=breakStruct.data[breakpoint]; 

	echo('<td><input type="checkbox" name="#id#" value="1" ');
	if(application.zcore.functions.zso(dataStruct, 'enabled', true, 1) EQ 1){
		echo('checked="checked" ');
	}
	echo(' /></td>');
}
echo('</tr>');
arrKey=structkeyarray(defaultBreakPoint);
arraySort(arrKey, "text", "asc");
for(i in arrKey){
	//i=defaultBreakPoint[arrKey[i]];
	echo('<tr>');
	echo('<th>'&labelStruct[i]&'</th>');
	for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
		breakpoint=breakStruct.arrBreak[n]; 
		dataStruct=breakStruct.data[breakpoint]; 
		id=application.zcore.functions.zescape(i, "_")&"_"&breakpoint;
		echo('<td><input type="number" from="0.1" to="100.00" step="0.1" name="#id#" value="'&dataStruct[i]&'" style="width:50px;min-width:50px;" /></td>');
	}
	echo('</tr>');
}

minimum_column_width=application.zcore.functions.zso(breakStruct, 'minimum_column_width');
echo('<tr>
	<th>&nbsp;</th>
	<td colspan="#structcount(defaultBreakPoint)#">
	Column width that triggers single column below 980: <input type="text" name="minimum_column_width" style="max-width:100px; min-width:100px;" value="#htmleditformat(minimum_column_width)#"><br />
	Enable z-breakpoint: Checkbox
	</td>
	</tr>');
echo('<tr>
	<th>&nbsp;</th>
	<td colspan="#structcount(defaultBreakPoint)#">
	<input type="submit" name="save1" value="Save"> 
	<input type="button" name="save2" value="Restore Defaults" onclick="window.location.href=''/z/admin/layout-global/saveLayoutSettings?setToDefault=1''; "> 
	</td>');
echo('</table>
	</form>
	</div>');  
	showExample();
	</cfscript>
</cffunction>
	

<cffunction name="showExample" localmode="modern" access="remote" roles="member">
	<cfscript>
	 
	echo('<h2>Layout Example</h2>');
	application.zcore.skin.includeCSS("/zupload/layout-global.css"); 
	</cfscript>  
	<style type="text/css">
	.zapp-shell-container{padding-left:0px; padding-right:0px;}
	.z-container:nth-child(even){ background-color:##555;}
	.z-container:nth-child(odd){ background-color:##666;}
	.z-container div{ background-color:##aaa;}
	.z-container .z-center{ background-color:##aaa;}
	.z-container .z-center div { background-color:##EEE;}
	</style>
<div class="wrapper">
	<div class="z-container">
		<div class="z-center z-section-20"> 
			<div class="z-column">
				For visualizing space adjustments, background colors have been applied. Dark = z-container, medium = z-center, lightest = z-column
			</div>
		</div>
	</div> 
	<div class="z-container z-section-10">
		<div class="z-center"> 
			<div class="z-column " > 
				Each grid system can have columns that span 1 or more of the columns. Examples:
			</div>
		</div>
	</div>
	<div class="z-container z-section-10">
		<div class="z-center z-center-children"> 
			<div class="z-1of4 " > 
				<div class="z-heading-24">z-1of4</div>
				<div class="z-text-12">Text</div> 
			</div>
			<div class="z-2of4 " > 
				<div class="z-heading-24">z-2of4</div>
				<div class="z-text-12">Text</div>
			</div> 
			<div class="z-1of4" > 
				<div class="z-heading-24">z-1of4</div>
				<div class="z-text-12">Text</div>
			</div>
		</div> 
	</div>
	<div class="z-container z-section-10">
		<div class="z-center z-center-children"> 
			<div class="z-1of3" > 
				<div class="z-heading-24">z-1of3</div>
				<div class="z-text-12">Text</div>
			</div>
			<div class="z-2of3"> 
				<div class="z-heading-24">z-2of3</div>
				<div class="z-text-12">Text</div> 
			</div> 
		</div>
	</div>
	<div class="z-container z-section-10">
		<div class="z-center z-center-children"> 
			<div class="z-4of4" > 
				<div class="z-heading-24">z-4of4</div>
				<div class="z-text-12">Text</div> 
			</div>
		</div>
	</div>

	<div class="z-container z-section-10">
		<div class="z-center z-center-children"> 
			<div class="z-column" > 
				<h2>All Grid Systems</h2>
			</div>
		</div>
	</div>
	<!--- <cfloop from="2" to="4" index="i">
		<div class="z-container z-section-#10*i#">
			<div class="z-center z-center-children"> 
				<cfscript>
				columnsLeft=i;
				</cfscript>
				<cfloop from="1" to="#i#" index="n">
					<cfscript>
					if(columnsLeft EQ 0){
						break;
					}
					columns=min(3,randRange(1, columnsLeft));
					columnsLeft-=columns;
					</cfscript>
					<div class="z-#columns#of#i#" >
						<div class="z-heading-12">#columns#</div>
					</div>
				</cfloop>
			</div>
		</div>
	</cfloop> --->
	<cfloop from="2" to="16" index="i">
		<div class="z-container z-section-10">
			<div class="z-center z-section-10"> 
				<div class="z-column z-heading-18">#i# column grid system ( class="z1of#i#" )</div>
			</div>
			<div class="z-center z-center-children"> 
				<cfloop from="1" to="#i#" index="n">
					<div class="z-1of#i#" > 
						<div class="z-heading-12">#n#</div>
					</div>
				</cfloop>
			</div>
		</div>
	</cfloop> 
	<div class="z-container z-section-10">
		 <div class="z-center z-equal-heights"> 
		 	<div class="z-1of3">
				<div class="z-heading-36">
					Heading1
				</div>  
				<div class="z-heading-30">
					Heading2
				</div>  
				<div class="z-heading-24">
					Heading3
				</div> 
				<div class="z-heading-18">
					Heading4
				</div>  
				<div class="z-heading-14">
					Heading5
				</div>  
			</div>
			<div class="z-1of3">
				<h1>Heading1</h1>
				<h2>Heading2</h2>
				<h3>Heading3</h3> 
				<h4>Heading4</h4>
				<h5>Heading5</h5>
			</div>
			<div class="z-1of3">
				<div class=" z-text-36">
				Text36
				</div> 
				<div class=" z-text-24">
				Text24
				</div> 
				<div class=" z-text-18">
				Text18
				</div>  
			</div>
		</div>
	</div>  
</div>
</cffunction>
	
</cfoutput>
</cfcomponent>