<cfcomponent>
<cfoutput>
<cffunction name="spellCheck" localmode="modern" access="remote" roles="member">
	<cfscript>
	</cfscript>
	<div style="max-width:960px;float:left; font-size:18px; line-height:30px;"> 
	<h1>Add advanced spell checking &amp; grammar support</h1>
	<p>Your web site is often the first impression your visitors have with your company.  Not all of us are blessed with perfect spelling and grammar as we work throughout the day.  That's why using tools to help support you is important.</p>
	<p>The text fields throughout the web site manager now support your browser's native spell checking if it is available & enabled.  However, if you want something more robust, we have found a better solution.</p>
	<p>We are recommending you install the free browser extension "<strong>Grammarly Lite</strong>" to have a spell check and grammar correction tool that works anywhere you manage content on the web.</p>
	<h2 style="font-size:24px; line-height:30px;">You can install Grammarly Lite for <a href="http://www.grammarly.com/download/chrome" target="_blank">Chrome</a>, 
	<a href="http://www.grammarly.com/download/firefox" target="_blank">Firefox</a> or
	<a href="http://www.grammarly.com/download/safari">Safari</a>.</h2>
	<p>Grammarly Lite is free software enjoyed by over 3 million people across the world.  It shouldn't cause annoying ads or additional costs for you over time for its free features.</p>
	<p>Grammarly Lite is not available for Internet Explorer.  It is highly recommended you install <a href="http://www.google.com/chrome/‎" target="_blank">Chrome</a> or 
	<a href="http://www.firefox.com/" target="_blank">Firefox</a> when managing your web site as these browsers are better supported and provide superior features.</p>
	<p>If you have trouble with any of these links, let your web developer know.</p>
	<h2 style="font-size:24px; line-height:30px;">Want the most advanced plagiarism and proofreading tool?<br />
	<a href="#request.zos.grammarlyTrackingURL#" target="_blank">Upgrade to Grammarly Pro</a></h2>
	<ul>
	<li>Grammarly Pro features grammar, punctuation and style correction features that can catch more errors then Microsoft&reg; Word and other word processors.</li>
	<li>You can purchase an individual subscription for grammarly and it works pretty much anywhere you write in text boxes throughout the web.</li>
	<li>Learn to write better English on your other online accounts such as webmail, Facebook, Twitter.</li>
	 <li>Avoid plagiarism and choose better words via the thesaurus features.</li>
	 </ul>
	<p>Interested in Grammarly Pro? Signup for the 7 day free trial at <a href="#request.zos.grammarlyTrackingURL#" target="_blank">http://www.grammarly.com/</a> to help you decide if it is worth the price to improve the professionalism of your communications.</p> 
	</div>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.zSetPageHelpId("1");
	application.zcore.functions.zstatushandler(request.zsid);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>