import os
import pushpak_jaiswal.webview.serve

fn test_static_server_rejects_missing_directory() {
	path := os.join_path(@VMODROOT, 'missing-l1-test-directory')
	if _ := serve.serve_static(path, 0) {
		assert false, 'expected missing directory to be rejected'
	} else {
		assert err.msg().contains('failed to find ui path')
	}
}

fn test_static_server_rejects_file_path() {
	if _ := serve.serve_static(os.join_path(@VMODROOT, 'v.mod'), 0) {
		assert false, 'expected file path to be rejected'
	} else {
		assert err.msg().contains('is not a directory')
	}
}
