import common, raygui

const styleData = staticRead(getRayguiStyleDir("candy") & "/style_candy.rgs")

proc guiLoadStyleCandy*() =
  ## Load style Candy over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
