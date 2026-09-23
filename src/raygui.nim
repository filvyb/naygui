from raylib import Vector2, Vector3, Color, Rectangle, Texture2D, Image, GlyphInfo, Font
export Vector2, Vector3, Color, Rectangle, Texture2D, Image, GlyphInfo, Font

import std/[assertions, paths]
from std/strutils import align
const rayguiDir = currentSourcePath().Path.parentDir / Path"raygui"

when defined(mingw):
  import std/private/globs
  from std/private/ospaths2 import joinPath
  func `/`(head, tail: Path): Path {.inline.} =
    joinPath(head.string, tail.string).nativeToUnixPath.Path
  {.passC: "-I/usr/x86_64-w64-mingw32/include".}

{.passC: "-I" & rayguiDir.string.}
{.compile: string(rayguiDir / Path"raygui.c").}

const
  RayguiVersion* = (5, 0, 0)

type
  GuiResult* {.size: sizeof(int32).} = enum ## Gui control result
    ResultNone
    ResultPressed
    ResultChanged
    ResultTabClose = 4 ## GuiTabBar(), tab close request

  GuiState* {.size: sizeof(int32).} = enum ## Gui control state
    Normal
    Focused
    Pressed
    Disabled

  GuiTextAlignment* {.size: sizeof(int32).} = enum ## Gui control text alignment
    Left
    Center
    Right

  GuiTextAlignmentVertical* {.size: sizeof(int32).} = enum ## Gui control text alignment vertical
    Top
    Middle
    Bottom

  GuiTextWrapMode* {.size: sizeof(int32).} = enum ## Gui control text wrap mode
    TextWrapNone
    TextWrapChar
    TextWrapWord

  GuiControl* {.size: sizeof(int32).} = enum ## Gui controls
    Default
    Label ## Used also for: LABELBUTTON
    Button
    Toggle ## Used also for: TOGGLEGROUP
    Slider ## Used also for: SLIDERBAR, TOGGLESLIDER
    Progressbar
    Checkbox
    Combobox
    Dropdownbox
    Textbox ## Used also for: TEXTBOXMULTI
    Valuebox
    Tabbar
    Listview
    Colorpicker
    Scrollbar
    Statusbar

  ControlProperty* {.size: sizeof(int32).} = enum ## Controls BASE properties for every control (RAYGUI_MAX_PROPS_BASE = 16)
    BorderColorNormal ## Control border color in STATE_NORMAL
    BaseColorNormal ## Control base color in STATE_NORMAL
    TextColorNormal ## Control text color in STATE_NORMAL
    BorderColorFocused ## Control border color in STATE_FOCUSED
    BaseColorFocused ## Control base color in STATE_FOCUSED
    TextColorFocused ## Control text color in STATE_FOCUSED
    BorderColorPressed ## Control border color in STATE_PRESSED
    BaseColorPressed ## Control base color in STATE_PRESSED
    TextColorPressed ## Control text color in STATE_PRESSED
    BorderColorDisabled ## Control border color in STATE_DISABLED
    BaseColorDisabled ## Control base color in STATE_DISABLED
    TextColorDisabled ## Control text color in STATE_DISABLED
    BorderWidth ## Control border size, 0 for no border
    TextPadding ## Control text padding, not considering border
    TextAlignment ## Control text horizontal alignment inside control text bound (after border and padding): 0-Left, 1-Center, 2-Right
    Baseprop16 ## Not used yet...

  DefaultProperty* {.size: sizeof(int32).} = enum ## DEFAULT control, extended properties
    TextSize = 16 ## Text size (glyphs max height)
    TextSpacing ## Text spacing between glyphs
    LineColor ## Line control color
    BackgroundColor ## Background color
    TextLineSpacing ## Text spacing between lines
    TextAlignmentVertical ## Text vertical alignment inside text bounds (after border and padding): 0-Top, 1-Middle, 2-Bottom
    TextWrapMode ## Text wrap-mode inside text bounds
    Extprop08 ## Not used yet...

  ToggleProperty* {.size: sizeof(int32).} = enum ## Toggle/ToggleGroup
    GroupPadding = 16 ## ToggleGroup separation between toggles
    GroupWidthFull ## ToggleGroup bounds width considers all items: 0-Width per item, 1-Full width

  SliderProperty* {.size: sizeof(int32).} = enum ## Slider/SliderBar
    SliderWidth = 16 ## Slider size of internal bar
    SliderPadding ## Slider/SliderBar internal bar padding

  ProgressBarProperty* {.size: sizeof(int32).} = enum ## ProgressBar
    ProgressPadding = 16 ## ProgressBar internal padding
    ProgressSide ## ProgressBar increment side: 0-Left->Right, 1-Right->Left

  ScrollBarProperty* {.size: sizeof(int32).} = enum ## ScrollBar
    ArrowsSize = 16 ## ScrollBar arrows size
    ArrowsVisible ## ScrollBar arrows visible
    ScrollSliderPadding ## ScrollBar slider internal padding
    ScrollSliderSize ## ScrollBar slider size
    ScrollPadding ## ScrollBar scroll padding from arrows
    ScrollSpeed ## ScrollBar scrolling speed

  CheckBoxProperty* {.size: sizeof(int32).} = enum ## CheckBox
    CheckPadding = 16 ## CheckBox internal check padding

  ComboBoxProperty* {.size: sizeof(int32).} = enum ## ComboBox
    ComboButtonWidth = 16 ## ComboBox right button width
    ComboButtonSpacing ## ComboBox button separation

  DropdownBoxProperty* {.size: sizeof(int32).} = enum ## DropdownBox
    ArrowPadding = 16 ## DropdownBox arrow separation from border and items
    DropdownItemsSpacing ## DropdownBox items separation
    DropdownArrowHidden ## DropdownBox arrow hidden
    DropdownRollUp ## DropdownBox roll up flag: 0-Roll down, 1-Roll up

  TextBoxProperty* {.size: sizeof(int32).} = enum ## TextBox/TextBoxMulti/ValueBox/Spinner
    TextReadonly = 16 ## TextBox in read-only mode: 0-Text editable, 1-Text read-only

  ValueBoxProperty* {.size: sizeof(int32).} = enum ## ValueBox/Spinner
    SpinnerButtonWidth = 16 ## Spinner left/right buttons width
    SpinnerButtonSpacing ## Spinner buttons separation

  TabBarProperty* {.size: sizeof(int32).} = enum ## TabBar
    TabItemsWidth = 16 ## TabBar tab items width
    TabCloseButton ## TabBar tab close button: 0-Not shown, 1-Shown
    TabLineSide ## TabBar tabs side: 0-Bottom, 1-Top

  ListViewProperty* {.size: sizeof(int32).} = enum
    ListItemsHeight = 16 ## ListView items height
    ListItemsSpacing ## ListView items separation
    ScrollbarWidth ## ListView scrollbar size (usually width)
    ScrollbarSide ## ListView scrollbar side: 0-Left side, 1-Right Side
    ListItemsBorderNormal ## ListView items border enabled in normal state
    ListItemsBorderWidth ## ListView items border width

  ColorPickerProperty* {.size: sizeof(int32).} = enum ## ColorPicker
    ColorSelectorSize = 16 ## ColorPicker selector square size
    HuebarWidth ## ColorPicker right hue bar width
    HuebarPadding ## ColorPicker right hue bar separation from panel
    HuebarSelectorHeight ## ColorPicker right hue bar selector height
    HuebarSelectorOverflow ## ColorPicker right hue bar selector overflow

  GuiIconName* {.size: sizeof(int32).} = enum
    None
    FolderFileOpen
    FileSaveClassic
    FolderOpen
    FolderSave
    FileOpen
    FileSave
    FileExport
    FileAdd
    FileDelete
    FiletypeText
    FiletypeAudio
    FiletypeImage
    FiletypePlay
    FiletypeVideo
    FiletypeInfo
    FileCopy
    FileCut
    FilePaste
    CursorHand
    CursorPointer
    CursorClassic
    Pencil
    PencilBig
    BrushClassic
    BrushPainter
    WaterDrop
    ColorPicker
    Rubber
    ColorBucket
    TextT
    TextA
    Scale
    Resize
    FilterPoint
    FilterBilinear
    Crop
    CropAlpha
    SquareToggle
    Symmetry
    SymmetryHorizontal
    SymmetryVertical
    Lens
    LensBig
    EyeOn
    EyeOff
    FilterTop
    Filter
    TargetPoint
    TargetSmall
    TargetBig
    TargetMove
    CursorMove
    CursorScale
    CursorScaleRight
    CursorScaleLeft
    Undo
    Redo
    Reredo
    Mutate
    Rotate
    Repeat
    Shuffle
    Emptybox
    Target
    TargetSmallFill
    TargetBigFill
    TargetMoveFill
    CursorMoveFill
    CursorScaleFill
    CursorScaleRightFill
    CursorScaleLeftFill
    UndoFill
    RedoFill
    ReredoFill
    MutateFill
    RotateFill
    RepeatFill
    ShuffleFill
    EmptyboxSmall
    Box
    BoxTop
    BoxTopRight
    BoxRight
    BoxBottomRight
    BoxBottom
    BoxBottomLeft
    BoxLeft
    BoxTopLeft
    BoxCenter
    BoxCircleMask
    Pot
    AlphaMultiply
    AlphaClear
    Dithering
    Mipmaps
    BoxGrid
    Grid
    BoxCornersSmall
    BoxCornersBig
    FourBoxes
    GridFill
    BoxMultisize
    ZoomSmall
    ZoomMedium
    ZoomBig
    ZoomAll
    ZoomCenter
    BoxDotsSmall
    BoxDotsBig
    BoxConcentric
    BoxGridBig
    OkTick
    Cross
    ArrowLeft
    ArrowRight
    ArrowDown
    ArrowUp
    ArrowLeftFill
    ArrowRightFill
    ArrowDownFill
    ArrowUpFill
    Audio
    Fx
    Wave
    WaveSinus
    WaveSquare
    WaveTriangular
    CrossSmall
    PlayerPrevious
    PlayerPlayBack
    PlayerPlay
    PlayerPause
    PlayerStop
    PlayerNext
    PlayerRecord
    Magnet
    LockClose
    LockOpen
    Clock
    Tools
    Gear
    GearBig
    Bin
    HandPointer
    Laser
    Coin
    Explosion
    Icon1up
    Player
    PlayerJump
    Key
    Demon
    TextPopup
    GearEx
    Crack
    CrackPoints
    Star
    Door
    Exit
    Mode2d
    Mode3d
    Cube
    CubeFaceTop
    CubeFaceLeft
    CubeFaceFront
    CubeFaceBottom
    CubeFaceRight
    CubeFaceBack
    Camera
    Special
    LinkNet
    LinkBoxes
    LinkMulti
    Link
    LinkBroke
    TextNotes
    Notebook
    Suitcase
    SuitcaseZip
    Mailbox
    Monitor
    Printer
    PhotoCamera
    PhotoCameraFlash
    House
    Heart
    Corner
    VerticalBars
    VerticalBarsFill
    LifeBars
    Info
    Crossline
    Help
    FiletypeAlpha
    FiletypeHome
    LayersVisible
    Layers
    Window
    Hidpi
    FiletypeBinary
    Hex
    Shield
    FileNew
    FolderAdd
    Alarm
    Cpu
    Rom
    StepOver
    StepInto
    StepOut
    Restart
    BreakpointOn
    BreakpointOff
    BurgerMenu
    CaseSensitive
    RegExp
    Folder
    File
    SandTimer
    Warning
    HelpBox
    InfoBox
    Priority
    LayersIso
    Layers2
    Mlayers
    Maps
    Hot
    Label
    NameId
    Slicing
    ManualControl
    Collision
    CircleAdd
    CircleAddFill
    CircleWarning
    CircleWarningFill
    BoxMore
    BoxMoreFill
    BoxMinus
    BoxMinusFill
    Union
    Intersection
    Difference
    Sphere
    Cylinder
    Cone
    Ellipsoid
    Capsule
    FiletypeFont
    Filetype3d
    FiletypeCodeXml
    FiletypeCodeC
    FiletypeCodePython
    FiletypeCodeJs
    FiletypeIcon

