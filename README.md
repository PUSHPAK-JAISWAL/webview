# webview - V Binding

# Webview for V

[![build-status](https://img.shields.io/github/actions/workflow/status/PUSHPAK-JAISWAL/webview/ci.yml?branch=main)](https://github.com/PUSHPAK-JAISWAL/webview/actions/workflows/ci.yml?query=branch%3Amain)
[![last-commit](https://img.shields.io/github/last-commit/PUSHPAK-JAISWAL/webview)](https://github.com/PUSHPAK-JAISWAL/webview)

This repository provides a V binding for [webview](https://github.com/webview/webview), a cross-platform library
for building desktop applications with native web views.

Maintained by [Pushpak Jaiswal](https://github.com/PUSHPAK-JAISWAL) ([pushpakmjaiswal@gmail.com](mailto:pushpakmjaiswal@gmail.com)).
This is a community-maintained continuation of [ttytm/webview](https://github.com/ttytm/webview). The original project
and its contributors remain credited; this repository carries forward the V compatibility, packaging, and platform-build
updates described here.

The upstream C++ implementation is pinned in [`UPSTREAM_WEBVIEW_VERSION`](UPSTREAM_WEBVIEW_VERSION). A scheduled GitHub
Actions workflow checks upstream tags and opens a pull request with updated source for review.

[Contributing](CONTRIBUTING.md) · [Code of Conduct](CODE_OF_CONDUCT.md) · [Security](SECURITY.md) · [License](LICENSE)

## Installation

**Build Tools and WebKit**

- Linux - Debian/Ubuntu example

  ```sh
  sudo apt install build-essential pkg-config libgtk-3-dev libwebkit2gtk-4.1-dev
  # For distributions that package WebKitGTK 4.0 instead:
  sudo apt install build-essential pkg-config libgtk-3-dev libwebkit2gtk-4.0-dev
  ```

- macOS

  ```sh
  xcode-select --install
  ```

- Windows

  Install MinGW-w64 (for example through [MSYS2](https://www.msys2.org/)) and ensure the matching `gcc` and `g++`
  toolchain is on `PATH`. The WebView2 SDK headers are included with the package; Windows includes the WebView2 Runtime.

**V**

- [Installing V from source](https://github.com/vlang/v#installing-v-from-source)

**Webview Module**

- Install the module

  ```sh
  v install pushpak_jaiswal.webview
  ```

- Import `pushpak_jaiswal.webview` in your V application and build it normally. V compiles the package's native
  implementation automatically as part of the application build; no separate library-build command is required.
- Linux still requires GTK 3 and WebKitGTK development packages. macOS uses the system WebKit framework. Windows requires
  MinGW-w64 and the WebView2 Runtime.

## Usage Example

> [!TIP]
> When building on Windows, select the C and C++ compilers from the same MinGW-w64 installation. For MSYS2 UCRT64:
>
> ```sh
> v -cc gcc -c++ g++ run .
> ```

<br>

```v ignore
import pushpak_jaiswal.webview

const html = '<!DOCTYPE html>
<html lang="en">
  <head>
    <style>
      body {
        background: linear-gradient(to right, #274060, #1B2845);
        color: GhostWhite;
        font-family: sans-serif;
        text-align: center;
      }
    </style>
  </head>
  <body>
    <h1>Your App Content!</h1>
    <button onclick="callV()">Call V!</button>
  </body>
  <script>
    async function callV() {
      // Call a V function that takes an argument and returns a value.
      const res = await window.my_v_func(\'Hello from JS!\');
      console.log(res);
    }
  </script>
</html>'

fn my_v_func(e &webview.Event) string {
	println('Hello from V from V!')
	e.eval("console.log('Hello from V from JS!');")
	str_arg := e.get_arg[string](0) or { '' } // Get string arg at index `0`
	return str_arg + ' Hello back from V!'
}

w := webview.create(debug: true)
w.bind('my_v_func', my_v_func)
w.set_size(600, 400, .@none)
w.set_html(html)
w.run()
```

Output when pressing <kbd>Call V!</kdb>

```
Hello from V from V!
CONSOLE LOG Hello from V from JS!
CONSOLE LOG Hello from JS! Hello back from V!
```

---

### Additional Examples

Examples live in the [`examples/`](https://github.com/PUSHPAK-JAISWAL/webview/tree/main/examples) directory.

1. [v-js-interop-simple](https://github.com/PUSHPAK-JAISWAL/webview/tree/main/examples/v-js-interop-simple) - simple example with a similar complexity as the readme example above.
2. [v-js-interop-app](https://github.com/PUSHPAK-JAISWAL/webview/tree/main/examples/v-js-interop-app) - shows the basic code architecture of an application.
3. [project-structure](https://github.com/PUSHPAK-JAISWAL/webview/tree/main/examples/project-structure) - organizes `2. v-js-interop-app` into a directory structure that can be used as orientation for more complex projects.
4. [astro-project](https://github.com/PUSHPAK-JAISWAL/webview/tree/main/examples/astro-project) - uses a modern web framework for the UI.

External Examples

1. [LVbag](https://github.com/ttytm/LVbag/blob/main/examples/gui_project) - minimal example that automates embedding of the UI into the executable.
2. [emoji-mart-desktop](https://github.com/ttytm/emoji-mart-desktop) - application that combines above concepts. It uses SvelteKit for the UI and embeds it inside a single executable.

## Documentation

An overview of exported functions is accessible in [`lib.v`](https://github.com/PUSHPAK-JAISWAL/webview/blob/main/lib.v)
and on the [documentation site](https://pushpak-jaiswal.github.io/webview/webview.html).

### Debugging

> [!NOTE]
> The debug feature currently works on Linux and Windows.

Use the `webview_debug` flag to enable developer tools - this enables the Web Inspector (allowing
for e.g., _right click_ <kbd>Inspect Element</kbd>) and `console.log` prints to the terminal. E.g.:

```sh
v -d webview_debug run .
```

Alternatively, control the debug mode explicitly for a window by using the optional debug argument.

```v ignore
webview.create() // enabled when the application was build with `-d webview_debug`
webview.create(debug: true) // explicitly enabled for the window
webview.create(debug: false) // explicitly disabled for the window, even when built with `-d webview_debug`
```

## Disclaimer

Until a stable version 1.0 is available, new features will be introduced, existing ones may change,
or breaking changes may occur in minor(`0.<minor>.*`) versions.

## Complementary Projects

- [Dialog](https://github.com/ttytm/dialog) - Cross-platform utility library to open system dialogs - files, message boxes etc.
- [LVbag](https://github.com/ttytm/LVbag) - Generate embedded file lists for directories.

## License

Open source software under the [MIT license](LICENSE).
