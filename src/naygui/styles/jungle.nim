import common, raygui

const styleData = staticRead(getRayguiStyleDir("jungle") & "/style_jungle.rgs")

proc guiLoadStyleJungle*() =
  ## Load style Jungle over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