const
  ScrollbarLeftSide* = 0
  ScrollbarRightSide* = 1

type
  Texture* {.importc, header: "raygui.h", completeStruct, bycopy.} = object ## It should be redesigned to be provided by user
    id*: uint32 ## OpenGL texture id
    width*: int32 ## Texture base width
    height*: int32 ## Texture base height
    mipmaps*: int32 ## Mipmap levels, 1 by default
    format*: int32 ## Data format (PixelFormat type)

  StyleProp* {.importc: "GuiStyleProp", header: "raygui.h", completeStruct, bycopy.} = object ## NOTE: Used when exporting style as code for convenience
    controlId*: uint16 ## Control identifier
    propertyId*: uint16 ## Property identifier
    propertyValue*: int32 ## Property value



{.push callconv: cdecl, header: "raygui.h".}
proc guiEnable*() {.importc: "GuiEnable", sideEffect.}
  ## Enable gui controls (global state)
proc guiDisable*() {.importc: "GuiDisable", sideEffect.}
  ## Disable gui controls (global state)
proc guiLock*() {.importc: "GuiLock", sideEffect.}
  ## Lock gui controls (global state)
proc guiUnlock*() {.importc: "GuiUnlock", sideEffect.}
  ## Unlock gui controls (global state)
proc guiIsLocked*(): bool {.importc: "GuiIsLocked", sideEffect.}
  ## Check if gui is locked (global state)
