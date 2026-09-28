# SceneFX Vulkan & HDR Support Tracking

This document explains the technical relationship between **SceneFX**, **wlroots**, **Vulkan**, and **HDR** in **MangoWM**, tracking the status of Vulkan blur implementation.

---

## 1. References & Links

* **PR #204 (Blur Implementation)**: [wlrfx/scenefx#204 — vulkan: implement blur](https://github.com/wlrfx/scenefx/pull/204)
* **PR #192 (Base Vulkan Renderer)**: [wlrfx/scenefx#192 — Vulkan](https://github.com/wlrfx/scenefx/pull/192)
* **Issue #7 (Original Tracking Issue)**: [wlrfx/scenefx#7 — Add vulkan renderer](https://github.com/wlrfx/scenefx/issues/7)
* **wlroots Fork (Required hooks)**: [spoloxs/wlroots-vkfx (vulkan-effects branch)](https://github.com/spoloxs/wlroots-vkfx/tree/vulkan-effects)
* **wlroots Color Management MR**: [wlroots!3804 — Color management protocol & Vulkan pipeline](https://gitlab.freedesktop.org/wlroots/wlroots/-/merge_requests/3804)

---

## 2. Technical Overview: The "HDR vs. Blur" Dilemma

### The Problem
* **HDR requires the Vulkan renderer**: In `wlroots`, color management and HDR output were designed exclusively for the Vulkan backend (`WLR_RENDERER=vulkan`). The legacy GLES2 renderer does not support the required color spaces and wide-gamut pipelines.
* **SceneFX was locked to GLES2**: Historically, SceneFX (which provides window blur, shadows, and rounded corners) was implemented strictly using GLES2 fragment shaders.
* **MangoWM's Trade-off**:
  * **Option A (GLES2)**: Compositors can use SceneFX for blur and eye candy, but **lose HDR completely**.
  * **Option B (Vulkan)**: Compositors can use pure wlroots on Vulkan for **full HDR** (`mango/wl-only`), but **lose SceneFX blur**.

### Why Blur is Difficult in Vulkan
To blur a window, the compositor must sample the pixels already rendered behind it. In Vulkan, interrupting a render pass to read from the framebuffer violates Vulkan specification rules on subpass dependencies.

### How PR #204 Solves It
PR #204 solves this by:
1. **Splitting Render Passes**: Introducing two distinct render passes — rendering geometry to an intermediate blending `VkImage`, then pausing the pass with custom suspend/resume hooks (`wlr_vk_render_pass_suspend()` / `resume()`).
2. **Dual-Kawase Blur on Intermediate Image**: Performing N downsample and N upsample passes directly on the intermediate linear texture.
3. **Composing Directly with HDR**:
   > *"Because blur only works on the two-pass pathway, it is skipped elsewhere rather than corrupting the frame. **That pathway is also the one colour-managed and HDR output always take, so blur and HDR compose.**"*
   Because blur runs during the linear blending stage prior to tonemapping and transfer functions, translucent blurred windows maintain wide-gamut luminance without clipping highlights to SDR (0.0–1.0).

---

## 3. Impact on MangoWM & mangoNix

* **Current State in mangoNix**:
  * Flake uses `inputs.mangowm.url = "github:mangowm/mango/wl-only"`
  * Environment sets `WLR_RENDERER=vulkan` and `ENABLE_HDR_WLR_EQ_1=1`
  * Displays run in pure 10-bit HDR on OLED (`DP-1`), but without SceneFX blur.
* **Future State (Post-PR #204)**:
  * MangoWM can merge its `wl-only` and effects branches into a unified Vulkan compositor.
  * You will be able to enable window blur, rounded corners, and shadows without disabling HDR or switching to GLES2.

---

## 4. Upstream Dependency & Merge Tracker

- [ ] **wlroots Hooks**: Upstream wlroots (or `ammen99/wlroots` / `spoloxs/wlroots-vkfx`) exposes `wlr_vk_render_pass_suspend()`, `resume()`, and `get_blend_image()`.
- [ ] **SceneFX PR #192**: Base Vulkan renderer merged into `wlrfx/scenefx`.
- [ ] **SceneFX PR #204**: Vulkan blur merged into `wlrfx/scenefx`.
- [ ] **MangoWM Upstream**: MangoWM updates dependencies to the new SceneFX Vulkan release, re-enabling blur on Vulkan sessions.
- [ ] **mangoNix Flake**: Update flake input `mangowm` to the merged release.
