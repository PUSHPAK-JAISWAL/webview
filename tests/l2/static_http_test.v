module serve

import net.http
import os
import time
import pushpak_jaiswal.webview.serve

fn test_static_server_serves_index_over_http() {
	ui_path := os.join_path(@VMODROOT, 'tests', 'l2', 'ui')
	port := serve.serve_static(ui_path, 49150) or { panic(err) }
	url := 'http://localhost:${port}/'
	mut response := http.Response{}
	mut last_error := ''
	for _ in 0 .. 40 {
		if result := http.get(url) {
			response = result
			break
		} else {
			last_error = err.msg()
			time.sleep(50 * time.millisecond)
		}
	}
	assert response.status_code == 200, 'GET ${url} failed: ${last_error}'
	assert response.body.contains('<h1>Static UI served</h1>')
}
