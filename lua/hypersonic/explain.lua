-- FIXME: make some format, that will know if is it inside group/class
-- TODO: make it more readable

local U = require('utils')
local S = require('split')
local T = require('tables')
local M = {}

---@param char string
---@return string
local explain_char = function(char)
    if U.is_escape_char(char) then
        local single_char = string.sub(char, 2, 2)
        local meta_explain =
            T.meta_table[single_char] == nil
            and 'Match escaped ' .. char
            or T.meta_table[single_char]
        return meta_explain
    elseif T.char_table[char] ~= nil then
        return T.char_table[char]
    elseif T.special_table[char] ~= nil then
        return T.special_table[char]
    else
        return "Match " .. char
    end
end


---@param tbl table
---@return table
local explain_class = function(tbl)
    local class = { {'class #CLASS', tbl[1]} }

    for idx, v in pairs(tbl) do
        if v ~= '#CLASS' then
            local explained = explain_char(v)

            -- class does not have "or" as "|"
            if explained == T.special_table['|'] then
                explained = 'Match |'
            end

            table.insert(class, { v, explained })

            -- add "or"
            local not_range = tbl[idx+1] ~= '-' and tbl[idx] ~= '-'
            if idx ~= #tbl and not_range then
                table.insert(class, { '', 'or' })
            end
        end
    end

    return class
end

---@param tbl table
---@param result_tbl table
---@return table
M.explain = function(tbl, result_tbl)
    for _, v in pairs(tbl) do
        if type(v) == 'table' then
            -- if is table, check if is it class -> explain class, group -> explain normal
            if v[1] == '#CLASS' then
                table.insert(result_tbl, explain_class(v))
            else
                table.insert(result_tbl, M.explain(v, {}))
            end
        elseif v ~= '#CLASS' and v ~= '#GROUP' then
            table.insert(result_tbl, { v, explain_char(v) })
        end
    end

    return result_tbl
end

-- local test_idx = 5
local test_idx = 7
local test_tbl = S.split(T.test_inputs[test_idx])
U.print_table(test_tbl, 0); print("\n")
local result = M.explain(test_tbl, { { 'Regex', T.test_inputs[test_idx] } })
U.print_table(result, 0)

return M