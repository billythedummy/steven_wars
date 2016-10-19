-- The overall game state has changed
function GameMode:_OnGameRulesStateChange(keys)
  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    --Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    GameMode:PostLoadPrecache()
    GameMode:OnAllPlayersLoaded()

    if USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS then
      for i=0,9 do
        if PlayerResource:IsValidPlayer(i) then
          local color = TEAM_COLORS[PlayerResource:GetTeam(i)]
          PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
        end
      end
    end
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    GameMode:OnGameInProgress()
  end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:_OnNPCSpawned(keys)
  local npc = EntIndexToHScript(keys.entindex)

  if npc:IsRealHero() and npc.bFirstSpawned == nil then
    npc.bFirstSpawned = true
    GameMode:OnHeroInGame(npc)
  end
end

-- An entity died
function GameMode:_OnEntityKilled( keys )
  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker ) --killedUnit.last_attacker.last_attacker_id 
  end

  if killedUnit:IsRealHero() then 
    GameMode.survivors[killedUnit:GetPlayerID()] = nil
    local survivors = 0
    for k, v in pairs(GameMode.survivors) do
      --print(k, v)
      survivors = survivors + 1
    end

    if  survivors == 2 then
      local teamtracker = {}
      local k = 0
      for playerid, hero in pairs(GameMode.survivors) do 
        teamtracker[k] = PlayerResource:GetTeam(playerid)
        k = k + 1
      end
      --for k, v in pairs(teamtracker) do
        --print(k, v)
      --end
      if teamtracker[0] == teamtracker[1] then 
        GameMode:EndRound( teamtracker[0] )
      end
    elseif survivors == 1 then
      for playerid, hero in pairs(GameMode.survivors) do 
        GameMode:EndRound( PlayerResource:GetTeam(playerid) )
      end
    elseif survivors == 0 then 
      GameMode:EndRound()
    end

    --DebugPrint("KILLED, KILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
    if END_GAME_ON_KILLS and GetTeamHeroKills(killerEntity:GetTeam()) >= KILLS_TO_END_GAME_FOR_TEAM then
      GameRules:SetSafeToLeave( true )
      GameRules:SetGameWinner( killerEntity:GetTeam() )
    end

    --PlayerResource:GetTeamKills
    if SHOW_KILLS_ON_TOPBAR then
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS) )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS) )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_CUSTOM_1, GetTeamHeroKills(DOTA_TEAM_CUSTOM_1) )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_CUSTOM_2, GetTeamHeroKills(DOTA_TEAM_CUSTOM_2) )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_CUSTOM_3, GetTeamHeroKills(DOTA_TEAM_CUSTOM_3) )
    end
  end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:_OnConnectFull(keys)
  GameMode:_CaptureGameMode()

  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  local userID = keys.userid

  self.vUserIds = self.vUserIds or {}
  self.vUserIds[userID] = ply
end