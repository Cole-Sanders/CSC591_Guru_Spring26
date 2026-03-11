local M = {}

local function run(rules, s, p)
  if rules[s] and rules[s].action then rules[s].action(p) end
  
  local e = table.remove(p.queue, 1)
  if not e then return p end
  
  -- Determine the next state; transition can be a string or a guard function(p) -> string
  local raw = rules[s].transitions[e]
  local next_s = (type(raw) == "function" and raw(p) or raw) or s
  
  -- Record the transition to our history trace before the tail call
  table.insert(p.trace, string.format("[%s] %s -> %s", e, s, next_s))
  
  -- Tail Call Optimization is preserved because this is the final return
  return run(rules, next_s, p) 
end

function M.start(rules, s, p) 
  -- Ensure the trace table exists on startup so we don't crash on the first append
  p.trace = p.trace or {} 
  return run(rules, s, p) 
end

return M