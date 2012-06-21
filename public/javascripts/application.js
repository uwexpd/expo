// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// put functions that should be run onload here
Event.observe(window, 'load', function() { 
  
});

// add to link_to_function elements to add an overlay 
// the fuction will show the overlay and the element of the passed id
// when the overlay is clicked it will hide the overlay and the element
// == Arguments ==
// id = id of the menu element 
// opaque = true:opaque/false:transparent
// (optional) animation_duration = set the speed of the blind up and down
function toggle_menu(id,opaque,animation_duration) {
  if (animation_duration === undefined) {animation_duration = 0.25}
  overlay = $('global_overlay');
  if (!overlay) {
    overlay = new Element('div', {'id': 'global_overlay'});
  }
  if (opaque) {
    overlay.removeClassName('overlay-clear').addClassName('overlay-shaded'); 
  } else {
    overlay.removeClassName('overlay-shaded').addClassName('overlay-clear'); 
  }
  $(id).insert({after:overlay});
  Effect.BlindDown(id, { duration: animation_duration });
  overlay.show();
  overlay.stopObserving('click');
  overlay.observe('click', function(event) {
    Element.hide.delay(animation_duration, overlay);
    Effect.BlindUp(id, { duration: animation_duration });
  });
}

function mark_for_destroy(element,type) { 
  $(element).next('.should_destroy').value = 1 
  $(element).up('.'+type).hide(); 
}

Array.prototype.sum = function(){
        for(var i=0,sum=0;i<this.length;sum+=this[i++]);
        return sum;
}

Array.prototype.max = function(){
        return Math.max.apply({},this)
}

Array.prototype.min = function(){
        return Math.min.apply({},this)
}



// Handles filtering lists in place
function initFilters(filter_keys) {
	filters = new Hash;  // filters are the things to filter on, like status and assigned_to
	filterables = new Hash;  // filterables are the items to filter, like table rows or list items
	appliedFilters = new Hash;  // applied filters is a snapshot of the current state of all the filters
	filter_keys.each(function(f) { filters.set(f, new Array) });
	filter_keys.each(function(f) { filterables.set(f, new Hash) });
	filter_keys.each(function(f) { appliedFilters.set(f, new Array) });
}

// Adds a key to the list of filters
function addToFilter(filter_key, value) {
	filters.get(filter_key).push(value)
	appliedFilters.get(filter_key).push(value)
}

// Adds a filterable item
// The filterables hash looks like:
//    assigned_to (hash key)
//        - 3103 (hash value -> array)
//             - object
//             - object
//        - 144 (hash value -> array)
//             - object
//             - object
function filterable(obj_id, filter_key, value) {
	h = filterables.get(filter_key)
	if (h.get(value) == undefined) {
		h.set(value, new Array)
	}
	h.get(value).push($(obj_id))
}

function changeFilter(obj_dom_id, filter_key, value) {
	element = $(obj_dom_id)
	// alert("obj_dom_id: " + obj_dom_id + " -- checked?: " + element.checked + " -- filter_key: " + filter_key + "-- value: " + value)
	if (element.checked) {
		appliedFilters.get(filter_key).push(value)
	} else {
		appliedFilters.set(filter_key, appliedFilters.get(filter_key).without(value))
	}
	executeFilters();
}

// Executes the filter on the filterables, taking into account all of the filters that have been applied or not.
function executeFilters() {
	showAllFilterables();
	filterables.each(function(pair) {
		filter_key = pair.key
		pair.value.each(function(elements) {
			if (appliedFilters.get(filter_key).indexOf(elements.key) == -1) {
				// alert("Hiding " + filter_key + ":" + elements.key)
				elements.value.invoke('hide')
			} else {
				// alert("Showing " + filter_key + ":" + elements.key)
				// elements.value.invoke('show')
			}
		})
	})
}

// shows all the filterable items to give us a clean slate before running executeFilters()
function showAllFilterables() {
	filterables.each(function(filter_keys) {
		filter_keys.value.each(function(elements) {
			elements.value.invoke('show')
		})
	})
}

// Sets a filter using some shortcuts and then executes the new filter. Valid options for 'type' are:
// 	'only'	- shows just the value that's passed
// 	'all'	- shows all filterables in this category
// 	'none'	- shows none of the filterables in this category (this is the default)
function setFilter(type, filter_key, value) {
	value += ''	// convert int to string
	if (filter_key === undefined) {
		filter_key = ''
	}
	appliedFilters.get(filter_key).clear() // filter everything to start
	$$('.' + filter_key + '_filter_checkbox').each(function(e) {e.checked = false}) // uncheck all the boxes to start
	if (type == 'only') {
		appliedFilters.get(filter_key).push(value)
		dom_id = "filter_" + filter_key + "_" + value
		$(dom_id).checked = true
	}
	if (type == 'all') {
		appliedFilters.set(filter_key, filters.get(filter_key).clone())
		$$('.' + filter_key + '_filter_checkbox').each(function(e) {e.checked = true})
	}
	executeFilters();
}

