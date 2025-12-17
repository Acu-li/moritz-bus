ESX = nil

TriggerEvent(Config.ESXShared, function(obj) ESX = obj end)

local function sendDiscordLog(msg)
    if not Config.DiscordWebhook or Config.DiscordWebhook == "" then return end

    PerformHttpRequest(
        Config.DiscordWebhook,
        function() end,
        "POST",
        json.encode({
            username = Config.DiscordWebhookName or "NBV Bus Logs",
            avatar_url = Config.DiscordWebhookAvatar or nil,
            embeds = {{
                color = 3447003, -- blau
                description = msg,
                footer = { text = "Neuberg Verkehrsbund" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }),
        { ["Content-Type"] = "application/json" }
    )
end


local function getPlayerIdentifiersText(src)
  local ids = GetPlayerIdentifiers(src)
  return ids and table.concat(ids, " | ") or ""
end

local function safeName(src)
  local name = GetPlayerName(src)
  if not name then return ("%s"):format(src) end
  return name
end

local function appendLogLine(line)
  local path = "logs/bus.log"
  local current = LoadResourceFile(GetCurrentResourceName(), path) or ""
  SaveResourceFile(GetCurrentResourceName(), path, current .. line .. "\n", -1)
end

local function logBus(src, action, fromKey, toKey, amount, result)
  local fromName = (Config.Locations and fromKey and Config.Locations[fromKey] and Config.Locations[fromKey].Name) or tostring(fromKey or "")
  local toName = (Config.Locations and toKey and Config.Locations[toKey] and Config.Locations[toKey].Name) or tostring(toKey or "")
  local ts = os.date("!%Y-%m-%dT%H:%M:%SZ")
  local line = ("%s | %s | src=%s | name=%s | action=%s | from=%s | to=%s | amount=%s | result=%s | ids=%s")
    :format(ts, GetCurrentResourceName(), tostring(src), safeName(src), tostring(action), tostring(fromName), tostring(toName), tostring(amount or ""), tostring(result or ""), getPlayerIdentifiersText(src))
  print("[ikipm_bus][LOG] " .. line)
  appendLogLine(line)

local discordMsg = ("**Aktion:** %s\n**Spieler:** %s (`%s`)\n**Von:** %s\n**Nach:** %s\n**Betrag:** %s\n**Status:** %s")
    :format(
        action,
        safeName(src),
        src,
        tostring(fromName),
        tostring(toName),
        tostring(amount or "-"),
        tostring(result or "-")
    )

sendDiscordLog(discordMsg)


end

RegisterNetEvent('ikipm_bus:log')
AddEventHandler('ikipm_bus:log', function(action, fromKey, toKey, amount, result)
  logBus(source, action, fromKey, toKey, amount, result)
end)

RegisterServerEvent('ikipm_bus:getMoney')
AddEventHandler('ikipm_bus:getMoney', function(amount, fromKey, toKey, result)
  local xPlayer = ESX.GetPlayerFromId(source)

  if xPlayer then
    xPlayer.removeMoney(amount)
    logBus(source, "ticket_charged", fromKey, toKey, amount, result)
  end
end)
