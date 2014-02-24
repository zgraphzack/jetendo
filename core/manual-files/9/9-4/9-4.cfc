<cfcomponent>
<cfoutput>
<cffunction name="index" access="public">
<p>Note: This is an early draft of the security documentation for Jetendo.</p>
<h2>Outline</h2>
<ul>
<li><a href="##intro">Introduction</a></li>
<li><a href="##ubuntu">Ubuntu Security</a></li>
<li><a href="##filesystem">Filesystem Security</a></li>
<li><a href="##Nginx">Nginx Security</a></li>
<li><a href="##railo">Railo Security</a></li>
<li><a href="##async">Asynchronous message passing in Jetendo</a></li>
<li><a href="##php">PHP Security</a></li>
<li><a href="##mariadb">MariaDB Security</a></li>
<li><a href="##jetendo">Jetendo Security</a></li>
<li><a href="##development">Development Server Security</a></li>
<li><a href="##selfhealing">Verification &amp; Self-healing</a></li>
<li><a href="##logging">Logging</a></li>
<li><a href="##deploy">Secure Deployment</a></li>
<li><a href="##review">Periodic Security Review</a></li>
<li><a href="##conclusion">Conclusion</a></li>
</ul>

<h2 id="intro">Introduction</h2>
<p>Jetendo has been engineered to provide the ultimate level of security.</p>
<p>Security is a moving target as threats change, but there are things that should always have been done better, and many companies neglect year after year. As an open source application, we also can't rely on "security through obscurity" as much as a proprietary software developer might choose to do.   For our security to be effective, it needs to be layered and robust enough to thwart even the most motivated attackers who may have full knowledge of the system they are attacking.   While we can't claim to guarantee a system we don't manage is secure, we know that security is an important part of web development and we can do a lot to protect developers from their own mistakes through education, better application programming interfaces, and better defaults.</p>
<p>Jetendo may be primarily considered a CFML Content Management System (CMS), but it approaches web development from all angles as a singular solution to running a successful web development company. To have success as a company, it is important to protect customer data and comply with regulations and keep your business online.  You also want systems to fend off spam &amp; other abuse related problems.</p>
<p>We research and apply best practices across the entire system.   Instead of focusing only on our software, we extend our security considerations to include the related software including Ubuntu Linux, Nginx, MariaDB, PHP, and Railo.  As a result, a deployment of Jetendo that relies on our supported environment offers a significantly more security then nearly any other open source solution on the market.</p>
<p>We review other security recommendations online including popular answers to security questions on forums/q&amp;a web sites.  We also consider some of the requirements listed in The Payment Application Data Security Standard (PA DSS), Payment Card Industry Data Security Standard (PCI DSS 2.0) and National Security Agency (NSA) security publications to generate ideas for further enhancing the security.  We don't claim to be following any security certification or standard at the moment, but it is a goal of this project to automate as much as possible of the requirements for PCI DSS 2.0 Level 4, SAQ D so that it is compliant with the least amount of extra work for users of Jetendo.  It is very expensive to have an application audited for compliance according to the PA-DSS due to the independent analysis costs.</p>
<p>Below, we outline the specific details of our security implementation across all the related software.</p>

