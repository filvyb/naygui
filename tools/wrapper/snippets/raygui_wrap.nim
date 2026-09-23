
type
  TextArray* = object
    data: cstringArray
    count: int32

proc `=destroy`*(t: TextArray) =
  if t.data != nil:
    deallocCStringArray(t.data)
proc `=dup`*(source: TextArray): TextArray {.error.}
proc `=copy`*(dest: var TextArray; source: TextArray) {.error.}

proc toTextArray*(texts: openArray[string]): TextArray =
  TextArray(data: allocCStringArray(texts), count: texts.len.int32)

proc memFree(p: pointer) {.importc: "NayguiFree", cdecl, sideEffect.}

proc listView*(bounds: Rectangle, text: TextArray, scrollIndex: var int32, active: var int32, focus: var int32): GuiResult {.discardable.} =
  ## List View with extended parameters.
  listViewImpl(bounds, text.data, text.count, addr scrollIndex, addr active, addr focus)

proc tabBar*(bounds: Rectangle, text: TextArray, hscroll: var int32, active: var int32, focus: var int32): GuiResult {.discardable.} =
  ## Tab Bar with extended parameters. ResultTabClose identifies the tab in focus.
  tabBarImpl(bounds, text.data, text.count, addr hscroll, addr active, addr focus)

proc takeIconNames(names: cstringArray): seq[string] =
  if names == nil: return
  # Upstream allocates 512 slots, with no extra sentinel when all are used.
  for i in 0..<512:
    if names[i] == nil: break
    var name = ""
    for j in 0..<32:
      if names[i][j] == '\0': break
      name.add(names[i][j])
    result.add(name)
    memFree(names[i])
  memFree(names)

proc loadIcons*(fileName: string, loadIconsName: bool): seq[string] =
  ## Load raygui icons file (.rgi), optionally returning the icon names.
  takeIconNames(loadIconsImpl(fileName.cstring, loadIconsName))

proc loadIconsFromMemory*(data: openArray[uint8], loadIconsName: bool): seq[string] =
  ## Load raygui icons (.rgi) from memory, optionally returning the icon names.
  if data.len == 0: return
  takeIconNames(loadIconsFromMemoryImpl(unsafeAddr data[0], data.len.int32, loadIconsName))

proc guiLoadStyleFromMemory*(data: openArray[uint8]) =
  ## Load a binary raygui style (.rgs) from memory.
  if data.len > 0:
    guiLoadStyleFromMemoryImpl(unsafeAddr data[0], data.len.int32)

template withTextBuffer(text: var string, call: untyped): untyped =
  # setLen makes a writable copy before C mutates the string, and exposes its
  # full capacity. Restore the Nim length on every frame, including live edits.
  assert text.capacity > 0, "Expects a preallocated string buffer."
  let oldLen = text.len
  text.setLen(text.capacity)
  if oldLen < text.len: text[oldLen] = '\0'
  result = call
  var newLen = 0
  while newLen < text.len and text[newLen] != '\0': inc newLen
  text.setLen(newLen)

proc textBox*(bounds: Rectangle, text: var string, editMode: bool): GuiResult {.discardable.} =
  ## Text Box control. Reserve the maximum input length with newStringOfCap.
  withTextBuffer(text):
    textBoxImpl(bounds, text.cstring, text.len.int32 + 1, editMode)

proc valueBoxFloat*(bounds: Rectangle, text: string, textValue: var string, value: var float32, editMode: bool): GuiResult {.discardable.} =
  ## Float Value Box. The input buffer must have capacity for at least 32 bytes.
  assert textValue.capacity >= 32, "Expects a buffer with capacity of at least 32."
  withTextBuffer(textValue):
    valueBoxFloatImpl(bounds, if text.len == 0: nil else: text.cstring, textValue.cstring, addr value, editMode)

proc textInputBox*(bounds: Rectangle, title: string, message: string, text: var string, buttons: string, buttonActive: var int32, secretViewActive: var bool): GuiResult {.discardable.} =
  ## Text Input Box with secret mode. buttonActive is 0 for close, 1 for the first button.
  withTextBuffer(text):
    textInputBoxImpl(bounds, title.cstring, if message.len == 0: nil else: message.cstring, text.cstring, text.len.int32 + 1, buttons.cstring, addr buttonActive, addr secretViewActive)

proc textInputBox*(bounds: Rectangle, title: string, message: string, text: var string, buttons: string, buttonActive: var int32): GuiResult {.discardable.} =
  ## Text Input Box without secret mode. Inspect buttonActive on ResultPressed.
  withTextBuffer(text):
    textInputBoxImpl(bounds, title.cstring, if message.len == 0: nil else: message.cstring, text.cstring, text.len.int32 + 1, buttons.cstring, addr buttonActive, nil)

type
  GuiStyleProperty* = ControlProperty|DefaultProperty|ToggleProperty|SliderProperty|
                      ProgressBarProperty|ScrollBarProperty|CheckBoxProperty|
                      ComboBoxProperty|DropdownBoxProperty|TextBoxProperty|
                      ValueBoxProperty|TabBarProperty|ListViewProperty|ColorPickerProperty

  GuiStyleValue* = GuiState|GuiTextAlignment|GuiTextAlignmentVertical|
                   GuiTextWrapMode|GuiControl|int32|bool

template validatePropertyControlMapping(control, property: untyped) =
  when property is ControlProperty:
    discard "ControlProperty applies to all controls"
  elif property is DefaultProperty:
    assert control == Default, "DefaultProperty should match Default control"
  elif property is ToggleProperty:
    assert control == Toggle, "ToggleProperty should match Toggle control"
  elif property is SliderProperty:
    assert control == Slider, "SliderProperty should match Slider control"
  elif property is ProgressBarProperty:
    assert control == Progressbar, "ProgressBarProperty should match Progressbar control"
  elif property is ScrollBarProperty:
    assert control == Scrollbar, "ScrollBarProperty should match Scrollbar control"
  elif property is CheckBoxProperty:
    assert control == Checkbox, "CheckBoxProperty should match Checkbox control"
  elif property is ComboBoxProperty:
    assert control == Combobox, "ComboBoxProperty should match Combobox control"
  elif property is DropdownBoxProperty:
    assert control == Dropdownbox, "DropdownBoxProperty should match Dropdownbox control"
  elif property is TextBoxProperty:
    assert control == Textbox, "TextBoxProperty should match Textbox control"
  elif property is ValueBoxProperty:
    assert control == Valuebox, "ValueBoxProperty should match ValueBox control"
  elif property is TabBarProperty:
    assert control == Tabbar, "TabBarProperty should match Tabbar control"
  elif property is ListViewProperty:
    assert control == Listview, "ListViewProperty should match Listview control"
  elif property is ColorPickerProperty:
    assert control == Colorpicker, "ColorPickerProperty should match Colorpicker control"

proc guiSetStyle*[P: GuiStyleProperty, V: GuiStyleValue](control: GuiControl, property: P, value: V) =
  ## Set one style property
  validatePropertyControlMapping(control, P)
  guiSetStyleImpl(control, property.int32, value.int32)

proc guiGetStyle*[P: GuiStyleProperty](control: GuiControl, property: P): int32 =
  ## Get one style property
  validatePropertyControlMapping(control, P)
  guiGetStyleImpl(control, property.int32)

proc iconText*(iconId: GuiIconName, text: string = ""): string =
  ## Get text with icon id prepended (if supported)
  when defined(NayguiNoIcons):
    result = ""
  else:
    result = "#" & align($iconId.ord, 3, '0') & "#"
    if text.len > 0:
      result = result & text
