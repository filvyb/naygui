import common, raygui

const styleData = staticRead(getRayguiStyleDir("wisteria") & "/style_wisteria.rgs")

proc guiLoadStyleWisteria*() =
  ## Load style Wisteria over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
