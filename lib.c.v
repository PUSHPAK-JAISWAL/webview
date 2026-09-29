module webview

#flag -DWEBVIEW_STATIC

#flag windows -I@VMODROOT/webview2/include

#flag linux -DWEBVIEW_GTK

#flag darwin -DWEBVIEW_COCOA

#flag windows -DWEBVIEW_EDGE

#flag @VMODROOT/webview.o

#flag linux -lstdc++ -ldl

#flag darwin -framework WebKit -lc++

#flag windows -ladvapi32 -lole32 -lshell32 -lshlwapi -luser32 -lversion -static -lstdc++

#include "@VMODROOT/webview.h"

$if linux {
	#pkgconfig gtk+-3.0
	$if $pkgconfig('webkit2gtk-4.1') {
		#pkgconfig webkit2gtk-4.1
	} $else {
		#pkgconfig webkit2gtk-4.0
	}
}

@[typedef]
struct C.webview_t {}

fn C.webview_create(debug int, window voidptr) C.webview_t

fn C.webview_destroy(w C.webview_t)

fn C.webview_run(w C.webview_t)

fn C.webview_terminate(w C.webview_t)

fn C.webview_dispatch(w C.webview_t, func fn (w C.webview_t, ctx voidptr), ctx voidptr)

fn C.webview_get_window(w C.webview_t) voidptr

fn C.webview_set_title(w C.webview_t, title &char)

fn C.webview_set_size(w C.webview_t, width int, height int, hints int)

fn C.webview_navigate(w C.webview_t, url &char)

fn C.webview_set_html(w C.webview_t, html &char)

fn C.webview_init(w C.webview_t, code &char)

fn C.webview_eval(w C.webview_t, code &char)

fn C.webview_bind(w C.webview_t, func_name &char, func fn (event_id &char, args &char, ctx voidptr), ctx voidptr)

fn C.webview_unbind(w C.webview_t, func_name &char)

fn C.webview_return(w C.webview_t, event_id &char, status int, result &char)
