import common, raygui

const styleData = staticRead(getRayguiStyleDir("sunny") & "/style_sunny.rgs")

proc guiLoadStyleSunny*() =
  ## Load style Sunny over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
