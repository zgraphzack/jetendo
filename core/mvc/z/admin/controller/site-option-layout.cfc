<cfcomponent>
<cfoutput>
<!--- 
Layout
	Breakpoint - 960+
		Row 1 - set number of divisions and how they are sized to auto create the panels below
				Panel 1
					Widget 1
					Widget 2
					Widget 3
				Panel 2	
					Widget 1
		Row 2
			Panel 1
				Widget 1
	Breakpoint - 750+
		Row 1

		
TODO: Help with layout builder: Building a feature that lets you visually connect widgets to custom data sources that have different field names.
	This feature would let you take existing widgets and feed them different data sources that don't match the original variable names.
	Widgets could be placed anywhere in the layout - They wouldn't have a fixed position or sort order like it does on security first.
	The interface to map the new and old fields would be part of the manager.  Not requiring programming.
	Support could be added to allow inserting widgets in TinyMCE editors that can be configured visually.
	An instance of the widget could be created with a unique name and inserted anywhere in the source code for more custom usage.
	In the actual front-end code, the widget is passed the structure of the current placeStruct, and it automatically maps it's type to the new type so that the code for the widget doesn't have to be rewritten.
		It would be this simple to add new widgets in the code, and the rest would be configured with the manager.
			slideShowWidget.render(placeStruct)
		widgets can have:
			required fields when data is being mapped.
			support for mapping nested data
			be installed globally or per site
			the ability to have their own set of nested forms in the manager that doesn't require mapping it to another data source to support custom applications of the widget.  Such as a hardcoded uniquely configured home page slideshow.
	example:
		slideshow widget requires 1 image, 2 text, and 1 url text field.   This allows the variables named: photo, heading 1, heading 2 and a button URL to be output.
		A place would have Title, URL and image library.
		The interface would let you connect "image" in the widget to place's "image library", which will make it automatically pull the first image from the library.
		The other fields are simple text fields, and the mapping would just assign the value to the new variable name.
	widget layouts
		a layout would be the HTML / css / js to make the widget display itself.
		each widget could have multiple layouts assigned to it in the manager by uploading html/css/js directly to the manager - this would be a developer only feature usually.
		each instance of a widget could select the layout that you want to apply to it.
		layouts will have various information that identifies how they have been programmed:
			minimum width
			maximum width
			responsive: yes|no (indicates whether widget will scale smoothly between min/max size automatically or not)
			high dpi support: yes|no
			touch enabled: yes|no
			mobile first implementation: yes|no
	the widget will be able to be packaged into a simple zip file format for automated import / export into different installations of jetendo allowing commercial sale of the feature if desired.
	This requires making several new layers on top of the form builder so that the form builder configuration can be saved into a format that is attached to the widget.
	
	Everything we do can be a widget eventually.
	
	Building "layouts" as the next layer of abstraction
		The global theme that is applied to a page or a specific type of record would be considered a "layout". 
			examples: A Place, Blog, Home Page
		You could add widgets, columns, rows, "other layouts" and their options to the layout
		This could be done with drag and drop while in the simplistic layout mode.  It could also be done by programming the layout with simple code.
		Once a layout is saved, it can be associated with a site_option_group (custom data), page, blog or triggered to be used through programming at a higher level to take effect for an entire section of the web site.
		Layouts would be able to be nested inside of each other so that you could have master layout, and child layouts.  Like when the header/footer is shared with another layout, but the "place" layout is using a different layout.
		Layouts would be dropped into the page as simple boxes that have the layout name on them as a label. They'd snap into place on unlimited numbers of columns and rows.
		Columns would be able to be defined as a fixed size or stretching. So you could build a full page web site or a centered 960 site or whatever.
		Layouts could be overridden for one specific page within a section that already has a layout associated easily by going into the customize layout mode.  This would give you the option for the scope for the layout and selecting which layout on the current page you want to change.
		You would have a central place to view all the different layouts that have been created.   
		If you want to delete a layout, a warning will be given if live data is using the layout currently so you don't accidentally break the live site.
		When a layout is removed, the data it was connected to is not deleted.  It just becomes unable to be displayed.   Any custom programming that relied on the layout would also suddenly disappear and be broken once it is deleted.
		If you delete a record that has a specific layout attached to it that is no longer used by any other record, you will be given the option to delete the layout at the same time.
	
	You could also create a another layer of abstraction that allows you define layout / widget sets that apply to specific devices or regional versions of the web site, yet are mapped to the same data / same manager.   You could make a site that works great on an Xbox, one that works on 8" tablet, and one that works on 22" desktop monitor without programming all those differences manually.
		
	Then you are able to do visual programming for the entire front-end and back-end system.
		
 --->
<cffunction name="index" access="public" localmode="modern">

</cffunction>
</cfoutput>
</cfcomponent>