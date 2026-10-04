// Zen Browser Custom Preferences
// Performance, Wayland support, and sleek UI

// Hardware Acceleration & Wayland DMA-BUF
user_pref("gfx.webrender.all", true);
user_pref("layers.acceleration.force-enabled", true);
user_pref("widget.dmabuf.force-enabled", true);

// Hardware Video Decoding (VA-API)
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("media.rdd-ffmpeg.enabled", true);

user_pref("layout.css.color-mix.enabled", true);
user_pref("svg.context-properties.content.enabled", true);
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);
user_pref("ui.systemUsesDarkTheme", 1);

user_pref("devtools.chrome.enabled", true);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
