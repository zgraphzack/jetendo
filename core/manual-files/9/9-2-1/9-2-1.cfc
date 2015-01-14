<cfcomponent>
<cfoutput>
<cffunction name="index" access="public" localmode="modern">
<p>Purpose: Enhances cfquery by analyzing SQL to enforce security &amp; framework conventions.</p>
  <p>Version: 0.1.001</p>
  <p>Language(s) used: ColdFusion Markup Language (CFML)</p>
   <p>Project Home Page: <a href="https://www.jetendo.com/z/admin/manual/view/9.2.1/db-dot-cfc.html">https://www.jetendo.com/z/admin/manual/view/9.2.1/db-dot-cfc.html</a></p>
  
   <p>GitHub Home Page: <a href="https://github.com/jetendo/db-dot-cfc" target="_blank">https://github.com/jetendo/db-dot-cfc</a></p>
  <h2>Outline</h2>
  <ul>
  <li><a href="##whyuse">Why use db-dot-cfc?</a></li>
  <li><a href="##cfqueryvs">cfquery vs db-dot-cfc</a></li>
  <li><a href="##security">Security</a></li>
  <li><a href="##partialsql">Partial SQL parsing</a></li>
  <li><a href="##performance">Performance</a></li>
  <li><a href="##compatibility">Compatibility</a></li>
  <li><a href="##dbcfcoptions">db-dot-cfc Options Reference</a></li>
  <li><a href="##functionref">Function Reference</a></li>
  </ul>

<h2 id="whyuse">Why use db-dot-cfc?</h2>
<p>
  The <code>&lt;cfquery&gt;</code> tag is very simple to use and provides the basic requirements needed to do database work.  However, in a larger application, you may want to augment <code>&lt;cfquery&gt;</code> with additional features, yet not cause your CFML code for queries to be more verbose or harder to understand.   Queries should be easy to write, secure, fast and follow the conventions set forth by your framework/application.  db-dot-cfc provides enhancements that go beyond <code>&lt;cfquery&gt;</code>, yet it strives to retain the simplicity of cfquery.<br />
</p>
<h2 id="cfqueryvs">cfquery vs db-dot-cfc</h2>
<p>Using cfquery</p>
  <cfscript>request.manual.codeExample("using-cfquery.cfm");</cfscript>
  
<p>Using db-dot-cfc</p>
  <cfscript>request.manual.codeExample("using-db-cfc.cfm");</cfscript>
<p>If you were to <code>writeoutput(q.sql);</code> before running <code>q.execute()</code>, you'd see it looks like this:</p>
  <cfscript>request.manual.codeExample("sql.sql");</cfscript>
  
  <br />
  The SQL is transformed when <code>q.execute()</code> runs to be the same as the <code>&lt;cfquery&gt;</code> example.<br />
<br />
  Continue reading the db-dot-cfc documentation to understand all its features.<br />
<br />
  <h2 id="security">Security</h2>
  <p>This was the primary reason for making db-dot-cfc.  The goal was to prevent a developer (including myself) from writing an insecure query by coming up with a way to detect mistakes.  It's very easy to mistakenly write a query that could allow a SQL Injection attack.  In my app, I use a User Defined Function (UDF) instead of <code>&lt;cfquery&gt;</code> directly because I have many features that depend on changing the behavior of <code>&lt;cfquery&gt;</code>.   It has been difficult prior to making db-dot-cfc to ensure that all variables are escaped properly.  Now with db-dot-cfc, I just need to update these queries to use db-dot-cfc and it will prevent me from making the most sql validation mistakes. </p>
