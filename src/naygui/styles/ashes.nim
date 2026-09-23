import common, raygui

const styleData = staticRead(getRayguiStyleDir("ashes") & "/style_ashes.rgs")

proc guiLoadStyleAshes*() =
  ## Load style Ashes over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
