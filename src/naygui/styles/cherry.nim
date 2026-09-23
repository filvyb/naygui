import common, raygui

const styleData = staticRead(getRayguiStyleDir("cherry") & "/style_cherry.rgs")

proc guiLoadStyleCherry*() =
  ## Load style Cherry over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
