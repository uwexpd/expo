document.onkeypress = function(e) { return captureCardReader(e); }

var keyQueue = "";
var cardReaderEnabled = true;

// Captures input that starts with a ";" and ends with a "?"
function captureCardReader(e) {
	var k
	if (!e) e = window.event
	document.all ? k = e.keyCode : k = e.which
	var ch = String.fromCharCode(k)

	if (keyQueue == "" && ch == ";") {
		keyQueue = ch
		updatekq()
		return false;
	} else if (keyQueue != "" && (ch.match(/[\d]/) || ch == '?')) {
		keyQueue += ch
		updatekq()
		return false;
	} else if (keyQueue != "" && k == 13) {
		processCardReaderInput()
		keyQueue = ""
		updatekq()
		return false;
	} else if (keyQueue.length > 16) {
		keyQueue = ""
		updatekq()
	}
}

function updatekq() {
	$('keyQueue').innerHTML = keyQueue;
}

// Makes sure that we have a student card (starting with a ";1") and we're not in the middle of something important
function processCardReaderInput() {
	student_regexp = /;1\d{2}(\d{7})\d{4}\?/
	non_student_regexp = /;[2-9]\d{13}\?/
	if (!cardReaderEnabled) {
		$('find_student_error').innerHTML = "The card reader is currently disabled."
		return false
	}
	if (keyQueue.match(student_regexp)) {
		$('find_student_error').innerHTML = ""
		$('student_no').value = keyQueue.match(student_regexp)[1]
		submitFindStudentForm()
	} else if (keyQueue.match(non_student_regexp)) { // staff or department cards get rejected
		$('find_student_error').innerHTML = "Only student Husky Cards are allowed."
	} else {
		$('find_student_error').innerHTML = "Sorry, that's not a valid Husky Card."
	}
}

function disableCardReader() {
	cardReaderEnabled = false
	$('cardStatus').removeClassName('on')
	$('cardStatus').addClassName('off')
}

function enableCardReader() {
	cardReaderEnabled = true
	$('cardStatus').removeClassName('off')
	$('cardStatus').addClassName('on')
}

function toggleCardReader() {
	if (cardReaderEnabled) {
		disableCardReader()
	} else {
		enableCardReader()
	}
}