<h2 id="ubuntu">Ubuntu Security</h2>
<p>Abusive connection rate or total number of connection is automatically blocked with iptables.</p>
<p>/etc/sysctl.conf hardening according to various guides and research.</p>
<p>UFW Firewall only allows public access to port 80 and 443.  All other services are tunnelled through SSH on port 22.</p>
<p>SSH login requires RSA key.  Root password login is disabled, even at the console.  Requires reboot into single user mode to remove security.  Email alerts are generated when server reboots.</p>
<p>Fail2Ban is installed and configured to prevent access to SSH after 5 failures from the same host.</p>
<p>AppArmor is configured to run in enforce mode for MariaDB, PHP5-FPM, Railo and Nginx.</p>
<p>A custom partition table was used to allow isolation between var logs, Jetendo, root and boot filesystems.</p>
<p>Ubuntu minimal was installed and configured manually for all processes.  Only the required software is installed and the complete configuration is documented.  The server documentation will be published on the Jetendo web site at a later date.</p>
<h2 id="filesystem">Filesystem Security</h2>
<p>A good foundation for security begins with filesystem permissions being as restrictive as possible.</p>
<p>In Linux, UMASK, is a feature that control what permissions are given to new files. Software can always change the permissions, but if they don't, the default will be used. In Ubuntu, the default is to give everyone read access, and only the owner write access. You can prevent other users from being able to read new files by making a more strict UMASK, such as 0027 or 0007. On our system, we are using 0027 so only the owner has write access and "other" user bits are completely disabled, so only user and group can read these files. If you want to use FTP for individual sites with less security, Jetendo allows this, but you'd need to use Umask 0007 so that both the user and group have write access.</p>
<p>Because Railo/Tomcat runs as the group (Nginx), it is necessary for have UMASK 0007 for Railo so that the group has write access for new files created by Jetendo. we set this UMASK during Railo/Tomcat start-up.</p>
<p>The source code and static files for all Jetendo sites and the core application are given read only access to the user and group. Directories are given execute permissions so that scripts can be executed. i.e. chmod 440 for files, and chmod 550 for directories.   These files are owned by the Nginx user.  This prevents the source code from being overwritten by anyone but the root user.</p>
<p>Any place in the application where we need to have a dynamic set of files such as user uploads or an image cache, we read and write access to both the user and group, but not to other users.</p>
<p>On the development environment, filesystem permissions for all the source code and dynamic files are set to chmod 777 so it is easy to develop. This is enforced through the samba mount configuration in /etc/fstab.</p>
<p>On both production and development, there are extra layers of security besides the filesystem security including Railo's sandbox and AppArmor which have both been configured to be specific to Jetendo's needs.</p>
<p>Some attacks can be prevented at the filesystem level via mount options. All our web site source code is mounted as a separate partition with the following mount options: defaults,nosuid,noexec,nodev</p>
<h3>Mount option benefits:</h3>
<p>nodev prevents mounting another filesystem in this location.  Such as a remote location or usb device that has malicious code on it.</p>
<p>noexec prevents running any binary processes from this location.  For example: You wouldn't want a user to be able to upload malicious binary and be able to execute it from a php script.</p>
<p>nosuid disabled setuid and setgid, which allows users to gain additional privileges on specific files or directories.</p>
<h2 id="Nginx">Nginx Security</h2>
<p><a href="http://www.Nginx.org/" target="_blank">Nginx</a> is one of the fastest and most secure open source web servers available. </p>
<p>Part of being open source is that they are open about their security flaw, and they document them here: <a href="http://Nginx.org/en/security_advisories.html" target="_blank">http://Nginx.org/en/security_advisories.html</a> </p>
<p> With only a few issues in recent years, there hasn't been a lot to be concerned with related to security with Nginx especially if you limit yourself to the core features like Jetendo does.</p>
<p>We compile and install the Nginx core server with some of the optional modules we need. By compiling from source, we are able to run a newer version of Nginx with only the features we need compared to installing the version on Ubuntu's repositories.</p>
<p>Nginx runs as it's own user, not root. This helps the other security systems prevent flaws in Nginx further compromising the system.</p>
<p>The Nginx filesystem permissions are restricted to root except for directories that require write access by Nginx such as various temp cache directories. The SSL Certificates are read only by the root user.</p>
<p>Nginx acts as a reverse proxy for Tomcat/Railo.  Nginx serves all the static files, so that Tomcat only has to serve dynamic requests.   Nginx acts like a firewall for Railo because it prevents direct access to the Railo administrator via public URLs.</p>
<h3>Custom AppArmor profile for Nginx + Jetendo</h3>
<p>Nginx has been configured with it's own AppArmor to further limit the access Nginx has to the rest of the system.</p>
<h3>Future plans for Nginx security</h3>
<p>Implement ModSecurity module to protect against some forms of automated attacks.</p>
<p>Run Nginx on a separate physical or virtual machine from the source code &amp; database to create a better security isolation.</p>
<p>Require SSL for all site managers through the use of a wildcard SSL Certificate.</p>
<p>Implement Nginx proxy caching to cache more of the dynamic requests to improve overall performance and resistance to denial of service attacks.  Nginx can serve 1,000 more static requests per second then a complex dynamic request to PHP or Railo.</p>

<h2 id="railo">Railo &amp; Tomcat Security</h2>
<p>Railo is a free open source alternative to Adobe Coldfusion.  One of the best features of Railo is that doesn't cause you to pay anything for its core language and security features.  Adobe Coldfusion Enterprise costs $8,499 (Source Adobe.com on 1/21/2014) to provide the extra security isolation provided via multiple installations or multiple Java server contexts.  However, with Railo, you can install as many copies as you wish, or you can use the sandboxing and contexts features to do this.  If you need many servers later, you don't end up paying more. It is also easier to distribute Railo with commercial applications thanks to it's generous LGPL license.</p>
<h3>What is the Railo sandbox used for? </h3>
<p>The sandbox  access settings in Railo's server administrator let you define the level of access specific paths on the system have. Internally, it relies on Java &amp; tomcat security model, which is quite robust. Jetendo has been engineered to allow an extremely restricted security integration with Railo.  Railo has a number of advanced features that may be useful for development and specific users. However, with security, you may want to disable or limit these features.</p>
<p>Jetendo is fully functional when the following features are disabled in Railo's security sandbox:</p>
<ul>
	<li>Web Administer &amp; cfadmin tag</li>
	<li>Tag CFExecute</li>
	<li>Tag CFImport</li>
	<li>Tag CFObject / function CreateObject</li>
	<li>Tag CFRegistry</li>
	<li>CFX Tags</li>
	<li>Direct Java access</li>
	</ul>
