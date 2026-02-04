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