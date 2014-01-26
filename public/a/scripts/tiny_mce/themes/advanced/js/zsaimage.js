tinyMCEPopup.requireLangPack();

var ZSAImageDialog = {
	init : function(ed) {
		this.editor=ed;
	},

	update : function(htmlCode) {
		var ed = this.editor;		
		tinyMCEPopup.restoreSelection();

		if (this.action != 'update')
			ed.selection.collapse(1);

		ed.execCommand('mceInsertContent', 0,htmlCode);

		tinyMCEPopup.close();
	}
};

tinyMCEPopup.onInit.add(ZSAImageDialog.init, ZSAImageDialog);
