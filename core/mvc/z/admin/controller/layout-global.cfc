<cfcomponent extends="zcorerootmapping.com.zos.controller"> 
<cfoutput>
<cffunction name="getDefaultBreakpointConfig" localmode="modern" access="public">
	<cfscript>
	ts={
		headingScale:1.5,
		textScale:1.5,
		indentScale:1,
		boxPaddingTopPercent:1,
		boxPaddingSidePercent:1,
		boxPaddingBottomPercent:1,
		boxMarginTopPercent:1,
		boxMarginSidePercent:1,
		boxMarginBottomPercent:1,
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
		arrBreak=["Default","1800","1550","1362","992","767","479"],
		data:{
			"Default":{
				headingScale:1,
				textScale:1,
				minimumPadding:10,
				textMinimumFontSize:10,
				headingMinimumFontSize:10,
				indentScale:1.2
			},
			"1800":{
				headingScale:1,
				textScale:1,
				indentScale:1.15
			},
			"1550":{
				headingScale:1,
				textScale:1,
				indentScale:1.1
			}, 
			"1362":{
				headingScale:0.836,
				textScale:0.836,
				indentScale:1,
				/*boxPaddingTopPercent:0.836,
				boxPaddingSidePercent:0.836,
				boxPaddingBottomPercent:0.836,
				boxMarginTopPercent:0.836,
				boxMarginSidePercent:0.836,
				boxMarginBottomPercent:0.836,*/
			},
			"992":{
				headingScale:0.806,
				textScale:0.806,
				indentScale:0.806,
				/*boxPaddingTopPercent:0.806,
				boxPaddingSidePercent:0.806,
				boxPaddingBottomPercent:0.806,
				boxMarginTopPercent:0.806,
				boxMarginSidePercent:0.806,
				boxMarginBottomPercent:0.806,*/
			},
			"767":{
				headingScale:0.786,
				textScale:0.786,
				indentScale:0.786,
				/*boxPaddingTopPercent:0.786,
				boxPaddingSidePercent:0.786,
				boxPaddingBottomPercent:0.786,
				boxMarginTopPercent:0.786,
				boxMarginSidePercent:0.786,
				boxMarginBottomPercent:0.786,*/
			},
			"479":{
				headingScale:0.736,
				textScale:0.736,
				indentScale:0.736,
				/*boxPaddingTopPercent:0.736,
				boxPaddingSidePercent:0.736,
				boxPaddingBottomPercent:0.736,
				boxMarginTopPercent:0.736,
				boxMarginSidePercent:0.736,
				boxMarginBottomPercent:0.736,*/
			}
		},
		minimum_column_width:200,
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
		if(structkeyexists(form, 'setToDefault') and breakpoint NEQ 1800 and breakpoint NEQ 1550){
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
	breakStruct=arguments.breakpointConfig;
	startFontSize=12; 
	uniqueStruct={};

	for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
		breakpoint=breakStruct.arrBreak[n]; 
		dataStruct=breakStruct.data[breakpoint];
		//uniqueStruct={};
		arrCSS=breakStruct.css[breakpoint];
		tempScaleText=max(round(16*dataStruct.textScale), dataStruct.textMinimumFontSize); 


		v='body { line-height:#numberformat(dataStruct.textLineHeightScale*1.3, '_._')#; } ';
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		} 
		v='p{margin:0px; padding:0px; padding-bottom:#round(max(dataStruct.minimumPadding, tempScaleText*0.45))#px;}';
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		} 
		v='ul,ol,blockquote{ margin:0px; padding:0px; padding-left:#numberformat(dataStruct.indentScale*4, '_.___')#%; padding-bottom:#round(max(dataStruct.minimumPadding, tempScaleText*0.45))#px; }';
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		} 
		v='h1,h2,h3,h4,h5,h6{ line-height:#numberformat(dataStruct.headingLineHeightScale*1.3, '_._')#; margin:0px; padding:0px; }';
		//v='.z-container h1,.z-container h2,.z-container h3,.z-container h4,.z-container h5,.z-container h6{ line-height:#numberformat(dataStruct.headingLineHeightScale*1.3, '_._')#; margin:0px; padding:0px; }';
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		} 
		v='.z-container textarea, .z-container select, .z-container button, .z-container input{ font-size:#tempScaleText#px; line-height:#numberformat(dataStruct.headingLineHeightScale*1.3, '_._')#; }';
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		} 
		v='.z-center-children > div, .z-center-children > a{text-align:left;vertical-align:top; font-size:#max(dataStruct.textMinimumFontSize, round(16*dataStruct.textScale))#px;}';
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		}
		v='.z-center-children > div, .z-center-children > a{ font-size:#max(dataStruct.textMinimumFontSize, round(dataStruct.textScale*16))#px; }';
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		} 
		if(n EQ arrayLen(breakStruct.arrBreak)){
	 		v='.z-column{ min-height:1px; width:100%; margin-left:0%;  margin-right:0%; padding-left:#dataStruct.boxPaddingSidePercent#%; padding-right:#dataStruct.boxPaddingSidePercent#%; padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%; }';
		}else{
	 		v='.z-column{ min-height:1px; width:#numberformat(100-dataStruct.columnGapSidePercent, '_.___')#%; margin-left:#numberformat(dataStruct.columnGapSidePercent/2, '_.___')#%;  margin-right:#numberformat(dataStruct.columnGapSidePercent/2, '_.___')#%; padding-left:#dataStruct.boxPaddingSidePercent#%; padding-right:#dataStruct.boxPaddingSidePercent#%; padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%; }';
	 	}
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		} 
		limit=2; 

		arrOffsetCSS=[];
		for(i2=2;i2<=16;i2++){
			if(limit GT 7 and limit NEQ 12 and limit NEQ 16){
				limit++;
				continue;
			}
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
			}else if(nextBreakpoint EQ "default"){
				columnWidth=1280*(percent/100);
			}else{
				columnWidth=min(1280, nextBreakpoint)*(percent/100);
			}
			disableFirstLast=false; 
			// if the columns will be less then the minimum column width, force them all to 100% at this breakpoint
			if(n==arrayLen(breakStruct.arrBreak)){
				isSingleColumn=true;
				disableFirstLast=true;
			}else if(breakpoint <= 992 and columnWidth < breakStruct.minimum_column_width){
				// find the previous columnWidth that allows more then one column (if any)  
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
				if(columnWidth < breakStruct.minimum_column_width){
					isSingleColumn=true;
					disableFirstLast=true;
				}else{ 
					percent=tempPercent;
					currentLimit=i3;
					currentIndex=i3;
				}  
			} 
			for(n2=1;n2<=limit;n2++){
				width=percent*n2; 


				// need to calculate the total margin based on number of columns.  i.e. 3 column with 3% column gap is (3-1)*3
				if(breakpoint > 992){
					columnCount=round(100/percent);
					columnCount=n2;
					margin=dataStruct.columnGapSidePercent/2;  
					marginTemp=dataStruct.columnGapSidePercent;
					if(n2==currentLimit){
						margin=0;  
						marginTemp=dataStruct.columnGapSidePercent;   
					}
					width-=dataStruct.columnGapSidePercent;
					maxWidth=100;  
				}else if(breakpoint EQ 992){
					if(percent <= 33.34){
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
					totalMargin=dataStruct.columnGapSidePercent*columnCount;
					maxWidth=100-totalMargin;
					percentMargin=(percent/100)*totalMargin;
					width-=percentMargin; 
					width=min(maxWidth, int(width*100)/100);  
				}else{
					if(percent <= 50){
						percent=50;
						columnCount=1;
					}else{
						percent=100;
						columnCount=2;
					}
					disableFirstLast=true;
					width=n2*percent;
					margin=dataStruct.columnGapSidePercent/2; 
					totalMargin=dataStruct.columnGapSidePercent*columnCount;
					maxWidth=100-totalMargin;
					percentMargin=(percent/100)*totalMargin;
					width-=percentMargin; 
					width=min(maxWidth, int(width*100)/100);  
				} 
				padding=' padding-left:#dataStruct.boxPaddingSidePercent#%; padding-right:#dataStruct.boxPaddingSidePercent#%; padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%;';

				v='.z-#n2#of#limit#{ float:left; margin-left:#numberformat(margin, '_.___')#%; margin-right:#numberformat(margin, '_.___')#%; #padding# margin-bottom:#numberformat(dataStruct.columnGapBottomPercent, '_.___')#%;}';
			
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}  
				if(isSingleColumn){
					v='.z-#n2#of#limit#{ min-height:1px; max-width:100%; width:100%; margin-left:0px; margin-right:0px; display:block; }';
					if(not structkeyexists(uniqueStruct, v)){
						uniqueStruct[v]=true;
						arrayAppend(arrCSS, v);
					}   
				}else{    
					if(breakpoint LTE 992){
						v=".z-#n2#of#limit#{ min-width:#breakStruct.minimum_column_width#px; max-width:#maxWidth#%; width:#numberformat(width, '_.___')#%; }";
					}else{
						v=".z-#n2#of#limit#{ max-width:#maxWidth#%; width:#numberformat(width, '_.___')#%; }";
					} 
					if(not structkeyexists(uniqueStruct, v)){
						uniqueStruct[v]=true;
						arrayAppend(arrCSS, v);
					}  
				}
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}  
				// offset classes
				if(isSingleColumn){
					v='.z-offset-#n2#of#limit#{ margin-left:0px; }';
				}else{
					if(breakpoint > 992){ 
						v='.z-offset-#n2#of#limit#{ margin-left:#numberformat(margin+width, '_.___')#%; }';
					}else{
						v='.z-offset-#n2#of#limit#{ margin-left:#numberformat(margin, '_.___')#%; }';
					}
				}
				arrayAppend(arrOffsetCSS, v);
			} 
			limit++;
		}
		for(i=1;i<=arraylen(arrOffsetCSS);i++){
			arrayAppend(arrCSS, arrOffsetCSS[i]);
		}

		for(i=startFontSize;i<=70;i++){ 
			tempScaleHeading=max(round(i*dataStruct.headingScale), dataStruct.headingMinimumFontSize);
			tempScaleText=max(round(i*dataStruct.textScale), dataStruct.textMinimumFontSize); 
			if(n EQ 1){
				v='.z-fh-#i#{font-size:#i#px !important;  padding-bottom:#round(max(dataStruct.minimumPadding, i*0.45))#px !important;}';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}
				v='.z-ft-#i#{font-size:#i#px !important; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				} 
			}
			v='.z-h-#i#{font-size:#tempScaleHeading#px;  padding-bottom:#round(max(dataStruct.minimumPadding, tempScaleHeading*0.45))#px;}';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS, v);
			}
			v='.z-t-#i#{font-size:#tempScaleText#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS, v);
			} 
			headingEnabled=0; 
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
				v='h#headingEnabled#{font-size:#tempScaleHeading#px; padding-bottom:#round(max(dataStruct.minimumPadding, tempScaleHeading*0.45))#px;}';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}
			} 
		}
	}   
	savecontent variable="out"{
		for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
			breakpoint=breakStruct.arrBreak[i];  
			if(breakpoint NEQ 'Default'){
				echo('@media screen and (max-width: #breakpoint#px) {'&chr(10)); 
				echo(arrayToList(breakStruct.css[breakpoint], chr(10))&chr(10)); 
				echo('}'&chr(10));
			}else{
				echo(arrayToList(breakStruct.css[breakpoint], chr(10))&chr(10)); 
			}
		}  
		arrCSS2=[];
		for(g=0;g<=15;g++){
			c=g*10; 
			v='.z-fp-#c#{ padding-left:#c#px; padding-right:#c#px; padding-top:#c#px; padding-bottom:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v); 
			} 
			v='.z-fpt-#c#{ padding-top:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fpr-#c#{ padding-right:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fpb-#c#{ padding-bottom:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fpl-#c#{ padding-left:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fpv-#c#{ padding-top:#c#px; padding-bottom:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fph-#c#{ padding-left:#c#px; padding-right:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fm-#c#{ margin-left:#c#px; margin-right:#c#px; margin-top:#c#px; margin-bottom:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fmt-#c#{ margin-top:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fmr-#c#{ margin-right:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fmb-#c#{ margin-bottom:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fml-#c#{ margin-left:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fmv-#c#{ margin-top:#c#px; margin-bottom:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fmh-#c#{ margin-left:#c#px; margin-right:#c#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fmv-#c#-auto{ margin-top:#c#px; margin-bottom:#c#px; margin-left:auto; margin-right:auto; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
			v='.z-fmh-#c#-auto{ margin-left:#c#px; margin-right:#c#px; margin-top:auto; margin-bottom:auto; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS2, v);
			} 
		}
		echo(arrayToList(arrCSS2, chr(10)));
		uniqueStruct={};
		for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
			breakpoint=breakStruct.arrBreak[i];   
			dataStruct=breakStruct.data[breakpoint];
			multiplier=0;
			arrCSS2=[];
		 	for(g=0;g<=15;g++){
		 		if(g EQ 1){
		 			multiplier=0.8;
		 		}
		 		pt=dataStruct.boxPaddingTopPercent*multiplier;
		 		pb=dataStruct.boxPaddingBottomPercent*multiplier;
		 		ph=dataStruct.boxPaddingSidePercent*multiplier;
		 		mt=dataStruct.boxMarginTopPercent*multiplier;
		 		mb=dataStruct.boxMarginBottomPercent*multiplier;
		 		mh=dataStruct.boxMarginSidePercent*multiplier;
		 		v='.z-p-#g*10#{ padding-left:#ph#%; padding-right:#ph#%; padding-top:#pt#%; padding-bottom:#pb#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v); 
				} 
				v='.z-pt-#g*10#{ padding-top:#pt#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-pr-#g*10#{ padding-right:#ph#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-pb-#g*10#{ padding-bottom:#pb#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-pl-#g*10#{ padding-left:#ph#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-pv-#g*10#{ padding-top:#pt#%; padding-bottom:#pb#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-ph-#g*10#{ padding-left:#ph#%; padding-right:#ph#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-m-#g*10#{ margin-left:#ph#%; margin-right:#ph#%; margin-top:#pt#%; margin-bottom:#pb#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mt-#g*10#{ margin-top:#pt#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mr-#g*10#{ margin-right:#ph#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mb-#g*10#{ margin-bottom:#pb#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-ml-#g*10#{ margin-left:#ph#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mv-#g*10#{ margin-top:#pt#%; margin-bottom:#pb#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mh-#g*10#{ margin-left:#ph#%; margin-right:#ph#%; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mv-#g*10#-auto{ margin-top:#pt#%; margin-bottom:#pb#%; margin-left:auto; margin-right:auto; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mh-#g*10#-auto{ margin-left:#ph#%; margin-right:#ph#%; margin-top:auto; margin-bottom:auto; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				multiplier+=0.8; 
			}
			if(breakpoint NEQ 'Default'){
				echo('@media screen and (max-width: #breakpoint#px) {'&chr(10)); 
				echo(arrayToList(arrCSS2, chr(10))&chr(10)); 
				echo('}'&chr(10));
			}else{
				echo(arrayToList(arrCSS2, chr(10))&chr(10)); 
			}
		}  
		echo('.z-width-fill, .z-fill-width{display:table-cell; direction:ltr; width:10000px; float:none;}');
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
echo('<h2 class="z-fh-30">Instance Layout Settings</h2>');

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
	breakStruct.minimum_column_width=application.zcore.functions.zso(oldBreakStruct, 'minimum_column_width', true, 150);
}
echo('<h2 class="z-fh-30">Global Layout Settings</h2>');
echo('<p>You must include the following stylesheet in your template to make use of this feature: /zupload/layout-global.css</p>');
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
	indentScale:"Indent Scale",
	boxPaddingTopPercent:"Box Padding Top %",
	boxPaddingSidePercent:"Box Padding Side %",
	boxPaddingBottomPercent:"Box Padding Bottom %",
	boxMarginTopPercent:"Box Margin Top %",
	boxMarginSidePercent:"Box Margin Side %",
	boxMarginBottomPercent:"Box Margin Bottom %",
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
echo('<div style="width:100%; overflow:auto; font-size:14px !important; float:left; padding-left:5px; padding-right:5px;">
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
		echo('<td><input type="text" name="#id#" value="'&dataStruct[i]&'" style="font-size:14px; width:70px;min-width:70px;" /></td>');
	}
	echo('</tr>');
}

