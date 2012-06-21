function add_to(id, max, fields) {
	var obj
	var val
	obj = $(id)
	val = parseInt($F(obj) || 0)
	if (sum(fields) < max) {
		obj.value = val + 1
		print_error("")
	} else {
		print_error("You have already allocated all " + max + " slots. You can't add any more.")
	}
}

function subtract_from(id, min) {
	var obj
	var val
	obj = $(id)
	val = parseInt($F(obj) || 0)
	if (val > 0) {
		if (val - 1 < min) {
			print_error("There are already " + min + " students placed in that class. You can't subtract any more slots.")
		} else {
			obj.value = val - 1
			print_error("")		
		}
	} else {
		print_error("You can't go below zero!")
	}
}

function sum(fields) {
	if (fields == null) { return 0 }
	var sum = 0
	var i=0
	for (i=0;i<fields.length;i++) {
		sum = sum + parseInt($F(fields[i]))
	}
	return sum
}

function update_unallocated_field(field, fields, total) {
	field.update(total - sum(fields))
}

function print_error(text) {
	field = 'js_errors'
	$(field).update(text)
	if (text != '') {
		$(field).highlight()
	}
}