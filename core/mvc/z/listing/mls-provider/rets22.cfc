<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>
<cfscript>
this.retsVersion="1.7";

this.mls_id=22;
if(request.zos.istestserver){
	hqPhotoPath="#request.zos.sharedPath#mls-images/22/";
}else{
	hqPhotoPath="#request.zos.sharedPath#mls-images/22/";
}
this.useRetsFieldName="system";
this.arrTypeLoop=["A","B","C","D","E"];
//this.arrTypeLoop=["CommercialProperty","IncomeProperty","Rental","ResidentialProperty","VacantLand"];
this.arrColumns=listtoarray("BOARDCODE	colisting_member_address	colisting_member_email	colisting_member_fax	colisting_member_name	colisting_member_phone	colisting_member_shortid	colisting_member_url	coselling_member_address	coselling_member_email	coselling_member_fax	coselling_member_name	coselling_member_phone	coselling_member_shortid	coselling_member_url	FEAT20130303191402055377000000	FEAT20130303191418283689000000	FEAT20130303191614868962000000	FEAT20130303192136457093000000	FEAT20130303192342330382000000	FEAT20130303192406427253000000	FEAT20130303192424224044000000	FEAT20130303192448505389000000	FEAT20130303192613677192000000	FEAT20130303192639158718000000	FEAT20130303192710146451000000	FEAT20130303192732303667000000	FEAT20130303192757214251000000	FEAT20130303192819080310000000	FEAT20130303192841762175000000	FEAT20130303192853530677000000	FEAT20130311203427169504000000	FEAT20130311203455364360000000	FEAT20130311203633352493000000	FEAT20130311203651472732000000	FEAT20130311203816668450000000	FEAT20130311203854178425000000	FEAT20130311204037960304000000	FEAT20130311204059244934000000	FEAT20130311204115909928000000	FEAT20130311204143648880000000	FEAT20130311204201421075000000	FEAT20130311204216351611000000	FEAT20130311204234872729000000	FEAT20130312180901287538000000	FEAT20130312180923868874000000	FEAT20130312180943423178000000	FEAT20130312181004923671000000	FEAT20130312184010894153000000	FEAT20130312184432190678000000	FEAT20130312184452532398000000	FEAT20130312184503305368000000	FEAT20130312184517534659000000	FEAT20130312184534388987000000	FEAT20130312184547979158000000	FEAT20130312184622995608000000	FEAT20130312184643010360000000	FEAT20130312184652820129000000	FEAT20130312184706851966000000	FEAT20130312184912484980000000	FEAT20130313160631073350000000	FEAT20130313160631077279000000	FEAT20130313160631469603000000	FEAT20130313160631473319000000	FEAT20130313160631630957000000	FEAT20130313160631645969000000	FEAT20130313160631660601000000	FEAT20130313160631705545000000	FEAT20130313160631825168000000	FEAT20130313160631838989000000	FEAT20130313160631853140000000	FEAT20130313160701732196000000	FEAT20130313160701735985000000	FEAT20130313160701958756000000	FEAT20130313160701962559000000	FEAT20130313160702017264000000	FEAT20130313160702031487000000	FEAT20130313160702063669000000	FEAT20130313160702133164000000	FEAT20130313160719368896000000	FEAT20130313160719372957000000	FEAT20130313160719601137000000	FEAT20130313160719604733000000	FEAT20130313160719685705000000	FEAT20130313160719755982000000	FEAT20130313161226461294000000	FEAT20130313161237397405000000	FEAT20130313161245231945000000	FEAT20130313190815074000000000	FEAT20130313190828603938000000	FEAT20130313190906773058000000	FEAT20130313191049996222000000	FEAT20130313191112947114000000	FEAT20130313191124503957000000	FEAT20130313191146449874000000	FEAT20130313191204391898000000	FEAT20130313192627063999000000	FEAT20130319214220589448000000	FEAT20130319214252023533000000	FEAT20130319214414183622000000	FEAT20130319214503919043000000	FEAT20130319214628003861000000	FEAT20130319214720027988000000	FEAT20130319214903655046000000	FEAT20130319214942471150000000	FEAT20130319215045733772000000	FEAT20130319215139210547000000	FEAT20130319215213923486000000	FEAT20130319215248583193000000	FEAT20130319215317129400000000	FEAT20130326145136634598000000	FEAT20130326145233182918000000	FEAT20130604141844269365000000	FEAT20130604141914741367000000	FEAT20130612161749389935000000	FEAT20130612161808434509000000	FEAT20130612194821347639000000	FEAT20130612194841460123000000	FEAT20130612194858080015000000	FEAT20130612194910083135000000	FEAT20130612194927789339000000	FEAT20130612194950711636000000	FEAT20130612195024083776000000	FEAT20130612195040678965000000	FEAT20130612195519226141000000	FEAT20130612195540414993000000	FEAT20130612195554128745000000	FEAT20130612195606428318000000	FEAT20130612195621538623000000	FEAT20130612195633858405000000	FEAT20130612195644320817000000	FEAT20130612195656438612000000	FEAT20130612195710968169000000	FEAT20130612195730582842000000	FEAT20130612195751390006000000	FEAT20130612195814353659000000	FEAT20130612195832134036000000	FEAT20130612200815226512000000	FEAT20130612200823811366000000	FEAT20130612200832172139000000	FEAT20130612200841087605000000	FEAT20130612200850093596000000	FEAT20130612200900387076000000	FEAT20130612200920178303000000	FEAT20130612200944068549000000	FEAT20130612200951442665000000	FEAT20130612200958761351000000	FEAT20130612201007213294000000	FEAT20130612201016971519000000	FEAT20130612201025271119000000	FEAT20130612201033664294000000	FEAT20130612201055018917000000	FEAT20130612201103718346000000	FEAT20130612201112326058000000	FEAT20130612201121498208000000	FEAT20130612201131602677000000	FEAT20130612201140474891000000	FEAT20130612201149850971000000	FEAT20130612201235915719000000	FEAT20130612201244549880000000	FEAT20130612201252119665000000	FEAT20130612201300214333000000	FEAT20130612201308359317000000	FEAT20130612201315985038000000	FEAT20130612201324842465000000	FEAT20130612201349866919000000	FEAT20130612201357723183000000	FEAT20130612201406004587000000	FEAT20130612201414168103000000	FEAT20130612201423718858000000	FEAT20130612201432156075000000	FEAT20130612201442252778000000	FEAT20130614160744525830000000	FEAT20130614161127957321000000	FEAT20130614161349170117000000	FEAT20130614161737504340000000	FEAT20130708162140967911000000	FEAT20130708162212410860000000	FEAT20130708162638415154000000	FEAT20130708162659233702000000	GF20130226165731387094000000	GF20130226165731427254000000	GF20130226165731429972000000	GF20130226165731432547000000	GF20130226165731434887000000	GF20130226165731437450000000	GF20130226165731474849000000	GF20130226165731479786000000	GF20130226165731557326000000	GF20130226165731564034000000	GF20130226165731566769000000	GF20130226165731571198000000	GF20130226165731574189000000	GF20130226165731576538000000	GF20130226165731591186000000	GF20130226165731602719000000	GF20130226180901462976000000	GF20130226181006088052000000	GF20130226181615784641000000	GF20130226183322711092000000	GF20130226183401757426000000	GF20130226183428681591000000	GF20130226183439864246000000	GF20130226183523439532000000	GF20130226183625437242000000	GF20130226183651996394000000	GF20130226183722703541000000	GF20130304162857190766000000	GF20130304162857252439000000	GF20130304162857335366000000	GF20130304162857373099000000	GF20130304162857541289000000	GF20130304162857760358000000	GF20130304162857785818000000	GF20130304162858465110000000	GF20130304162858532569000000	GF20130304162858580559000000	GF20130304162858707435000000	GF20130304162858760252000000	GF20130304162858854843000000	GF20130304162858885380000000	GF20130304162858945692000000	GF20130304162858984183000000	GF20130304162859011223000000	GF20130304162859141784000000	GF20130306200652563727000000	GF20130306200706288865000000	GF20130306200748323850000000	GF20130306200811311544000000	GF20130306200853143209000000	GF20130307163524340443000000	GF20130313160629991243000000	GF20130313160630470904000000	GF20130313160630596209000000	GF20130313160631364646000000	GF20130313160631930033000000	GF20130313160632099768000000	GF20130313160632288140000000	GF20130313160632432737000000	GF20130313160632471914000000	GF20130313160632499631000000	GF20130313160632632644000000	GF20130313160701087172000000	GF20130313160701230816000000	GF20130313160701309776000000	GF20130313160701380862000000	GF20130313160701439929000000	GF20130313160701550178000000	GF20130313160701663397000000	GF20130313160701687658000000	GF20130313160701761964000000	GF20130313160701860449000000	GF20130313160702141121000000	GF20130313160702258186000000	GF20130313160702301802000000	GF20130313160702382495000000	GF20130313160702405956000000	GF20130313160702462897000000	GF20130313160702493319000000	GF20130313160702569820000000	GF20130313160702630730000000	GF20130313160702672864000000	GF20130313160702700206000000	GF20130313160702830745000000	GF20130313160718864886000000	GF20130313160718904233000000	GF20130313160719015644000000	GF20130313160719324809000000	GF20130313160719498393000000	GF20130313160719833262000000	GF20130313160719925404000000	GF20130313160720009083000000	GF20130313160720031347000000	GF20130313160720087170000000	GF20130313160720191088000000	GF20130313160720249829000000	GF20130313160720288508000000	GF20130313160720315061000000	GF20130313162111126800000000	GF20130313162138419721000000	GF20130313162509346678000000	GF20130313162526237784000000	GF20130313162539308166000000	GF20130313162605183406000000	GF20130313192250062794000000	GF20130313201301289976000000	GF20130313202052440770000000	GF20130313202405130588000000	GF20130313203958104166000000	GF20130319214025301462000000	GF20130325004325380721000000	GF20130325004350594096000000	GF20130325004724016354000000	GF20130325004802989662000000	GF20130325004839543181000000	GF20130325004927153694000000	GF20130325005028050581000000	GF20130325005136509718000000	GF20130325005211886712000000	GF20130325005403527424000000	GF20130325005430836869000000	GF20130325005532206518000000	GF20130325005644860196000000	GF20130325011324862288000000	GF20130325011351253489000000	GF20130325011543709339000000	GF20130325011621775162000000	GF20130325011707384047000000	GF20130604154546211961000000	GF20130604183058509522000000	GF20130604202930078590000000	GF20130604202940710553000000	GF20130604203750505027000000	GF20130606024608499268000000	GF20130611133802518156000000	GF20130612141103459183000000	GF20130612141114419516000000	GF20130612194427521223000000	GF20130612194516437733000000	GF20130612194532666240000000	GF20130612194554752046000000	GF20130612194621309993000000	GF20130612194635986201000000	GF20130612194642909384000000	GF20130612210517078686000000	GF20130613133554474391000000	GF20130613133713422689000000	GF20130613133722653768000000	GF20130613161043853028000000	GF20130614153345482319000000	GF20130618140532666471000000	GF20130702134753249824000000	GF20130702135847480250000000	GF20130702135916588997000000	GF20130702140004488300000000	GF20130702140346507495000000	LIST_0	LIST_1	LIST_10	LIST_101	LIST_104	LIST_105	LIST_106	LIST_107	LIST_108	LIST_109	LIST_11	LIST_110	LIST_112	LIST_113	LIST_114	LIST_115	LIST_117	LIST_118	LIST_119	LIST_12	LIST_120	LIST_121	LIST_122	LIST_123	LIST_124	LIST_125	LIST_126	LIST_13	LIST_130	LIST_131	LIST_132	LIST_133	LIST_134	LIST_135	LIST_137	LIST_14	LIST_15	LIST_16	LIST_17	LIST_18	LIST_19	LIST_2	LIST_20	LIST_21	LIST_22	LIST_23	LIST_27	LIST_28	LIST_29	LIST_3	LIST_30	LIST_31	LIST_33	LIST_34	LIST_35	LIST_37	LIST_39	LIST_4	LIST_40	LIST_41	LIST_43	LIST_46	LIST_47	LIST_48	LIST_49	LIST_5	LIST_51	LIST_52	LIST_53	LIST_54	LIST_56	LIST_57	LIST_58	LIST_59	LIST_6	LIST_60	LIST_61	LIST_62	LIST_63	LIST_65	LIST_66	LIST_67	LIST_68	LIST_69	LIST_7	LIST_71	LIST_72	LIST_73	LIST_74	LIST_75	LIST_76	LIST_77	LIST_78	LIST_79	LIST_8	LIST_80	LIST_81	LIST_82	LIST_83	LIST_84	LIST_85	LIST_86	LIST_87	LIST_88	LIST_89	LIST_9	LIST_90	LIST_91	LIST_92	LIST_93	LIST_94	LIST_95	LIST_97	listing_member_address	listing_member_email	listing_member_fax	listing_member_name	listing_member_phone	listing_member_shortid	listing_member_url	listing_office_address	listing_office_email	listing_office_fax	listing_office_name	listing_office_phone	listing_office_shortid	listing_office_url	ROOM_B1_room_length	ROOM_B1_room_width	ROOM_BA_room_length	ROOM_BA_room_width	ROOM_BR1_room_length	ROOM_BR1_room_width	ROOM_BR2_room_length	ROOM_BR2_room_rem	ROOM_BR2_room_width	ROOM_BR3_room_length	ROOM_BR3_room_rem	ROOM_BR3_room_width	ROOM_BR4_room_length	ROOM_BR4_room_rem	ROOM_BR4_room_width	ROOM_DN_room_length	ROOM_DN_room_rem	ROOM_DN_room_width	ROOM_FR_room_length	ROOM_FR_room_rem	ROOM_FR_room_width	ROOM_KI_room_length	ROOM_KI_room_rem	ROOM_KI_room_width	ROOM_LV_room_length	ROOM_LV_room_rem	ROOM_LV_room_width	ROOM_MB_room_length	ROOM_MB_room_rem	ROOM_MB_room_width	ROOM_OR1_room_length	ROOM_OR1_room_width	ROOM_OT1_room_length	ROOM_OT1_room_rem	ROOM_OT1_room_width	ROOM_PR_room_length	ROOM_PR_room_rem	ROOM_PR_room_width	ROOM_PT_room_length	ROOM_PT_room_rem	ROOM_PT_room_width	selling_member_address	selling_member_email	selling_member_fax	selling_member_name	selling_member_phone	selling_member_shortid	selling_member_url	selling_office_address	selling_office_email	selling_office_fax	selling_office_name	selling_office_phone	selling_office_shortid	selling_office_url	UNBRANDEDIDXVIRTUALTOUR",chr(9));
this.arrFieldLookupFields=listtoarray("LGT220130226165731231246000000,LGT120130226165731231246000000,LGT320130226165731231246000000,20130226165748400000000000,20130226165748700000000000,20130226165748800000000000,20130226165748500000000000,20130226165748300000000000,20130226165749000000000000,20130226165748600000000000,20130226165748900000000000,20130303192406400000000000,20130303192613700000000000,20130303192639200000000000,20130303192710100000000000,20130303192732300000000000,20130303192757200000000000,20130303192819100000000000,20130303192841800000000000,20130303192853500000000000,20130614160744500000000000,20130303191418300000000000,20130604141914700000000000,20130303192448500000000000,20140224170426900000000000,20140224170552800000000000,20140224170702000000000000,GFLU20130226183428681591000000,GFLU20130226183322711092000000,GFLU20130226165731429972000000,GFLU20130604202930078590000000,GFLU20130226183523439532000000,GFLU20130226165731564034000000,GFLU20130226165731591186000000,GFLU20130226165731479786000000,GFLU20130226181615784641000000,GFLU20130604183058509522000000,GFLU20130226165731432547000000,GFLU20130604202940710553000000,GFLU20130226165731427254000000,GFLU20130226180901462976000000,GFLU20130226183401757426000000,GFLU20130226165731571198000000,GFLU20130226183439864246000000,GFLU20130226165731576538000000,GFLU20130226183651996394000000,GFLU20130226165731566769000000,GFLU20130226165731602719000000,GFLU20130606024608499268000000,GFLU20130614153345482319000000,GFLU20130226183625437242000000,GFLU20130611133802518156000000,GFLU20130226165731434887000000,GFLU20130226165731574189000000,GFLU20130226165731437450000000,GFLU20130226165731474849000000,GFLU20130226165731387094000000,GFLU20130226183722703541000000,GFLU20130604154546211961000000,GFLU20130226165731557326000000,GFLU20130226181006088052000000,GFLU20130604203750505027000000,GFLU20130702134753249824000000,20130226165749200000000000,20130226165749100000000000,20130226165749300000000000,20130226165749400000000000,20130311203854200000000000,20130311204038000000000000,20130311204059200000000000,20130311204115900000000000,20130311204216300000000000,20130311204143600000000000,20130311204201400000000000,20130311204234900000000000,20130614161128000000000000,20130311203455400000000000,20130708162212400000000000,20140224204427900000000000,20140224204442800000000000,20140224204455600000000000,GFLU20130304162857252439000000,GFLU20130304162857335366000000,GFLU20130612141103459183000000,GFLU20130304162857373099000000,GFLU20130304162857541289000000,GFLU20130304162857190766000000,GFLU20130304162857760358000000,GFLU20130304162857785818000000,GFLU20130612141114419516000000,GFLU20130306200811311544000000,GFLU20130304162858465110000000,GFLU20130304162858580559000000,GFLU20130304162858707435000000,GFLU20130304162858760252000000,GFLU20130304162858532569000000,GFLU20130306200652563727000000,GFLU20130307163524340443000000,GFLU20130304162858854843000000,GFLU20130304162858885380000000,GFLU20130304162858945692000000,GFLU20130306200706288865000000,GFLU20130306200853143209000000,GFLU20130306200748323850000000,GFLU20130304162858984183000000,GFLU20130304162859011223000000,GFLU20130304162859141784000000,GFLU20130702135847480250000000,20130226165749500000000000,20130226165749800000000000,20130226165749700000000000,20130226165750000000000000,20130226165749600000000000,20130226165749900000000000,20130313160631600000000000,20130313160631700000000000,20130313160631800000000000,20130614161349200000000000,20130313160631100000000000,20130612161808400000000000,20140224204638600000000000,20140224204532700000000000,20140224204615100000000000,GFLU20130313160629991243000000,GFLU20130313160630470904000000,GFLU20130313162138419721000000,GFLU20130313160630596209000000,GFLU20130313162509346678000000,GFLU20130313162111126800000000,GFLU20130313160631364646000000,GFLU20130313160632099768000000,GFLU20130313160631930033000000,GFLU20130313162605183406000000,GFLU20130313162539308166000000,GFLU20130313160632288140000000,GFLU20130313160632432737000000,GFLU20130313162526237784000000,GFLU20130313160632471914000000,GFLU20130313160632499631000000,GFLU20130313160632632644000000,GFLU20130702135916588997000000,20130226165750200000000000,20130226165750300000000000,20130226165750100000000000,20130226165750400000000000,20130313190815100000000000,20130313190828600000000000,20130313190906800000000000,20130313160702000000000000,20130313160701700000000000,20130708162659200000000000,20140224204719300000000000,20140224204701200000000000,20140224204709700000000000,GFLU20130313192250062794000000,GFLU20130313160701230816000000,GFLU20130618140532666471000000,GFLU20130313160701309776000000,GFLU20130313160701550178000000,GFLU20130313160701439929000000,GFLU20130313160701663397000000,GFLU20130313160701687658000000,GFLU20130313203958104166000000,GFLU20130313160701761964000000,GFLU20130313202052440770000000,GFLU20130313160701860449000000,GFLU20130313160702141121000000,GFLU20130313160702301802000000,GFLU20130313160702405956000000,GFLU20130313160702258186000000,GFLU20130313160702382495000000,GFLU20130313201301289976000000,GFLU20130313160702493319000000,GFLU20130313160702462897000000,GFLU20130313160701087172000000,GFLU20130313160702569820000000,GFLU20130313160702630730000000,GFLU20130313160701380862000000,GFLU20130313160702672864000000,GFLU20130313160702700206000000,GFLU20130313160702830745000000,GFLU20130313202405130588000000,GFLU20130702140004488300000000,20130226165750500000000000,20130226165750600000000000,20130226165750700000000000,20130226165750900000000000,20130226165750800000000000,20130313160719700000000000,20130614161737500000000000,20130319215045700000000000,20130319214903600000000000,20130313160719400000000000,GFLU20130325005136509718000000,GFLU20130325011707384047000000,GFLU20130313160718904233000000,GFLU20130325004724016354000000,GFLU20130319214025301462000000,GFLU20130325005532206518000000,GFLU20130325005430836869000000,GFLU20130313160718864886000000,GFLU20130612210517078686000000,GFLU20130325005211886712000000,GFLU20130313160719015644000000,GFLU20130325004839543181000000,GFLU20130325005644860196000000,GFLU20130325011351253489000000,GFLU20130613133554474391000000,GFLU20130313160719324809000000,GFLU20130325005403527424000000,GFLU20130325005028050581000000,GFLU20130313160719498393000000,GFLU20130325011324862288000000,GFLU20130313160719925404000000,GFLU20130313160720031347000000,GFLU20130313160720009083000000,GFLU20130313160719833262000000,GFLU20130325004325380721000000,GFLU20130313160720087170000000,GFLU20130613161043853028000000,GFLU20130313160720191088000000,GFLU20130325011621775162000000,GFLU20130313160720249829000000,GFLU20130325011543709339000000,GFLU20130325004927153694000000,GFLU20130613133713422689000000,GFLU20130313160720288508000000,GFLU20130613133722653768000000,GFLU20130325004350594096000000,GFLU20130325004802989662000000,GFLU20130612194427521223000000,GFLU20130612194516437733000000,GFLU20130612194532666240000000,GFLU20130612194554752046000000,GFLU20130612194621309993000000,GFLU20130612194635986201000000,GFLU20130612194642909384000000,GFLU20130313160720315061000000,GFLU20130702140346507495000000,20130819094205700000000000,20130819094205800000000000,20130819094205900000000000,20130819094206000000000000,20130819094206100000000000,20130819094206200000000000",",");
this.mls_provider="rets22";
variables.resourceStruct=structnew();
variables.resourceStruct["property"]=structnew();
variables.resourceStruct["property"].resource="property";
variables.resourceStruct["property"].id="list_105";
this.emptyStruct=structnew();
variables.resourceStruct["office"]=structnew();
variables.resourceStruct["office"].resource="office";
variables.resourceStruct["office"].id="office_0";
variables.resourceStruct["agent"]=structnew();
variables.resourceStruct["agent"].resource="activeagent";
variables.resourceStruct["agent"].id="member_0";

