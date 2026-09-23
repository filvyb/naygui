import common, raygui

const styleData = staticRead(getRayguiStyleDir("genesis") & "/style_genesis.rgs")

proc guiLoadStyleGenesis*() =
  ## Load style Genesis over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