minimum_column_width=application.zcore.functions.zso(breakStruct, 'minimum_column_width');
echo('<tr>
	<th>&nbsp;</th>
	<td colspan="#structcount(defaultBreakPoint)#">
	Column width that triggers single column below 992: <input type="text" name="minimum_column_width" style="font-size:14px; max-width:100px; min-width:100px;" value="#htmleditformat(minimum_column_width)#"><br />
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
	 
	echo('<h2 class="z-fh-30">Layout Example</h2>');
	application.zcore.skin.includeCSS("/zupload/layout-global.css"); 
	</cfscript>  
	<style type="text/css">
	.zapp-shell-container{padding-left:0px; padding-right:0px;}
	section:nth-child(even){ background-color:##555;}
	section:nth-child(odd){ background-color:##666;}
	section section{background:none;}
	.z-container{ background-color:##aaa;}
	.z-fill-width, .z-container div, .z-column { background-color:##EEE !important;}
	.z-left-sidebar, .z-right-sidebar{ background-color:##ccc !important;}

	</style>
<div class="wrapper">
	<section>
		<div class="z-container"> 
			<div class="z-column">
				For visualizing space adjustments, background colors have been applied. Dark = section, medium = z-container, lightest = z-column
			</div> 
		</div> 
	</section>
	<section>
		<div class="z-container z-pv-10">
			<div class="z-column " > 
				Each grid system can have columns that span 1 or more of the columns. Examples:
			</div>
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container z-center-children"> 
			<div class="z-1of4 " > 
				<div class="z-h-24">z-1of4</div>
				<div class="z-t-16">Text</div> 
			</div>
			<div class="z-2of4 " > 
				<div class="z-h-24">z-2of4</div>
				<div class="z-t-16">Text</div>
			</div> 
			<div class="z-1of4" > 
				<div class="z-h-24">z-1of4</div>
				<div class="z-t-16">Text</div>
			</div> 
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container z-center-children"> 
				<div class="z-1of3" > 
					<div class="z-h-24">z-1of3</div>
					<div class="z-t-16">Text</div>
				</div>
				<div class="z-2of3"> 
					<div class="z-h-24">z-2of3</div>
					<div class="z-t-16">Text</div> 
				</div> 
			</div>
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container z-center-children"> 
				<div class="z-4of4" > 
					<div class="z-h-24">z-4of4</div>
					<div class="z-t-16">Text</div> 
				</div>
			</div>
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container z-center-children"> 
				<div class="z-column" > 
					<h2>All Grid Systems</h2>
				</div>
			</div>
		</div>
	</section>
	<cfloop from="2" to="16" index="i">
		<cfscript>
		if(i gt 7 and i NEQ 12 and i NEQ 16){
			continue;
		}
		</cfscript>

		<section class="z-pv-10">
			<div class="z-container z-center-children"> 
				<div class="z-column z-h-18">#i# column grid system ( class="z-1of#i#" )</div> 
				<section class="z-center-children z-pv-10"> 
					<cfloop from="1" to="#i#" index="n">
						<div class="z-1of#i#" > 
							<div class="z-h-16">#n#</div>
						</div>
					</cfloop>
				</section>
			</div>
		</section>
	</cfloop> 

	<section class="z-pv-10">
		<div class="z-container">
			<div class="z-column z-h-18">Right sidebar with automatic fill width column</div> 
		</div>
		<div class="z-container z-mv-10"> 
			<div class="z-column z-p-0">
				<aside class="z-column z-fill-width">
					z-column and z-fill-width
				</aside>
				<section class="z-1of4 z-right-sidebar">
					z-1of4 and z-right-sidebar
				</section>
			</div> 
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container">
			<div class="z-column z-h-18">Left sidebar with automatic fill width column and reverse order html</div> 
		</div>
		<div class="z-container z-mv-10"> 
			<div class="z-column z-reverse-order z-p-0">
				<section class="z-column z-fill-width">
					z-column and z-fill-width
				</section>
				<aside class="z-1of4 z-left-sidebar">
					z-1of4 and z-left-sidebar
				</aside> 
			</div>
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container z-mv-10">
			<div class="z-column z-h-18">Responsive Heading and Text Classes</div> 
		</div>
		<div class="z-container z-center-children z-equal-heights" data-column-count="3"> 
		 	<div class="z-1of3">
				<div class="z-h-36">
					z-h-36
				</div>  
				<div class="z-h-30">
					z-h-30
				</div>  
				<div class="z-h-24">
					z-h-24
				</div> 
				<div class="z-h-18">
					z-h-18
				</div>  
				<div class="z-h-14">
					z-h-14
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
				<div class=" z-t-36">
				z-t-36
				</div> 
				<div class=" z-t-24">
				z-t-24
				</div> 
				<div class=" z-t-18">
				z-t-18
				</div>  
			</div>
		</div>
		<div class="z-container z-mv-10">
			<div class="z-column z-h-18">Fixed Size Heading and Text Classes</div> 
		</div>

		<div class="z-container z-center-children z-equal-heights" data-column-count="3"> 
		 	<div class="z-1of3">
				<div class="z-fh-36">
					z-fh-36
				</div>  
				<div class="z-fh-30">
					z-fh-30
				</div>  
				<div class="z-fh-24">
					z-fh-24
				</div> 
				<div class="z-fh-18">
					z-fh-18
				</div>  
				<div class="z-fh-14">
					z-fh-14
				</div>  
			</div>
			<div class="z-1of3">
				<h1 class="z-fh-36">Heading1</h1>
				<h2 class="z-fh-30">Heading2</h2>
				<h3 class="z-fh-24">Heading3</h3> 
				<h4 class="z-fh-18">Heading4</h4>
				<h5 class="z-fh-14">Heading5</h5>
			</div>
			<div class="z-1of3">
				<div class=" z-ft-36">
				z-ft-36
				</div> 
				<div class=" z-ft-24">
				z-ft-24
				</div> 
				<div class=" z-ft-18">
				z-ft-18
				</div>  
			</div>
		</div>
	</section>  
</div>
</cffunction>
	
</cfoutput>
</cfcomponent>