variables.tableLookup=structnew();
variables.tableLookup["A"]="A";
variables.tableLookup["B"]="B";
variables.tableLookup["C"]="C";
variables.tableLookup["D"]="D"; // this one was actually blank
variables.tableLookup["E"]="E";  

/*
t5=structnew();

t5["county"]=structnew();

t5["countyreverse"]=structnew();
for(n in t5["county"]){
t5["countyreverse"][t5["county"][n]]=n;
}



t5["style"]=structnew();


t5["frontage"]=structnew();



t5["subtypeid"]=structnew();


t5["typeid"]=structnew();

t5["view"]=structnew();


t5["county"].lookupfield="county";
t5["frontage"].lookupfield="frontage";
t5["subtypeid"].lookupfield="sub_type_id";
t5["typeid"].lookupfield="type_id";
t5["style"].lookupfield="style";
t5["view"].lookupfield="view";
this.remapFieldStruct=t5;
*/
</cfscript>

<cffunction name="deleteListings" localmode="modern" output="no" returntype="any">
	<cfargument name="idlist" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var arrId=listtoarray(mid(replace(arguments.idlist," ","","ALL"),2,len(arguments.idlist)-2),"','");
	super.deleteListings(arguments.idlist);
	
	db.sql="DELETE FROM #db.table("rets22_property", request.zos.zcoreDatasource)#  
	WHERE rets22_list_105 IN (#db.trustedSQL(arguments.idlist)#)";
	db.execute("q"); 
	</cfscript>
</cffunction>

<cffunction name="initImport" localmode="modern" output="no" returntype="any">
	<cfargument name="resource" type="string" required="yes">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var local=structnew();
	var qZ=0;
	super.initImport(arguments.resource, arguments.sharedStruct);
	
	arguments.sharedStruct.lookupStruct.cityRenameStruct=structnew();
	</cfscript>
</cffunction>

<cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var rs5=0;
	var r222=0;
	var values="";
	var newlist="";
	var i=0;
	var columnIndex=structnew();
	var cityname=0;
	var cid=0;
	var a9=arraynew(1);
	var ts=0;
	var col=0;
	var tmp=0;
	var uns=0;
	var arrt3=0;
	var address=0;
	var arrt2=0;
	var datacom=0;
	var ad=0;
	var liststatus=0;
	var s2=0;
	var curlat=0;
	var curlong=0;
	var ts2=0;
	var s=0;
	var arrT=0;
	var rs=0;
	
	if(structcount(this.emptyStruct) EQ 0){
		for(i=1;i LTE arraylen(this.arrColumns);i++){
			this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
		}
	}
	
	for(i=1;i LTE arraylen(arguments.ss.arrData);i++){
		if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxSkipDataIndexStruct, i) EQ false){
			arrayappend(a9, arguments.ss.arrData[i]);	
		}
	}
	arguments.ss.arrData=a9;
	ts=duplicate(this.emptyStruct);
	if(arraylen(arguments.ss.arrData) NEQ arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
		application.zcore.functions.zdump(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);
		application.zcore.functions.zdump(arguments.ss.arrData);
		application.zcore.functions.zabort();
	}  
	if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
		application.zcore.template.fail("RETS#this.mls_id#: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
	}
	for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
		col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)].longname);
		ts["rets22_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
		if(arguments.ss.arrData[i] EQ '0'){
			arguments.ss.arrData[i]="";	
		}
		if(structkeyexists(ts,col)){
			if(ts[col] NEQ ""){
				ts[col]=ts[col]&","&application.zcore.functions.zescape(arguments.ss.arrData[i]);
			}else{
				ts[col]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			}
		}else{ 
			ts[col]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
		}
		//ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=ts[col];
		columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
	}
	if(not structkeyexists(ts, "list price")){
		ts["list price"]=replace(ts["original list price"],",","","ALL");
	}else{
		ts["list price"]=replace(ts["list price"],",","","ALL");
	}
	// need to clean this data - remove not in subdivision, 0 , etc.
	
	local.listing_subdivision=this.getRetsValue("property", ts["rets22_list_8"], "LIST_77",ts['Subdivision/Condo Name']);
	if(local.listing_subdivision NEQ ""){
		if(findnocase(","&local.listing_subdivision&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
			local.listing_subdivision="";
		}else{
			local.listing_subdivision=application.zcore.functions.zFirstLetterCaps(local.listing_subdivision);
		}
	} 
	ts['zip code']=this.getRetsValue("property", ts["rets22_list_8"], "LIST_43",ts['zip code']); 
	
	this.price=ts["list price"];
	local.listing_price=ts["list price"];
	cityName="";
	cid=0;
	ts["State/Province"]="FL";
	//writeoutput(ts['city']&"|"&ts["rets22_list_39"]&"<br>");
	//writedump(structkeyarray(application.zcore.listingStruct.mlsStruct[22].sharedStruct.metaStruct["property"].typeStruct));
	ts['city']=this.getRetsValue("property", ts["rets22_list_8"], "LIST_39", ts['city']);
	if(structkeyexists(request.zos.listing.cityStruct, ts["city"]&"|"&ts["State/Province"])){
		cid=request.zos.listing.cityStruct[ts["city"]&"|"&ts["State/Province"]];
	}
	//writeoutput(cid&"|"&ts["city"]&"|"&ts["State/Province"]); 
	if(cid EQ 0 and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct, ts['zip code'])){
		cityName=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct[ts['zip code']];
		ts["city"]=listgetat(cityName,1,"|");
		if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&ts["State/Province"])){
			cid=request.zos.listing.cityStruct[cityName&"|"&ts["State/Province"]];
		}
	}
	local.listing_county=this.listingLookupNewId("county",ts['county']);
	
	local.listing_parking=this.listingLookupNewId("parking",ts['Parking']);

	local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type",ts['rets22_list_9']);
	
	local.listing_type_id=this.listingLookupNewId("listing_type",ts['rets22_list_8']);

	ad=ts['street ##'];
	if(ad NEQ 0){
		address="#ad# ";
	}else{
		address="";	
	}
	ts['street suffix']=this.getRetsValue("property", ts["rets22_list_8"], "LIST_37",ts['street suffix']);
	ts['street dir']=this.getRetsValue("property", ts["rets22_list_8"], "LIST_33",ts['street dir']);
	address&=application.zcore.functions.zfirstlettercaps(ts['Street Dir']&" "&ts['street name']&" "&ts['street suffix']);
	curLat=ts["rets22_list_46"];
	curLong=ts["rets22_list_47"];
	if(curLat EQ "" and trim(address) NEQ ""){
		rs5=this.baseGetLatLong(address,ts['State/Province'],ts['zip code'], arguments.ss.listing_id);
		curLat=rs5.latitude;
		curLong=rs5.longitude;
	}
	
	if(ts['Unit ##'] NEQ ''){
		address&=" Unit: "&ts["Unit ##"];	
	}else if(ts['Condo Unit ##'] NEQ ''){
		address&=" Unit: "&ts["Condo Unit ##"];
	}
	
	
	
	
	s2=structnew();
	liststatus=this.getRetsValue("property", ts["rets22_list_8"], 'list_15', ts["status"]);
	if(liststatus EQ "Active"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
	}else if(liststatus EQ "Withdrawn"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["withdrawn"]]=true;
	}else if(liststatus EQ "Pending"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["pending"]]=true;
	}else if(liststatus EQ "Expired"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["expired"]]=true;
	}else if(liststatus EQ "Closed"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["sold"]]=true;
	}else if(liststatus EQ "Contingent"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["contingent"]]=true;
	}else if(liststatus EQ "Deleted"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["deleted"]]=true;
	}else if(liststatus EQ "Cancelled"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["cancelled"]]=true;
	}
	local.listing_liststatus=structkeylist(s2,",");
	
	arrT3=[];
	uns=structnew();
	tmp=ts['style'];
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("style",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	tmp=ts['property style'];
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("style",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	tmp=ts['dwelling'];
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("style",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	local.listing_style=arraytolist(arrT3);
	
	// view & frontage
	arrT3=[];
	
	uns=structnew();
	tmp=ts['Waterfront Type'];
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("frontage",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	local.listing_frontage=arraytolist(arrT3); 
	
	arrT2=[]; 
	uns=structnew();
	tmp=ts['Dwelling View'];
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("view",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT2,tmp);
			}
		}
	}
	local.listing_view=arraytolist(arrT2);
	

	local.listing_pool=0; 
	pt={
		"A":{
			key:"rets22_GF20130226165731566769000000",
			data:{
				"15373EEHYRPV":true, 
				"1536QBSXEUN4":true, 
				"1536QBSWLBCA":true
			}
		},
		"B":{
			key:"rets22_GF20130304162858707435000000",
			data:{
				"156ZJMT9EDPD":true,
				"156ZJMTK17WU":true,
				"156ZJMTUERQ3":true
			}
		},
		"D":{
			key:"rets22_GF20130313160702258186000000",
			data:{
				"1541KGQNC9FJ":true,
				"1541KGQNBTVG":true,
				"1541KGQNC05P":true,
				"1541KGQNC6C2":true
			}
		}
	};
	local.listing_pool=0;
	for(i in pt){
		if(i EQ ts.rets22_list_8){
			arrPool=listtoarray(ts[pt[i].key], ",");
			for(n=1;n LTE arraylen(arrPool);n++){
				if(structkeyexists(pt[i].data, arrPool[n])){
					local.listing_pool=1;
					break;
				}
			}
		}
	}

	if(ts.rets22_list_8 EQ "E" or ts.rets22_list_8 EQ "C" or ts.rets22_list_8 EQ "D" or ts.rets22_list_8 EQ "B") {
	}else{
		local.backup48=ts["rets22_list_48"];
		ts["rets22_list_48"]=ts["rets22_list_49"];
		ts["rets22_list_49"]=local.backup48;
	}
			
	//if(structkeyexists(variables.tableLookup,ts.rets22_list_8)){
		//  ts["rets22_list_8"]
		ts=this.convertRawDataToLookupValues(ts, ts["rets22_list_8"], ts["rets22_list_8"]);//variables.tableLookup[ts.rets22_list_8]);
	//}
	
	ts2=structnew();
	ts2.field="";
	ts2.yearbuiltfield=ts['year built'];
	ts2.foreclosureField="";
	
	s=this.processRawStatus(ts2);
	
	if(ts["rets22_list_8"] EQ "D"){//structkeyexists(ts, 'Rental Price') and ts['Rental Price'] NEQ ""){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
	}else{
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
	} 
	if(structkeyexists(ts, 'rets22_list_71')){
		if(ts['rets22_list_71'] CONTAINS 'hud'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["hud"]]=true;
		}
		if(ts['rets22_list_71'] CONTAINS 'relo company'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["relo company"]]=true;
		}
		if(ts['rets22_list_71'] CONTAINS 'auction'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["auction"]]=true;
		}
		if(ts['rets22_list_71'] CONTAINS 'bank owned'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}
		if(ts['rets22_list_71'] CONTAINS 'short sale'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}   
	}
	local.listing_status=structkeylist(s,",");
	
	local.arrRoom=listToArray('room_br2_room,room_br3_room,room_br4_room,room_dn_room,room_fr_room,room_ki_room,room_lv_room,room_mb_room,room_ot1_room,room_pr_room,room_pt_room,room_b1_room,room_ba_room,room_br1_room,room_br2_room,room_br3_room,room_br4_room,room_dn_room,room_fr_room,room_ki_room,room_lv_room,room_or1_room', ',');
	for(i=1;i LTE arraylen(local.arrRoom);i++){
		if(structkeyexists(ts, "rets22_"&local.arrRoom[i]&"_length") and ts["rets22_"&local.arrRoom[i]&"_length"] NEQ ""){
			ts["rets22_"&local.arrRoom[i]&"_length"]=ts["rets22_"&local.arrRoom[i]&"_width"]&"x"&ts["rets22_"&local.arrRoom[i]&"_length"];
		}
	}
	dataCom=this.getRetsDataObject();
	local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
	local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
	local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
	
	rs=structnew();
	rs.listing_id=arguments.ss.listing_id;
	rs.listing_acreage=ts["Acreage"];
	if(structkeyexists(ts, "Baths")){
		rs.listing_baths=ts["Baths"];
	}else if(structkeyexists(ts, 'Baths - Total')){
		rs.listing_baths=ts["Baths - Total"];
	}else{
		rs.listing_baths='';
	}
	rs.listing_halfbaths=ts["Baths - Half"];
	rs.listing_beds=ts["Bedrooms"];
	rs.listing_city=cid;
	rs.listing_county=local.listing_county;
	rs.listing_frontage=","&local.listing_frontage&",";
	rs.listing_frontage_name="";
	rs.listing_price=ts["list price"];
	rs.listing_status=","&local.listing_status&",";
	rs.listing_state=ts["State/Province"];
	rs.listing_type_id=local.listing_type_id;
	rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
	rs.listing_style=","&local.listing_style&",";
	rs.listing_view=","&local.listing_view&",";
	if(ts.rets22_list_8 EQ "E" or ts.rets22_list_8 EQ "C" or ts.rets22_list_8 EQ "D" or ts.rets22_list_8 EQ "B") {
		rs.listing_lot_square_feet=ts["Lot SqFt"];
		if(not structkeyexists(ts, "SqFt - Living")){
			rs.listing_square_feet=ts["SqFt - Building Ttl"];
		}else{
			rs.listing_square_feet=ts["SqFt - Living"];
		}
	}else{
		rs.listing_lot_square_feet=ts["rets22_list_48"];
		rs.listing_square_feet=ts["rets22_list_49"]; 
	}
	rs.listing_subdivision=local.listing_subdivision;
	rs.listing_year_built=ts["year built"];
	rs.listing_office=ts["Office ID"];
	rs.listing_agent=ts["Agent ID"];
	rs.listing_latitude=curLat;
	rs.listing_longitude=curLong;
	rs.listing_pool=local.listing_pool;
	rs.listing_photocount=ts["Picture Count"];
	rs.listing_coded_features="";
	rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
	rs.listing_primary="0";
	rs.listing_mls_id=arguments.ss.listing_mls_id;
	rs.listing_address=trim(address);
	rs.listing_zip=ts["zip code"];
	rs.listing_condition="";
	rs.listing_parking=local.listing_parking;
	rs.listing_region="";
	rs.listing_tenure="";
	rs.listing_liststatus=local.listing_liststatus;
	rs.listing_data_remarks=ts["Narrative"];
	rs.listing_data_address=trim(address);
	rs.listing_data_zip=trim(ts["zip code"]);
	rs.listing_data_detailcache1=local.listing_data_detailcache1;
	rs.listing_data_detailcache2=local.listing_data_detailcache2;
	rs.listing_data_detailcache3=local.listing_data_detailcache3; 
	return {
		listingData:rs,
		columnIndex:columnIndex,
		arrData:arguments.ss.arrData
	};
	</cfscript>
