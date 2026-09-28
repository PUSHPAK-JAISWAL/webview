module serve

import net
import veb
import os

pub struct App {
	veb.StaticHandler
pub mut:
	ui_path string
}

pub struct Context {
	veb.Context
}

// serve_static serves a UI directory over HTTP and returns the selected port.
pub fn serve_static(ui_path string, port u16) !u16 {
	if !os.exists(ui_path) {
		return error('failed to find ui path `${ui_path}`.')
	}
	if !os.is_dir(ui_path) {
		return error('ui path `${ui_path}` is not a directory.')
	}
	mut final_port := port
	for {
		if mut l := net.listen_tcp(.ip6, ':${final_port}') {
			l.close()!
			break
		}
		final_port++
	}

	// Serves files from ui_path under the root URL path "/"
	spawn fn [ui_path, final_port] () {
		mut app := App{
			ui_path: ui_path
		}
		app.mount_static_folder_at(ui_path, '/') or { return }
		veb.run[App, Context](mut app, int(final_port))
	}()
	return final_port
}

// index serves the UI index file when it exists.
pub fn (app &App) index(mut ctx Context) veb.Result {
	index_file := os.join_path(app.ui_path, 'index.html')
	if os.exists(index_file) {
		return ctx.html(os.read_file(index_file) or { return ctx.server_error(err.msg()) })
	}
	return ctx.not_found()
}
