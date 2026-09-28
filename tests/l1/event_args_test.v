module webview

import pushpak_jaiswal.webview

struct Person {
	name string
	age  int
}

fn test_event_gets_primitive_arguments() {
	raw := '["hello",42,true]'
	event := webview.Event{
		event_id: &char(raw.str)
		args: &char(raw.str)
	}

	assert event.get_arg[string](0)! == 'hello'
	assert event.get_arg[int](1)! == 42
	assert event.get_arg[bool](2)! == true
}

fn test_event_gets_complex_arguments_and_negative_indexes() {
	raw := '["{\\"name\\":\\"Ada\\",\\"age\\":37}","[1,2,3]"]'
	event := webview.Event{
		event_id: &char(raw.str)
		args: &char(raw.str)
	}

	assert event.get_arg[Person](0)! == Person{'Ada', 37}
	assert event.get_arg[[]int](-1)! == [1, 2, 3]
}

fn test_event_rejects_out_of_range_indexes() {
	raw := '[1,2,3]'
	event := webview.Event{
		event_id: &char(raw.str)
		args: &char(raw.str)
	}

	if _ := event.get_arg[int](3) {
		assert false, 'expected out-of-range index to fail'
	} else {
		assert err.msg().contains('Failed finding argument')
	}
	if _ := event.get_arg[int](-4) {
		assert false, 'expected negative out-of-range index to fail'
	} else {
		assert err.msg().contains('Failed finding argument')
	}
}

fn test_event_rejects_malformed_json() {
	raw := '[1,]'
	event := webview.Event{
		event_id: &char(raw.str)
		args: &char(raw.str)
	}

	if _ := event.get_arg[int](0) {
		assert false, 'expected malformed JSON to fail'
	} else {
		assert err.msg().contains('Failed decoding argument')
	}
}
