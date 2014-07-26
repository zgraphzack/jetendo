<cfoutput> 
<cffunction name="setupAppGlobals1" localmode="modern" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var t3=0;
	var t9=0;		
	var ts=arguments.ss;
	ts.tempTokenCache=structnew();

	
	// railo 4.1.010 can't do soft serialization yet, but it was fixed in the next version
	ts.queryCache=structnew('soft');
	
	ts.robotThatHitSpamTrap=structnew();
	
	ts.mysqlSelectReservedNames=structnew();
	ts.mysqlSelectReservedNames.ALL=true;
	ts.mysqlSelectReservedNames.DISTINCT=true;
	ts.mysqlSelectReservedNames.DISTINCTROW=true;
	ts.mysqlSelectReservedNames.HIGH_PRIORITY=true;
	ts.mysqlSelectReservedNames.STRAIGHT_JOIN=true;
	ts.mysqlSelectReservedNames.SQL_SMALL_RESULT=true;
	ts.mysqlSelectReservedNames.SQL_BIG_RESULT=true;
	ts.mysqlSelectReservedNames.SQL_BUFFER_RESULT=true;
	ts.mysqlSelectReservedNames.SQL_CACHE=true;
	ts.mysqlSelectReservedNames.SQL_NO_CACHE=true;
	ts.mysqlSelectReservedNames.SQL_CACHE=true;
	ts.mysqlSelectReservedNames.SQL_CALC_FOUND_ROWS=true; 
	
	ts.mysqlDataTypeStruct=structnew();
	ts.mysqlDataTypeStruct["bigint_unsigned"]="cf_sql_char";
	ts.mysqlDataTypeStruct["bigint"]="cf_sql_char";
	ts.mysqlDataTypeStruct["mediumint"]="cf_sql_integer";
	ts.mysqlDataTypeStruct["mediumint_unsigned"]="cf_sql_integer";
	ts.mysqlDataTypeStruct["int"]="cf_sql_integer";
	ts.mysqlDataTypeStruct["int_unsigned"]="cf_sql_bigint";
	ts.mysqlDataTypeStruct["smallint_unsigned"]="cf_sql_smallint";
	ts.mysqlDataTypeStruct["smallint_signed"]="cf_sql_smallint";
	ts.mysqlDataTypeStruct["tinyint_unsigned"]="cf_sql_smallint";
	ts.mysqlDataTypeStruct["tinyint"]="cf_sql_tinyint";
	ts.mysqlDataTypeStruct["date"]="cf_sql_date";
	ts.mysqlDataTypeStruct["decimal"]="cf_sql_decimal";
	ts.mysqlDataTypeStruct["decimal_unsigned"]="cf_sql_decimal";
	ts.mysqlDataTypeStruct["bit"]="cf_sql_bit";
	ts.mysqlDataTypeStruct["bool"]="cf_sql_bit";
	ts.mysqlDataTypeStruct["blob"]="cf_sql_blob";
	ts.mysqlDataTypeStruct["char"]="cf_sql_char";
	ts.mysqlDataTypeStruct["double"]="cf_sql_double";
	ts.mysqlDataTypeStruct["precision"]="cf_sql_double";
	ts.mysqlDataTypeStruct["real"]="cf_sql_double";
	ts.mysqlDataTypeStruct["mediumblog"]="cf_sql_longvarbinary";
	ts.mysqlDataTypeStruct["longblog"]="cf_sql_longvarbinary";
	ts.mysqlDataTypeStruct["tinyblog"]="cf_sql_longvarbinary";
	ts.mysqlDataTypeStruct["longtext"]="cf_sql_longvarchar";
	ts.mysqlDataTypeStruct["text"]="cf_sql_longvarchar";
	ts.mysqlDataTypeStruct["mediumtext"]="cf_sql_longvarchar";
	ts.mysqlDataTypeStruct["numeric"]="cf_sql_numeric";
	ts.mysqlDataTypeStruct["float"]="cf_sql_real";
	ts.mysqlDataTypeStruct["datetime"]="cf_sql_timestamp";
	ts.mysqlDataTypeStruct["timestamp"]="cf_sql_timestamp";
	ts.mysqlDataTypeStruct["varbinary"]="cf_sql_varbinary";
	ts.mysqlDataTypeStruct["varchar"]="cf_sql_varchar";
	ts.mysqlDataTypeStruct["tinytext"]="cf_sql_varchar";
	ts.mysqlDataTypeStruct["enum"]="cf_sql_varchar";
	ts.mysqlDataTypeStruct["set"]="cf_sql_varchar";
 
	ts.siteOptionTypeStruct={
		"0": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.textSiteOptionType"),
		"1": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.textareaSiteOptionType"),
		"2": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.htmlEditorSiteOptionType"),
		"3": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.imageSiteOptionType"),
		"4": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.dateTimeSiteOptionType"),
		"5": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.dateSiteOptionType"),
		"6": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.timeSiteOptionType"),
		"7": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.selectMenuSiteOptionType"),
		"8": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.checkboxSiteOptionType"),
		"9": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.fileSiteOptionType"),
		"10": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.emailSiteOptionType"),
		"11": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.htmlSeparatorSiteOptionType"),
		"12": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.hiddenSiteOptionType"),
		"13": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.mapPickerSiteOptionType"),
		"14": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.radioSiteOptionType"),
		"15": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.urlSiteOptionType"),
		"16": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.userPickerSiteOptionType"),
		"17": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.numberSiteOptionType"),
		"18": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.colorSiteOptionType"),
		"19": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.stateSiteOptionType"),
		"20": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.countrySiteOptionType"),
		"21": createobject("component", "zcorerootmapping.mvc.z.admin.siteOptionTypes.listingSavedSearchSiteOptionType")
	};
	
	
	// setup legacy url redirect routes
	ts.urlRewriteStruct={
		redirectStruct={
			"/admin"={ url="/z/admin/admin-home/index" },
			"/manager"={ url="/z/admin/admin-home/index" },
			"/admin/"={ url="/z/admin/admin-home/index" },
			"/manager/"={ url="/z/admin/admin-home/index" },
			"/member"={ url="/z/admin/admin-home/index" },
			"/member/"={ url="/z/admin/admin-home/index" },
			"/z/_com/app/walkscore"={ url="/z/misc/walkscore/index" },
			"/z/_a/video"={ url="/z/misc/embed/video" },
			"/z/_a/util/walkscore"={ url="/z/misc/walkscore/index" },
			"/z/_a/secure-message"={ url="/z/a/secure-message.php"	},
			"/z/_a/content/mortgage-calculator"={ url="/z/misc/mortgage-calculator/index" },
			"/z/_a/content/mortgage-quote"={ url="/z/misc/mortgage-quote/index" },
			"/z/_a/content/agents"={ url="/z/misc/members/index" },
			"/z/_a/search-site"={ url="/z/misc/search-site/index" },
			"/z/_a/site-map"={ url="/z/misc/site-map/index" },
			"/z/_a/inquiry"={ url="/z/misc/inquiry/index" },
			"/z/_e/privacy"={ url="/z/user/privacy/index" },
			"/z/_e/in"={ url="/z/user/in/index" },
			"/z/_e/out"={ url="/z/user/out/index" },
			"/z/_e/pref"={ url="/z/user/preference/index" },
			"/z/_e/login-form"={ url="/z/user/login/index" },
			"/z/_com/listing/search"={ url="/z/listing/search/index" },
			"/z/_a/content/slideshow"={ url="/z/misc/slideshow/index" },
			"/z/_a/content/slideshow_embed"={ url="/z/misc/slideshow/embed" },
			"/z/_a/listing/cma-inquiry"={ url="/z/listing/cma-inquiry/index"},
			"/z/_a/member/inquiries/index"={ url="/z/inquiries/admin/manage-inquiries/index" },
			"/z/_a/member/inquiries/feedback"={ url="/z/inquiries/admin/feedback/view" },
			 "/z/_zcore-app/listing/quick-search"={url="/z/listing/quick-search/index" },
			 "/z/_zcore-app/listing/cma-inquiry"={url="/z/listing/cma-inquiry/index" }
		}
		
	};
	
	
	t9=structnew();
	t9[request.zos.urlRoutingParameter]=true;
	t9.__zcoreinternalroutingpath=true;
	t9.zld=true;
	t9.zp=true;
	t9.zLogin=true;
	t9.fieldnames=true;
	t9.zLogOut=true;
	t9.zReset=true;
	t9.zOS_modeVarDumpName=true;
	t9.zOS_mode=true;
	t9.zOS_modeValue=true;
	t9.zDebugOn=true;
	t9.FIELDNAMES=true;
	t9.zUserSubmit=true;
	t9.zUsername=true;
	t9.zPassword=true;
	ts.repostVarsIgnoreStruct=t9;
	
	t9=structnew();
	t9.disableContentMeta=false;
	t9.arrContentReplaceKeywords=arraynew(1);
	t9.searchincludebars=false;
	t9.disableChildContentSummary=false;
	t9.hideContentSold=false;
	t9.disableChildContent=false;
	t9.contentForceOutput=false;
	t9.contentDisableLinks=false;
	t9.contentSimpleFormat=false;
	t9.tablestyle="";
	t9.content_id="";
	t9.showmlsnumber=false;
	
	t9.contentEmailFormat=false;
	ts.contentDefaultConfigStruct=t9;
	// server globals
	ts.serverGlobals=structnew(); 
	
	t3=structnew();
	t3["/z/misc/system/redirect"]="";
	t3["/z/listing/inquiry/index"]="";
	t3["/z/listing/inquiry-pop/index"]="";
	ts.spiderTrapScripts=t3;
	ts.spiderList="bot,spider,scrape,purebot,mrsputnik,jikespider,voilabot,yandexbot,lycosa.se,facebookfeedparser,sogou_web_spider,ezooms,mj12bot,bingbot,sistrix_crawler,abachobot,abcdatos_botlink_,accoona_ai_agent,ace_explorer,acoon,aesop_com_spiderman,ah_ha_com_crawler,aipbot,aitcsrobot_,alkalinebot,almaden,answerbus_,anthillv_,aolserver_tcl,appie,arachnoidea,arachnophilia,araneo_,araybot_,architextspider,arks_,aspider_,atlocalbot,atn_worldwide,atomz,auditbot,auresys_,autolinkspro_link_checker_,awapclient,backrub_,baiduspider_,bayspider,bbot_,bigcliquebot,big_brother,bjaaland_,blackberry,blackwidow,blogslive_,blogssay_blog_search_crawler_,boitho_com_dc,borg_bot_,botswana_v_,boxseabot_,bravobrian_bstop_bravobrian_it,bruinbot_,bspider_libwww_perl_,bumblebee_relevare_com,buscaplus_robi,butch_,cactvs_chemistry_spider,calif_,cehmgnkabgxpet_tksgsybnlkj_h_qeteeyp,cfetch,checkbot_x_xx_lwp_x,cienciaficcion_net_spider,cipinetbot,cjnetworkquality_,clever_components_downloader,cmc_,combine,computingsite_robi_,confuzzledbot_x_x,contactbot,converacrawler,converamultimediacrawler,coolbot,cosmixcrawler,cosmos_,crawlconvera_,crawlpaper_n_n_n,curl,cusco_,cyberspyder_,cydralspider,cydralspider_x_x,cyveillance,datacha_s,deepak_usc,deepindex,desertrealm_com_j_,deweb_,diamond,diamondbot,dienstspider_,die_blinde_kuh,digger_jdk_,digimarc_cgireader_,digimarc_webreader_,diibot,dlw_robot_x_y,dnabot_,dnsyu_gedsariwq_nwdfrpmu_gscpoywyn_,dpeoorctnm_ryvitlkrr,dragonbot_libwww_,dtsearch,dumbot,duppies,dwcp_,ebiness_a,eit_link_verifier_robot_,elfinbot,emacs_w_v_,emailsiphon,emc_spider,emeraldshield_com_webbot,esculapio_,esirover_v_,esismartspider,esther,evliya_celebi,experibot,expired_domain_sleuth,explorersearch,extreme_picture_finder,ezresult,fastcrawler_x,fast_crawler_v_x,fast_enterprise_crawler_used_by_fast_,fast_partnersite_crawler,fast_webcrawler,fdm_x,feedfetcher_google_,feedfinder,feedster_crawler,feedvalidator,felixide_,fetch_libfetch,fido,fido_harvest_pl_,findexa_crawler_,findimbot,findlinks,fish_search_robot,fluffy_the_spider,freecrawl,funnelweb_,gaisbot,gammaspider_xxxxxxx_,gazz_,gcreep_,geniebot_,geniebot_wgao_genieknows_com,gestalticonoclast_libwww_fm_,gethtmlcontents_,geturl_rexx_v_,gigabot,gigabotsitesearch,girafa_com,golem_,googlebot,googlebot_image,googlebot_x,grabber,griffon_,gromit_,grub_crawler,gulliver,gulper,gulper_web_bot_,harvest,havindex_x_xx_bxx_,henrythemiragorobot,hl_ftien_spider,holmes,hometown_spider_pro,htdig_b_,htmlgobble_v_,http_www_sygol_com,hämähäkki_,iajabot_,ia_archiver,ichiro,iltrovatore_setaccio,imac_,image_kapsi_net_,incywincy_b_,indy_library,ineturl,informant,infoseek_robot_,infoseek_sidewinder,infospiders_,ingrid_,innerprisebot,inspectorwww_,internet_cruiser_robot_,ip_works_v_http,irlbot,israelisearch_,i_robot_,jakarta_commons_httpclient,javabee,jayde_crawler_http_,jbot,jcrawler_,jetbot,jobo,jobot_alpha_libwww_perl_,jubiirobot_version_,jumpstation,katipo_,kdd_explorer_,kit_fireball_,ko_yappo_robot_,labelgrab_,larbin,libwww_perl,linkidator_,linkscan_server_linkscan_workstation_,linksmanager_com_,linkwalker,lmqueuebot,lnspiderguy,localcombot,lockon_xxxxx,logo_gif_crawler,lotus_notes,lwp,lycos_spider_,lycos_spider_t_rex_,lycos_x_x,magpie_,mantraagent,markwatch,marvin_infoseek,mediafox_x_y,mediapartners_google,merzscope,metaspinner,metatagrobot,mfc_tear_sample,microsoft_data_access_internet_publishing_provider_cache_manager,microsoft_data_access_internet_publishing_provider_dav_,microsoft_data_access_internet_publishing_provider_protocol_discovery,microsoft_url_control__,microsoft_webdav_miniredir,mindcrawler,minirank,missigua_locator_,mister_pix_ii_,mj_bot,mnogosearch,moget_,momspider_libwww_perl_,monster_vx_x_x_type,motor_,mouse_house_,mozdex,msfrontpage,mshelp,msnbot,msnbot_,msnptc,msproxy,muninn_libwww_perl_,muscatferret_,mwdsearch_,nameprotect,nationaldirectory_superspider,naverbot_,nazilla,ndspider_,nec_meshexplorer,nederland_zoek,netcarta_cyberpilot_pro,netmechanic,netmechanic_v_,netscoop_libwww_a,newscan_online_,nhsewalker_,nicebot,nomad_v_x,northstar,npbot,nutch,nutchcvs,objectssearch,occam_,ocelli,ocp_hrs_,omnifind_sanantonio_,ontospider_libwww_perl_,openbot,orbsearch_,os_heritrix,packrat_,pageboy_,parasite_,patric_a,peregrinator_mathematics_,perlcrawler_xavatoria_,pgp_ka_,phpdig_x_x_x,piltdownman_profitnet_myezmail_com,ping_blo_gs,pioneer,pipeliner,plumtreewebaccessor_,pmafind,poirot,pompos,poppi_,portalbspider_,portaljuice_com_,program_shareware_,psbot,psbot_x,puresight,python_urllib,p_p_validator,raven_v_,reciprocal_links_checker_,redcarpet,resume_robot,rhcs_a,riroikrcjrx_grefrxtwo,rixbot,road_runner_imagescape_robot,robbie_,robocrawl,robofox_v_,robot_du_crim_a,robozilla,robozilla_,roffle,root_,rora_ibm_test_crawler_rhlas_,roverbot,rpt_httpclient,rufusbot_,rules_libwww_,sbider,schmozilla,scooter,scooter_g_r_a_b_v_,scrubby,scspider,searchprocess_,seekbot,semanticdiscovery,senrigan_xxxxxx,sensis_web_crawler_,sg_scout,shagseeker_at_http_www_shagseek_com_,shai_hulud,sherlock,shopwiki,simbot_,sitetech_rover,site_valet,slcrawler,slurp,snap_com_beta_crawler_v_,snooper_b_,solbot_lwp_,speedy_spider,spiderbot_,spiderline_,spiderman_,ssearcher_,straight_flash_getterroboplus_,suntek_,surf,surveybot,tamu_cs_irl_crawler,tarantula,tarka,tarspider,techbot,templeton_version_for_platform_,teoma_agent_,teradex_mapper,titan_,titin_,tlspider_,tracerlock,travelbot,travellazerbot,turnitinbot,turnpike_emporium_linkchecker,tutorgigbot,tutorial_crawler_,twiceler_www_cuill_com,ucsd_crawler,udmsearch,uk_searcher_spider,ultraseek,unchaos_crawler_,uoftdb_experiment_,uptimebot,urcpbfyyfh_qxsaxtoscm,urlck_,url_spider_pro,valkyrie_libwww_perl_,versus_,verticrawl,victoria_,vision_search_,void_bot_,voyager,voyager_,vwbot_k_,waol_exe,wdg_validator,webbandit_,webcatcher_,webcollage,webcollage_perl,webcopy_,webcrawler,webindexer,weblayers_,weblinker_libwww_perl_,webmoose__,webquest_,webreaper_webreaper_otway_com_,webs_recruit_co_jp,webtrends,webvac_,webwalk,webwalker_,webwatch,web_robot,web_robot_pegasus,wget,wget_,whatuseek_winona_,winona,wintools,wired_digital_newsbot_,wlm_,wolp_mda_,wotbox,wume_crawler,wwwc_,wwwwanderer_v_,www_mechanize,w_crobot,w_c_validator,w_index,w_mir,w_m_x_xxx,w_pspider_xxx_by_wap_com,xenu_link_sleuth,xget_,yacy_,yahoofeedseeker,yahoofeedseeker_testing,yahooseeker,yahoo_blogs,yahoo_mmcrawler,yahoo_verticalcrawler_formerwebcrawler,ydr_ecjghfxwuxxljqauwpgcgwdkmwnwn,y_oasis,zao_crawler,zealbot,zeus,zeusbot,zipppbot,zyborg,_ahoy_the_homepage_finder_,_hazel_s_ferret_web_hopper_,_hku_www_robot_,_iagent_,_ibm_planetwide_,_joebot_x_x_,_openfind_data_gatherer_openbot_,_openfind_piranha_shark_,_safetynet_robot_,_webfetcher_";
	ts.spiderListReplace="_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_";

	t3=structnew();
	t3["/z/misc/system/redirect"]=true;
	t3["/z/listing/sl/index"]=true;
	t3["/z/misc/slideshow/index"]=true;
	t3["/z/_com/app/walkscore"]=true;
	t3["/z/user/login/index"]=true;
	t3["/z/listing/ajax-geocoder/index"]=true;
	t3["/z/listing/search-form-js/index"]=true;
	t3["/z/listing/inquiry-pop/index"]=true;
	ts.trackingDisabledStruct=t3;
	
	
	// for statistics
	ts.requestCacheIndex=0;	
	ts.arrRequestCache=arraynew(1);
	ts.runningScriptIndex=0;
	ts.runningScriptStruct=structnew();
	ts.resetApplicationTrackerStruct=structnew();
	</cfscript>
