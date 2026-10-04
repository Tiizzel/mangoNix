-- -----------------------------------------------------
-- Monitors
-- -----------------------------------------------------

hl.monitor({
    output = "DP-1",
    mode = "5120x1440@240.0",
    position = "0x0",
    scale = 1.0,
    bitdepth = 10,
    cm = "hdr",
    sdrbrightness = 1.69,
    sdrsaturation = 1.25,
    supports_hdr = 1,
})

-- Fallback for any additional connected display
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1.0,
})
