# Headless regression tests for the FFI helpers; no graphics context is needed.
include ../src/raygui

static:
  doAssert RayguiVersion == (5, 0, 0)
  doAssert sizeof(GuiResult) == sizeof(int32)
  doAssert ord(ResultTabClose) == 4
  doAssert ord(Tabbar) == 11
  doAssert ord(TabItemsWidth) == 16

proc writeInput(buffer: cstring, size: int32, value: string,
                event: GuiResult): GuiResult =
  doAssert value.len < size
  let chars = cast[ptr UncheckedArray[char]](buffer)
  for i, ch in value: chars[i] = ch
  chars[value.len] = '\0'
  event

proc editInput(text: var string, value: string, event: GuiResult): GuiResult =
  withTextBuffer(text):
    writeInput(text.cstring, text.len.int32 + 1, value, event)

block:
  var text = newStringOfCap(64)
  doAssert editInput(text, "live input", ResultNone) == ResultNone
  doAssert text == "live input"
  let copy = text
  doAssert editInput(text, "edited", ResultChanged) == ResultChanged
  doAssert text == "edited"
  doAssert copy == "live input"
  doAssert editInput(text, "", ResultPressed) == ResultPressed
  doAssert text.len == 0
  doAssert editInput(text, "again", ResultNone) == ResultNone
  doAssert text == "again"

block:
  # A full icon set has no sentinel slot and names need not be NUL-terminated.
  const count = 512
  var data = newSeq[uint8](12 + count * (32 + 32))
  data[0] = uint8('r')
  data[1] = uint8('G')
  data[2] = uint8('I')
  data[3] = uint8(' ')
  data[4] = 100
  data[8] = 0
  data[9] = 2
  data[10] = 16
  for i in 0..<count * 32: data[12 + i] = uint8('A')
  data[12 + count * 32] = 1
  let names = loadIconsFromMemory(data, true)
  doAssert names.len == count
  for name in names:
    doAssert name == "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  doAssert getIcons()[0] == 1
  doAssert loadIconsFromMemory([], true).len == 0
  doAssert takeIconNames(nil).len == 0

guiSetState(Disabled)
doAssert guiGetState() == Disabled
guiEnable()
doAssert guiGetState() == Normal
guiLock()
doAssert guiIsLocked()
guiUnlock()
doAssert not guiIsLocked()

guiSetStyle(Valuebox, SpinnerButtonWidth, 24)
doAssert guiGetStyle(Valuebox, SpinnerButtonWidth) == 24
guiSetStyle(Tabbar, TabCloseButton, true)
doAssert guiGetStyle(Tabbar, TabCloseButton) == 1

# Compile and link the changed control signatures without drawing headlessly.
proc compileControls() {.exportc.} =
  let bounds = Rectangle(width: 100, height: 30)
  var active, hscroll, focus: int32
  let tabs = toTextArray(["One", "Two"])
  tabBar(bounds, "One;Two", hscroll, active)
  tabBar(bounds, tabs, hscroll, active, focus)
  var text = newStringOfCap(64)
  var value: float32
  var secret: bool
  valueBoxFloat(bounds, "", text, value, false)
  textBox(bounds, text, false)
  messageBox(bounds, "Title", "Message", "OK", active)
  textInputBox(bounds, "Title", "Message", text, "OK", active)
  textInputBox(bounds, "Title", "Message", text, "OK", active, secret)
  discard loadIcons("icons.rgi", true)
  guiLoadStyleFromMemory([])