<p>Additionally, the paths Jetendo needs to allow Railo to access are isolated in a way that allows parts of Jetendo to be invisible to Railo.</p>
<p>With no ability to call Java code directly and no ability to execute other processes on the system, Railo is only able to execute pure CFML. This makes Jetendo excellent in a shared hosting environment. We plan to offer Jetendo exclusive shared hosting in the future. Multiple installations of Jetendo could run on separate Java contexts safely, without being able to attack each other.</p>
<h3>Custom AppArmor Profile for Railo + Jetendo</h3>
<p>Railo has a custom AppArmor profile configured to be specific to Jetendo's requirements. Because Railo is only running CFML, the AppArmor profile is extremely simple to maintain, due to only a few dozen rules being needed. </p>
<p>After adding AppArmor, Jetendo has at least 4 layers of security protecting access to files. The filesystem permissions, AppArmor profile, the Railo Sandbox and validation in Jetendo's API. An attacker may need to find a flaw in more then one of these systems to gain additional access to the rest of the system.</p>
<h2 id="async">Asynchronous message passing in Jetendo</h2>
<p>With no direct system access, you may think that Jetendo must be more limited in what it can do. However, this is not true. You don't need to directly access the database data files in order to use a database, and likewise you shouldn't need to access a unconfined process directly.  To work around this, Jetendo has implemented all of its advanced shell integration features through message passing between Railo and PHP cron jobs that are constantly running.</p>
<p>This process of passing messages back and forth occurs through the database or filesystem in a location where both Railo and the PHP cron jobs can read and write.  Because messages are processed sequentially one at a time, it is not possible for a task to consume all system resources and slow down the system. If many users attempt to resize images at the same time, it may take slightly longer for them to all complete, but this would only be a few seconds, not very noticeable. If a task takes longer then a minute, another PHP cron job will be fired off, and then there will be some parallel activity. </p>
<p>The system is also setting to have a timeout where these processes are automatically killed if they take too long. So far all of these shell integration features take between 10 milliseconds and 10 seconds, so the timeout settings are usually able to be set very low. This helps keep the number of active connections low on a busy server.</p>
<p>To prevent mistakes that could lead to a security breach, the message data is validated on both sides of the message in the ways that it should be to prevent unexpected results. For example, does a file exist inside the sandbox? Is a number in a valid range? This validation being done on both sides, protects the system much better then just a single layer of protection on one side.</p>

