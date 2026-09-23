# Naygui

Welcome to this repository! Here you'll find a Nim wrapper for raygui, an auxiliar module for raylib to create simple GUI interfaces.

Targets [raygui 5.0](https://github.com/raysan5/raygui/releases/tag/5.0).

## Documentation

Please refer to the raygui readme and examples writen in C:
https://github.com/raysan5/raygui/

[API docs](https://planetis-m.github.io/naygui/raygui.html)

## Installation

```
nimble install https://github.com/planetis-m/naygui.git
```

## Examples

Example code located in tests dir:
https://github.com/planetis-m/naygui/blob/master/tests/controls_test_suite.nim

```
nim compile -r tests/controls_test_suite.nim
```

### Development Status

Currently some features are missing.

## raygui 5.0 migration

Controls return a discardable `GuiResult`: `ResultNone`, `ResultPressed`,
`ResultChanged`, or `ResultTabClose`. Compare edit controls with `ResultPressed`
to toggle edit mode; use `ResultChanged` to detect value changes. Dropdowns
close on either `ResultPressed` or `ResultChanged`, so compare with `ResultNone`.

`messageBox` takes a button index by reference. `textInputBox` takes the mutable
text before the button labels, followed by a button index and an optional secret
mode flag. On `ResultPressed`, index 0 means close and indices 1 onward identify
the buttons. `tabBar` takes a horizontal scroll offset and active index; its
`TextArray` overload also takes a focus index, which identifies a closing tab.

Reserve text input buffers with `newStringOfCap`; `valueBoxFloat` requires a
mutable string with capacity for at least 32 bytes. Binary styles and icons can
be loaded with `guiLoadStyleFromMemory` and `loadIconsFromMemory`.
