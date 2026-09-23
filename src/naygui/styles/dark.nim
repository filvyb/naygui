import common, raygui

const styleData = staticRead(getRayguiStyleDir("dark") & "/style_dark.rgs")

proc guiLoadStyleDark*() =
  ## Load style Dark over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
