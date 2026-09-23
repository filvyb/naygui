import common, raygui

const styleData = staticRead(getRayguiStyleDir("advance") & "/style_advance.rgs")

proc guiLoadStyleAdvance*() =
  ## Load style Advance over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
