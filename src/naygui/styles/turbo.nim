import common, raygui

const styleData = staticRead(getRayguiStyleDir("turbo") & "/style_turbo.rgs")

proc guiLoadStyleTurbo*() =
  ## Load style Turbo over global style.
  guiLoadStyleFromMemory(styleData.toOpenArrayByte(0, styleData.high))
