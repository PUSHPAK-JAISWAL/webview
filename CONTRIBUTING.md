# Contributing

Bug reports, compatibility reports, documentation improvements, and focused pull requests
are welcome.

## Before You Start

- Search existing issues and pull requests before opening a new one.
- For larger changes, open an issue first to agree on scope.
- Keep changes focused and explain the behavior they affect.
- Preserve attribution and licensing notices in upstream vendored files.

## Local Checks

Install V, a C++ compiler, and the native webview dependencies for your operating system.
See the installation section in the [README](README.md). Building an application automatically
compiles the native sources; no separate build step is needed. Run tests by level:

```sh
v test tests/l1/
# For windowed GUI integration tests, use a display server (for example xvfb-run on Linux).
v test -run-only 'test_fn_call*,test_get_js_arg,test_return_value_to_js,test_return_value_from_threaded_task_to_js,test_static_server_serves_index_over_http' tests/l2/
```

On Linux, also build the examples where their optional frontend dependencies are installed.
Pull requests should pass the Linux, macOS, and Windows workflows when changes affect shared
or native code.

## Upstream C++ Updates

The vendored C++ implementation comes from [webview/webview](https://github.com/webview/webview).
The scheduled updater opens a pull request for new upstream tags. Please keep
`UPSTREAM_WEBVIEW_VERSION`, `webview.h`, and `webview.cpp` in sync, and do not remove notices
supplied by upstream.

## Pull Requests

Include a concise description, the reason for the change, and the checks you ran. Add or update
tests when behavior changes. Do not include generated object files, native binaries, credentials,
or unrelated formatting changes.