<h3>Video encoding</h3>
<p>Jetendo has built advanced browser interface for uploading, resizing and outputting HTML 5 and Flash Player compatible video files so you can host video privately.   The system was built in a secure single-threaded way that allows only 1 video to be encoded at a time to prevent using too much CPU.  By passing messages asynchronously, HandBrakeCLI, FFMpeg and other commands can be run without having to give Railo more privileges.  There is robust error handling and logging to make it easier to debug problems with video encoding.   The system has been configured to allow up to 4gb files to be uploaded.   It keeps the session alive with ajax during this process.</p>
<h3>Performance</h3>
<p>To avoid excessive CPU waste, the PHP cron job sleeps briefly after checking for new messages to process. Sleep only adds up to a couple hundred milliseconds mainly due to amount of milliseconds the sleep is set to on both sides of the message passing system. If sleep was set too low, more system resources would be wasted. Jetendo only uses this message passing feature for specific features that pure CFML can't do as well. ImageMagick image manipulation and advanced server administration like deploying code, configuring other parts of the system and setting up new sites are the main use cases for this system.</p>
<h2 id="php">PHP Security</h2>
<p>The PHP language was selected for cron jobs because Railo 4's Command Line Interface (CLI) is not officially part of the Railo release yet. PHP is optimized for fast execution of multiple processes that are short-lived. If they fail, it doesn't cause the rest of the server to fail. Railo has to be more carefully managed to avoid it hanging or crashing. PHP allows advanced processing of shell commands with simple syntax. We don't have to concern ourselves with PHP's security via command line as long as the validation is working correctly.</p>
<p>It's important to realize that the PHP cron job scripts are executing via command line, instead of via the HTTP web server.  This allows PHP to do anything the root user can do, which is exactly what we want in this case. If PHP was running through the web server, then it we'd have exposing root access permissions to the public, which is dangerous.</p>
<p>We try to minimize the amount of PHP we introduce into the Jetendo project because it is primarily intended to be a pure CFML application. PHP is much easier to use for now when dealing with shell integration and image resizing.  We will evaluate Railo's CLI again when it improves.</p>
<h3>PHP + Nginx</h3>
<p>There is a small portion of PHP code that runs in HTTP via Nginx.</p>
<p>To secure this code, we only allow specific PHP scripts to be executed explicitly in Nginx.</p>
<h3>Custom AppArmor profile for PHP5-FPM + Jetendo</h3>
<p>AppArmor for php is extremely restrictive to allow allow access to resize images, and mostly read-only access to Jetendo files.  Because most of the shell commands Jetendo uses are run with command line PHP instead of php5-fpm, the AppArmor profile is very simple and allows only a few specific features.</p>
<h3>Future plans for PHP + Nginx Security</h3>
<p>Remove all PHP execution via HTTP by translating these scripts to CFML.</p>
<h2 id="mariadb">MariaDB Security</h2>
<p>MariaDB is a drop-in replacement of MySQL due to binary compatibility with the data files.   MariaDB aims to keep the most popular open source database more free and to earn it's own premium support customers.  Notable companies such as Wikipedia, Google, and Fedora have already moved to use MariaDB instead of Oracle's MariaDB.</p>
<p>Securing MariaDB mostly has to do with making sure the queries run against it are secure, which is discussed further in the Jetendo Security section.</p>
<p>When doing backup and restore operations, it needs to access a few extra locations Jetendo has setup to be as isolated as possible.  MariaDB's backups are kept in a separate place from the publicly accessible files and can only be accessed by a process with root privileges or the correct MariaDB privileges.</p>
<h3>Custom AppArmor profile for MariaDB + Jetendo</h3>
<p>MariaDB has a very small amount of files it needs to access.  </p>
<h3>Future plans for MariaDB security</h3>
<p>Implement separate users for different levels of privileges.  I.e. Create a separate user and datasource for LOAD DATA INFILE, ALTER TABLE, DROP TABLE, GRANT and other operations that are more dangerous.</p>
<p>Create a read-only mode for demo site by allowing the primary datasource to be changed to a different datasource that is read-only to prevent the application from changing in the demo.</p>
<p>Add monitoring to detect MariaDB login failures to bring awareness around possible attacks that occur inside the firewall. - Use log_warnings = 2 | This logs connection failures in the error log - which is not on by default.</p>
<p>Run MariaDB on a separate virtual machine to prevent direct access to it attacker gains root access on Application Server layer of Jetendo.</p>
<p>MySQL Proxy + LUA script  or Middleware between application and database.  Allows creating custom security to protect the database.</p>
<p>Configure secure_file_priv to limit MariaDB to accessing files in a specific directory with LOAD DATA / INTO OUTFILE statements.</p>
<p>Configure bind-address to limit ip database runs on.</p>
<p>Configure MariaDB to require SSL client certificate authentication<!---  for PHP's MySQLi ( $db->ssl_set('/etc/mysql/ssl/client-key.pem', '/etc/mysql/ssl/client-cert.pem', '/etc/mysql/ssl/ca-cert.pem', NULL, NULL); ) and JDBC (   StringBuffer sb = new StringBuffer("jdbc:mysql://localhost/bt?useSSL=true&");
        sb.append("user=vic&password=12345&");
        sb.append("clientCertificateKeyStorePassword=123456&");
        sb.append("clientCertificateKeyStoreType=JKS&");
        sb.append("clientCertificateKeyStoreUrl=file:///home/vic/tmp/client-keystore&");
        sb.append("trustCertificateKeyStorePassword=123456&");
        sb.append("trustCertificateKeyStoreType=JKS&");
        sb.append("trustCertificateKeyStoreUrl=file:///home/vic/tmp/ca-keystore");  or use this mariadb : http://stackoverflow.com/questions/4663061/mysql-jdbc-over-ssl-problem - https://github.com/properssl/java-jdbc-mariadb
) ---></p>


