import common, raygui

const styleData = staticRead(getRayguiStyleDir("rltech") & "/style_rltech.rgs")

proc guiLoadStyleRLtech*() =
  ## Load style Rltech over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
