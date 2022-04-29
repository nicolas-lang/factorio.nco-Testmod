---Class Factory
---call with `TestClass = require("script.Class")(Object,ParentClass)`
---@param object table
---@param parent_class any
---@return any class
return function(object, parent_class)
    --- garbage collection callback, just to ensure everything is cleaned up correctly
    ---@param self any
    object["__gc"] = function(self)
        if self.__name and global.class_objects and global.class_objects[self.__name] and self.id then
            assert(global.class_objects[self.__name][self.id] == nil, self.__name .. " has not been cleaned up correctly")
        end
    end
    object.__index = object
    setmetatable(
        object,
        {
            ---parent class; this is what makes the inheritance work
            ---@see http://lua-users.org/wiki/MetatableEvents
            __index = parent_class,
            ---Class instanciation
            ---@see http://lua-users.org/wiki/MetatableEvents
            ---@param base table the class prototype that is being called/instanciated providing static class variables
            ---@param o table existing simplified object-data (no metatables, no functions; for example a globalized class instance that got chopped down during saveing)
            ---@param ... any? parameters for the constructor
            ---@return any class reference to created class instance
            __call = function(base, o, ...)
                local data = (o or {})
                local self = setmetatable(data, base)
                self:new(o == nil, ...)
                return self
            end
        }
    )
    return object
end