proc guiSetAlpha*(alpha: float32) {.importc: "GuiSetAlpha", sideEffect.}
  ## Set gui controls alpha (global state), alpha goes from 0.0f to 1.0f
proc guiSetState*(state: GuiState) {.importc: "GuiSetState", sideEffect.}
  ## Set gui state (global state)
proc guiGetState*(): GuiState {.importc: "GuiGetState", sideEffect.}
  ## Get gui state (global state)
proc guiSetFont*(font: Font) {.importc: "GuiSetFont", sideEffect.}
  ## Set gui custom font (global state)
proc guiGetFont*(): Font {.importc: "GuiGetFont", sideEffect.}
  ## Get gui custom font (global state)
proc guiSetStyleImpl(control: GuiControl, property: int32, value: int32) {.importc: "GuiSetStyle", sideEffect.}
proc guiGetStyleImpl(control: GuiControl, property: int32): int32 {.importc: "GuiGetStyle", sideEffect.}
proc guiLoadStyleImpl(fileName: cstring) {.importc: "GuiLoadStyle", sideEffect.}
proc guiLoadStyleFromMemoryImpl(fileData: ptr uint8, dataSize: int32) {.importc: "GuiLoadStyleFromMemory", sideEffect.}
proc guiLoadStyleDefault*() {.importc: "GuiLoadStyleDefault", sideEffect.}
  ## Load style default over global style
