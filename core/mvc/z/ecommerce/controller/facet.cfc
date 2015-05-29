<cfcomponent output="yes">
<cfoutput>
<cffunction name="showProgress" access="remote" localmode="modern">
	<cfscript>
	echo("Progress:"&application.zcore.functions.zso(application, 'progress1'));
	abort;
</cfscript>
</cffunction>
<cffunction name="index" access="remote" localmode="modern"> 
	disabled<cfabort>
	<cfsavecontent variable="out">
	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut porta, urna ut cursus bibendum, quam ligula sollicitudin tortor, sit amet aliquam lacus purus a sapien. Morbi facilisis, libero sit amet molestie facilisis, metus sapien pharetra est, quis porttitor tortor libero eget neque. Nunc in pulvinar orci. Cras rhoncus velit eu mi fermentum dignissim. Interdum et malesuada fames ac ante ipsum primis in faucibus. Donec et accumsan tortor, vitae scelerisque urna. Nunc hendrerit sagittis tellus, luctus finibus purus suscipit vitae. Cras egestas ipsum est. Praesent in diam odio. Duis vel dolor purus.

Nullam fermentum mattis nulla sit amet lacinia. Nam ac ligula arcu. Integer egestas felis velit, quis cursus dolor consectetur sed. Aenean porta bibendum leo, ut sodales lacus vehicula at. Praesent suscipit dapibus velit, at laoreet eros sollicitudin sed. Quisque quis ex nec libero vulputate venenatis eu at lorem. Praesent mollis sit amet elit sit amet dignissim. Praesent ornare nulla ex, sed varius dolor scelerisque ut. Suspendisse sollicitudin mi eget tellus aliquet mollis. Praesent porta iaculis metus vitae venenatis. Nullam posuere risus gravida erat consequat aliquam. Morbi mattis, purus eget vestibulum lacinia, nisi lacus facilisis tellus, id feugiat leo lacus ut tellus. Sed non dui scelerisque, feugiat lectus vel, viverra tortor.

Ut in est nec arcu ullamcorper malesuada. Nulla facilisi. Suspendisse laoreet accumsan arcu ac fringilla. Etiam eget tellus viverra, interdum diam nec, congue sem. Cras efficitur dolor in facilisis egestas. Ut at leo posuere, sollicitudin ex vitae, interdum urna. Nulla quis nulla varius, sodales est vitae, gravida ante. Vestibulum ultricies lacus at massa tempor vestibulum. Nullam ullamcorper fringilla nunc, a auctor leo viverra quis. Donec accumsan neque tristique porta sodales. Praesent sed gravida libero. Nam rutrum sit amet nulla eget sagittis. Aliquam rutrum euismod tempus. Morbi accumsan metus ac ex ullamcorper, finibus eleifend risus efficitur. Mauris pharetra posuere justo eu efficitur. Donec bibendum eros sed leo efficitur fringilla.
</cfsavecontent>
	<cfscript>

setting requesttimeout="10000";
	db=request.zos.queryobject;

	for(i=1;i LTE 50000;i++){ 
		application.progress1=i;
		arrText=[];
		facetCount=randrange(1, 5);
		for(f=1;f LTE facetCount;f++){
			arrayAppend(arrText, ":facet"&f&":"&randrange(1, 50)&"|");
		} 

		paraLen=len(out);
		wordCount=max(20, randrange(1, 60));

		for(f=1;f LTE wordCount;f++){
			wordLen=randrange(4, 20);
			position=randrange(1, paraLen-wordLen);
			arrayAppend(arrText, mid(out, position, wordLen));
		}

		t9={
			table:"a5",
			datasource:"monterey",
			struct:{ a5_name:"dname "&i, a5_text:arrayToList(arrText, "") }
		};
		application.zcore.functions.zInsert(t9);
	}
	echo('done');
	abort;
	</cfscript>
	
</cffunction>


</cfoutput>
</cfcomponent>