// Adds the specified text to the textfield at the cursor's current position.
// From www.alexking.org and modified.
// function insertAtCursor(myField, myValue) {
// 	//IE support
// 	if (document.selection) {
// 		myField.focus();
// 		sel = document.selection.createRange();
// 		sel.text = myValue;
// 	}
// 	//MOZILLA/NETSCAPE support
// 	else if (myField.selectionStart || myField.selectionStart == '0') {
// 		var startPos = myField.selectionStart;
// 		var endPos = myField.selectionEnd;
// 		myField.value = myField.value.substring(0, startPos)
// 						+ myValue
// 						+ myField.value.substring(endPos, myField.value.length);
// 	} else {
// 		myField.value += myValue;
// 	}
// }
// 
// Only allows numbers in a text field
function onlyAllowNumbers(e) {
	var k
	if (!e) e = window.event
	document.all ? k = e.keyCode : k = e.which
	var char = String.fromCharCode(k)
	if(!char.match(/[\d]/) && k != 13 && k != 8) return false
	return true
}

function flipToggleable(element_id_to_toggle, link_element) {
	element_to_toggle = $(element_id_to_toggle)
	if (element_to_toggle.visible()) {
		Effect.SlideUp(element_id_to_toggle)
		link_element.removeClassName('expanded')
		Element.select(link_element, '.toggle_state').first().innerHTML = "+"
	} else {
		Effect.SlideDown(element_id_to_toggle)
		link_element.addClassName('expanded')
		Element.select(link_element, '.toggle_state').first().innerHTML = "&ndash;"
	}
}

// Checks that a field with the given element_id is not blank. Returns false if it is and writes error_message to error_element_id.
function validateNotBlank(element_id, error_element_id, error_message) {
	form_element = $(element_id)
	error_element = $(error_element_id)
	if (form_element.value == '') {
		error_element.innerHTML = error_message
		form_element.addClassName("fieldWithErrors")
		return false
	} else {
		error_element.innerHTML = ''
		form_element.removeClassName("fieldWithErrors")
		return true
	}
}


/*
* This is the function that actually highlights a text string by
* adding HTML tags before and after all occurrences of the search
* term. You can pass your own tags if you'd like, or if the
* highlightStartTag or highlightEndTag parameters are omitted or
* are empty strings then the default <font> tags will be used.
*/
function doHighlight(bodyText, searchTerm, highlightStartTag, highlightEndTag) 
{
	// the highlightStartTag and highlightEndTag parameters are optional
	if ((!highlightStartTag) || (!highlightEndTag)) {
		highlightStartTag = "<span class='highlight'>";
		highlightEndTag = "</span>";
	}

	// find all occurences of the search term in the given text,
	// and add some "highlight" tags to them (we're not using a
	// regular expression search, because we want to filter out
	// matches that occur within HTML tags and script blocks, so
	// we have to do a little extra validation)
	var newText = "";
	var i = -1;
	var lcSearchTerm = searchTerm.toLowerCase();
	var lcBodyText = bodyText.toLowerCase();

	while (bodyText.length > 0) {
		i = lcBodyText.indexOf(lcSearchTerm, i+1);
		if (i < 0) {
			newText += bodyText;
			bodyText = "";
		} else {
			// skip anything inside an HTML tag
			if (bodyText.lastIndexOf(">", i) >= bodyText.lastIndexOf("<", i)) {
				// skip anything inside a <script> block
				if (lcBodyText.lastIndexOf("/script>", i) >= lcBodyText.lastIndexOf("<script", i)) {
					newText += bodyText.substring(0, i) + highlightStartTag + bodyText.substr(i, searchTerm.length) + highlightEndTag;
					bodyText = bodyText.substr(i + searchTerm.length);
					lcBodyText = bodyText.toLowerCase();
					i = -1;
				}
			}
		}
	}

	return newText;
}


/*
* This is sort of a wrapper function to the doHighlight function.
* It takes the searchText that you pass, optionally splits it into
* separate words, and transforms the text on the current web page.
* Only the "searchText" parameter is required; all other parameters
* are optional and can be omitted.
*/
function highlightSearchTerms(containerElements, searchText, treatAsPhrase, warnOnFailure, highlightStartTag, highlightEndTag)
{
	// if the treatAsPhrase parameter is true, then we should search for 
	// the entire phrase that was entered; otherwise, we will split the
	// search string so that each word is searched for and highlighted
	// individually
	if (treatAsPhrase) {
		searchArray = [searchText];
	} else {
		searchArray = searchText.split(" ");
	}

	if (!document.body || typeof(document.body.innerHTML) == "undefined") {
		if (warnOnFailure) {
			alert("Sorry, for some reason the text of this page is unavailable. Searching will not work.");
		}
		return false;
	}

	for (var e = 0; e < containerElements.length; e++) {
		elem = containerElements[e]
		var bodyText = elem.innerHTML;
		for (var i = 0; i < searchArray.length; i++) {
			bodyText = doHighlight(bodyText, searchArray[i], highlightStartTag, highlightEndTag);
		}
		elem.innerHTML = bodyText;
	}

	return true;
}

// For the specified input element, capture the "Enter" key so that hitting
// enter in that field doesn't submit the form. Instead, return false and
// refocus the input to the element_id passed as the parameter. This
// is particularly useful for elements that are observed and have to make an
// AJAX call to fill out an important part of the form.
function captureEnterAndRefocus(refocus_element_id,e) {
	var k
	if (!e) e = window.event
	document.all ? k = e.keyCode : k = e.which

	if (k == 13) {
		$(refocus_element_id).focus()
		return false;
	} else {
		return true;
	}
	
}

// Adds comma delimiters to a number string
function addCommas(nStr)
{
	nStr += '';
	x = nStr.split('.');
	x1 = x[0];
	x2 = x.length > 1 ? '.' + x[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(x1)) {
		x1 = x1.replace(rgx, '$1' + ',' + '$2');
	}
	return x1 + x2;
}






