proc enableTooltip*() {.importc: "GuiEnableTooltip", sideEffect.}
  ## Enable gui tooltips (global state)
proc disableTooltip*() {.importc: "GuiDisableTooltip", sideEffect.}
  ## Disable gui tooltips (global state)
proc setTooltipImpl(tooltip: cstring) {.importc: "GuiSetTooltip", sideEffect.}
proc setIconScale*(scale: int32) {.importc: "GuiSetIconScale", sideEffect.}
  ## Set default icon drawing size
proc getIcons*(): ptr UncheckedArray[uint32] {.importc: "GuiGetIcons", sideEffect.}
  ## Get raygui icons data pointer
proc loadIconsImpl(fileName: cstring, loadIconsName: bool): cstringArray {.importc: "GuiLoadIcons", sideEffect.}
proc loadIconsFromMemoryImpl(fileData: ptr uint8, dataSize: int32, loadIconsName: bool): cstringArray {.importc: "GuiLoadIconsFromMemory", sideEffect.}
proc drawIcon*(iconId: GuiIconName, posX: int32, posY: int32, pixelSize: int32, color: Color) {.importc: "GuiDrawIcon", sideEffect.}
  ## Draw icon using pixel size at specified position
proc getTextWidthImpl(text: cstring): int32 {.importc: "GuiGetTextWidth", sideEffect.}
proc windowBoxImpl(bounds: Rectangle, title: cstring): GuiResult {.importc: "GuiWindowBox", sideEffect.}
proc groupBoxImpl(bounds: Rectangle, text: cstring): GuiResult {.importc: "GuiGroupBox", sideEffect.}
proc lineImpl(bounds: Rectangle, text: cstring): GuiResult {.importc: "GuiLine", sideEffect.}
proc panelImpl(bounds: Rectangle, text: cstring): GuiResult {.importc: "GuiPanel", sideEffect.}
proc scrollPanelImpl(bounds: Rectangle, text: cstring, content: Rectangle, scroll: ptr Vector2, view: out Rectangle): GuiResult {.importc: "GuiScrollPanel", sideEffect.}
proc labelImpl(bounds: Rectangle, text: cstring): GuiResult {.importc: "GuiLabel", sideEffect.}
proc buttonImpl(bounds: Rectangle, text: cstring): GuiResult {.importc: "GuiButton", sideEffect.}
proc labelButtonImpl(bounds: Rectangle, text: cstring): GuiResult {.importc: "GuiLabelButton", sideEffect.}
proc toggleImpl(bounds: Rectangle, text: cstring, active: ptr bool): GuiResult {.importc: "GuiToggle", sideEffect.}
proc toggleGroupImpl(bounds: Rectangle, text: cstring, active: ptr int32): GuiResult {.importc: "GuiToggleGroup", sideEffect.}
proc toggleSliderImpl(bounds: Rectangle, text: cstring, active: ptr int32): GuiResult {.importc: "GuiToggleSlider", sideEffect.}
proc checkBoxImpl(bounds: Rectangle, text: cstring, checked: ptr bool): GuiResult {.importc: "GuiCheckBox", sideEffect.}
proc comboBoxImpl(bounds: Rectangle, text: cstring, active: ptr int32): GuiResult {.importc: "GuiComboBox", sideEffect.}
proc dropdownBoxImpl(bounds: Rectangle, text: cstring, active: ptr int32, editMode: bool): GuiResult {.importc: "GuiDropdownBox", sideEffect.}
proc spinnerImpl(bounds: Rectangle, text: cstring, value: ptr int32, minValue: int32, maxValue: int32, editMode: bool): GuiResult {.importc: "GuiSpinner", sideEffect.}
proc valueBoxImpl(bounds: Rectangle, text: cstring, value: ptr int32, minValue: int32, maxValue: int32, editMode: bool): GuiResult {.importc: "GuiValueBox", sideEffect.}
proc valueBoxFloatImpl(bounds: Rectangle, text: cstring, textValue: cstring, value: ptr float32, editMode: bool): GuiResult {.importc: "GuiValueBoxFloat", sideEffect.}
proc textBoxImpl(bounds: Rectangle, text: cstring, textSize: int32, editMode: bool): GuiResult {.importc: "GuiTextBox", sideEffect.}
proc sliderImpl(bounds: Rectangle, textLeft: cstring, textRight: cstring, value: ptr float32, minValue: float32, maxValue: float32): GuiResult {.importc: "GuiSlider", sideEffect.}
proc sliderBarImpl(bounds: Rectangle, textLeft: cstring, textRight: cstring, value: ptr float32, minValue: float32, maxValue: float32): GuiResult {.importc: "GuiSliderBar", sideEffect.}
proc progressBarImpl(bounds: Rectangle, textLeft: cstring, textRight: cstring, value: ptr float32, minValue: float32, maxValue: float32): GuiResult {.importc: "GuiProgressBar", sideEffect.}
proc statusBarImpl(bounds: Rectangle, text: cstring): GuiResult {.importc: "GuiStatusBar", sideEffect.}
proc dummyRecImpl(bounds: Rectangle, text: cstring): GuiResult {.importc: "GuiDummyRec", sideEffect.}
proc gridImpl(bounds: Rectangle, text: cstring, spacing: float32, subdivs: int32, mouseCell: out Vector2): GuiResult {.importc: "GuiGrid", sideEffect.}
proc listViewImpl(bounds: Rectangle, text: cstring, scrollIndex: ptr int32, active: ptr int32): GuiResult {.importc: "GuiListView", sideEffect.}
proc listViewImpl(bounds: Rectangle, text: cstringArray, count: int32, scrollIndex: ptr int32, active: ptr int32, focus: ptr int32): GuiResult {.importc: "GuiListViewEx", sideEffect.}
proc tabBarImpl(bounds: Rectangle, text: cstring, hscroll: ptr int32, active: ptr int32): GuiResult {.importc: "GuiTabBar", sideEffect.}
proc tabBarImpl(bounds: Rectangle, text: cstringArray, count: int32, hscroll: ptr int32, active: ptr int32, focus: ptr int32): GuiResult {.importc: "GuiTabBarEx", sideEffect.}
proc messageBoxImpl(bounds: Rectangle, title: cstring, message: cstring, btnText: cstring, btnActive: ptr int32): GuiResult {.importc: "GuiMessageBox", sideEffect.}
proc textInputBoxImpl(bounds: Rectangle, title: cstring, message: cstring, text: cstring, textSize: int32, btnText: cstring, btnActive: ptr int32, secretViewActive: ptr bool): GuiResult {.importc: "GuiTextInputBox", sideEffect.}
proc colorPickerImpl(bounds: Rectangle, text: cstring, color: ptr Color): GuiResult {.importc: "GuiColorPicker", sideEffect.}
proc colorPanelImpl(bounds: Rectangle, text: cstring, color: ptr Color): GuiResult {.importc: "GuiColorPanel", sideEffect.}
proc colorBarAlphaImpl(bounds: Rectangle, text: cstring, alpha: ptr float32): GuiResult {.importc: "GuiColorBarAlpha", sideEffect.}
proc colorBarHueImpl(bounds: Rectangle, text: cstring, value: ptr float32): GuiResult {.importc: "GuiColorBarHue", sideEffect.}
proc colorPickerHSVImpl(bounds: Rectangle, text: cstring, colorHsv: ptr Vector3): GuiResult {.importc: "GuiColorPickerHSV", sideEffect.}
proc colorPanelHSVImpl(bounds: Rectangle, text: cstring, colorHsv: ptr Vector3): GuiResult {.importc: "GuiColorPanelHSV", sideEffect.}
{.pop.}


