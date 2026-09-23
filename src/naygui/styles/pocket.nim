import common, raygui

const styleData = staticRead(getRayguiStyleDir("pocket") & "/style_pocket.rgs")

proc guiLoadStylePocket*() =
  ## Load style Pocket over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
