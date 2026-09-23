# Package

version     = "26.39.0"
author      = "Antonis Geralis"
description = "Raygui Nim wrapper"
license     = "MIT"
srcDir      = "src"

# Deps

requires "nim >= 2.2.0"
requires "naylib >= 26.39.0"
feature "dev":
  requires "eminim == 2.8.2"

task test, "Runs the test suite":
  exec "nim c -r tests/bindings_test.nim"
  exec "nim c -d:release tests/controls_test_suite.nim"
  exec "nim c examples/scroll_panel.nim"
