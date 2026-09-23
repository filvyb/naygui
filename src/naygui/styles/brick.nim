import common, raygui

const styleData = staticRead(getRayguiStyleDir("brick") & "/style_brick.rgs")

proc guiLoadStyleBrick*() =
  ## Load style Brick over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
