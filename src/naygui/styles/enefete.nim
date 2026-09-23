import common, raygui

const styleData = staticRead(getRayguiStyleDir("enefete") & "/style_enefete.rgs")

proc guiLoadStyleEnefete*() =
  ## Load style Enefete over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