<h2 id="jetendo">Jetendo Security</h2>
<p>Custom error handler hides exceptions from real users, but displays them for developers.  Also creates a logged entry and email notification.</p>
<p>It is inevitable for developers of all experience levels to make mistakes.  We all have real-life budgets, and challenges besides trying to become a security expert.   It's when life challenges us most, that security may falter.   A large portion of the attacks against CFML can be automatically avoided by using a few of the core Jetendo features.</p>
<p>The entire Server Manager and Site Manager are able to run on an alternative domain that requires SSL.  The will allow all logins, and site/server management to be done with an encrypted connection.  This will defeat most man in the middle attacks, and greatly improves the security of Jetendo users while on untrusted, unencrypted networks such as public Wi-fi.</p>
<h3>Automated SQL Parsing to prevent SQL injection and misuse of database tables</h3>
<p>Nearly all queries in Jetendo are written with the db-dot-cfc project instead of using cfquery directly.   This protects developers from making mistakes by making a few assumptions about how queries should be written.  For example, if you insert a literal number or string in the SQL, this will be treated as an exception that must be corrected before the query can execute.   To correct this, you use the param() and trustedSQL() methods of dbQuery.cfc to properly escape the values so the SQL parsing engine doesn't see them as errors anymore.   This system supports nearly all MySQL/MariaDB syntax, so it's quite useful for automating protection against SQL attacks.</p>
<p>Additionally, Jetendo is a multi-tenant application that allows many sites to be setup and run from a single copy of the source code and database.  To facilitate this, a site_id is in many of the tables to isolate data between sites.   If you forget to add the site_id to the query, you may cause a security flaw that allows data to leak between sites.   The SQL Parsing engine is also able to detect when a site_id column was missing, even when there are complex joins.   It does this by requiring that all tables are specified with the dbQuery.table() function.  This also makes the sql parser aware of the database to use for that table.  Tables with a site_id column are automatically detected when the application starts, so the developer doesn't have to worry that they made a mistake with the multi-tenant security when they rely on the existing functionality of db.cfc.</p>
<h3>Abuse Detection</h3>
<p>If a robot hits the server an excessive amount of times, they may cause too much session memory to be used.  Jetendo automatically clears the session memory when this situation is detected.   It can also be configured to block these bad robots or serve them different content with just a few small changes.</p>
<p>Session tracking is used to keep track of what pages a user visited after submitting an inquiry form.   It is also used to pass messages between pages without using the database.  Session memory in Railo is very fast, but you want to protect against using too much memory so that Railo is stable.  Someone attacking the system in order to overwhelm it's capacity is often called a Denial of Service attack.   Jetendo attempts to prevent denial of service attacks by limiting connections and preventing excessive memory usage.</p>
<h3>OpenID Integration</h3>
<p>Any user in Jetendo can have an OpenID account attached.  The logos for Google, Aol, and Yahoo OpenID are listed at the create account and login screens.    Some OpenID providers support multi-factor authentication and they apply more strict login security because they have a lot more security concerns then a small business.   For Example, Google lets you configure the service to send you an automatic call when you login to the service from a new location or every 30 days.    Jetendo can be configured to require OpenID login instead of password or allow both.</p>
<h3>Secure Password Storage</h3>
<p>Jetendo now encrypts user passwords by default with Scrypt using the asynchronous message passing system to execute a simple Java console application to check and encrypt passwords.  It is also possible to use hash(), no hashing or your own custom hash function by changing the Jetendo configuration.   The system is able to have multiple password hashing systems in place at the same time, so that you can migrate between them without forcing everyone to reset their password.  When a user logs in, their password is re-encrypted if the hashing method has changed.</p>
<p>Jetendo uses <a href="https://github.com/wg/scrypt" target="_blank">ScryptUTIL</a>, an open source Java implementation of Scrypt.   Scrypt combines the use of excessive amounts of CPU with excessive amounts of memory to make hardware brute force cracking of encrypted data more expensive.</p>
<p>When an exception occurs during the login process, the password variables are automatically deleted so that no actual password data is logged or emailed.</p>
<h3>Tokens for persistent login</h3>
<p>When a user chooses to login automatically in the future, we made this more secure according to best practices.   Instead of storing the hashed password or the actual password on the user's system, we create a new long random password, encrypt it with Scrypt, store it in the database and then set a cookie with the same hash.   If someone steals their cookies somehow, they won't be able to decrypt or see the actual password.   These tokens can be automatically invalidated.   If the same user logs in on multiple devices, each device has it's own login token.  So this allows you to protect against multiple logins with the same token.  Someone has to login again whenever the user agent or IP address changes even if the token matches.   When combined with requiring SSL for an entire site, the login token system is very secure.</p>
<h3>Password expiration</h3>
<p>Many security breaches on large companies have occurred due to attackers gaining access to older systems, backups or large databases that probably shouldn't exist.</p>
<p>Why store the password or hashes of passwords for thousands or even millions of users in a single database?   If a user hasn't logged in for a long time, they are probably not interested in your service.  It is not useful for you to store their password forever.  Instead, you can configure Jetendo to automatically expire and delete passwords after a user has not logged in for an extended amount of time.  Jetendo's default is 6 months.   For many applications, this will probably reduces the amount of passwords that can be stolen by a huge amount.  Inconveniencing a few users who are less active for the sake of protecting their identity on other web sites is worth doing.</p>
<h3>Client-side processing</h3>
<p>Because so many attacks can be prevented by security best practices, many attackers resort to distributed denial of service attacks, which don't really compromise a system, but they have disastrous effects for all the users.   A site under DDoS attack may be inaccessible for hours or days, because there is no single source of abuse to block.   In this way, DDoS become a bit of a security issue for many web applications.   Protecting against them can be useful to maintain a certain level of operation during an attack,  but it may never be foolproof.</p>
<p>Typically, the client side is not to be trusted, so if there is a security breach in the browser or javascript is modified, Jetendo server already ignores that input through validation.    When more of the complex work is done on the client-side, this also reduces the amount of attack surface area for the Jetendo server.    For example, HTML 5 Canvas is able to download, resize and crop images in Jetendo without having to call PHP or Railo.  Google Maps geocoder is setup to geocode addresses on the client side instead of running on the server.    Systems like this make Jetendo faster because it is doing less.   It makes Jetendo secure, because less can go wrong that will impact other users.    We intend to make more of Jetendo able to happen on the client side in the future because this provides the best traits of security, performance and user experience.</p>
<p>Jetendo is able to serve request as minimal ajax pages, where fewer requests are made.  Just the title, url and body content are replaced.   This makes it more stable under load.</p>
<p>More then one open window of a web site, shares the same cookies.  In Jetendo, we use this to implement a javascript function that lets you determine if the user is logged in or not, and display different content without needing to contact the server.   You can update a page immediately after they login. </p>