<p>db-dot-cfc allows you to bypass it's protection when you get into writing something more advanced by using <code>dbQuery.trustedSQL()</code>.  You need to be very careful that you are doing things correctly when you disable the SQL validation provided by db-dot-cfc.</p>
<p>There are a wide range of SQL security problems which can be automatically detected. db-dot-cfc throws exceptions when it finds a problem, rather then allow executing a possibly dangerous query.  db-dot-cfc analyzes the SQL to detect parameters that have not been secured by its own functions.  You will get an error for each literal number or string that is found in the SQL until they are wrapped with <code>dbQuery.param()</code> or <code>dbQuery.trustedSQL()</code>.  This approach works even when a variable or function outputs the SQL because all literal strings and numbers are considered an error until handled with <code>dbQuery.param()</code> or <code>dbQuery.trustedSQL()</code>.</p>
<p>To understand more about sql injection, read the wiki: <a href="http://en.wikipedia.org/wiki/SQL_injection" target="_blank">http://en.wikipedia.org/wiki/SQL_injection</a></p>
<p>db-dot-cfc sets out to help developers locate their mistakes by throwing exceptions when it finds literal strings or numbers in the SQL. </p>
<h3 id="sqlinjection">SQL Injection Example:</h3>
  <p>Let's assume the programmer makes a mistake and <code>##form.id##</code> is not further validated, so the user can pass in any value they want by modifying the url.</p>
  <cfscript>request.manual.codeExample("sql-injection.cfm");</cfscript>
<p>I intentionally used <code>structget()</code> there because the results of a function call is not auto-escaped.  Some CFML developers might forget about that detail when switching from a simple value output to using a function.  This is why it is best to always use <code>&lt;cfqueryparam&gt;</code> like the following example.</p>
 <cfscript>request.manual.codeExample("cfqueryparam.cfm");</cfscript>
<p>However, a lot of developer may not understand cfqueryparam or want to type so much, so they just ignore it.</p>
<p>With db-dot-cfc, you write code like this to secure that query:</p>
 <cfscript>request.manual.codeExample("verify-queries1.cfm");</cfscript>
<p>It's important to realize that db-dot-cfc is not just using alternative syntax, but it's actually validating the SQL before it runs the query when you set <code>verifyQueriesEnabled=true</code>.</p>
<p>In this next example, <code>dbQuery.execute()</code> will throw an exception because the <code>##form.id##</code> was not output with <code>dbQuery.param()</code> or <code>dbQuery.trustedSQL()</code>.  This demonstrates the power of db-dot-cfc when it comes to improving the security of your application.</p>
 <cfscript>request.manual.codeExample("verify-queries2.cfm");</cfscript>

<h2 id="partialsql">Partial SQL parsing</h2>
  <p>db-dot-cfc provides the ability to let you run your own filters on the SQL statement to determine if the query is valid and modify it if necessary.  db-dot-cfc does some of the sql statement parsing for you and provides many variables for you to use to further inspect the parts of the query.  To register a custom filtering function with db-dot-cfc, you use code like this:</p>
  <cfscript>request.manual.codeExample("parsed-sql-function.cfm");</cfscript>
<p>For example, in Jetendo CMS, we have many tables with a <code>site_id</code> column to keep the content on different sites unique.  Our application validates that the <code>site_id</code> column is always specified for each table in the query that has a <code>site_id</code> column.</p>
<h2>Separation of SQL from its execution</h2>
  <p>Many times, you need to build a query with a variety of functions as a string and then pass the string to cfquery like this:</p>
   <cfscript>request.manual.codeExample("cfquery-sql-separation.cfm");</cfscript>
<p>Unfortunately, this prevents the automatic escaping from occuring and you can't use the <code>&lt;cfqueryparam&gt;</code> anymore because you built the query outside of the <code>&lt;cfquery&gt;</code> tags.</p>
<p>You could make a custom tag which mimicks the behavior of cfquery, but then you'd still be limited to using the tag syntax.  It's also a bit harder to install a custom tag, and requires restarting the server in some CFML engines to get it to be recognized.</p>
<p>db-dot-cfc augments cfquery with more flexible syntax and it's able to enforce the security of query parameters.</p>
<h2 id="performance">Performance</h2>
  <p>Every CFML performance trick has been used in db-dot-cfc.  Each feature has been extensively tweaked to use the fastest / most minimal code possible.  When just a few queries are used in a request, db-dot-cfc is between 10% and 30% slower then a plain <code>&lt;cfquery&gt;</code> when the query result is already cached.  Performance is even closer to a plain <code>&lt;cfquery&gt;</code> when in production mode with <code>verifyQueriesEnabled=false</code>. In my load tests, I found the extra overhead of db-dot-cfc to be under a millisecond when compared to running a plain cfquery.</p>
