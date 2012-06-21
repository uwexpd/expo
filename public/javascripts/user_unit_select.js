var unit_users = new Hash()
var user_units = new Hash()

function updateStaffPersonSelect(val) {
	elem = $('appointment_staff_person_id')
	emptySelect(elem)
	elem.options[0] = new Option("-- Select Staff Person --")
	unit_users.get(val).each(function(pair) {
		elem.options[elem.options.length] = new Option(pair.value, pair.key)
	})
}

function updateUnitSelect(val, showAllIfNull) {
	elem = $('appointment_unit_id')
	emptySelect(elem)
	user_units.get(val).each(function(pair) {
		elem.options[elem.options.length] = new Option(pair.value, pair.key)
	})
	if (elem.options.length == 0 && showAllIfNull == true) {
		updateUnitSelect('ALL')
	}
}

function emptySelect(elem) {
	for (i = elem.options.length-1; i >= 0; i--) {
		elem.removeChild(elem.options[i])
	}
}