<h3>Future plans for client-side processing</h3>
<p>Implement more denial of service protection</p>
<p>Finish partial page caching system so Nginx can do proxy caching.</p>
<p>Make all session related features work entirely with Javascript so that most of the HTML can be static.</p>

<h2 id="deploy">Secure Deployment Tool</h2>
<p>Most web developers rely on FTP to send files to the server.</p>
<p>FTP is error-prone, and tedious.   If you want to work as a team, it gets harder to determine which version is the newest if multiple people are accessing the FTP.   FTP also requires that all the files are writable by the FTP user, or you can upload anything.   This reduces the security of your system.</p>
<p>To prevent these problems, Jetendo includes a secure deployment tool built around rsync to efficiently synchronize the test and production environment source code.   It excludes user uploaded files &amp; system cache.   Most projects are relatively small for the actual source code, so in practice, rsync finishes deploying in just seconds.  Rsync gives you a guarantee that the files match, but what about the permissions?   Jetendo automates correctly the ownership and permissions recursively after each deploy.    Jetendo also has a variety of caching systems that can be cleared at the same time that you are deploying changes.  This lets you have a fully working production environment in a single click. </p>
<h3>Teamwork &amp Scalability</h3>
<p>In a team, everything doesn't have the ability to figure out exactly what has changed, so you must rely on the version control system, such as Git, to get the correct version.   Once someone has synced with the git server, then can do some testing.  If everything is ok, then they can sync their test copy of Jetendo with the production Jetendo server.</p>
<p>Jetendo's deployment tool is also able to deploy to multiple servers at once with a single click.  You could have servers in different locations and update them all in seconds.</p>
<p>To make sure files are pushed to the right location, Jetendo has a browser based control panel for managing the mapping of local and remote sites individually.  It is able to do this because there is an remoting API behind the scenes that lets you connect 2 installations of Jetendo in different ways.    It also protects you from syncing the wrong direction by letting you identify which server is a test server.</p>