<p><code>verifyQueriesEnabled=false</code> by default so that the code runs fast by default.  However, the developer should turn it on when developing so that they can be sure their SQL is secure and conforms to the framework conventions set up by the parsed sql filters that have been implemented.</p>
<p>In Jetendo CMS, I create an instance of db-dot-cfc during application.cfc's <code>onApplicationStart()</code> and then in <code>onRequestStart()</code>, I duplicate it into the request scope.   <code>request.zos.db=duplicate(application.zcore.db);</code>  This allows the application to use it without the overhead of creating a new object over and over.</p>
<p>db.cfc component is thread-safe and can be cached in the application for reuse in every request.  dbQuery.cfc requires a separate instance for each simultaneous thread that is executing a query so you must call db.newQuery() at least once per thread/request.  Because the internal parameter array of dbQuery.cfc is only relevant for one query at a time, it's important to run <code>dbQuery.execute()</code> before attempting to build another SQL statement.  An error will be thrown if this mistake is detected.  </p>
<h2 id="compatibility">Compatibility</h2>
  <p>db-dot-cfc has been tested to work with Railo 4.1.  db-dot-cfc has no external dependencies, so it should work correctly in any CFML project.  If you notice a compatibility problem when using another database or CFML engine, feel free to improve the code and/or report the issue.</p>
  <p>The SQL Parser doesn't understand all syntax.  It can parse regular Delete, Insert, Select, Update statements.   Some statement such as <code>INSERT INTO ... SELECT ... FROM</code> or  subqueries will not work with the current version of the SQL Parser.  You can set <code>db.init({verifyQueriesEnabled=false;})</code> when you need to run one of these unsupported queries.</p>