</cffunction>

<cffunction name="setupAppGlobals2" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var tempVar=0;
	var t9=0;
	var ds=0;
	var local=structnew();
	var q1=0;
	var t3=0;
	var es=0;
	var qa=0;
	var cfcatch=0;
	var template=0;
	var i=0;
	var _ztemp99_helpStruct=0;
	var ts=arguments.ss;
	var cfquery=0;


    versionCom=createobject("component", "zcorerootmapping.version");
    ts2=versionCom.getVersion();
    ts.databaseVersion=ts2.databaseVersion;
    ts.sourceVersion=ts2.sourceVersion;
    
	if(isDefined('request.zsession.user')){
		request.zos.userSession=duplicate(request.zsession.user);
	}else{
		request.zos.userSession=structnew();
		request.zos.userSession.groupAccess=structnew();	
	}
	ts.uuidCacheStruct=structnew();
	ts.imageLibraryLastDeleteDate="";
	ts.compiledTemplatePathCache=structnew();
	ts.forceUserUpdateSession={};
	
	ts.appComPathStruct=structnew();
	ts.appComPathStruct[10]={name:"blog", cfcPath:"zcorerootmapping.mvc.z.blog.controller.blog", cache:true};
	ts.appComPathStruct[11]={name:"listing", cfcPath:"zcorerootmapping.mvc.z.listing.controller.listing", cache:false};
	ts.appComPathStruct[12]={name:"content", cfcPath:"zcorerootmapping.mvc.z.content.controller.content", cache:true};
	ts.appComPathStruct[13]={name:"rental", cfcPath:"zcorerootmapping.mvc.z.rental.controller.rental", cache:false};
	ts.appComName={};
	for(i in ts.appComPathStruct){
		ts.appComName[ts.appComPathStruct[i].name]=i;
	}
	
	tempVar=createobject("component","zcorerootmapping.functionInclude");
	ts.functions=tempVar.init();
	if(request.zos.allowRequestCFC){
		request.zos.functions=ts.functions;
	}
	application.zcore.functions=ts.functions; 
	ts.serverGlobals.serverhomedir=request.zos.zcoreRootPath;
	ts.serverGlobals.serverdatasource=request.zos.zcoreDatasource;
	ts.serverGlobals.datasource=request.zos.zcoreDatasource;


	dbUpgradeCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.db-upgrade");
	if(not dbUpgradeCom.checkVersion(ts.serverGlobals.serverdatasource)){
		if(request.zos.isTestServer or request.zos.isDeveloper){
			echo('Database upgrade failed');
			abort;
		}
	}

	
	query name="qA" datasource="#ts.serverGlobals.serverdatasource#"{
		writeoutput("SHOW DATABASES like '%#request.zos.zcoredatasource#%' ");
	}
	if(qA.recordcount EQ 0){
		throw("zcorerootmapping ERROR: The database and datasource name must be identical. #ts.serverGlobals.datasource# does not exist in database server. Please correct site globals.", "custom");
	} 
	
	var qDomain=0;
	query name="qDomain" datasource="#ts.serverGlobals.serverdatasource#"{
		writeoutput("SELECT domain_redirect.*, site.site_domain FROM domain_redirect, site 
		WHERE site.site_id = domain_redirect.site_id and 
		site.site_id <> -1 and
		site_deleted=0 and  
		domain_redirect_deleted=0");
	}
	ts.domainRedirectStruct={};
	for(var row in qDomain){
		ts.domainRedirectStruct[row.domain_redirect_old_domain]=row;
	}
	
	// default environment variables
	es=structnew();
	es.live=true;
	es.databaseprefix="";
	es.shortdomain="";
	es.datasource="#request.zos.zcoreDatasource#";
	
	// default global variables
	ds=structnew();
	ds.id="";
	ds.emailCampaignFrom=request.zos.developerEmailFrom;
	ds.emailpopserver="mailserver";
	ds.emailusername=request.zos.developerEmailTo;
	ds.emailpassword="notusedyet";
	ds.emailCampaignFrom="";
	ds.emailCampaignFrom="";
	ds.emailCampaignFrom="";
	ds.editorStylesheet="/stylesheets/style-manager.css";
	ds.editorFonts="";
	ds.typekitURL="";
	ds.maximagewidth="760";
	ds.domainMapping=structnew();
	ds.environment=structnew();
	ds.environment.dev=duplicate(es);
	ds.environment.test=duplicate(es);
	ds.environment.live=duplicate(es);
	
	local.zTempGlobalStruct=StructNew();
	local.zTempCurrentPath="";
	/*ts.abusiveIPStruct=structnew();
	for(local.i=0;local.i LTE 59;local.i++){
		ts.abusiveIPStruct[local.i]=structnew();
	}
	ts.abusiveIPDate=0;
	if(isDefined('application.zcore.abusiveBlockedIpStruct') and structkeyexists(form,  'force') EQ false){
		ts.abusiveBlockedIpStruct=application.zcore.abusiveBlockedIpStruct;
	}else{
		query name="local.qS" datasource="#request.zos.zcoreDatasource#"{
			writeoutput('SELECT ip_block_ip FROM ip_block WHERE ip_block_deleted=0 ');
		}
		ts.abusiveBlockedIpStruct=structnew();
		for(local.i=1;local.i LTE local.qs.recordcount;local.i++){
		ts.abusiveBlockedIpStruct[local.qs.ip_block_ip[local.i]]=true;	
		}
	}*/
	ts.processList=structnew(); 
	ts.serverglobals.serveremail = request.zos.developerEmailTo;
	ts.serverglobals.serverpass = "";
	if(request.zos.cgi.http_host CONTAINS "."&request.zos.testDomain){
		ts.serverglobals.serverdomain = request.zOS.zcoreTestAdminDomain;
		ts.serverglobals.serversecuredomain = request.zOS.zcoreTestAdminDomain;
		ts.serverglobals.servershortdomain = replace(replace(request.zOS.zcoreTestAdminDomain,"http://",""),"https://","");
	}else{
		ts.serverglobals.serverdomain = request.zOS.zcoreAdminDomain;
		ts.serverglobals.serversecuredomain = request.zOS.zcoreAdminDomain;
		ts.serverglobals.servershortdomain = replace(replace(request.zOS.zcoreAdminDomain,"http://",""),"https://","");
	}
	ts.serverglobals.serverdatasource="#request.zos.zcoreDatasource#";
	ts.serverglobals.serverid = 1;
	ts.serverglobals.serversiteroot = ""; 
	ts.serverglobals.servername = ts.serverglobals.servershortdomain;
	ts.serverglobals.serverprivatehomedir = request.zos.zcoreRootPrivatePath;
	ts.serverglobals.serverhomedir = request.zos.zcoreRootPath;
	ts.serverglobals.serverdebugenabled = true;
	ts.serverglobals.serveremailpopserver = "mailserver";
	ts.serverglobals.serveremailpassword = "password";
	ts.serverglobals.serveremailusername = "username";
	arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart 3-1-2'});
	 
	if(fileexists(ts.serverglobals.serverprivatehomedir&"_cache/scripts/sites.json")){
		ts.sitePaths=deserializeJson(application.zcore.functions.zreadfile(ts.serverglobals.serverprivatehomedir&"_cache/scripts/sites.json"));
	}else{
		application[request.zos.installPath&":displaySetupScreen"]=true;
	}
	query name="local.qS" datasource="#request.zos.zcoreDatasource#"{
		writeoutput("SELECT site_id, site_short_domain FROM `#request.zos.zcoreDatasourcePrefix#site` WHERE site_active='1' ");
	}
	if(structkeyexists(application, 'zcore') and structkeyexists(application.zcore, 'siteglobals')){
		ts.siteglobals=application.zcore.siteglobals;
	}else{
		ts.siteglobals={};
	}
	for(local.row in local.qS){
		local.tempPath=application.zcore.functions.zGetDomainInstallPath(local.row.site_short_domain);
		local.tempPath2=application.zcore.functions.zGetDomainWritableInstallPath(local.row.site_short_domain);
		if(not structkeyexists(ts.siteglobals, local.row.site_id) and fileexists(local.tempPath2&"_cache/scripts/global.json")){
			local.tempGlobal=deserializeJson(application.zcore.functions.zreadfile(local.tempPath2&"_cache/scripts/global.json"));
			structappend(local.tempGlobal, ts.serverGlobals, false);
			local.tempGlobal.homeDir=local.tempPath;
			local.tempGlobal.secureHomeDir=local.tempPath;
			local.tempGlobal.privateHomeDir=local.tempPath2; 
			ts.siteglobals[local.row.site_id]=local.tempGlobal;
		}
	} 
	
	arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart 3-1'});
	ts.componentObjectCache=structnew();
	ts.componentObjectCache.cache=CreateObject("component","zcorerootmapping.com.zos.cache");
	ts.componentObjectCache.session=CreateObject("component","zcorerootmapping.com.zos.session");
	ts.componentObjectCache.tracking=CreateObject("component","zcorerootmapping.com.app.tracking");
	ts.componentObjectCache.template=CreateObject("component","zcorerootmapping.com.zos.template");
	ts.componentObjectCache.routing=CreateObject("component", "zcorerootmapping.com.zos.routing");
	ts.componentObjectCache.debugger=CreateObject("component","zcorerootmapping.com.zos.debugger");
	ts.componentObjectCache.user=CreateObject("component","zcorerootmapping.com.user.user");
	ts.componentObjectCache.skin=CreateObject("component","zcorerootmapping.com.display.skin");
	ts.componentObjectCache.status=CreateObject("component","zcorerootmapping.com.zos.status");
	ts.componentObjectCache.email=CreateObject("component","zcorerootmapping.com.app.email");
	ts.componentObjectCache.siteOptionCom=CreateObject("component","zcorerootmapping.com.app.site-option");
	ts.componentObjectCache.imageLibraryCom=CreateObject("component","zcorerootmapping.com.app.image-library");
	ts.componentObjectCache.hook=CreateObject("component","zcorerootmapping.com.zos.hook");
	ts.componentObjectCache.app=CreateObject("component","zcorerootmapping.com.zos.app");
	ts.componentObjectCache.db=createobject("component","zcorerootmapping.com.model.db");
	ts.componentObjectCache.adminSecurityFilter=createobject("component","zcorerootmapping.com.app.adminSecurityFilter");


	
	structappend(ts, ts.componentObjectCache);
	if(request.zos.allowRequestCFC){
		structappend(request.zos, ts.componentObjectCache, true);
	}
	application.zcore.db=ts.db;
	
	arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart 3-2'});
	ts.cacheData={
		tagHashCache:structnew()
	}
	/*
	// this need to be within request.zos.installPath now.
	directory action="list" recurse="yes" directory="/var/jetendo-server/nginx/tagcache/" name="local.qD";
	for(local.row IN local.qD){
		ts.cacheData.tagHashCache[left(local.row.name, len(local.row.name)-5)]=true;
	}
	*/
	request.zos.globals=structnew();
	structappend(request.zos.globals,duplicate(ts.serverGlobals));
	if(request.zos.isdeveloper and isDefined('request.zsession.verifyQueries') and request.zsession.verifyQueries){
		local.verifyQueriesEnabled=true;
	}else{
		local.verifyQueriesEnabled=false;
	}
	ts.dbInitConfigStruct={
		insertIdSQL:"select @zLastInsertId id2, last_insert_id() id",
		datasource:request.zos.globals.serverdatasource,
		tablePrefix:request.zos.zcoreDatasourcePrefix,
		parseSQLFunctionStruct:{
			checkSiteId:application.zcore.functions.zVerifySiteIdsInDBCFCQuery
			//, checkDeletedField:application.zcore.functions.zVerifyDeletedInDBCFCQuery
		},
		verifyQueriesEnabled:local.verifyQueriesEnabled,
		cacheStructKey:'application.zcore.queryCache'
	}
	ts.db.init(ts.dbInitConfigStruct);
	request.zos.queryObject=ts.db.newQuery();
	
	
	local.c=ts.db.getConfig();
	local.c.datasource=request.zos.globals.serverdatasource;
	local.c.verifyQueriesEnabled=false;
	local.c.cacheDisabled=false;
	local.c.autoReset=false;
	request.zos.noVerifyQueryObject=ts.db.newQuery(local.c);

	request.zos.queryObject.sql="SHOW VARIABLES LIKE #request.zos.queryObject.param('version')#";
	
	local.qV=request.zos.queryObject.execute("qV");
	ts.enableFullTextIndex=false;
	if(local.qV.recordcount NEQ 0){
		local.arrV=listtoarray(local.qV.value, ".", false);
		if(local.arrV[1] GTE 5 and local.arrV[2] GTE 6){
			ts.enableFullTextIndex=true;
		}
	}
	
	ts.verifyTablesExcludeStruct={};
	ts.verifyTablesExcludeStruct[request.zos.zcoreDatasource]={
	};
	
	ts.primaryKeyMapStruct={};
	//ts.primaryKeyMapStruct[request.zos.zcoreDatasource&".special_rate"]="rate_id";
	
	ts.helpStruct=structnew();
	local.datasourceUniqueStruct=structnew();
	local.datasourceUniqueStruct[request.zos.zcoredatasource]=true;
	ts.arrGlobalDatasources=structkeyarray(local.datasourceUniqueStruct);
	ts.tableColumns=structnew();
	ts.tablesWithSiteIdStruct=structnew();


	arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart 3-3'});

	query name="local.qD" datasource="#request.zos.zcoredatasource#"{
		writeoutput(" SELECT concat(TABLE_SCHEMA, '.', TABLE_NAME) `table` , COLUMN_NAME, COLUMN_DEFAULT
		FROM information_schema.COLUMNS 
		WHERE  TABLE_SCHEMA IN ('#preserveSingleQuotes(arraytolist(ts.arrGlobalDatasources, "','"))#') ");
	}
	for(local.row in local.qD){
		if(not structkeyexists(ts.tableColumns, local.row.table)){
			ts.tableColumns[local.row.table]={};
		}
		ts.tableColumns[local.row.table][local.row.COLUMN_NAME]=local.row.COLUMN_DEFAULT;
	}
	ts.siteTableColumns={};
	for(local.i in ts.tableColumns[request.zos.zcoreDatasource&".site"]){
		ts.siteTableColumns[replace(replace(local.i, "site_", ""), "_", "", "all")]=ts.tableColumns[request.zos.zcoreDatasource&".site"][local.i];
	}
	for(local.i in ts.siteglobals){
		// force new site table fields to exist immediately after application cache is cleared!
		structappend(ts.siteglobals[local.i], ts.siteTableColumns, false); 
	}
	query name="local.qD" datasource="#request.zos.zcoredatasource#"{
		writeoutput("SELECT concat(TABLE_SCHEMA, '.', TABLE_NAME) `table` 
		FROM information_schema.COLUMNS 
		WHERE COLUMN_NAME = 'site_id' AND 
		TABLE_SCHEMA IN ('#preserveSingleQuotes(arraytolist(ts.arrGlobalDatasources, "','"))#') ");
	}
	for(local.row in local.qD){
		ts.tablesWithSiteIdStruct[local.row.table]=true;
	}
	//structdelete(ts.tablesWithSiteIdStruct, request.zos.zcoreDatasource&".manual_listing");
	
	application.zcore.arrGlobalDatasources=ts.arrGlobalDatasources;
	application.zcore.verifyTablesExcludeStruct=ts.verifyTablesExcludeStruct;
	application.zcore.primaryKeyMapStruct=ts.primaryKeyMapStruct;
	application.zcore.tableColumns=ts.tableColumns;
	application.zcore.siteTableColumns=ts.siteTableColumns;
	application.zcore.tablesWithSiteIdStruct=ts.tablesWithSiteIdStruct;
	if(structkeyexists(application, request.zos.installPath&":dbUpgradeCheckVersion")){
		// verify tables
		verifyTablesCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.verify-tables");
		arrLog=verifyTablesCom.index(true);
		structdelete(application, request.zos.installPath&":dbUpgradeCheckVersion");
	}
	query name="qVersion" datasource="#request.zos.zcoreDatasource#"{
		echo("SELECT * FROM jetendo_setup LIMIT 0,1");
	}
	if(qVersion.recordcount NEQ 0){
		ts.installedDatabaseVersion=qVersion.jetendo_setup_database_version;
	}else{
		ts.installedDatabaseVersion=0;
	}



	arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart 3-4'});
	
	ts.controllerComponentCache=structnew();
	/*ts.modelDataCache=structnew();
	ts.modelDataCache.modelComponentCache=structnew();
	ts.modelDataCache.selectComponentCache=structnew();
	ts.modelDataCache.selectComponent=createobject("component","zcorerootmapping.com.model.select");
	ts.modelDataCache.tableCache=structnew();
	
	if(structkeyexists(form,  'zregeneratemodelcache')){
		local.tempCom=createobject("component","zcorerootmapping.com.model.base");
		local.tempCom._generateModels(ts);
	}*/
	ts.registeredControllerStruct=structnew();
	ts.registeredControllerPathStruct=structnew();
	ts.hookAppCom=structnew();
	request.zos.functions.zUpdateGlobalMVCData(ts);
	if(fileexists(request.zos.installPath&"database-upgrade/tooltips.json")){
		ts.helpStruct=deserializeJson(application.zcore.functions.zreadfile(request.zos.installPath&"database-upgrade/tooltips.json"));
	}
	ts.railowebinfpath=expandpath("/railo-context/");
	ts.railowebinfpath=listdeleteat(ts.railowebinfpath, listlen(ts.railowebinfpath,"/"),"/")&"/";
	
	ts.searchformresetdate=now();
	ts.templateCache=structnew();
	ts.searchFormCache=structnew();
	
	arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart 3-6'});
	if(request.zos.zreset EQ "app" and structkeyexists(application, 'zcore') and structkeyexists(form, 'zforcelisting') EQ false and structkeyexists(application.zcore,'listing') and structkeyexists(application.zcore,'listingStruct')){
		ts.listingStruct=application.zcore.listingStruct;
		ts.listingCom=application.zcore.listingCom;
		if(request.zos.allowRequestCFC){
			request.zos["listingCom"]=ts.listingCom;
		}
	}else{
		ts.listingCom=createobject("component","zcorerootmapping.mvc.z.listing.controller.listing");
		ts.listingStruct=structnew();
		if(request.zos.allowRequestCFC){
			request.zos["listingCom"]=ts.listingCom;
		}
		ts.listingStruct=ts.listingCom.onApplicationStart(ts.listingStruct);
		ts.listingStruct.configCom=ts.listingCom;
	}
	arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart 3-7'});
	ts.skin.onApplicationStart(ts);
	application.zcore=ts;
	</cfscript>
</cffunction>





<cffunction name="OnApplicationStart" localmode="modern" access="public"  returntype="any" output="false" hint="Fires when the application is first created.">
	<cfscript>
	var local=structnew();
	var ts=structnew();
	setting requesttimeout="500";
       
	arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart begin'});
	if(structkeyexists(form, request.zos.urlRoutingParameter) EQ false){
		return;	
	}
	if(isDefined('request.zsession.user')){
		request.zos.userSession=duplicate(request.zsession.user);
	}else{
		request.zos.userSession=structnew();
		request.zos.userSession.groupAccess=structnew();	
	}
	if(structkeyexists(request.zos,'onApplicationStartCalled')){
		return;
	}
	request.zos.onApplicationStartCalled=true;
	if(request.zos.zreset EQ ''){
		if(structkeyexists(application, 'zcoreIsInit') EQ false){
			application.zcoreIsInit=false;
		}else if(application.zcoreIsInit EQ false){
			header statuscode="503" statustext="HTTP Error 503 - Service unavailable";
			writeoutput('<h1>HTTP Error 503 - Service Unavailable</h1>');
			if(request.zos.isdeveloper){
				writeoutput('<p>application.cfc onApplicationStart() is running.</p>');
			}
			writeoutput('<p>Please try again in a few seconds.</p>');
			abort;
		}else{
			application.zcoreIsInit=true;
		}
	}
	if(request.zos.zreset EQ "all"){
		setting requesttimeout="12000";
	}
	
	local.dumpLoadFailed=true;
	local.coreDumpFile=request.zos.zcoreRootCachePath&"scripts/memory-dump/"&server.railo.version&"-zcore.bin";
	local.coreDumpFile2=request.zos.zcoreRootCachePath&"scripts/memory-dump/"&server.railo.version&"-sitestruct.bin";
	local.dumpLoadFailed=false;
	if(fileexists(local.coreDumpFile) and request.zos.zreset NEQ "all" and request.zos.zreset NEQ "app"){
		try{
			ts.zcore=objectload(local.coreDumpFile);
			ts.siteStruct=objectload(local.coreDumpFile2);
			application.zcore=ts.zcore;
			application.siteStruct=ts.siteStruct;
			if(request.zos.allowRequestCFC){
				request.zos.functions=application.zcore.functions;
			}
			application.zcore.functions.zdeletefile(local.coreDumpFile);
			application.zcore.functions.zdeletefile(local.coreDumpFile2);
			if(request.zos.isJavaEnabled){
				local.coreDumpFile3=request.zos.zcoreRootCachePath&"scripts/memory-dump/"&server.railo.version&"-sessions.bin";
				application.sessionStruct=objectload(local.coreDumpFile3);
				application.zcore.functions.zdeletefile(local.coreDumpFile3);
			}
			application.zcore.runOnCodeDeploy=true; 
			application.zcore.runMemoryDatabaseStart=true; 
		}catch(Any local.e){
			local.dumpLoadFailed=true;
		}
	}

	if(local.dumpLoadFailed or request.zos.zreset EQ "app" or request.zos.zreset EQ "all" or not structkeyexists(application, 'zcore') or not structkeyexists(application.zcore, 'functions')){
		ts.zcore=structnew();
		variables.setupAppGlobals1(ts.zcore);
		arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart 2'});
		variables.setupAppGlobals2(ts.zcore);
		arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart 3'});
		application.zcore=ts.zcore;
	}
	if(request.zos.allowRequestCFC){
		request.zos.functions=application.zcore.functions;
	}
	application.zcore.functions.zClearCFMLTemplateCache();
	


	arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart 4'});
	if(structkeyexists(application, 'siteStruct') EQ false){
		application.siteStruct=structnew();
	}  
	for(local.n IN ts.zcore.siteGlobals){
		if((ts.zcore.siteGlobals[local.n].homedir EQ Request.zOSHomeDir and (not structkeyexists(application.siteStruct, local.n) or not structkeyexists(application.siteStruct[local.n], 'getSiteRan'))) or request.zos.zreset EQ "all"){
			local.siteStruct[local.n]=structnew();
			local.siteStruct[local.n].globals=duplicate(ts.zcore.serverglobals);
			structappend(local.siteStruct[local.n].globals,(ts.zcore.siteGlobals[local.n]),true);
			local.siteStruct[local.n].site_id=local.n;
			local.siteStruct[local.n]=application.zcore.functions.zGetSite(local.siteStruct[local.n]);
			arrayClear(request.zos.arrQueryLog);
			application.siteStruct[local.n]=local.siteStruct[local.n];
			application.sitestruct[request.zos.globals.id]=local.siteStruct[local.n];
		}
	} 
	application.zcoreIsInit=true;
	arrayappend(request.zos.arrRunTime, {time:gettickcount('nano'), name:'Application.cfc onApplicationStart end'});
	</cfscript>
	</cffunction>
</cfoutput>