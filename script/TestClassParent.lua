--- mock parent class to keep example short
---@class TestClassParent
local TestClassParent = {
    log = function(_, msg)
        local msg = (((debug.getinfo(2, "n").name) or "") .. ":" .. (msg or ""))
        if game and game.print then
            game.print(msg)
        end
        log(msg)
    end,
    new = function(_)
    end
}

return TestClassParent
