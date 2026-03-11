--[[
Because we are passing a payload that contains the queue of events,
we gain a really powerful new ability: the FSM can modify its own
future. If the character takes a hit and their HP drops below 0,
the FSM can dynamically inject a "die" event to the very front of
the queue, instantly hijacking the flow.

You don't need to change the engine from the previous step at all.
You just need this main.lua:
]]--

local machine = require"fsm3"

-- === DSL Helpers === --
-- Clumsy idom fix #1
local function say(msg)
  return function(p)
    local formatted = msg:gsub("{hp}", tostring(p.hp))
    print(string.format("[%s] %s", p.name, formatted))
  end
end

-- Clumsy idom fix #2: Global transitions that apply to all states, with ability to override
local global_trans = { hit = "staggered", die = "dead" }
local function trans(specifics)
  local t = {}
  for k, v in pairs(global_trans) do t[k] = v end
  for k, v in pairs(specifics or {}) do t[k] = v end
  return t
end

-- Clumsy idom fix #3: Action helpers for common patterns
local function take_damage(p)
  local dmg = table.remove(p.damage_queue, 1) or 0
  p.hp = p.hp - dmg
  return dmg
end

local function inject(p, event)
  table.insert(p.queue, 1, event)
end

-- Trace Printer Helper
local function print_trace(p)
  print("\n=== FSM EXECUTION TRACE ===")
  if not p.trace or #p.trace == 0 then
    print("No transitions recorded.")
    return
  end
  for i, log in ipairs(p.trace) do
    print(string.format("%02d: %s", i, log)) 
  end
end

--Linter
local function lint(rules, initial)
  print("=== RUNNING LINTER ===")
  local reachable = { [initial] = true }
  local warnings = 0

  for state_name, state_data in pairs(rules) do
    
    -- 1. Check for Dead ends
    -- A state is a dead end if it has no transitions table, or the table is empty.
    if not state_data.transitions or next(state_data.transitions) == nil then
      print(string.format("  [!] DEAD END: State '%s' has no outbound transitions.", state_name))
      warnings = warnings + 1
    end

    -- Loop through all transitions in this state
    for event, target_state in pairs(state_data.transitions or {}) do
      
      -- Mark this target as reachable for our later check
      reachable[target_state] = true
      
      -- 2. Check for Ghost states
      -- The target state doesn't exist anywhere in our rules table
      if not rules[target_state] then
        print(string.format("  [!] GHOST STATE: '%s' -> [%s] -> '%s' (State does not exist!)", state_name, event, target_state))
        warnings = warnings + 1
      end
    end
  end

  -- 3. Check for Unreachable states
  -- Loop through all defined rules; if they aren't marked reachable, flag them.
  for state_name in pairs(rules) do
    if not reachable[state_name] then
      print(string.format("  [!] UNREACHABLE: State '%s' is defined but nothing transitions to it.", state_name))
      warnings = warnings + 1
    end
  end

  if warnings == 0 then
    print("  ✓ Linter passed: 0 warnings found.")
  else
    print(string.format("  => Linter finished with %d warning(s).", warnings))
  end
  print("======================\n")
end

-- === FSM Rules === --
local rpg_rules = {
  idle = {
    action = say("is idling. HP: {hp}"),
    transitions = trans({
      walk = "moving",
      -- Guard: only enter attacking if stamina is sufficient, otherwise stay idle
      attack = function(p)
        if p.stamina > 10 then
          return "attacking"
        else
          print(string.format("   > [%s] is too exhausted to attack! (stamina: %d)", p.name, p.stamina))
          return "idle"
        end
      end
    })
  },
  
  moving = {
    action = say("is walking forward."),
    transitions = trans({ stop = "idle", attack = "attacking" })
  },
  
  attacking = {
    action = function(p)
      p.stamina = p.stamina - 12  -- each swing costs stamina
      print(string.format("   [%s] swings their weapon! (stamina now: %d)", p.name, p.stamina))
    end,
    transitions = trans({ recover = "idle" })
  },
  
  staggered = {
    action = function(p)
      local dmg = take_damage(p)
      print(string.format("   > BOOM! [%s] took %d damage! HP is now %d", p.name, dmg, p.hp))
      
      if p.hp <= 0 then
        print("   > SYSTEM: Fatal damage detected! Injecting 'die' event...")
        inject(p, "die")
      end
    end,
    -- We can override globals if needed, or just add specifics
    transitions = trans({ recover = "idle" }) 
  },
  
  dead = {
    action = say("has collapsed to the ground."),
    transitions = { revive = "idle" } -- We don't use trans() here because dead shouldn't transition to staggered/dead
  }
}

-- === Payload & Execution === --
local my_payload = {
  name = "Hero",
  hp = 100,
  stamina = 30,   -- enough for ~2 attacks before guard triggers
  queue = { 
    "walk", "attack", "recover",   -- attack 1: stamina 30 -> 18, passes guard
    "hit", "recover", 
    "walk", "attack",              -- attack 2: stamina 18 -> 6, passes guard
    "recover",
    "attack",                      -- attack 3: stamina 6, BLOCKED by guard
    "hit", "walk" 
  },
  damage_queue = { 15, 90 } 
}

lint(rpg_rules, "idle")

print("=== STARTING TCO RPG BATTLE ===")
local final_memory = machine.start(rpg_rules, "idle", my_payload)

print("\n=== PROCESSING COMPLETE ===")
print("Final Queue Size remaining: " .. #final_memory.queue)
print("Final HP: " .. final_memory.hp)

print_trace(final_memory)