proc guiLoadStyle*(fileName: string) =
  ## Load style file over global style variable (.rgs)
  guiLoadStyleImpl(fileName.cstring)

proc setTooltip*(tooltip: string) =
  ## Set tooltip string
  setTooltipImpl(if tooltip.len == 0: nil else: tooltip.cstring)

proc getTextWidth*(text: string): int32 =
  ## Get text width considering gui style and icon size (if required)
  getTextWidthImpl(text.cstring)

proc windowBox*(bounds: Rectangle, title: string): GuiResult {.discardable.} =
  ## Window Box control, shows a window that can be closed
  windowBoxImpl(bounds, title.cstring)

proc groupBox*(bounds: Rectangle, text: string): GuiResult {.discardable.} =
  ## Group Box control with text name
  groupBoxImpl(bounds, if text.len == 0: nil else: text.cstring)

proc line*(bounds: Rectangle, text: string): GuiResult {.discardable.} =
  ## Line separator control, could contain text
  lineImpl(bounds, if text.len == 0: nil else: text.cstring)

proc panel*(bounds: Rectangle, text: string): GuiResult {.discardable.} =
  ## Panel control, useful to group controls
  panelImpl(bounds, if text.len == 0: nil else: text.cstring)

proc scrollPanel*(bounds: Rectangle, text: string, content: Rectangle, scroll: var Vector2, view: out Rectangle): GuiResult {.discardable.} =
  ## Scroll Panel control
  scrollPanelImpl(bounds, if text.len == 0: nil else: text.cstring, content, addr scroll, view)

