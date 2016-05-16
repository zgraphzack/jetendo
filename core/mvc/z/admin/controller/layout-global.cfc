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
		columnGapSidePercent:3,
		columnGapBottomPercent:3,
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
		dataStruct["enabled"]=application.zcore.functions.zso(form, "enabled_"&breakpoint, true, 0); 
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
		dataStruct["enabled"]=application.zcore.functions.zso(form, "enabled_"&breakpoint, true, 0); 
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
	arrFull=[];
	arr1280=[];
	arr980=[];
	arr768=[];
	arr480=[]; 
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

				for(i2=2;i2<=7;i2++){
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
						// this code depends on z-first and z-last classes removing margins from first and last elements in a row.

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
							v='.z-#n2#of#limit#{ background-color:##EEE; max-width:100%; width:100%; display:block; float:left;  padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%; margin-left:0px; margin-right:0px; padding-left:#dataStruct.boxPaddingSidePercent#%; padding-right:#dataStruct.boxPaddingSidePercent#%; margin-bottom:#numberformat(dataStruct.columnGapBottomPercent, '_.__')#%; } ';
							if(not structkeyexists(uniqueStruct, v)){
								uniqueStruct[v]=true;
								arrayAppend(arrCSS, v);
							}   
							v='.z-#n2#of#limit#.z-first{ margin-left:0px; } ';
							if(not structkeyexists(uniqueStruct, v)){
								uniqueStruct[v]=true;
								arrayAppend(arrCSS, v);
							}  
							v='.z-#n2#of#limit#.z-last{ margin-right:0px; } ';
							if(not structkeyexists(uniqueStruct, v)){
								uniqueStruct[v]=true;
								arrayAppend(arrCSS, v);
							}   
						}else{   
							if(disableFirstLast){
								v='.z-#n2#of#limit#.z-first{ margin-left:#numberformat(margin, '_.__')#%; } ';
								if(not structkeyexists(uniqueStruct, v)){
									uniqueStruct[v]=true;
									arrayAppend(arrCSS, v);
								}  
								v='.z-#n2#of#limit#.z-last{ margin-right:#numberformat(margin, '_.__')#%; } ';
								if(not structkeyexists(uniqueStruct, v)){
									uniqueStruct[v]=true;
									arrayAppend(arrCSS, v);
								}  
							}
							v='.z-#n2#of#limit#{ background-color:##EEE; min-width:#breakStruct.minimum_column_width#px; max-width:#maxWidth#%;  width:#numberformat(width, '_.___')#%; #padding# float:left; margin-left:#numberformat(margin, '_.___')#%; margin-right:#numberformat(margin, '_.___')#%;  margin-bottom:#numberformat(dataStruct.columnGapBottomPercent, '_.__')#%;}';
						
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
	echo('
	#arrayToList(arrFull, chr(10))#

	.z-container *{
		-webkit-box-sizing: border-box;
		-moz-box-sizing: border-box;
		box-sizing:border-box;
	}
	.z-center-children{ text-align:center; font-size:0px;} 
 	.z-center-children > div{ display:inline-block; text-align:left; vertical-align:top; float:none; font-size:#dataStruct.textScale*16# }
 	.z-column{ margin-left:#numberformat(dataStruct.columnGapSidePercent/2, '_.__')#%;  margin-right:#numberformat(dataStruct.columnGapSidePercent/2, '_.__')#%; padding-left:#dataStruct.boxPaddingSidePercent#%; padding-right:#dataStruct.boxPaddingSidePercent#%; padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%; }

	.z-container .z-center{margin:0 auto; width:1280px;}
	@media screen and (max-width: 1280px) {
	#arrayToList(arr1280, chr(10))#
	.z-container .z-center{margin:0 auto; width:980px;}
 
	}
	@media screen and (max-width: 980px) {
	#arrayToList(arr980, chr(10))# 
	.z-container .z-center{margin:0 auto; width:100%;}  
	}
	@media screen and (max-width: 768px) {

 	.z-column{ margin-left:0px; margin-right:0px; }
	#arrayToList(arr768, chr(10))#
	}

	@media screen and (max-width: 480px) {
	#arrayToList(arr480, chr(10))#

	}');
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
echo('
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
for(i in defaultBreakPoint){
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
	<input type="button" name="save2" value="Restore Defaults" onclick="window.location.href=''/z/admin/layout-global/saveLayoutSettings''; "> 
	</td>');
echo('</table>
	</form>');  
	showExample();
	</cfscript>
</cffunction>
	

<cffunction name="showExample" localmode="modern" access="remote" roles="member">
	<cfscript>
	 
	echo('<h2>Layout Example</h2>');
	application.zcore.skin.includeCSS("/zupload/layout-global.css");
	application.zcore.skin.includeCSS("/z/stylesheets/zframework.css");
	</cfscript> 
	<p>This code depends on z-first and z-last classes removing margins from first and last elements in a row.</p>
<!--- 
on container
    width: 1280px; - the hardcoded width is what fixes it
    overflow: hidden;
    margin: 0 auto;
 on inner container:
    margin: 0 auto;
    width: 103%;
    margin-right: -1.5%;
    margin-left: -1.5%;
 --->
<div class="z-container">
<div class="z-center z-center-children"> 
<div class="z-1of4 z-first " >
<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
<div class="z-heading-30">1of4</div>
<div class="z-text-16">Text</div>
</div>
</div>
<div class="z-2of4 " >
<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
<div class="z-heading-30">2of4</div>
<div class="z-text-16">Text</div>
</div>
</div>
<div class="z-1of4 z-last" >
<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
<div class="z-heading-30">1of4</div>
<div class="z-text-16">Text</div>
</div>
</div>
</div>
	<div class="z-center z-center-children"> 
		<div class="z-1of3 z-first" >
			<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
				<div class="z-heading-30">1of3</div>
				<div class="z-text-16">Text</div>
			</div>
		</div>
		<div class="z-2of3 z-last">
			<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
				<div class="z-heading-30">2of3</div>
				<div class="z-text-16">Text</div>
			</div>
		</div> 
	</div>
	<div class="z-center z-center-children"> 
		<div class="z-4of4 z-first z-last" >
			<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
				<div class="z-heading-30">4of4</div>
				<div class="z-text-16">Text</div>
			</div>
		</div>
	</div>
	<h2>Other Examples</h2>
	<cfloop from="2" to="7" index="i">
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
				<div class="z-#columns#of#i#<cfif n EQ 1> z-first</cfif> <cfif columnsLeft EQ 0> z-last</cfif>" >
					<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
						<div class="z-heading-30">#columns#of#i#</div>
						<div class="z-text-16">Text</div>
					</div>
				</div>
			</cfloop>
		</div>
	</cfloop>
	<cfloop from="2" to="7" index="i">
		<div class="z-center z-center-children"> 
			<cfloop from="1" to="#i#" index="n">
				<div class="z-1of#i#<cfif n EQ 1> z-first<cfelseif n EQ i> z-last</cfif>" >
					<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
						<div class="z-heading-30">1of#i#</div>
						<div class="z-text-16">1of#i#</div>
					</div>
				</div>
			</cfloop>
		</div>
	</cfloop>
	<!--- <div class="z-center z-center-children"> 
		<div class="z-1of3 z-first" >
			<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
				<div class="z-heading-36">1of3</div>
				<div class="z-text-18">1of3</div>
			</div>
		</div>
		<div class="z-1of3">
			<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
				<div class="z-heading-36">1of3</div>
				<div class="z-text-18">1of3</div>
			</div>
		</div>
		<div class="z-1of3 z-last" >
			<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
				<div class="z-heading-36">1of3</div>
				<div class="z-text-18">1of3</div>
			</div>
		</div>
	</div>
	<div class="z-center z-center-children"> 
		<div class="z-1of3 z-first" >
			<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
				<div class="z-heading-36">1of3</div>
				<div class="z-text-18">1of3</div>
			</div>
		</div>
		<div class="z-1of3">
			<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
				<div class="z-heading-36">1of3</div>
				<div class="z-text-18">1of3</div>
			</div>
		</div>
		<div class="z-1of3 z-last" >
			<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
				<div class="z-heading-36">1of3</div>
				<div class="z-text-18">1of3</div>
			</div>
		</div>
	</div> --->

	<!--- <div class="z-center z-center-children"> 
		<div class="z-1of3" >1of3
		</div>
		<div class="z-2of3">2of3
		</div> 
	</div>
	<div class="z-center z-center-children"> 
		<div class="z-1of4" >1of4
		</div>
		<div class="z-2of4">2of4
		</div> 
		<div class="z-1of4" >1of4
		</div>
	</div>
	<div class="z-center z-center-children">   
		<div class="z-1of5">1of5
		</div>
		<div class="z-1of5">1of5
		</div>
		<div class="z-3of5">3of5
		</div>
	</div> --->
</div>
<div class="z-container">
	 <div class="z-center"> 
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
			<h1>Heading1</h1>
			<h2>Heading2</h2>
			<h3>Heading3</h3> 
			<h4>Heading4</h4>
			<h5>Heading5</h5>
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
</cffunction>
	
</cfoutput>
</cfcomponent>