import common, raygui

const styleData = staticRead(getRayguiStyleDir("terminal") & "/style_terminal.rgs")

proc guiLoadStyleTerminal*() =
  ## Load style Terminal over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