proc label*(bounds: Rectangle, text: string): GuiResult {.discardable.} =
  ## Label control
  labelImpl(bounds, text.cstring)

proc button*(bounds: Rectangle, text: string): GuiResult {.discardable.} =
  ## Button control, returns true when clicked
  buttonImpl(bounds, text.cstring)

proc labelButton*(bounds: Rectangle, text: string): GuiResult {.discardable.} =
  ## Label button control, returns true when clicked
  labelButtonImpl(bounds, text.cstring)

proc toggle*(bounds: Rectangle, text: string, active: var bool): GuiResult {.discardable.} =
  ## Toggle Button control
  toggleImpl(bounds, text.cstring, addr active)

proc toggleGroup*(bounds: Rectangle, text: string, active: var int32): GuiResult {.discardable.} =
  ## Toggle Group control
  toggleGroupImpl(bounds, text.cstring, addr active)

proc toggleSlider*(bounds: Rectangle, text: string, active: var int32): GuiResult {.discardable.} =
  ## Toggle Slider control
  toggleSliderImpl(bounds, if text.len == 0: nil else: text.cstring, addr active)

proc checkBox*(bounds: Rectangle, text: string, checked: var bool): GuiResult {.discardable.} =
  ## Check Box control, returns true when active
  checkBoxImpl(bounds, if text.len == 0: nil else: text.cstring, addr checked)

proc comboBox*(bounds: Rectangle, text: string, active: var int32): GuiResult {.discardable.} =
  ## Combo Box control
  comboBoxImpl(bounds, text.cstring, addr active)

proc dropdownBox*(bounds: Rectangle, text: string, active: var int32, editMode: bool): GuiResult {.discardable.} =
  ## Dropdown Box control
  dropdownBoxImpl(bounds, text.cstring, addr active, editMode)

proc spinner*(bounds: Rectangle, text: string, value: var int32, minValue: int32, maxValue: int32, editMode: bool): GuiResult {.discardable.} =
  ## Spinner control
  spinnerImpl(bounds, if text.len == 0: nil else: text.cstring, addr value, minValue, maxValue, editMode)