<h2 id="dbcfcoptions">db-dot-cfc Options Reference:</h2>
 <p>The <code>db.init(configStruct)</code> or <code>db.newQuery(configStruct)</code> functions can passed the following options.  The default values are shown below. </code></p>
 
 
 <cfscript>
 local.arrRow=[];
 local.arrColumn=["Name","Default","Description"];
 arrayappend(local.arrRow, {
	 name:'autoReset',
	 default:'true',
	 description:'Set to false to allow the current db object to retain it''s configuration after running <code>dbQuery.execute()</code>.  Only the parameters will be cleared.'
 });
 arrayappend(local.arrRow, {
	 name:'cacheEnabled',
	 default:'true',
	 description:'Set to false to disable the query cache.'
 });
 arrayappend(local.arrRow, {
	 name:'cacheForSeconds',
	 default:0,
	 description:'Set how many seconds the query should be cached for.  Requires cacheEnabled to be set to true.'
 });
 arrayappend(local.arrRow, {
	 name:'cacheStruct',
	 default:0,
	 description:'Set to an application or server scope struct to store this data in shared memory instead of within db.cfc. Use structnew("soft") on Railo to have automatic garbage collection when the JVM is low on memory.  structnew("soft") has been tested and it will actively delete a large portion of the cached queries to free up heap space before throwing an OutOfMemory exception.'
 });
 
 arrayappend(local.arrRow, {
	 name:'datasource',
	 default:'false',
	 description:'Optionally change the datasource.  This option is required if the query doesn''t use <code>dbQuery.table()</code>.'
 });
 arrayappend(local.arrRow, {
	 name:'dbtype',
	 default:'"datasource"',
	 description:'Query, hsql or datasource are valid values.'
 });
 arrayappend(local.arrRow, {
	 name:'identifierQuoteCharacter',
	 default:'`',
	 description:'Modify the character that should surround database, table or field names.'
 });
 arrayappend(local.arrRow, {
	 name:'lazy',
	 default:'false',
	 description:'Railo''s <code>cfquery lazy=&quot;true&quot;</code> option returns a simple Java resultset instead of the CFML compatible query object.  This reduces memory usage when some of the columns are unused. This option does nothing when using ColdFusion.'
 });
 arrayappend(local.arrRow, {
	 name:'parseSQLFunctionStruct',
	 default:'{}',
	 description:'Each struct key value should be a function that accepts and returns <code>parsedSQLStruct</code>. Prototype: <code>struct customFunction(required struct parsedSQLStruct, required string defaultDatabaseName);</code>'
 });
 arrayappend(local.arrRow, {
	 name:'sql',
	 default:'&quot;&quot;',
	 description:'Set to a valid SQL statement.'
 });
 arrayappend(local.arrRow, {
	 name:'verifyQueriesEnabled',
	 default:'false',
	 description:'Set to true to enable SQL validation.  This takes more cpu time, so it should only be set to true during development.'
 });
 request.manual.renderTable(local.arrColumn, local.arrRow);
 </cfscript>
 
  <p>After each <code>dbQuery.execute()</code> call, the options are reset to their original <code>db.init()</code> values you specified unless <code>autoReset=false</code>.  If <code>autoReset=false</code>, you must call <code>dbQuery.reset()</code> manually or work with a duplicate of dbQuery by calling <code>db.newQuery()</code>.</p>

  <h2 id="functionref">Function reference:</h2>
  
  <h2>db.cfc Functions</h2>
  <h3>db.init(configStruct)</h3>
 <cfscript>
 local.arrRow=[];
 local.arrColumn=["Name","Type","Required","Default","Description"];
 arrayappend(local.arrRow, {
	 name:'configStruct',
	 type:'struct',
	 required:'false',
	 default:'',
	 description:'A struct containing any of the db.cfc options.'
 });
 request.manual.renderTable(local.arrColumn, local.arrRow);
 </cfscript>
 <p>You must initialize db.cfc with this function before executing queries.  Pass in a configStruct to override the default values. No return value.</p>
  
  <h3>db.getConfig()</h3>
  <p>Returns a duplicate copy of the current config struct in the db.cfc instance.</p>
  
  <h3>db.newQuery(configStruct)</h3>
 <cfscript>
 local.arrRow=[];
 local.arrColumn=["Name","Type","Required","Default","Description"];
 arrayappend(local.arrRow, {
	 name:'configStruct',
	 type:'struct',
	 required:'false',
	 default:'',
	 description:'A struct containing any of the db.cfc options.'
 });
 request.manual.renderTable(local.arrColumn, local.arrRow);
 </cfscript>
 <p>You must call this function to be able to build a sql statement and it's parameters. It creates and returns a new instance of dbQuery.cfc with the specified configuration inherited from db.cfc and the configStruct you pass in.</p>
 
 <p>This function returns a unique dbQuery.cfc object that is initialized the current configuration of db.cfc and the configuration you optionally provide.  You should only need to use this function once per request unless you are doing queries in multiple threads <em>simultaneously</em>.</p>
  <hr />
  <h2>dbQuery.cfc Functions</h2>

  <h3>dbQuery.getConfig()</h3>
  <p>Returns a duplicate copy of the current config struct in dbQuery.</p>
  
  <h3>dbQuery.table(tableName, datasource)</h3>
  
 <cfscript>
 local.arrRow=[];
 local.arrColumn=["Name","Type","Required","Default","Description"];
 arrayappend(local.arrRow, {
	 name:'tableName',
	 type:'string',
	 required:'true',
	 default:'',
	 description:'The name of a table in the database.'
 });
 arrayappend(local.arrRow, {
	 name:'datasource',
	 type:'string',
	 required:'false',
	 default:'##variables.config.datasource##',
	 description:'The name of a CFML datasource, which has a matching database name.'
 });
 request.manual.renderTable(local.arrColumn, local.arrRow);
 </cfscript>
  <p>This function formats the database table and associates the query with a specific datasource.  Note that your database name must match the datasource name for <code>dbQuery.table()</code> to work correctly because it will explicitly insert the datasource name into the SQL statement to better qualify the table when joining tables between databases.  <code>&quot;:ztablesql:&quot;</code> is inserted so that we can track that the table sql has been created using db-dot-cfc and not hardcoded into the string.  This is important because db-dot-cfc supports automatic table prefixing so that <code>&quot;user&quot;</code> could be <code>&quot;prefix_user&quot;</code> if the user wanted to install the application with a table name prefix.  Using this function changes the default datasource used when executing the query.  You can override the datasource used like this: <code>q=db.newQuery({datasource=&quot;anotherDatasource&quot;});</code></p>
