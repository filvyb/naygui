import common, raygui

const styleData = staticRead(getRayguiStyleDir("lavanda") & "/style_lavanda.rgs")

proc guiLoadStyleLavanda*() =
  ## Load style Lavanda over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
