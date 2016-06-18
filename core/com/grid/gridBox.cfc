<cfcomponent>
<cfoutput>
<!--- /z/_com/app/gridBox?method=boxSettings --->
<cffunction name="boxSettings" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	application.zcore.skin.includeJS("/z/javascript/jetendo-grid/grid-manager.js");
	var gridData={
	    "groups": [
	        {
	            "settings": {
	                "grid_group_box_border_radius": 0,
	                "grid_group_visible": "1",
	                "grid_group_heading": "Heading",
	                "grid_group_background_type": 0,
	                "grid_group_children_center": "0",
	                "grid_group_box_border": "",
	                "grid_group_background_value": "",
	                "grid_group_padding": "",
	                "grid_group_box_background_value": "",
	                "grid_id": 57,
	                "grid_group_box_background_type": 0,
	                "grid_group_text": "",
	                "grid_group_column_count": 0,
	                "grid_group_heading2": "Heading2",
	                "grid_group_sort": 1,
	                "grid_group_box_layout": 0,
	                "grid_group_id": 1,
	                "grid_group_section_center": "0"
	            },
	            "boxes": [
	                {
	                    "grid_box_image_intermediate": "",
	                    "grid_box_sort": 0,
	                    "grid_box_column_size": 2,
	                    "grid_id": 57,
	                    "grid_box_button_text": "",
	                    "grid_box_heading": "Heading",
	                    "grid_box_visible": "1",
	                    "grid_box_summary": "",
	                    "grid_box_image": "0",
	                    "grid_box_button_url": "",
	                    "grid_box_id": 1,
	                    "grid_group_id": 1
	                }
	            ]
	        },
	        {
	            "settings": {
	                "grid_group_box_border_radius": 0,
	                "grid_group_visible": "1",
	                "grid_group_heading": "Head2",
	                "grid_group_background_type": 0,
	                "grid_group_children_center": "0",
	                "grid_group_box_border": "",
	                "grid_group_background_value": "",
	                "grid_group_padding": "",
	                "grid_group_box_background_value": "",
	                "grid_id": 57,
	                "grid_group_box_background_type": 0,
	                "grid_group_text": "",
	                "grid_group_column_count": 0,
	                "grid_group_heading2": "Head22",
	                "grid_group_sort": 2,
	                "grid_group_box_layout": 0,
	                "grid_group_id": 2,
	                "grid_group_section_center": "0"
	            },
	            "boxes": [
	                {
	                    "grid_box_image_intermediate": null,
	                    "grid_box_sort": null,
	                    "grid_box_column_size": null,
	                    "grid_id": 57,
	                    "grid_box_button_text": null,
	                    "grid_box_heading": null,
	                    "grid_box_visible": null,
	                    "grid_box_summary": null,
	                    "grid_box_image": null,
	                    "grid_box_button_url": null,
	                    "grid_box_id": null,
	                    "grid_group_id": 2
	                }
	            ]
	        }
	    ],
	    "settings": {
	        "grid_visible": "0",
	        "grid_active": "1",
	        "grid_id": 57
	    }
	};

	boxSettings={
		"grid_box_image_intermediate": "",
		"grid_box_sort": 0,
		"grid_box_column_size": 2,
		"grid_id": 57,
		"grid_box_button_text": "",
		"grid_box_heading": "Heading",
		"grid_box_visible": "1",
		"grid_box_summary": "",
		"grid_box_image": "0", 
		"grid_box_button_url": "",
		"grid_box_id": 1,
		"grid_group_id": 1
	};
	groupSettings={
		"grid_group_box_border_radius": 0, 
		"grid_group_visible": "1",
		"grid_group_heading": "Heading",
		"grid_group_background_type": 0,
		"grid_group_children_center": "0",
		"grid_group_box_border": "",
		"grid_group_background_value": "",
		"grid_group_padding": "",
		"grid_group_box_background_value": "",
		"grid_id": 57,
		"grid_group_box_background_type": 0,
		"grid_group_text": "",
		"grid_group_column_count": 5,
		"grid_group_heading2": "Heading2",
		"grid_group_sort": 1,
		"grid_group_box_layout": 0,
		"grid_group_id": 1,
		"grid_group_section_center": "0"
	}; 
	
	boxLayout={
		"1":"Vertical - Image / Heading / Heading 2 / Summary / Button",
		"2":"Vertical - Heading / Image / Heading 2 / Summary / Button",
		"3":"Vertical - Heading / Heading 2 / Image / Summary / Button",
		"4":"Left: Image | Right: Heading / Heading 2 / Summary / Button",
		"5":"Left: Heading / Heading 2 / Summary / Button | Right: Image",
		"6":"Image with White Heading on Black Overlay",
		"7":"Image with Black Heading on White Overlay"
	}
	</cfscript>
	<script type="text/javascript">
	var gridData=#serializeJSON(gridData)#;
	var groupSettings=#serializeJSON(groupSettings)#;
	var boxSettings=#serializeJSON(boxSettings)#;
 
	</script>

<form id="gridBoxForm" action="" method="get">
	<cfscript> 
	tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
	tabCom.init();
	tabCom.setTabs(["Box Settings"]); 
	tabCom.setMenuName("grid-box-edit");
	tabCom.setCancelURL("");
	tabCom.enableSaveButtons();
	</cfscript>
	#tabCom.beginTabMenu()#
	#tabCom.beginFieldSet("Box Settings")# 
	<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr>
			<th style="width:120px;">Image</th>
			<td><input type="text" name="grid_box_image" id="grid_box_image" value="" /></td>
		</tr>
		<tr>
			<th>Heading</th>
			<td><input type="text" name="grid_box_heading" id="grid_box_heading" value="" /></td>
		</tr>
		<tr>
			<th>Summary</th>
			<td>
				<cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "grid_box_summary";
				htmlEditor.value= "";
				htmlEditor.width= "100%";
				htmlEditor.height= 250;
				htmlEditor.create();
				</cfscript>
			</td>
		</tr>
		<tr>
			<th>Button Text</th>
			<td><input type="text" name="grid_box_button_text" id="grid_box_button_text" value="" /></td>
		</tr>
		<tr>
			<th>Button Url</th>
			<td><input type="text" name="grid_box_button_url" id="grid_box_button_url" value="" /></td>
		</tr>
		<tr>
			<th>Column Size</th>
			<td>
				<select size="1" name="grid_box_column_size" id="grid_box_column_size"> 
					<option value="1">1</option>
					<option value="2">2</option>
					<option value="3">3</option>
					<option value="4">4</option>
					<option value="5">5</option>
					<option value="6">6</option>
					<option value="7">7</option>
				</select>
			</td>
		</tr> 
		<tr>
			<th>Visible</th>
			<td>#application.zcore.functions.zInput_Boolean("grid_box_visible")#</td>
		</tr>
	</table>
	#tabCom.endFieldSet()#
	#tabCom.endTabMenu()#
	<input type="hidden" name="grid_id" id="grid_id" value="" />
	<input type="hidden" name="grid_group_id" id="grid_group_id" value="" />
	<input type="hidden" name="grid_box_id" id="grid_box_id" value="" />
	<input type="hidden" name="grid_box_sort" id="grid_box_sort" value="" />
	<!--- <input type="text" name="grid_box_image_intermediate" id="grid_box_image_intermediate" value="" /> --->
</form>
</cffunction>
</cfoutput>
</cfcomponent>