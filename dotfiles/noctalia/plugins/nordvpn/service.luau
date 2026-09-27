--!nonstrict
-- NordVPN background service for Noctalia

noctalia.setUpdateInterval(1000)

local STATE_KEY = "nordvpn.status"
local COMMAND_KEY = "nordvpn.cmd"

local snapshot = {
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

local function publishState()
  noctalia.state.set(STATE_KEY, snapshot)
end

local isPolling = false

local function pollStatus()
  if isPolling then return end
  isPolling = true

  noctalia.runAsync("nordvpn status", function(res)
    local out = (res.stdout or "") .. "\n" .. (res.stderr or "")

    if out:find("Status: Connected") then
      snapshot.connected = true
      snapshot.statusText = "Connected"
      snapshot.server = out:match("Current server:%s*([^\r\n]+)") or ""
      snapshot.country = out:match("Country:%s*([^\r\n]+)") or ""
      snapshot.city = out:match("City:%s*([^\r\n]+)") or ""
      snapshot.ip = out:match("Server IP:%s*([^\r\n]+)") or ""
      snapshot.technology = out:match("Current technology:%s*([^\r\n]+)") or "NordLynx"
    elseif out:find("Status: Disconnected") then
      snapshot.connected = false
      snapshot.statusText = "Disconnected"
      snapshot.server = ""
      snapshot.country = ""
      snapshot.city = ""
      snapshot.ip = ""
    elseif out:find("Permission denied") then
      snapshot.connected = false
      snapshot.statusText = "Permission Denied"
    elseif out:find("not logged in") then
      snapshot.connected = false
      snapshot.statusText = "Not logged in"
    else
      snapshot.statusText = "Disconnected"
      snapshot.connected = false
    end

    -- Query settings
    noctalia.runAsync("nordvpn settings", function(setRes)
      local setOut = (setRes.stdout or "") .. "\n" .. (setRes.stderr or "")
      if setRes.exitCode == 0 then
        snapshot.killSwitch = setOut:find("Kill Switch:%s*enabled") ~= nil
        snapshot.threatProtection = (setOut:find("Threat Protection Lite:%s*enabled") ~= nil or setOut:find("CyberSec:%s*enabled") ~= nil)
        snapshot.autoConnect = setOut:find("Auto-connect:%s*enabled") ~= nil
        local tech = setOut:match("Technology:%s*([^\r\n]+)")
        if tech and tech ~= "" then
          snapshot.technology = tech
        end
      end
      isPolling = false
      publishState()
    end, 4000)
  end, 4000)
end

-- Command listener
noctalia.state.watch(COMMAND_KEY, function(cmd)
  if type(cmd) ~= "table" or not cmd.op then return end

  local op = cmd.op
  if op == "connect" then
    snapshot.busy = true
    snapshot.busyAction = "Connecting..."
    publishState()

    local target = cmd.target or ""
    local cmdStr = "nordvpn connect"
    if target ~= "" then
      cmdStr = "nordvpn connect " .. tostring(target)
    end

    noctalia.runAsync(cmdStr, function(res)
      snapshot.busy = false
      snapshot.busyAction = ""
      pollStatus()
      if res.exitCode == 0 then
        if type(noctalia.notify) == "function" then
          noctalia.notify("NordVPN", "Connected successfully")
        end
      else
        local err = (res.stderr ~= "" and res.stderr or res.stdout) or "Unknown error"
        if type(noctalia.notify) == "function" then
          noctalia.notify("NordVPN", "Connection failed: " .. err)
        end
      end
    end, 20000)

  elseif op == "disconnect" then
    snapshot.busy = true
    snapshot.busyAction = "Disconnecting..."
    publishState()

    noctalia.runAsync("nordvpn disconnect", function()
      snapshot.busy = false
      snapshot.busyAction = ""
      snapshot.connected = false
      snapshot.statusText = "Disconnected"
      publishState()
      pollStatus()
      if type(noctalia.notify) == "function" then
        noctalia.notify("NordVPN", "Disconnected")
      end
    end, 10000)

  elseif op == "set_killswitch" then
    local val = cmd.value and "on" or "off"
    noctalia.runAsync("nordvpn set killswitch " .. val, function()
      pollStatus()
    end, 5000)

  elseif op == "set_threatprotection" then
    local val = cmd.value and "on" or "off"
    noctalia.runAsync("nordvpn set threatprotectionlite " .. val, function()
      pollStatus()
    end, 5000)

  elseif op == "set_autoconnect" then
    local val = cmd.value and "on" or "off"
    noctalia.runAsync("nordvpn set autoconnect " .. val, function()
      pollStatus()
    end, 5000)

  elseif op == "set_technology" then
    local val = cmd.value or "nordlynx"
    noctalia.runAsync("nordvpn set technology " .. val, function()
      pollStatus()
    end, 5000)

  elseif op == "refresh" then
    pollStatus()
  end
end)

local tick = 0
function update()
  tick += 1
  if tick % 5 == 0 then
    pollStatus()
  end
end

function onEnable()
  pollStatus()
end

pollStatus()
