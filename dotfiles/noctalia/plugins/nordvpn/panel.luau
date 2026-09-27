--!nonstrict
-- NordVPN Interactive Control Panel for Noctalia

local STATE_KEY = "nordvpn.status"
local COMMAND_KEY = "nordvpn.cmd"

local status = noctalia.state.get(STATE_KEY) or {
  connected = false,
  statusText = "Disconnected",
  server = "",
  country = "",
  city = "",
  ip = "",
  technology = "NordLynx",
  killSwitch = false,
  threatProtection = false,
  autoConnect = false,
  busy = false,
  busyAction = "",
}

local function sendCmd(op, extra)
  local cmd = { op = op }
  if type(extra) == "table" then
    for k, v in pairs(extra) do
      cmd[k] = v
    end
  end
  noctalia.state.set(COMMAND_KEY, cmd)
end

local function render()
  local isConn = status.connected == true
  local isBusy = status.busy == true

  -- Connection Card
  local connCard = ui.column({ gap = 8, padding = 10, fill = "surface_variant/0.3", radius = 10 }, {
    ui.row({ align = "center", justify = "space_between" }, {
      ui.row({ align = "center", gap = 8 }, {
        ui.box({
          width = 10,
          height = 10,
          radius = 5,
          fill = if isConn then "primary" elseif isBusy then "tertiary" else "outline",
        }),
        ui.label({
          text = if isBusy then (status.busyAction ~= "" and status.busyAction or "Working...") else status.statusText,
          fontSize = 13,
          fontWeight = "bold",
          color = if isConn then "primary" else "on_surface",
        }),
      }),
      ui.label({
        text = status.technology or "NordLynx",
        fontSize = 10,
        color = "on_surface_variant",
      }),
    }),

    -- If connected, show server details
    if isConn and status.server ~= "" then
      ui.column({ gap = 2, paddingV = 4 }, {
        ui.row({ justify = "space_between" }, {
          ui.label({ text = "Location", fontSize = 11, color = "on_surface_variant" }),
          ui.label({ text = (status.country ~= "" and status.country or "Unknown") .. (status.city ~= "" and (", " .. status.city) or ""), fontSize = 11, fontWeight = "bold" }),
        }),
        ui.row({ justify = "space_between" }, {
          ui.label({ text = "Server", fontSize = 11, color = "on_surface_variant" }),
          ui.label({ text = status.server, fontSize = 11 }),
        }),
        if status.ip ~= "" then
          ui.row({ justify = "space_between" }, {
            ui.label({ text = "IP", fontSize = 11, color = "on_surface_variant" }),
            ui.label({ text = status.ip, fontSize = 11 }),
          })
        else nil,
      })
    else nil,

    -- Main Connect / Disconnect button
    ui.button({
      text = if isBusy then "Please wait..." elseif isConn then "Disconnect" else "⚡ Quick Connect",
      variant = if isConn then "outline" else "primary",
      onClick = function()
        if isConn then
          sendCmd("disconnect")
        else
          sendCmd("connect")
        end
      end,
    }),
  })

  -- Locations Grid
  local locationButtons = ui.column({ gap = 6 }, {
    ui.label({ text = "Quick Locations", fontSize = 12, fontWeight = "bold", color = "on_surface_variant" }),
    ui.row({ gap = 6 }, {
      ui.button({
        text = "🇩🇪 Germany",
        flexGrow = 1,
        controlSize = "sm",
        variant = if status.country == "Germany" then "primary" else "ghost",
        onClick = function() sendCmd("connect", { target = "de" }) end,
      }),
      ui.button({
        text = "🇳🇱 Netherlands",
        flexGrow = 1,
        controlSize = "sm",
        variant = if status.country == "Netherlands" then "primary" else "ghost",
        onClick = function() sendCmd("connect", { target = "nl" }) end,
      }),
    }),
    ui.row({ gap = 6 }, {
      ui.button({
        text = "🇨🇭 Switzerland",
        flexGrow = 1,
        controlSize = "sm",
        variant = if status.country == "Switzerland" then "primary" else "ghost",
        onClick = function() sendCmd("connect", { target = "ch" }) end,
      }),
      ui.button({
        text = "🇦🇹 Austria",
        flexGrow = 1,
        controlSize = "sm",
        variant = if status.country == "Austria" then "primary" else "ghost",
        onClick = function() sendCmd("connect", { target = "at" }) end,
      }),
    }),
    ui.row({ gap = 6 }, {
      ui.button({
        text = "🇬🇧 United Kingdom",
        flexGrow = 1,
        controlSize = "sm",
        variant = if status.country == "United Kingdom" then "primary" else "ghost",
        onClick = function() sendCmd("connect", { target = "uk" }) end,
      }),
      ui.button({
        text = "⚡ Fastest Server",
        flexGrow = 1,
        controlSize = "sm",
        variant = "ghost",
        onClick = function() sendCmd("connect", { target = "" }) end,
      }),
    }),
  })

  -- Security & Settings
  local settingsSection = ui.column({ gap = 6 }, {
    ui.label({ text = "Settings", fontSize = 12, fontWeight = "bold", color = "on_surface_variant" }),
    ui.row({ align = "center", justify = "space_between", paddingV = 2 }, {
      ui.row({ align = "center", gap = 6 }, {
        ui.glyph({ name = "shield-alert", size = 14, color = if status.killSwitch then "primary" else "on_surface_variant" }),
        ui.label({ text = "Kill Switch", fontSize = 12 }),
      }),
      ui.toggle({
        checked = status.killSwitch == true,
        onToggle = function(val)
          sendCmd("set_killswitch", { value = val })
        end,
      }),
    }),
    ui.row({ align = "center", justify = "space_between", paddingV = 2 }, {
      ui.row({ align = "center", gap = 6 }, {
        ui.glyph({ name = "shield-check", size = 14, color = if status.threatProtection then "primary" else "on_surface_variant" }),
        ui.label({ text = "Threat Protection Lite", fontSize = 12 }),
      }),
      ui.toggle({
        checked = status.threatProtection == true,
        onToggle = function(val)
          sendCmd("set_threatprotection", { value = val })
        end,
      }),
    }),
    ui.row({ align = "center", justify = "space_between", paddingV = 2 }, {
      ui.row({ align = "center", gap = 6 }, {
        ui.glyph({ name = "refresh", size = 14, color = if status.autoConnect then "primary" else "on_surface_variant" }),
        ui.label({ text = "Auto-Connect", fontSize = 12 }),
      }),
      ui.toggle({
        checked = status.autoConnect == true,
        onToggle = function(val)
          sendCmd("set_autoconnect", { value = val })
        end,
      }),
    }),
    ui.row({ align = "center", justify = "space_between", paddingV = 2 }, {
      ui.row({ align = "center", gap = 6 }, {
        ui.glyph({ name = "cpu", size = 14, color = "on_surface_variant" }),
        ui.label({ text = "Protocol", fontSize = 12 }),
      }),
      ui.button({
        text = status.technology == "openvpn" and "OpenVPN" or "NordLynx",
        controlSize = "xs",
        variant = "outline",
        onClick = function()
          local nextTech = status.technology == "openvpn" and "nordlynx" or "openvpn"
          sendCmd("set_technology", { value = nextTech })
        end,
      }),
    }),
  })

  -- Full Panel Render
  panel.render(ui.column({ flexGrow = 1, gap = 12, padding = 12 }, {
    -- Header
    ui.row({ align = "center", justify = "space_between" }, {
      ui.row({ align = "center", gap = 8 }, {
        ui.glyph({ name = "shield-lock-filled", size = 18, color = "primary" }),
        ui.label({ text = "NordVPN", fontSize = 15, fontWeight = "bold" }),
      }),
      ui.row({ gap = 2 }, {
        ui.button({
          glyph = "refresh",
          variant = "ghost",
          controlSize = "sm",
          tooltip = "Refresh Status",
          onClick = function()
            sendCmd("refresh")
          end,
        }),
        ui.button({
          glyph = "x",
          variant = "ghost",
          controlSize = "sm",
          tooltip = "Close",
          onClick = function()
            noctalia.togglePanel("custom/nordvpn:panel")
          end,
        }),
      }),
    }),

    -- Scrollable body
    ui.scroll({ flexGrow = 1, gap = 12 }, {
      connCard,
      locationButtons,
      ui.separator({}),
      settingsSection,
    }),
  }))
end

noctalia.state.watch(STATE_KEY, function(newStatus)
  if type(newStatus) == "table" then
    status = newStatus
    render()
  end
end)

render()
