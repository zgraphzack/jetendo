<cfcomponent implements="zcorerootmapping.interface.widget" extends="zcorerootmapping.com.widget.baseWidget"> 
<cfoutput>  
<cffunction name="getHTML" localmode="modern" access="public" output="no"> 
	<cfargument name="dataFields" type="struct" required="yes">
	<cfscript>
	ds=arguments.dataFields;
	</cfscript>
	<cfsavecontent variable="out">
		<div class="test-example-1 zForceEqualHeights">
			<div class="test-example-2">
				<div class="test-example-3">#ds.Heading#</div>
				<div class="test-example-4">
					#ds["Body Text"]#
				</div>
			</div>
			<div class="test-example-5">
				<cfif ds["Image"] NEQ ""> 
					<img class="test-example-6" src="#ds["Image"]#" alt="Broker">
				</cfif>
			</div>
		</div>
	</cfsavecontent>
	<cfscript>
	return out;
	</cfscript>
</cffunction>
	
<cffunction name="getJS" localmode="modern" access="public" output="no">  
	<cfargument name="dataFields" type="struct" required="yes">
	<script type="text/javascript">
	<cfsavecontent variable="out">
	zArrDeferredFunctions.push(function(){
		var e="testWidgetJS - #arguments.dataFields.widgetContainer#";
		console.log(e);
	});
	</cfsavecontent>
	</script>
	<cfscript>
	return out;
	</cfscript>
</cffunction>
	
<cffunction name="getCSS" localmode="modern" access="public" output="no"> 
	<cfargument name="layoutFields" type="struct" required="yes">
	<cfscript>
	cs=arguments.layoutFields;
	c=cs.widgetContainer;
	/*
	// implement this:
	return application.zcore.functions.zReadFile("/path/to/css.css");

	// or this
	css="";
	return css;
	*/

 	fs=cs["Font Scale"];
	</cfscript> 
<style type="text/css">
<cfsavecontent variable="out">
#c# .test-example-1{ 
	padding:#round(cs["Container Padding"]*20)#px;
}
#c# .test-example-2{width:#round(cs["Left Column Width %"]*100)#%; padding-right:#cs["Column Gap"]#px;} 
#c# .test-example-5{width:#round((1-cs["Left Column Width %"])*100)#%;}
#c# .test-example-3{ font-size:#round(fs*36)#px; line-height:#round(fs*42)#px;}
#c# .test-example-4{ font-size:#round(fs*18)#px; line-height:#round(fs*24)#px;}
@media only screen and (max-width: 1200px) { 
#c# .test-example-3{ font-size:#round(fs*30)#px; line-height:#round(fs*36)#px; }
#c# .test-example-4{ font-size:#round(fs*16)#px; line-height:#round(fs*21)#px;}


}
@media only screen and (max-width: 960px) { 
#c# .test-example-4{ font-size:#round(fs*14)#px; line-height:#round(fs*18)#px;} 
#c# .test-example-3{ font-size:#round(fs*24)#px; line-height:#round(fs*30)#px;}
#c# .test-example-2{padding-bottom:#cs["Column Gap"]#px;}
#c# .test-example-5{width:100%;}
}
</cfsavecontent>
</style>
	<cfscript>
	return out;
	</cfscript>
</cffunction>


	
<cffunction name="getConfig" localmode="modern" access="public" output="no">
	<cfscript>
	cs={};
	cs.id="1";
	cs.name="Widget Example";
	cs.codeName="widget-example";
	cs.version=1;
	cs.arrStylesheet=["/z/a/widget/widget-example.css"];
 	// made there should be "previewValue" key below for dataFields

 	// TODO: need to support nested forms for recursive data
	cs.dataFields=[
		{
			id:"1",
			label:"Heading",
			type:"Text",
			required:true,
			defaultValue:"",
			previewValue:"Heading",
			options:{}
		},
		{
			id:"2",
			label:"Body Text",
			type:"HTML Editor",
			defaultValue:"",
			previewValue:"<p>Body Text</p>",
			options:{
				editorwidth:600,
				editorheight:300
			}
		},
		{
			id:"3",
			label:"Image",
			type:"Image",
			defaultValue:"",
			previewValue:application.zcore.functions.zGetImagePlaceholderURL(600, 600),
			options:{
				imagewidth:600,
				imageheight:600,
				imagecrop:0,
				imagemaskpath:""
			}
		}
	];
	cs.layoutFields=[
		{
			id:"1",
			label:"Font Scale", 
			type:'Slider',
			required:true,
			defaultValue:1,
			previewValue:1,
			options:{
				slider_from:0.5,
				slider_to:3,
				slider_step:0.1,
			}
		},
		{
			id:"2",
			label:"Container Padding", 
			type:'Slider',
			required:true,
			defaultValue:1,
			previewValue:1,
			options:{
				slider_from:0.5,
				slider_to:3,
				slider_step:0.1,
			}
		},
		{
			id:"3",
			label:"Left Column Width %", 
			type:'Slider',
			required:true,
			defaultValue:0.5,
			previewValue:0.5,
			options:{
				slider_from:0.1,
				slider_to:1,
				slider_step:0.05,
			}
		},
		{
			id:"4",
			label:"Column Gap", 
			type:'Number',
			required:true,
			defaultValue:10,
			previewValue:10,
			options:{
			}
		}
	];
	return cs;
	</cfscript>
</cffunction>


<cffunction name="upgrade" localmode="modern" access="public" output="no">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="jsonStruct" type="struct" required="yes">
	<cfscript>
	ds=arguments.dataStruct; 
	if(ds.widget_version EQ 1){
		// upgrade to version 2

		ds.widget_version=2;
	}
	return ds;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>