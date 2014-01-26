<cfcomponent hint="csvParser - uses cfml string parsing, simple listToArray or java depending on configuration.">
<cfscript>
this.enableJava=true;
this.arrColumn=[];
this.defaultStruct={};
this.separator=",";
this.textQualifier='"';
this.escapedBy='"';
this.pathToOstermillerCSVParserJar="";
</cfscript>
<cffunction name="init" localmode="modern" access="public" output="no">
	<cfscript>
	var i=0;
	variables.initRan=true;
	
	if(len(this.textQualifier) GT 1){
		throw('this.textQualifier must be an empty string or one character');
	}
	if(len(this.separator) GT 1){
		throw('this.separator must be only one character');
	}
	if(len(this.escapedBy) GT 1){
		throw('this.escapedBy must be an empty string or one character');
	}
	if(arrayLen(this.arrColumn) EQ 0){
		throw('You must set this.arrColumn');	
	} 
	for(i=1;i LTE arrayLen(this.arrColumn);i++){
		if(not structkeyexists(this.defaultStruct, this.arrColumn[i])){
			this.defaultStruct[this.arrColumn[i]]="";
			//throw('#this.arrColumn[i]# exists in this.arrColumn[i], but it is missing in this.defaultStruct.');
		}
	}
	if(this.enableJava){
		if(this.pathToOstermillerCSVParserJar EQ "" or not fileexists(this.pathToOstermillerCSVParserJar)){
			throw("this.pathToOstermillerCSVParserJar, ""#this.pathToOstermillerCSVParserJar#"", must be a valid file path when this.enableJava = true.");
		}
		if(not structkeyexists(variables, 'csvParser')){
			variables.stringReader = createObject("java", "java.io.StringReader").init('');
			variables.csvParser = createObject( "java", "com.Ostermiller.util.CSVParser", this.pathToOstermillerCSVParserJar ); 
			variables.csvParser.init(variables.stringReader);
		}
		variables.csvParser.changeDelimiter(this.separator);
		if(this.textQualifier EQ ""){
			variables.csvParser.changeQuote(''); // the character in the empty string/blank is not a space - it is: alt + 031 
			variables.csvParser.setEscapes('', '');
		}else{
			variables.csvParser.setEscapes("nrtf", "\n\r\t\f");
			variables.csvParser.changeQuote(this.textQualifier);
		}
	} 
	</cfscript>
</cffunction>

<cffunction name="parseLineIntoStruct" localmode="modern" access="public" returntype="struct" output="no">
	<cfargument name="csvString" type="string" required="yes">
	<cfscript>
	var arrList=this.parseLineIntoArray(arguments.csvString);
	var ts=duplicate(this.defaultStruct);
	var i=0;
	var count=min(arrayLen(arrList), arraylen(this.arrColumn)); 
	for(i=1;i LTE count;i++){
		ts[this.arrColumn[i]]=arrList[i];
	}
	return ts;
	</cfscript>
</cffunction>
	
<cffunction name="parseLineIntoArray" localmode="modern" access="public" returntype="array" output="no">
	<cfargument name="csvString" type="string" required="yes">
	<cfscript>
	var inQuote=false;
	var i=0;
	var letter=0;
	var arrFields=0;
	var line=arguments.csvString;
	var field=0;
	var fieldStart=1; 
	var arrList = ArrayNew(1);
	var currentGroupId=0;  
	if(not structkeyexists(variables, 'initRan')){
		throw("You must run csvParser.init() before csvParser.parseLine();");
	}
	if(this.textQualifier EQ ""){
		arrFields=listToArray(arguments.csvString, this.separator, true);
	}else{
		if(this.enableJava){
			arrList=variables.csvParser.parse(arguments.csvString);  
			arrFields=arrList[1];
		}else{
			inQuote=false;
			arrFields=ArrayNew(1);
			fieldStart=1;
			for(i=1;i LTE len(line);i=i+1){
				letter = mid(line,i,1);
				if(inQuote){
					if(letter EQ this.textQualifier and (fieldStart EQ i or (mid(line,i+1,1) NEQ this.escapedBy))){
						if(mid(line,i+1,1) EQ this.separator or i+1 GTE len(line)){
							inQuote=false;
							field = mid(line,fieldStart,(i-fieldStart));
							// unescape double quotes
							if(this.escapedBy NEQ ''){
								field = replace(field,this.escapedBy&this.textQualifier,this.textQualifier,"ALL");
							}
							ArrayAppend(arrFields,field);
							fieldStart=i+1;
						}
					}
				}else{
					if(letter EQ this.textQualifier and fieldStart EQ i){
						inQuote=true;
						fieldStart=i+1;
					}else if(letter EQ this.separator){
						if(i EQ 1 or mid(line,i-1,1) EQ this.separator){
							ArrayAppend(arrFields,'');
						}else if(fieldStart NEQ i){
							field = mid(line,fieldStart,(i-fieldStart));
							ArrayAppend(arrFields,field);
						}
						if(i+1 EQ len(line)){
							ArrayAppend(arrFields,'');
						}
						fieldStart=i+1;
					}else if(i EQ len(line) and fieldStart NEQ i){
						field = mid(line,fieldStart,(i-fieldStart)+1);
						ArrayAppend(arrFields,field);
					}
				}
			}
			if(right(line,1) EQ this.separator){
				ArrayAppend(arrFields,'');
			}  
		}
	}
	return arrFields;
	</cfscript>
</cffunction>
</cfcomponent>