</cffunction>
    
<cffunction name="getJoinSQL" localmode="modern" output="yes" returntype="any">
	<cfargument name="joinType" type="string" required="no" default="INNER">
	<cfscript>
	var db=request.zos.queryObject;
	</cfscript>
	<cfreturn "#arguments.joinType# JOIN #db.table("rets22_property", request.zos.zcoreDatasource)# rets22_property ON rets22_property.rets22_list_105 = listing.listing_id">
</cffunction>

    <cffunction name="getPropertyListingIdSQL" localmode="modern" output="yes" returntype="any">
    	<cfreturn "rets22_property.rets22_list_105">
    </cffunction>
    <cffunction name="getListingIdField" localmode="modern" output="yes" returntype="any">
    	<cfreturn "rets22_list_105">
    </cffunction>
    
<cffunction name="getDetails" localmode="modern" output="yes" returntype="any">
	<cfargument name="query" type="query" required="yes">
	<cfargument name="row" type="numeric" required="no" default="#1#">
	<cfargument name="fulldetails" type="boolean" required="no" default="#false#">
	<cfscript>
	var db=request.zos.queryObject;
	var q1=0;
	var t44444=0;
	var t99=0;
	var qOffice=0;
	var details=0;
	var i=0;
	var t1=0;
	var t3=0;
	var t2=0;
	var i10=0;
	var value=0;
	var n=0;
	var column=0;
	var arrV=0;
	var arrV2=0;
	var idx=this.baseGetDetails(arguments.query, arguments.row, arguments.fulldetails);
	t99=gettickcount();
	idx["features"]="";
	idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
	
	t44444=0;
	request.lastPhotoId=idx.listing_id;
	if(idx.listing_photocount EQ 0){
		idx["photo1"]='/z/a/listing/images/image-not-available.gif';
	}else{
		i=1;
		for(i=1;i LTE idx.listing_photocount;i++){
			local.fNameTemp1="22-"&idx.urlMlsPid&"-"&i&".jpeg";
			local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
			idx["photo"&i]=request.zos.retsPhotoPath&'22/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		}
	} 
	db.sql="select * from #db.table("rets22_office", request.zos.zcoreDatasource)# rets22_office 
	where rets22_office_0=#db.param(idx.listing_office)#";
	qOffice=db.execute("qOffice");  
	idx["agentName"]="";
	idx["agentPhone"]="";
	idx["agentEmail"]="";
	idx["officeName"]="";
	if(qOffice.recordcount NEQ 0){
		idx["officeName"]=qOffice.rets22_office_2;
	}
	idx["officePhone"]="";
	idx["officeCity"]="";
	idx["officeAddress"]="";
	idx["officeZip"]="";
	idx["officeState"]="";
	idx["officeEmail"]="";
		
	idx["virtualtoururl"]=arguments.query["rets22_unbrandedidxvirtualtour"];
	idx["zipcode"]=arguments.query["listing_zip"][arguments.row];
	idx["maintfees"]="";
	if(arguments.query["rets#this.mls_id#_FEAT20130612195730582842000000"][arguments.row] NEQ ""){
		idx["maintfees"]=arguments.query["rets#this.mls_id#_FEAT20130612195730582842000000"][arguments.row];
	}
	
	</cfscript>
	<cfsavecontent variable="details"><table class="ztablepropertyinfo">
	#idx.listing_data_detailcache1#
	#idx.listing_data_detailcache2#
	#idx.listing_data_detailcache3#
	</table></cfsavecontent>
	<cfscript>
	idx.details=details;
	return idx;
	</cfscript>
</cffunction>
    
<cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
	<cfargument name="mls_pid" type="string" required="yes">
	<cfargument name="num" type="numeric" required="no" default="#1#">
	<cfscript>
	request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
	local.fNameTemp1="22-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
	local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
	return request.zos.retsPhotoPath&'22/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
	
	</cfscript>
</cffunction>
	
<cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
	<cfscript>
	var i=0;
	var s=0;
	var arrSQL=[];
	var fd=0;
	var arrError=[];
	var i2=0;
	var tmp=0;
	var g=0;
	var db=request.zos.queryObject;
	var qD2=0;
	var arrC=0;
	var tempState=0;
	var failStr=0;
	var qD=0;
	var qZ=0;
	var cityCreated=false;
	//writedump(structkeyarray(application.zcore.listingStruct.mlsStruct["22"].sharedStruct.metaStruct["property"].typeStruct));
	//abort;
	//writedump(application.zcore.listingStruct.mlsStruct["22"].sharedStruct.metaStruct["property"].typeStruct);
	fd=structnew();
	fd["A"]="Residential";
	fd["B"]="Multi-Family";
	fd["C"]="Vacant Land";
	fd["D"]="Rental"; // this one was actually blank
	fd["E"]="Common Interest";
	for(i in fd){
		i2=i;
		if(i2 NEQ ""){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
		}
	}
	for(g=1;g LTE arraylen(this.arrTypeLoop);g++){
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"list_41");
		for(i in fd){
			i2=i;
			arrayappend(arrSQL,"('#this.mls_provider#','county','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
		} 
	
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"LIST_9"); 
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
			}
		}
		
		
		// style
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130226165731387094000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130306200748323850000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130313160701380862000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130325004325380721000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130313160719015644000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
			}
		}
		/*
		// subdivision
		fd=this.getRETSValues("property","LIST_77");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','subdivision','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
			}
		}
		*/
		// parking
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130226165731576538000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130313160719925404000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130313160702301802000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130304162858580559000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
			}
		}
		
		
		
		
		
		// frontage
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130702134753249824000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130702135847480250000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130702135916588997000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130702140004488300000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130702140346507495000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
		}
		
		
		// view
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130313160701309776000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130226165731564034000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#')");
		} 
		
		
		
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"list_39"); 
		arrC=arraynew(1);
		failStr="";
		for(i in fd){
			tempState="FL"; 
			if(fd[i] NEQ "SEE REMARKS" and fd[i] NEQ "NOT AVAILABLE" and fd[i] NEQ "NONE"){
				 db.sql="select * from #db.table("city_rename", request.zos.zcoreDatasource)# city_rename 
				WHERE city_name =#db.param(fd[i])# and 
				state_abbr=#db.param(tempState)# and 
				city_rename_deleted = #db.param(0)#";
				qD2=db.execute("qD2");
				if(qD2.recordcount NEQ 0){
					fd[i]=qD2.city_renamed;
				}
				//arrayappend(arrC,application.zcore.functions.zescape(application.zcore.functions.zFirstLetterCaps(fd[i])));
				 db.sql="select * from #db.table("city", request.zos.zcoreDatasource)# city 
				WHERE city_name =#db.param(fd[i])# and 
				state_abbr=#db.param(tempState)# and 
				city_deleted = #db.param(0)# ";
				qD=db.execute("qD");
				if(qD.recordcount EQ 0){
					/*
					//writeoutput(fd[i]&" missing<br />");
					 db.sql="select	* from #db.table("zipcode", request.zos.zcoreDatasource)# zipcode 
					WHERE city_name =#db.param(fd[i])# and 
					state_abbr=#db.param(tempState)# and 
					zipcode_deleted = #db.param(0)#";
					qZ=db.execute("qZ");
					if(qZ.recordcount NEQ 0){*/
						 db.sql="INSERT INTO #db.table("city", request.zos.zcoreDatasource)#  
						 SET city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
						 state_abbr=#db.param(tempState)#,
						 country_code=#db.param('US')#, 
						 city_mls_id=#db.param(i)#,
					 	city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
						 local.result=db.insert("q"); 
						 db.sql="INSERT INTO #db.table("#request.zos.ramtableprefix#city", request.zos.zcoreDatasource)#  
						 SET city_id=#db.param(local.result.result)#, 
						 city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
						 state_abbr=#db.param(tempState)#,
						 country_code=#db.param('US')#, 
						 city_mls_id=#db.param(i)#,
						 city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
						 db.execute("q");
						//writeoutput(qId.city_id);
						cityCreated=true; // need to run zipcode calculations
						/*
					}else{
						failStr&=("<a href=""http://maps.google.com/maps?q=#urlencodedformat(fd[i]&', florida')#"" rel=""external"" onclick=""window.open(this.href); return false;"">#fd[i]#, florida</a> is missing in `#request.zos.zcoreDatasource#`.zipcode.<br />");
					}*/
				}
			}
			
			arrayClear(request.zos.arrQueryLog);
		}
	}
	return {arrSQL:arrSQL, cityCreated:cityCreated, arrError:arrError};
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>