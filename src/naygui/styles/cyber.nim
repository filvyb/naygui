import common, raygui

const styleData = staticRead(getRayguiStyleDir("cyber") & "/style_cyber.rgs")

proc guiLoadStyleCyber*() =
  ## Load style Cyber over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