<h3>dbQuery.param(sqlParameter, cfSQLType)</h3>
 <cfscript>
 local.arrRow=[];
 local.arrColumn=["Name","Type","Required","Default","Description"];
 arrayappend(local.arrRow, {
	 name:'sqlParameter',
	 type:'string',
	 required:'true',
	 default:'',
	 description:'Any valid database parameter value.'
 });
 arrayappend(local.arrRow, {
	 name:'cfSQLType',
	 type:'string',
	 required:'false',
	 default:'&quot;&quot;',
	 description:'Any valid value allowed by the cfqueryparam cfSQLType attribute.'
 });
 request.manual.renderTable(local.arrColumn, local.arrRow);
 </cfscript>
  <p>This function stores the value in db-dot-cfc's <code>variables.arrParam</code> array and returns a question mark.  The <code>sqlParameter</code>'s type is automatically detected as either a decimal, integer or string so you don't have to type the second argument, <code>cfsqltype</code>, manually unless you want to override the default type.  Because the parameters are stored in an array as they are added, the order of the parameters will be preserved no matter how complex your SQL building code gets. The return value is a question mark, which should be inserted at the position of the parameter in the sql statement.</p>
<h3>dbQuery.trustedSQL(sqlString)</h3>
 <cfscript>
 local.arrRow=[];
 local.arrColumn=["Name","Type","Required","Default","Description"];
 arrayappend(local.arrRow, {
	 name:'sqlString',
	 type:'string',
	 required:'true',
	 default:'',
	 description:'Any valid SQL statement'
 });
 request.manual.renderTable(local.arrColumn, local.arrRow);
 </cfscript>
 <p>This function allows a literal sql statement to be output without any validation or modification.  Code that relies on this function must handle the security of the SQL output on its own.  <code>dbQuery.trustSQL()</code> adds <code>:ztrustedsql:</code> to the beginning and ending of the SQL and returns the string so that it can skip validation more accurately.  The sqlString can be as long and complex as you wish.</p>
<h3>dbQuery.execute(queryName);</h3>
 <cfscript>
 local.arrRow=[];
 local.arrColumn=["Name","Type","Required","Default","Description"];
 arrayappend(local.arrRow, {
	 name:'queryName',
	 type:'variablename',
	 required:'true',
	 default:'',
	 description:'Any string that follows CFML variable naming conventions'
 });
 request.manual.renderTable(local.arrColumn, local.arrRow);
 </cfscript>
 <p>This function performs validation on the sql statement, executes the query, and performs error handling.  It will name the <code>&lt;cfquery&gt;</code> <code>&quot;db.##arguments.queryName##&quot;</code>.  Internally, this function efficiently reinserts the parameter values using <code>&lt;cfqueryparam&gt;</code> in place of the question mark so the query that runs is identical the using cfquery code above.</p>
 
<h3>dbQuery.insert(queryName);</h3>
 <cfscript>
 local.arrRow=[];
 local.arrColumn=["Name","Type","Required","Default","Description"];
 arrayappend(local.arrRow, {
	 name:'queryName',
	 type:'variablename',
	 required:'true',
	 default:'',
	 description:'Any string that follows CFML variable naming conventions'
 });
 request.manual.renderTable(local.arrColumn, local.arrRow);
 </cfscript>
 
 
 <p>This function performs validation on the sql statement, executes the query, and performs error handling.  It will name the <code>&lt;cfquery&gt;</code> <code>&quot;db.##arguments.queryName##&quot;</code>.  Internally, this function efficiently reinserts the parameter values using <code>&lt;cfqueryparam&gt;</code> in place of the question mark so the query that runs is identical the using cfquery code above.</p>

<h3>dbQuery.reset();</h3>
<p>Call this function to reset the init configuration back to the values passed to <code>db.init()</code>.</p>

<h2>License</h2>
<p>Copyright &copy; 2013 Far Beyond Code LLC.</p>

<p>db-dot-cfc is Open Source under the MIT license<br />
  <a href="http://www.opensource.org/licenses/mit-license.php" target="_blank">http://www.opensource.org/licenses/mit-license.php</a></p>

</cffunction>
</cfoutput>
</cfcomponent>