<cfcomponent>
<cfoutput>
<cffunction name="index" access="public" localmode="modern">
<h2>Outline</h2>
  <ul>
  <li><a href="##whyintegrate">Why integrate with Wordpress?</a></li>
  <li><a href="##defaultconf">Default configuration information</a></li>
  <li><a href="##jetendocms">Jetendo CMS configuration</a></li>
  <li><a href="##wordpresscms">Wordpress configuration</a></li>
  <li><a href="##otherconsiderations">Other considerations</a></li>
  <li><a href="##supportfor">Support for other applications besides Wordpress</a></li>
  </ul>
  

<h2 id="whyintegrate">Why integrate with Wordpress?</h2>
<p>Sometimes you want to work with other developers who don't understand CFML enough to work on the application's source code, but they still want to use some of its features.</p>
<p>By integrating Jetendo CMS with Wordpress, we allow developers to use something they may be more familiar with and to get their work done more easily.</p>
<p>Rather then open up your server to many security risks when working with the third party developer, you can integrate Wordpress by using web server technology including Server Side Includes (SSI) and HTTP Proxy to make Wordpress function seamlessly on the same domain.  Wordpress and Jetendo CMS will be able to be separately managed on different domains and neither developer will be required to provide server access.</p>
<p>It's usually better for search engine optimization (SEO) to keep your on content on the same domain rather then make lots of subdomains.  This unique Wordpress integration makes it easy to do this as well as keep the look of the site consistent by automating updates to the theme.  You can also avoid any cross-domain security configuration problems and do ajax on either domain without trouble.   You can also use a single SSL certificate to server traffic for both domains without having to have multiple SSL certificates.</p>

<h2 id="defaultconf">Default configuration information</h2>
<p>This document makes a few assumptions about the way Jetendo CMS and Wordpress are installed in order to make it easier. </p>
<p>Assume the Jetendo CMS domain is www.mydomain.com</p>
<p>Assume Jetendo CMS is installed in /home/vhosts/</p>
<p>Assumes Wordpress should be installed in a subdirectory named &quot;wp&quot; on the third party server directly in the home directory of the web site.</p>
<p>Assume the Wordpress domain is wp.mydomain.com, which points to a different directory on the same server or a different physical server.</p>
<p>You should be able to see the Wordpress home page by visiting wp.mydomain.com/wp/ and the wordpress admin at wp.mydomain.com/wp/wp-admin/ prior to integrating it with Jetendo CMS.</p>

<h2 id="jetendocms">Jetendo CMS configuration</h2>
<h3>Configuring the Jetendo CMS theme template file</h3>
<p>The simplest possible Jetendo template file should contain the following HTML comments in the correct locations so that the system can extract the meta tags, header and footer when publishing the files that will be included with Server Side Includes (SSI).</p>
<cfscript>request.manual.codeExample("template.html");</cfscript>

<h3>Publishing the Jetendo CMS SSI files</h3>
<p>As a logged in user, you can manually republish the SSI include files by clicking the &quot;Re-publish SSI Includes&quot; button in the Site Manager menu. This button should link to the following url:<br />
www.mydomain.com/z/admin/ssi-skin/index</p>
<p>Our hosted service powered by Jetendo CMS is setup to run the republish theme script every night. You can setup your installation of Jetendo CMS to run it as any frequency you like. The URL to execute to schedule is: <br />
server-admin.com/z/server-manager/tasks/publish-ssi-skin/index</p>
<p>server-admin.com should be replaced to be the domain where the Jetendo CMS Server Manager is accessible.</p>
<h3>Configuring the web server where Jetendo CMS is installed</h3>
<p>	For Nginx web server, modify the server host conf file to have this near the top:</p>
<cfscript>request.manual.codeExample("nginx-jetendo.txt");</cfscript>
<p>	TODO: Add configuration for Apache</p>
<h3>Configuring the web server where Wordpress is installed</h3>
<p>The default wordpress URLs need some rewrite rules to work properly in a subdirectory. Please update your conf files for the web server you are using.</p>
<p>For Nginx Server:</p>
<cfscript>request.manual.codeExample("nginx-wordpress.txt");</cfscript>
<p> For Apache &lt;virtualhost&gt;:</p>
<cfscript>request.manual.codeExample("apache-wordpress.txt");</cfscript>
<p>TODO: Write configuration for IIS web server.</p>

<h2 id="wordpresscms">Wordpress configuration</h2>

