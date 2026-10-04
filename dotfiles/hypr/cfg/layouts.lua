-- -----------------------------------------------------
-- Layout Configurations
-- -----------------------------------------------------

hl.config({
    -- ==========================================================
    -- DWINDLE LAYOUT
    -- The default recursive split layout (similar to bspwm)
    -- ==========================================================
    dwindle = {
        preserve_split = true, -- Keeps the split direction regardless of resizing
        smart_split = false,
        smart_resizing = true,
    },

    -- ==========================================================
    -- MASTER LAYOUT
    -- Stack-based tiling (similar to dwm or xmonad)
    -- ==========================================================
    master = {
        mfact = 0.5,
        orientation = "center",
        slave_count_for_center_master = 0,
        new_status = "inherit",
        new_on_active = "before",
        drop_at_cursor = true,
        always_keep_position = true,
    },

    -- ==========================================================
    -- SCROLLING LAYOUT
    -- PaperWM-style infinite horizontal carousel
    -- ==========================================================
    scrolling = {
        fullscreen_on_one_column = false,
        column_width = 0.25,
        direction = "right",
        follow_focus = true,
        focus_fit_method = 1,
        explicit_column_widths = "0.25, 0.50, 0.75, 1.0",
    }
})