<h2 id="development">Development Server Security</h2>
<p>Protecting the production server is very important, but the security of that server relies on the security of the development machines and network being secure as well.</p>
<p>Jetendo may be deployed on Linux, but I develop on a Windows machine, and use a Linux virtual machine for testing.</p>
<p>Protecting Windows (or Mac), may require using some commercial software, and better hardware, but it's worth it to protect your business.</p>
<p>Intel SSD drives and select other drives support hardware encryption when combined with a motherboard that supports ATA Hard Drive password.   During boot, you have to enter a password to decrypt the hard drive.  This is different then a bios login password, so you have to check the motherboard/computer manual to verify this feature works as expected.</p>
<p>If your hardware doesn't support encryption, you can use Windows Bitlocker software encryption.  This degrade performance slightly depending on whether your CPU supports AES extensions.   Windows Bitlocker can be configured to require a pin during boot and all the other drives in your system, including external drives can be encrypted too.</p>
<p>By default, after Windows installation, you are logged in as an administrator user account. This is dangerous.  On an existing system, it is better to create a new administrator account, and then downgrade your current account to be a "Standard User". According to Microsoft, around 90% of the known attacks against Windows OS in the past were able to be prevented if you were not logged in an administrator.</p>
<p>Make sure you browser the Internet with Chrome or Firefox for the bulk of the browsing.  Only use Internet Explorer for development testing.   Internet Explorer has historically had security problems due to it's integration with the Windows Kernel and flash player giving attackers too much access to the system.   Modern browsers have sandboxed flash, and the browser better so this happens less now.</p>
<p>Make sure you are running the latest version of WIndows within 1 year of its release. Older Windows versions are not updated as often, and may be less secure over time.</p>
<p>Purchase a USB Smart Card token to use to SSH RSA Key Authentication.  There is a version of Putty that has been modified to work with the PKCS11 standard.  If your token says it works with PKCS11, then you should be able to use it to login to SSH in a more secure way.     If you don't use a smart card, you can still use RSA keys, but you have to store the key as a file on your computer.  A smart card stores a key internally and it can't be read back out.  The actual encryption occurs inside the hardware on a properly implemented smart card.  Virtual smart cards in Windows 8 are another option too which lets you use a regular USB stick as a smart card with special software like EIDVirtual, but encryption is done with software and is vulnerable to software attacks.  This is still vastly more secure then simple password login to SSH.</p>
<p>If you purchase a license for EIDAuthenticate, you can also configure Windows Login to require a smart card through changing Group Policy.</p>
<p>Configure your network, and windows firewalls to prevent access to your development machine on all ports.   Explicitly allow any ports you require, but it's better to allow nothing through.</p>
<p>Consider purchasing an computer anti-theft subscription and a laptop that support's Intel Anti-theft technology.  You can configure a system to be remotely located / wiped in the case of theft, for a reasonably low annual fee.</p>
<p>Purchase a license for BitDefender antivirus and keep it up to date.  They always have great coupon deals online for purchase and subscription renewal.  This is known as the best antivirus software for Windows.</p>
<p>Use Mozilla Thunderbird for email, and install the Master Password Add-on, to encrypt your passwords so they aren't stored on disk in plain text.   Having an offline backup of your email data is useful in case your online webmail account is compromised.</p>
<p>For Google accounts, use the App specific password feature and multi-factor authentication to protect the account.  If you lose your phone or tablet, you don't want to have to change your password.</p>
<p>Try to use a different account on mobile devices that is isolated from your important business accounts.  I.e. Paypal, hosting, bank, amazon, etc should all be on a separate account.  There is no good reason to be checking email and browsing on a phone that has access to your entire business.   If you want to monitor communications and leads sent to your phone, you could try filtering / forwarding some of your mail to that device instead of routing it all there.   You should expect your phone will be lost or stolen, and plan accordingly.  Most devices in recent years are not secure, encrypted and a lot of the data can be retrieved, especially if you "jail break" your device, as many developers do.</p>
<p>Pay for Jungledisk business edition and backup the most important files to this affordable cloud backup.  It might not be the cheapest, but it has excellent security, performance and uses less bandwidth.  Make sure you encrypt the data, and print the recovery key so you don't ever lose it.</p>
<p>Pay for Acronis True Image backup software so you can make backups of your computer to external media.   True Image is efficient and can encrypt your backups.   If someone steals your backups, you need them to be encrypted with a long password or all your data may be in the hands of the thief.  If you are using Windows Bitlocker with your external drive, you wouldn't need to use True Image, but beware: bitlocker on external drives makes them operate much slower.  If you have a lot of data, your backup may take much longer.   Make sure your backup drive is not connected to the computer after the backup is done.  You want to avoid it being damaged or hacked while the computer is running.</p>
<p>Don't use your business computer to install a ton of games, applications and other non-business related software.  You need to be responsible and focus on development and trusted software publishers.  If you want to do unsafe things, try to use a virtual machine if you can use a different computer entirely.</p>
<p>Make sure you test recovering your system, restoring your backups and document the steps so you are not frustrated later when you find you did it wrong.</p>


