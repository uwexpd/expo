function mceTriggerSaveHandler(inst) {
	tinyMCE.triggerSave(); 
	//changed = true;
}

document.observe("dom:loaded", function() {
	new PeriodicalExecuter(mceTriggerSaveHandler, 3);
});

function toggleEditor(id) {
	if (!tinyMCE.get(id))
		tinyMCE.execCommand('mceAddControl', false, id);
	else
		tinyMCE.execCommand('mceRemoveControl', false, id);
}