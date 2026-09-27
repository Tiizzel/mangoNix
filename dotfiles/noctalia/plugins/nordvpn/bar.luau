--!nonstrict
-- NordVPN bar widget: shield glyph reflecting status, click opens panel

local connected = false
local serverName = ""
local country = ""

local function render()
  if connected then
    barWidget.setGlyph("shield-lock-filled")
    barWidget.setColor("primary")
    if country ~= "" then
      barWidget.setText(country)
    else
      barWidget.setText("VPN")
    end
    barWidget.setTooltip("NordVPN: Connected (" .. (serverName ~= "" and serverName or country) .. ")")
  else
    barWidget.setGlyph("shield-lock")
    barWidget.setColor("on_surface_variant")
    barWidget.setText("")
    barWidget.setTooltip("NordVPN: Disconnected (Click to open panel)")
  end
end

noctalia.state.watch("nordvpn.status", function(status)
  if type(status) == "table" then
    connected = status.connected == true
    serverName = status.server or ""
    country = status.country or ""
  else
    connected = false
    serverName = ""
    country = ""
  end
  render()
end)

function onClick()
  noctalia.togglePanel("custom/nordvpn:panel")
end

render()
