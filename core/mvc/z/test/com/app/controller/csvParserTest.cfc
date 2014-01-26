<!--- 
/z/test/com/app/csvParserTest/runTestRemote
 --->

<cfcomponent extends="mxunit.framework.TestCase">

<!--- this will run before every single test in this test case --->
<cffunction name="setUp" localmode="modern" returntype="void" access="public" hint="put things here that you want to run before each test">

</cffunction>

<!--- this will run after every single test in this test case --->
<cffunction name="tearDown" localmode="modern" returntype="void" access="public" hint="put things here that you want to run after each test">

</cffunction>

<!--- this will run once after initialization and before setUp() --->
<cffunction name="beforeTests" localmode="modern" returntype="void" access="public" hint="put things here that you want to run before all tests">
</cffunction>

<cffunction name="parseLine" localmode="modern" returntype="void" access="public">
	<cfscript> 
	var arrCsvString=0;   
	var i=0; 
	var n=0; 
	var arrTemp=0;
	var row=0;  
	var csvParser=createObject("component", "zcorerootmapping.com.app.csvParser");
	csvParser.pathToOstermillerCSVParserJar=application.zcore.railowebinfpath&"lib/ostermillerutils.jar";
	csvParser.enableJava=false;
	csvParser.arrColumn=["Col1","Col2","Col3"];
	csvParser.defaultStruct={};
	for(i=1;i LTE arraylen(csvParser.arrColumn);i++){
		csvParser.defaultStruct[csvParser.arrColumn[i]]="";
	} 
	arrCsvString=[
		'',
		"'','','',''",
		"'Test33','Test2','T''es''t3'",
		"two,two,two",
	];
	csvParser.separator=",";
	csvParser.textQualifier="'";
	csvParser.escapedBy="'";
	csvParser.init();
	local.s=gettickcount(); 
	for(i=1;i LTE arraylen(arrCsvString);i++){
		row=csvParser.parseLineIntoStruct(arrCsvString[i]);
		assert(structcount(row) EQ 3);
	}  
	arrCsvString=[
		"tab#chr(9)#tab#chr(9)#tab",
		"tab#chr(9)#tab#chr(9)#tab",
	];
	csvParser.separator=chr(9);
	csvParser.textQualifier="";
	csvParser.escapedBy="";
	csvParser.init(); 
	for(i=1;i LTE arraylen(arrCsvString);i++){
		row=csvParser.parseLineIntoStruct(arrCsvString[i]);
		assert(structcount(row) EQ 3);
	} 
	csvParser.separator=",";
	csvParser.textQualifier='"';
	csvParser.escapedBy='"';
	csvParser.init(); 
	arrCsvString=[
		'"Test22","Test2",Test3',
		'"Test33",Test2,"T""es""t3"',
	]; 
	for(i=1;i LTE arraylen(arrCsvString);i++){
		arrTemp=csvParser.parseLineIntoArray(arrCsvString[i]); 
		assert(arrayLen(arrTemp) EQ 3); 
	} 
	arrCsvString=[
		"tab#chr(9)#tab#chr(9)#tab",
		"tab#chr(9)#tab#chr(9)#tab",
	];
	csvParser.separator=chr(9);
	csvParser.textQualifier="";
	csvParser.escapedBy="";
	csvParser.init();  
	for(i=1;i LTE arraylen(arrCsvString);i++){
		arrTemp=csvParser.parseLineIntoArray(arrCsvString[i]); 
		assert(arrayLen(arrTemp) EQ 3); 
	} 
	</cfscript>
</cffunction>

<!--- this will run once after all tests have been run --->
<cffunction name="afterTests" localmode="modern" returntype="void" access="public" hint="put things here that you want to run after all tests">

</cffunction> 
</cfcomponent>