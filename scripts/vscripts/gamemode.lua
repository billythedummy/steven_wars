-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode


-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    --DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')


--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  --DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  --DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  --DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  --DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to 0 unreliable gold
  hero:SetGold(0, false)
  hero:SetHasInventory(false)
  
--These lines maxes out all abilities on spawned heroes
  for i=0,3 do
    local ability = hero:GetAbilityByIndex(i)
    if ability then 
      ability:SetLevel(ability:GetMaxLevel())
    end
  end

--This line removes all ability points at level 1
  hero:SetAbilityPoints(0)
--sets up table last_attacker under hero object as a classic array indexing hero handles
  hero.last_attacker = {} 
  hero.last_attacker[0] = self
  GameMode.heroes[hero:GetPlayerID()] = self
  GameMode.survivors[hero:GetPlayerID()] = self


  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
end

--function to track hero's position and its last position one think cycle (0.01s) ago


--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  --DebugPrint("[BAREBONES] The game has officially begun")

  GameMode:StartNextRound()

  --Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    --function()
      --DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      --return 30.0 -- Rerun this timer every 30 game-time seconds 
    --end)


end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  --DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

  -- Call the internal function to set up the rules/behaviors specified in constants.lua
  -- This also sets up event hooks for all event handlers in events.lua
  -- Check out internals/gamemode to see/modify the exact code
  GameMode:_InitGameMode()

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  --Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  --DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')

  GameMode.heroes = {}
  GameMode.survivors = {}
  GameMode.colours = {}
  GameMode.colours[2] = "Teal"
  GameMode.colours[3] = "Yellow"
  GameMode.colours[6] = "Pink"
  GameMode.colours[7] = "Orange"
  GameMode.colours[8] = "Blue"

  GameRules.rounds = {}
  GameRules.rounds["CurrentRound"] = 0
  GameRules.rounds["VictoryCount"] = 3

  GameRules.victorycount = {}
  GameRules.victorycount[DOTA_TEAM_GOODGUYS] = 0
  GameRules.victorycount[DOTA_TEAM_BADGUYS] = 0
  GameRules.victorycount[DOTA_TEAM_CUSTOM_1] = 0
  GameRules.victorycount[DOTA_TEAM_CUSTOM_2] = 0
  GameRules.victorycount[DOTA_TEAM_CUSTOM_3] = 0


  GameMode:CreateProjectileTracker()
end

-- This is an example console command
--function GameMode:ExampleConsoleCommand()
  --print( '******* Example Console Command ***************' )
  --local cmdPlayer = Convars:GetCommandClient()
  --if cmdPlayer then
    --local playerID = cmdPlayer:GetPlayerID()
    --if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      --PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    --end
  --end

  --print( '*********************************************' )
--end

function GameMode:CreateProjectileTracker()
  ------keys are projectile ids, values are projectile infotables---------
  self.projectile_table = {}
end



function GameMode:StartNextRound()
  GameRules.rounds["CurrentRound"] = GameRules.rounds["CurrentRound"] + 1
  local p_round = 'Round ' .. GameRules.rounds['CurrentRound'] .. '!'
  Notifications:TopToAll({text=p_round, duration=4.0})
  print(p_round)

  local allHeroes = HeroList:GetAllHeroes()
  for _,hero in pairs(allHeroes) do
    hero:RespawnHero(false, false, false)
    hero:SetGold(0, false)
  end

  for playerid, hero in pairs(GameMode.heroes) do 
    GameMode.survivors[playerid] = hero
  end
  --for playerid, hero in pairs(GameMode.survivors) do
    --print(playerid, PlayerResource:GetTeam(playerid))
  --end
end

-- round is over, argument winner is winning teamnumber
function GameMode:EndRound( winner )
  winner = winner or -1

  if winner ~= -1 then 
    GameRules.victorycount[ winner ] = GameRules.victorycount[ winner ] + 1
    local p_round = GameMode.colours[winner] .. " team has won round " .. GameRules.rounds["CurrentRound"] .. "!"
    Notifications:TopToAll({text=p_round, duration=4.0})
    print( p_round )

    for team, count in pairs(GameRules.victorycount) do
      if count == GameRules.rounds.VictoryCount then
        local p_game = GameMode.colours[winner] .. " Team wins!"
        GameRules:SetCustomVictoryMessage(p_game)
        GameRules:SetGameWinner( team )
        return
      end
    end
  elseif winner == -1 then
    local d_round = "Draw!"
    Notifications:TopToAll({text=d_round, duration=4.0})
    print(d_round)
  end

    -- 5 second delayed, run once using gametime (respect pauses)
  Timers:CreateTimer({
    endTime = 5, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      GameMode:StartNextRound()
    end
  })
end


