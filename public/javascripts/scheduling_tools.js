selectNum = 0;
selectMode = null

function startDragSelect(obj, formElementForIds)
{

	// Set the selectMode if this is the beginning of the DragSelect
	if (selectMode == null) 
	{
		selectMode = Element.hasClassName(obj, "selected") ? "deselect" : "select"
	}
	// $('debug').innerHTML = "selectMode is " + selectMode

	// Select or deselect the current node based on the selectMode
	if (selectMode == "select")
	{
		obj.addClassName("selected")
	}
	else
	{
		obj.removeClassName("selected")
	}
	
	// Turn on the onMouseDown callbacks for all of the other selectable items
	$$('.selectable_time').each(function(e) {
		e.onmouseover = e.onmousedown
	})
	
	// Reassign the onMouseUp callback for this object to reset everything when the drag is done
	obj.onmouseup = function() 
	{
		$$('.selectable_time').each(function(e) {
			e.onmousedown = e.onmouseover
			e.onmouseover = null
		})
		selectMode = null
		
		selecteds = $$('.selectable .selected')
		formElementForIds.value = selecteds.size() < 1 ? "clear" : selecteds.pluck("id")
		
	}		
}

// Disables text selection inside the selectable element so that only the
// things we want to be be selectable are selectable
window.onload = function() {
	$$('.selectable').each(function(e) {
		e.onselectstart = function() {return false;} // ie
	  	e.onmousedown = function() {return false;} // mozilla
	})
}