<h2 id="selfhealing">Verification &amp; Self-healing</h2>
<p>What happens to security when a staff member accidentally or intentionally goes against best practices?   How does the rest of the team find out about this mistake?   How long will the system be vulnerable before the problem is addressed?   These are questions that can be partially solved through automation and monitoring.</p>
<p>Jetendo's automation attempts to be ambitious.</p>
<p>Many developers currently rely on complex control panels such as Plesk or Cpanel, Jetendo attempts to replace the need for them by applying its own conventions, tools and automation.</p>
<p>Most of the systems in Jetendo don't simply rely on the system being correct.  The code typically verifies if something exists or not, and then fixes the problem without throwing an error.   This reduces the amount of bugs you'll have to manually fix over time.</p>


<h2 id="logging">Logging</h2>
<p>Having a clean set of logs, makes servers easier to manage.  Jetendo development has always focused on fixing all bugs and minor validation exception immediately.  This results in the system running without any errors.  Typically, you will only experience errors after building new features that change the behavior of the system.   Jetendo's error handling gathers plenty of additional info, so that a developer can reproduce the state of the application quickly, even when a remote user had the problem.  When there are very few errors occurring, it becomes easy to see when a new problem has occurred.  This should improve increased awareness around validation errors, that could be potential security flaws.   A secure system should have no validation exception that are not properly handled.   Allowing Nginx or Railo error logs to fill up is a bad practice.   We routinely review and fix all the problems in these logs.  After years of doing that, the core system is very stable.</p>
<h3>Verify Sites PHP Cron Job</h3>
<p>When you create a new site with Jetendo, it gets monitored in the future in a variety of ways that impact security and it's ability to function correctly.  This dramatically reduces the amount of time you'll have a serious problem with the individual web sites you host.   Many monitoring approaches only check the entire server and not the individual sites, and processes on the system.  Jetendo attempt to monitor and fix problems at a more granular level.   This task can run at interval you wish, such as hourly. </p>
<p>The verify sites feature runs the following checks</p>
<ul>
<li>Verifies and correct the directory structure</li>
<li>Fixes Linux permissions if they are found to be incorrect.</li>
<li>Tests that the Linux user exists, the password is correct, and FTP login functions.</li>
<li>Verifies the @ and www. DNS records match the IP stored in the Jetendo database for that site.</li>
<li>Downloads the home page to verify it is working correctly.</li>
<li>Verifies /etc/hosts matches the database configuration for all the sites.  This allows DNS resolution of the sites hosted on the server to be faster.</li>
<li>Checks the expiration date of all SSL Certificates.</li>
<li>Verifies no extra Linux users exist that weren't already allowed through the configuration.</li>
</ul>
<p>When one of those problems is found, the script generates an email alert and writes it to a permanent log.  If you fix the problem, the next execution will remove the log entry.  The Jetendo Server Manager dashboard has a link to view the error logs directly from the browser.</p>

<h2 id="review">Periodic Security Review</h2>
<p>Security concerns change as new software is released, new features are added, and more is learned.</p>
<p>Jetendo tries to be proactive about using the latest software and improving it's security when a problem is found.</p>
<p>Over the years when Jetendo was closed source and used to service specific customers, there have been many times where an security issue was found and corrected proactively.  After 10 years of development, nearly every facet of the system has been iterated on more then once.  Also in that 10 year span, there has never been a successful security breach against Jetendo.  It used to run on Windows Server for the first 7 years, and now it runs on Linux only.</p>
<p>When a security flaw is found, the problem is fixed everywhere it occurs in an easy to maintain.  If the changes can be encapsulated into a function, then this is done, so that it can be solved once and reused.</p>
<p>As a result of the thousands of hours of previous development, Jetendo is much more secure despite being a relatively new project in terms of its open source lifespan.  Time has demonstrated it is much more difficult to break through the layers of security in Jetendo and the well established Java security model.</p>
<p>Many of the attacks that continue to plague other open source software occurs due to the countless plug-ins to add-on missing features.  Jetendo comes with most of what you need in the core, and the core is very secure.   If other developers create plug-ins in the future, we'll make sure they are given the right information to make them as secure as possible by utilizing the core API correctly to minimize the amount of security related code they need to write.</p>
<h2 id="conclusion">Conclusion</h2>
<p>Security is a primary feature of Jetendo.  No business should experience the disgrace of a security breach.  Adopting Jetendo's security strategy, server environment and tools can provide a great foundation for securing your web development company even if you developed applications in a different language.  If you adopt CFML for development, you'd find that Jetendo makes feature-rich web development substantially easier.</p>

</cffunction>
</cfoutput>
</cfcomponent>
