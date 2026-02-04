-- fp.lua

-- Helper function to print tables neatly (e.g., "{1, 2, 3}")
local function print_list(t)
    io.write("{")
    for i, v in ipairs(t) do
        io.write(tostring(v))
        if i < #t then io.write(", ") end
    end
    print("}")
end

---------------------------------------------------------
-- C1. collect(t, f)
-- Applies function f to every element in t
---------------------------------------------------------
function collect(t, f)
    local new_table = {}
    for i, v in ipairs(t) do
        new_table[i] = f(v)
    end
    return new_table
end

---------------------------------------------------------
-- C2. select(t, f)
-- Returns elements where f returns true
---------------------------------------------------------
function select(t, f)
    local new_table = {}
    for _, v in ipairs(t) do
        if f(v) then
            table.insert(new_table, v)
        end
    end
    return new_table
end

---------------------------------------------------------
-- C3. reject(t, f)
-- Returns elements where f returns false
---------------------------------------------------------
function reject(t, f)
    local new_table = {}
    for _, v in ipairs(t) do
        if not f(v) then
            table.insert(new_table, v)
        end
    end
    return new_table
end
---------------------------------------------------------
-- C4. inject(t, acc, f)
-- Fold left: f takes (accumulator, element)
---------------------------------------------------------
function inject(t, acc, f)
    for _, v in ipairs(t) do
        acc = f(acc, v)
    end
    return acc
end

---------------------------------------------------------
-- C5. detect(t, f)
-- Returns first element where f is true, or nil
---------------------------------------------------------
function detect(t, f)
    for _, v in ipairs(t) do
        if f(v) then return v end
    end
    return nil
end
---------------------------------------------------------
-- C6. range(start, stop, step)
-- Returns an iterator (closure) that generates numbers
---------------------------------------------------------
function range(start, stop, step)
  step = step or 1
  -- The closure captures 'start' as an upvalue to track state
  return function()
    if (step > 0 and start > stop) or (step < 0 and start < stop) then
      return nil
    end
    local v = start
    start = start + step
    return v
  end
end
---------------------------------------------------------
-- TEST CASES
---------------------------------------------------------
print("--- Functional Programming Tests ---")

-- Test for C1: Collect
-- Goal: Square the numbers
local input1 = {1, 2, 3}
local result1 = collect(input1, function(x) return x * x end)
io.write("Test collect({1,2,3}):  ")
print_list(result1)


-- Test for C2: Select
-- Goal: Keep only even numbers
local input2 = {1, 2, 3, 4, 5}
local result2 = select(input2, function(x) return x % 2 == 0 end)
io.write("Test select({1..5}):    ")
print_list(result2)


-- Test for C3: Reject
-- Goal: Reject even numbers (Keep only odds)
local input3 = {1, 2, 3, 4, 5}
local result3 = reject(input3, function(x) return x % 2 == 0 end)
io.write("Test reject({1..5}):    ")
print_list(result3)

-- Test for C4: Inject
-- Goal: Summation (0 + 1 + 2 + 3 + 4)
local sum = inject({1, 2, 3, 4}, 0, function(a, x) return a + x end)
print("Test inject (sum):      " .. tostring(sum)) -- Expected: 10
-- Goal: Product (1 * 1 * 2 * 3 * 4)
local prod = inject({1, 2, 3, 4}, 1, function(a, x) return a * x end)
print("Test inject (product):  " .. tostring(prod)) -- Expected: 24

-- Test for C5: Detect
-- Goal: Find first number greater than 2
local found = detect({1, 2, 3, 4}, function(x) return x > 2 end)
print("Test detect (>2):       " .. tostring(found)) -- Expected: 3
-- Goal: Find non-existent element (e.g., > 10)
local missing = detect({1, 2, 3, 4}, function(x) return x > 10 end)
print("Test detect (>10):      " .. tostring(missing)) -- Expected: nil
-- Test for C6: Range
-- Goal: Generate numbers from 1 to 10 with step 2
print("Test range(1, 10, 2):")
for x in range(1, 10, 2) do 
  io.write(x .. " ") 
end
print("") -- Output: 1 3 5 7 9