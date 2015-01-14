<cfcomponent>
<cfoutput>
<cffunction name="index" access="public" localmode="modern">
<p>Purpose: Provides session memory storage for temporary messages and data that must be sent between requests.</p>
  <p>Version: 0.1.002</p>
  <p>Language(s) used: ColdFusion Markup Language (CFML)</p>
   <p>Project Home Page: <a href="https://www.jetendo.com/z/admin/manual/view/9.2.3/status-dot-cfc.html">https://www.jetendo.com/z/admin/manual/view/9.2.3/status-dot-cfc.html</a></p>
  
   <p>GitHub Home Page: <a href="https://github.com/jetendo/status-dot-cfc" target="_blank">https://github.com/jetendo/status-dot-cfc</a></p>
  <h2>Outline</h2>
  <ul>
  <li><a href="##whyuse">Why use status-dot-cfc?</a></li>
  <li><a href="##moreon">More docs on the way</a></li>
  </ul>

<h2 id="whyuse">Why use status-dot-cfc?</h2>
<p>This project is used extensively in Jetendo CMS to pass status messages and form data between pages.  When a user submits a large form, the data may exceed the maximum URL length if you use a <code>get</code> http request, so this means you need to use the <code>post</code> method instead.  One of the problems with a post request is that any repeat visits to the page will ask the user for permission to repost the data they submitted.  This makes the application appear broken or harder to use with the back or refresh button of the browser.</p>
<p>To get around this problem, you can use a 302 redirect header to instruct the server to redirect to another URL after processing the posted form data.  Now the back button will work as expected without asking the user for permission to repost data.  However, the posted data is lost unless you somehow stored or sent it to the page you directed to.  Sometimes you need the posted data to be redisplayed such as when you need to display validation error messages and re-popular the form fields with the data the user entered.</p>
<p>This is where status-dot-cfc becomes useful. status-dot-cfc makes it easy to pass a large amount of messages and data between requests by storing this information in session memory and assigning it a unique id.  Once stored, you only need to pass the ID to the new page, and you'll have access to all the data you had created on the previous page as native CFML data structures.  This saves you from needing to write database storage or custom session memory code.</p>

<h2 id="moreon">More docs on the way</h2>
<p>Some limited documentation is provided by the examples included on the GitHub download.  More will be provided here in the future.</p>

<!---   <cfscript>request.manual.codeExample("using-cfquery.cfm");</cfscript> --->

<h2>License</h2>
<p>Copyright &copy; 2013 Far Beyond Code LLC.</p>

<p>cssSpriteMap-dot-cfc is Open Source under the MIT license<br />
  <a href="http://www.opensource.org/licenses/mit-license.php" target="_blank">http://www.opensource.org/licenses/mit-license.php</a></p>
</cffunction>
</cfoutput>
</cfcomponent>