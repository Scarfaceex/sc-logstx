-- [ Steam API checking ]
AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() == resourceName) then
      local apiKey = GetConvar('steam_webApiKey', '')
      if apiKey == '' then
          print("^3[WARN] Please Put SteamWeb API Key, if you didn't put it, it will not work")
          print("^5[INFO] https://forum.cfx.re/t/using-the-steam-api-key-manually-on-the-server/805987^7")
          print("^5[INFO] No further warnings will be shown.^7\n\n")
      end
  end
end)

-- [ Restart logs ]
AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
  LogRestart(eventData.secondsRemaining)
end)

-- [ DM logs ]
AddEventHandler('txAdmin:events:playerDirectMessage', function(eventData)
  LogDM(eventData.author, GetPlayerName(eventData.target), eventData.message)
end)

-- [ Revoke logs ]
AddEventHandler('txAdmin:events:actionRevoked', function(eventData)
  local action = eventData.actionType == 'ban' and 'Ban' or 'Warn'
  LogRevoke(eventData.revokedBy, eventData.actionId, action)
end)

-- [ Kick logs ]
AddEventHandler('txAdmin:events:playerKicked', function(eventData)
  local steamid, license, discord, ip = "NotFound", "NotFound", "NotFound", "NotFound"

  for k, v in pairs(GetPlayerIdentifiers(eventData.target)) do
      if v:find("steam:") == 1 then
          steamid = v
      elseif v:find("license:") == 1 then
          license = v
      elseif v:find("ip:") == 1 then
          ip = v:gsub('ip:', '')
      elseif v:find("discord:") == 1 then
          discord = v
      end
  end

  LogKick(eventData.author, GetPlayerName(eventData.target), eventData.reason, "Steam ID: " .. steamid .. "\nLicense: " .. license .. "\nDiscord: " .. discord .. "\nIP Address: " .. ip)
end)

-- [ Ban logs - Doesn't work for offline bans ]
AddEventHandler('txAdmin:events:playerBanned', function(eventData)
  local steamid, license, discord, ip = "NotFound", "NotFound", "NotFound", "NotFound"
  
  if eventData.expiration == false then
      LogBan(eventData.author, eventData.targetName, eventData.reason, "Permanent", eventData.actionId)
  else
      LogBan(eventData.author, eventData.targetName, eventData.reason, os.date('%d.%m.%Y %H:%M:%S', eventData.expiration), eventData.actionId)
  end
end)

-- [ Warn logs ]
AddEventHandler('txAdmin:events:playerWarned', function(eventData)
  local steamid, license, discord, ip = "NotFound", "NotFound", "NotFound", "NotFound"
  
  for k, v in pairs(GetPlayerIdentifiers(eventData.target)) do
      if v:find("steam:") == 1 then
          steamid = v
      elseif v:find("license:") == 1 then
          license = v
      elseif v:find("ip:") == 1 then
          ip = v:gsub('ip:', '')
      elseif v:find("discord:") == 1 then
          discord = v
      end
  }

  LogWarning(eventData.author, GetPlayerName(eventData.target), eventData.reason, "Steam ID: " .. steamid .. "\nLicense: " .. license .. "\nDiscord: " .. discord .. "\nIP Address: " .. ip)
end)

-- [ Function to log restart events ]
function LogRestart(time)
  local embed = {
      {
          ["color"] = 16711680, -- Red color
          ["title"] = "Restarting",
          ["fields"] = {
              {
                  ["name"] = "Minutes Remaining",
                  ["value"] = time,
                  ["inline"] = true
              }
          }
      }
  }
  PerformHttpRequest("YOUR_WEBHOOK_URL_HERE", function(err, text, headers) end, 'POST', json.encode({ username = "Webhook Bot", embeds = embed }), { ['Content-Type'] = 'application/json' })
end

-- [ Function to log DM events ]
function LogDM(admin, player, message)
  local embed = {
      {
          ["color"] = 16711935, -- Light Blue color
          ["title"] = "Direct Message",
          ["fields"] = {
              {
                  ["name"] = "Admin Name",
                  ["value"] = admin,
                  ["inline"] = true
              },
              {
                  ["name"] = "Player",
                  ["value"] = player,
                  ["inline"] = true
              },
              {
                  ["name"] = "Message",
                  ["value"] = message,
                  ["inline"] = true
              }
          }
      }
  }
  PerformHttpRequest("weebhok_url", function(err, text, headers) end, 'POST', json.encode({ username = "Webhook Bot", embeds = embed }), { ['Content-Type'] = 'application/json' })
end

-- [ Add similar functions for other log types as needed ]
