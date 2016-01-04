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
		arrBreak=["Default","1800","1550","1200","960","768","480"],
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
			"1200":{
				headingScale:1.2,
				textScale:1.2
			},
			"960":{
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

<cffunction name="saveLayoutSettings" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("layout_global", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_global_deleted =#db.param(0)#";
	qGlobal=db.execute("qGlobal");
	breakStruct=getBreakpointConfig();
	for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
		breakpoint=breakStruct.arrBreak[i]; 
		dataStruct=breakStruct.data[breakpoint];
		for(n in dataStruct){
			id=application.zcore.functions.zescape(n, "_")&"_"&breakpoint;
			if(structkeyexists(form, id)){
				dataStruct[n]=form[id];
			}
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
	generateGlobalBreakpointCSS(breakStruct);

	application.zcore.status.setStatus(request.zsid, "Saved");
	application.zcore.functions.zRedirect("/z/admin/layout-global/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="generateGlobalBreakpointCSS" localmode="modern" access="remote" roles="member">
	<cfargument name="breakpointConfig" type="struct" required="yes">
	<cfscript>
	arrFull=[];
	arr1200=[];
	arr960=[];
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
				for(i2=2;i2<=16;i2++){
					percent=100/limit;
					for(n2=1;n2<=limit;n2++){
						v=numberformat(percent*n2, '_.__');
						if(n2==limit){
							v="100";
						}
						maxWidth=100-(dataStruct.columnGapSidePercent/100);
						margin=(dataStruct.columnGapSidePercent/100)*v;
						v-=margin*4;
						marginBottom=(dataStruct.columnGapBottomPercent/100)*v;
						padding=' padding-left:#dataStruct.boxPaddingSidePercent#%; padding-right:#dataStruct.boxPaddingSidePercent#%; padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%;';
						if(isNumeric(breakpoint) and breakpoint LTE 960){
							v='.z-#n2#of#limit#{ width:100%;  padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%; margin-left:0px; margin-right:0px; padding-left:3%; padding-right:3%; } ';
							if(not structkeyexists(uniqueStruct, v)){
								uniqueStruct[v]=true;
								arrayAppend(arrCSS, v);
							}  
						}else{ 
							v='.z-#n2#of#limit#{ max-width:#maxWidth#%; width:#v#%; #padding# display:inline-block; margin-left:#numberformat(margin/2, '_.__')#%;margin-right:#numberformat(margin/2, '_.__')#%; margin-bottom:#numberformat(marginBottom, '_.__')#%;}';
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
 
	.z-container .z-center{margin:0 auto; width:1200px;}
	@media screen and (max-width: 1200px) {
	#arrayToList(arr1200, chr(10))#
	.z-container .z-center{margin:0 auto; width:960px;}
 
	}
	@media screen and (max-width: 960px) {
	#arrayToList(arr960, chr(10))# 
	.z-container .z-center{margin:0 auto; width:100%;}  
	}
	@media screen and (max-width: 768px) {

	#arrayToList(arr768, chr(10))#
	}

	@media screen and (max-width: 480px) {
	#arrayToList(arr480, chr(10))#

	}');
	}
	application.zcore.functions.zWriteFile(request.zos.globals.privateHomeDir&"zupload/layout-global.css", out);
	</cfscript>

</cffunction>


	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.zStatusHandler(request.zsid);
	db=request.zos.queryObject;

breakStruct={}; 

defaultBreakPoint=getDefaultBreakpointConfig();
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

// display form
echo('<h2>Global Layout Settings</h2>');
echo('
	<form action="/z/admin/layout-global/saveLayoutSettings" method="post">
	<table class="table-list">
	<tr>
	<th>&nbsp;</th>');
for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
	breakpoint=breakStruct.arrBreak[n]; 
	dataStruct=breakStruct.data[breakpoint];
	echo('<th>#breakpoint#</th>');
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
echo('<tr>
	<th>&nbsp;</th>
	<td colspan="#structcount(defaultBreakPoint)#">
	<input type="submit" name="save1" value="Save"> 
	<input type="button" name="save2" value="Restore Defaults" onclick="window.location.href=''/z/admin/layout-global/saveLayoutSettings''; "> 
	</td>');
echo('</table>
	</form>'); 

echo('<h2>Layout Example</h2>');
application.zcore.skin.includeCSS("/zupload/layout-global.css");
</cfscript> 

<div class="z-container">
	<div class="z-center z-center-children"> 
		<div class="z-1of3" >
			<div style="background-color:##CCC; padding:10px; width:100%; float:left;">
				<div class="z-heading-36">1of3</div>
				<div class="z-text-18">1of3</div>
			</div>
		</div>
		<div class="z-1of3">1of3
		</div>
		<div class="z-1of3" >1of3
		</div>
	</div>
	<div class="z-center z-center-children"> 
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
	</div>
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