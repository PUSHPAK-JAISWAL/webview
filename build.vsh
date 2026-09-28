#!/usr/bin/env -S v

import cli
import os
import net.http

const lib_dir = '${@VMODROOT}'
const cxx = if _ := find_abs_path_of_executable('g++') {
	'g++'
} else if _ := find_abs_path_of_executable('clang++') {
	'clang++'
} else {
	panic("Can't find C++ compiler. Make sure g++ or clang++ is executable.")
}

// == Build Docs ==============================================================

// Remove redundant readme section from module page.
fn rm_readme_section(html string) string {
	mut res := html
	if start_idx := res.index('<section id="readme_') {
		if end_idx := res.index_after('</section>', start_idx) {
			res = res[..start_idx] + res[end_idx + '</section>'.len..]
		}
	}
	if toc_start := res.index('<li class="open"><a href="#readme_') {
		if toc_end := res.index_after('</li>', toc_start) {
			res = res[..toc_start] + res[toc_end + '</li>'.len..]
		}
	}
	return res
}

fn build_docs() ! {
	// Cleanup old docs.
	rmdir_all('_docs') or {}
	// Build docs.
	mut p := new_process(@VEXE)
	p.set_args(['doc', '-readme', '-m', '-f', 'html', '.'])
	p.wait()
	mut webview_html_file := '_docs/webview.html'
	if !os.exists(webview_html_file) {
		for f in ls('_docs') or { []string{} } {
			if f.ends_with('webview.html') && f != 'index.html' {
				webview_html_file = '_docs/${f}'
				break
			}
		}
	}
	mut webview_html := read_file(webview_html_file)!
	webview_html = rm_readme_section(webview_html)
	write_file(webview_html_file, webview_html)!
	if webview_html_file != '_docs/webview.html' {
		cp(webview_html_file, '_docs/webview.html')!
	}
}

// == Download & Build Library ================================================

fn download_source() ! {
	if !os.exists('${lib_dir}/webview.cpp') {
		upstream_version := os.read_file('${lib_dir}/UPSTREAM_WEBVIEW_VERSION') or {
			return error('UPSTREAM_WEBVIEW_VERSION is missing; restore it from the package repository.')
		}
		upstream_url := 'https://raw.githubusercontent.com/webview/webview/refs/tags/${upstream_version.trim_space()}'
		println('Downloading webview ${upstream_version.trim_space()} source...')
		http.download_file('${upstream_url}/core/src/webview.cc', '${lib_dir}/webview.cpp')!
	}
}

fn build() ! {
	mut cmd := '${cxx} -std=c++17 -c "${lib_dir}/webview.cpp" -DWEBVIEW_STATIC -I"${lib_dir}" -o "${lib_dir}/webview.o"'
	$if linux {
		webkit_pkg := if execute('pkg-config --exists gtk+-3.0 webkit2gtk-4.1').exit_code == 0 {
			'webkit2gtk-4.1'
		} else {
			'webkit2gtk-4.0'
		}
		pkg_config := execute('pkg-config --cflags gtk+-3.0 ${webkit_pkg}')
		if pkg_config.exit_code != 0 {
			return error('GTK and WebKitGTK development packages are required (gtk+-3.0 and webkit2gtk-4.1 or webkit2gtk-4.0).')
		}
		cmd += ' -DWEBVIEW_GTK ${pkg_config.output}'
	} $else $if windows {
		cmd += ' -DWEBVIEW_EDGE -I"${lib_dir}/webview2/include"'
	} $else $if darwin {
		cmd += ' -DWEBVIEW_COCOA'
	}
	println('Building...')
	build_res := execute(cmd)
	if build_res.exit_code != 0 {
		return error('failed to build the webview library: ${build_res.output}')
	}
	println('Successfully built the webview library for this platform.')
}

fn run(_ cli.Command) ! {
	download_source()!
	build()!
}

// == Commands ================================================================

mut cmd := cli.Command{
	name:          'build.vsh'
	posix_mode:    true
	required_args: 0
	pre_execute:   fn (cmd cli.Command) ! {
		if cmd.args.len > cmd.required_args {
			eprintln('Unknown commands ${cmd.args}.\n')
			cmd.execute_help()
			exit(0)
		}
	}
	execute:       run
	commands:      [
		cli.Command{
			name:        'docs'
			description: 'Build docs used for GitHub pages.'
			execute:     fn (_ cli.Command) ! {
				build_docs() or {
					eprintln('Failed building docs. ${err}')
					exit(1)
				}
			}
		},
	]
	flags:         [
		cli.Flag{
			flag: .bool
			name: 'silent'
		},
	]
}

cmd.parse(os.args)