proc valueBox*(bounds: Rectangle, text: string, value: var int32, minValue: int32, maxValue: int32, editMode: bool): GuiResult {.discardable.} =
  ## Value Box control, updates input text with numbers
  valueBoxImpl(bounds, if text.len == 0: nil else: text.cstring, addr value, minValue, maxValue, editMode)

proc slider*(bounds: Rectangle, textLeft: string, textRight: string, value: var float32, minValue: float32, maxValue: float32): GuiResult {.discardable.} =
  ## Slider control
  sliderImpl(bounds, if textLeft.len == 0: nil else: textLeft.cstring, if textRight.len == 0: nil else: textRight.cstring, addr value, minValue, maxValue)

proc sliderBar*(bounds: Rectangle, textLeft: string, textRight: string, value: var float32, minValue: float32, maxValue: float32): GuiResult {.discardable.} =
  ## Slider Bar control
  sliderBarImpl(bounds, if textLeft.len == 0: nil else: textLeft.cstring, if textRight.len == 0: nil else: textRight.cstring, addr value, minValue, maxValue)

proc progressBar*(bounds: Rectangle, textLeft: string, textRight: string, value: var float32, minValue: float32, maxValue: float32): GuiResult {.discardable.} =
  ## Progress Bar control
  progressBarImpl(bounds, if textLeft.len == 0: nil else: textLeft.cstring, if textRight.len == 0: nil else: textRight.cstring, addr value, minValue, maxValue)

proc statusBar*(bounds: Rectangle, text: string): GuiResult {.discardable.} =
  ## Status Bar control, shows info text
  statusBarImpl(bounds, text.cstring)

proc dummyRec*(bounds: Rectangle, text: string): GuiResult {.discardable.} =
  ## Dummy control for placeholders
  dummyRecImpl(bounds, text.cstring)

proc grid*(bounds: Rectangle, text: string, spacing: float32, subdivs: int32, mouseCell: out Vector2): GuiResult {.discardable.} =
  ## Grid control
  gridImpl(bounds, text.cstring, spacing, subdivs, mouseCell)

proc listView*(bounds: Rectangle, text: string, scrollIndex: var int32, active: var int32): GuiResult {.discardable.} =
  ## List View control
  listViewImpl(bounds, if text.len == 0: nil else: text.cstring, addr scrollIndex, addr active)

proc tabBar*(bounds: Rectangle, text: string, hscroll: var int32, active: var int32): GuiResult {.discardable.} =
  ## Tab Bar control
  tabBarImpl(bounds, text.cstring, addr hscroll, addr active)

proc messageBox*(bounds: Rectangle, title: string, message: string, btnText: string, btnActive: var int32): GuiResult {.discardable.} =
  ## Message Box control, displays a message
  messageBoxImpl(bounds, title.cstring, message.cstring, btnText.cstring, addr btnActive)

proc colorPicker*(bounds: Rectangle, text: string, color: var Color): GuiResult {.discardable.} =
  ## Color Picker control, includes Color bar controls
  colorPickerImpl(bounds, text.cstring, addr color)

proc colorPanel*(bounds: Rectangle, text: string, color: var Color): GuiResult {.discardable.} =
  ## Color Panel control
  colorPanelImpl(bounds, text.cstring, addr color)

proc colorBarAlpha*(bounds: Rectangle, text: string, alpha: var float32): GuiResult {.discardable.} =
  ## Color Bar Alpha control
  colorBarAlphaImpl(bounds, text.cstring, addr alpha)

proc colorBarHue*(bounds: Rectangle, text: string, value: var float32): GuiResult {.discardable.} =
  ## Color Bar Hue control
  colorBarHueImpl(bounds, text.cstring, addr value)

proc colorPickerHSV*(bounds: Rectangle, text: string, colorHsv: var Vector3): GuiResult {.discardable.} =
  ## Color Picker control, using Hue-Saturation-Value color data, includes Color bar controls
  colorPickerHSVImpl(bounds, text.cstring, addr colorHsv)

proc colorPanelHSV*(bounds: Rectangle, text: string, colorHsv: var Vector3): GuiResult {.discardable.} =
  ## Color Panel control, using Hue-Saturation-Value color data
  colorPanelHSVImpl(bounds, text.cstring, addr colorHsv)

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
