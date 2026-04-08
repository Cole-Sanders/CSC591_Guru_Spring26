-- to_dot.lua
-- Converts an FSM rules table into a Graphviz DOT string.
--
-- Guard functions (transition values that are functions) are resolved by
-- calling them with a permissive mock payload — every numeric field returns
-- math.huge so guards like `stamina > 10` pass, revealing the "happy path"
-- target. A /* guard */ comment is appended to the edge to flag it.
--
-- Usage:
--   local to_dot = require "to_dot"
--   print(to_dot(rpg_rules))
--
-- Pipe straight to Graphviz:
--   lua machine2.lua | dot -Tpng -o fsm.png

-- Q5:exporter
local function to_dot(rules)
  -- Permissive mock payload: any key returns math.huge so numeric guards pass.
  local mock_p = setmetatable({}, {
    __index = function() return math.huge end
  })

  -- Collect edges as structs so we can sort for stable output
  -- (pairs() order is undefined in Lua).
  local edges = {}
  for state, data in pairs(rules) do
    for event, target in pairs(data.transitions or {}) do
      local resolved, is_guard = target, false

      if type(target) == "function" then
        -- Silence any print() calls inside the guard during mock execution
        local old_print = print
        print = function() end
        local ok, result = pcall(target, mock_p)
        print = old_print

        resolved = (ok and type(result) == "string") and result or "UNKNOWN"
        is_guard = true
      end

      edges[#edges + 1] = { from = state, to = resolved, event = event, guard = is_guard }
    end
  end

  -- Sort: primary = from-state name, secondary = event name
  table.sort(edges, function(a, b)
    if a.from ~= b.from then return a.from < b.from end
    return a.event < b.event
  end)

  -- Find the longest "  from -> to" segment for column-aligned labels
  local max_len = 0
  for _, e in ipairs(edges) do
    local len = #string.format("  %s -> %s", e.from, e.to)
    if len > max_len then max_len = len end
  end

  local lines = { "digraph fsm {" }

  for _, e in ipairs(edges) do
    local arrow   = string.format("  %s -> %s", e.from, e.to)
    local padding = string.rep(" ", max_len - #arrow + 1)
    local comment = e.guard and "  /* guard */" or ""
    lines[#lines + 1] = string.format('%s%s[ label="%s" ]%s',
      arrow, padding, e.event, comment)
  end

  lines[#lines + 1] = "}"
  return table.concat(lines, "\n")
end

return to_dot