<h3>Modifying the Wordpress theme to use the SSI files</h3>
<p> Insert   the following server side includes in the Wordpress theme files exactly where I have described.<br />
	<br />
	Above <code>&lt;?php wp_head(); ?&gt;</code> in theme/header.php, add:</p>
<p> <code>&lt;!--## include virtual=&quot;/zupload/ssi/zssihead.html&quot; --&gt;</code><br />
	<br />
	</p>
<p>Below <code>&lt;body &lt;?php body_class(); ?&gt;&gt;</code> in theme/header.php, add:</p>
<p><code>&lt;!--## include virtual=&quot;/zupload/ssi/zssiheader.html&quot; --&gt;</code><br />
	<br />
	</p>
<p>Below <code>&lt;?php wp_footer(); ?&gt;</code> in theme/footer.php, add:</p>
<p> <code>&lt;!--## include virtual=&quot;/zupload/ssi/zssifooter.html&quot; --&gt;</code></p>
<h3>Updating the Wordpress URL</h3>
<p> In the Wordpress Admin, under <span class="zdoc-menutext zdoc-rightarrowbox">Settings</span> <span class="zdoc-menutext">General</span>, update these fields:</p>
<p> Wordpress Address (URL) = http://www.mydomain.com/wp</p>
<p> Site Address (URL) = http://www.mydomain.com/wp</p>
<p>Notice that we are not using wp.mydomain.com above. It must use the domain where Jetendo CMS is installed.</p>

<h2 id="modalwindow">Modal Window in Jetendo CMS that loads Wordpress URL</h2>
<p>Let's say you want to build a custom form or popup in Wordpress and display it to users in a Jetendo CMS page.  Here is a code example of how to do that.</p>
<cfscript>request.manual.codeExample("modal.html");</cfscript>
<p>Once you have this working on a test page, you can take this code and insert it in the "Insert Advanced Code" field in the Edit Page feature</p>
<p>Jetendo CMS also has a feature to let you add code globally to the <code>HTML Head Tag</code>.</p>
<p>To do this, modify the <span class="zdoc-menutext zdoc-rightarrowbox">Content Manager</span> <span class="zdoc-menutext zdoc-rightarrowbox">Site Options</span> <span class="zdoc-menutext">Global HTML Head Source Code</span> field in the Site Manager (www.mydomain.com/member/).</p>


<h2 id="otherconsiderations">Other considerations</h2>
<p> You must put all your Wordpress files inside the &quot;wp&quot; directory for them to work through the proxy unless you modify the rewrite rules to support other URLs.<br />
	<br />
Once you have configured Wordpress and Jetendo CMS as described, you will login to   www.mydomain.com/wp/wp-admin/  instead of   wp.mydomain.com/wp/wp-admin/. wp.mydomain.com/wp/ will not be accessible anymore.  </p>
<p>You won't be able to use the Wordpress site via proxy until the DNS have been configured correctly and updated. You may need to restart Railo or the web server where Jetendo CMS is installed if you have trouble getting the DNS to update since it may be caching the old DNS information.<br />
	<br />
	Make sure you avoid using global css selectors like  div{} or body *{} or reset css files in your Wordpress code.  Those will break usually break Jetendo CMS.<br /><br />
	You will need to delete the parts of the wordpress theme that are   redundant or unnecessary so that the Jetendo CMS works with Wordpress as expected. It is also possible to customize the Jetendo CMS theme so that it has a special version for Wordpress that is different then the regular web site.</p>
	<p>If you create a Wordpress page that doesn't have the server side includes and it just outputs it's own code, my server won't modify it at all, so you can create custom layouts if needed without modifying Jetendo CMS.</p>
	<p>For better security and to reduce the chances of duplicate content being indexed, you should configure the Wordpress server to only allow incoming traffic from the Jetendo CMS server by modifying your web server or firewall as appropriate.</p>
	<p>Most of the files for the themes and the web site should be hosted on the Jetendo CMS server for best performance.   However, you could configure the proxy to go the opposite direction when you expect Wordpress to have more content then the Jetendo CMS server.   You could also try to setup the other hosting in the same datacenter so that you have better private network performance and security for the proxy connection.</p>

<h2 id="supportfor">Support for other applications besides Wordpress</h2>
<p>	You can also use the above SSI directives above in conjunction with ANY   programming language or application that is hosted on your system.    There is no requirement to use PHP and wordpress. We have just provided additional documentation information for Wordpress users since it is so popular.</p>
</cffunction>
</cfoutput>
</cfcomponent>