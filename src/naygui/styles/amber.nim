import common, raygui

const styleData = staticRead(getRayguiStyleDir("amber") & "/style_amber.rgs")

proc guiLoadStyleAmber*() =
  ## Load style Amber over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
