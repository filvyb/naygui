import common, raygui

const styleData = staticRead(getRayguiStyleDir("bluish") & "/style_bluish.rgs")

proc guiLoadStyleBluish*() =
  ## Load style Bluish over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
