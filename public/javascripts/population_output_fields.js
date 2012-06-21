// Adds or removes an output field from the "selected" list. Then calls #saveOutputFields.
function toggleOutputField(containerID, fieldName, element) {
	if (element.parentNode) {
		myParent = element.parentNode
	} else {
		myParent = element.parentElement
	}
	if (myParent.hasClassName('custom_output_field')) {
		myParent.remove()
		restorePopulationFieldCodesSortable()
		$('new_output_field_title').value = element.select('.association').first().innerHTML
		old_value = element.select('.fieldName').first().innerHTML
		$('new_output_field').value = old_value.match(/^CUSTOM_OUTPUT_FIELD\((.+)\):(.+)/)[2]
	} else if ($('selected_population_field_codes').select('.' + myParent.classNames().toString()).size() > 0) {
		element.removeClassName('selected')
		removeOutputField(myParent)
		if($('all_population_field_codes').select(klass).size() > 0) {
			$('all_population_field_codes').select(klass).first().select('a').invoke('removeClassName','selected')
		}
	} else {
		element.addClassName('selected')
		addOutputField(myParent.clone(true))
	}
	saveOutputFields(containerID)
	commitOutputFields()
}
	
// Adds an output field to the selected list and calls #restorePopulationFieldCodesSortable to make the 
// sorting work with the new element.
function addOutputField(element) {
	$('selected_population_field_codes').insert(element)
	restorePopulationFieldCodesSortable()
}

// Removes an output field to the selected list and removes the "selected" class for the corresponding element
// in the list of all possible output_codes. Calls #restorePopulationFieldCodesSortable to make the sorting
// work with the new element when done.
function removeOutputField(element) {
	klass = '.' + element.classNames().toString()
	$('selected_population_field_codes').select(klass).invoke('remove')
	if($('all_population_field_codes').select(klass).size() > 0) {
		$('all_population_field_codes').select(klass).first().select('a').invoke('toggleClassName','selected')
	}
	restorePopulationFieldCodesSortable()
}

// Reinitializes the Sortable object on the selected population field codes and also commits the new list to
// the DB by calling #commitOutputFields. This is done because we cannot use Sortable's "onUpdate" method and
// adding that to all onChange requests would result in too many AJAX requests.
function restorePopulationFieldCodesSortable() {
	Sortable.create("selected_population_field_codes", { 
		constraint:'vertical', 
		handle:'sort-handle', 
		tree:true, 
		onChange:function(){saveOutputFields('output_fields')},
		onUpdate:function(){commitOutputFields()}
	})
}

// Collects all the selected output fields, in order, from the list of selected codes. Creates a JSON array and inserts
// the JSON string into the specified container so that it can be uploaded to the DB through AJAX later.
function saveOutputFields(containerID) {
	container = $(containerID)
	fieldNames = $$('#selected_population_field_codes .selected .fieldName').collect(function(s) { return s.innerHTML })
	container.value = fieldNames.toJSON()
	$('save_output_fields_status').innerHTML = 'Saving...'
}

// Send the JSON string in the "output_fields" form element to Rails via AJAX request. You MUST set a variable called
// "commitOutputFieldsURL" to the URL that should be used for this AJAX request.
function commitOutputFields() {
	new Ajax.Updater('save_output_fields_status', 
					commitOutputFieldsURL, 
					{asynchronous:true, evalScripts:true, parameters:'output_fields=' + encodeURIComponent($F('output_fields'))}) 
}

function addCustomOutputField() {
	val = $F('new_output_field')
	title_val = $F('new_output_field_title')
	myElement = new Element('li')
	myElement.addClassName(val.gsub(/[\?, \(\)\-\=\:\#\|\;\"\'\.\<\>\[\]\{\}]/, '_'))
	myElement.addClassName("selected")
	myElement.addClassName("custom_output_field")
	myElement.innerHTML = "<span class=\"sort-handle\"><span>m</span></span>"
	myElement.innerHTML += "<a class=\"placeholder_text_link selected\" href=\"#\" onclick=\"toggleOutputField('output_fields', 'code_text', this); return false;\"><span class=\"custom outline tag\" style=\"margin-left:0\">Custom</span><span class=\"association\">" + title_val + "</span>" + val + "<span class=\"fieldName\" style=\"display:none\">CUSTOM_OUTPUT_FIELD(" + title_val + "):" + val + "</span></a>"
	addOutputField(myElement)
	saveOutputFields("output_fields")
	commitOutputFields()
	$('new_output_field').clear()
	$('new_output_field_title').clear()
}