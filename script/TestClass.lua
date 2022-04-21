local TestClassParent = require("__nco-Testmod__.script.TestClassParent")

---TestClass to examine loading and re-creating class objects from globals
---@class TestClass : TestClassParent
---@field class_name string class name used for logging and to index global.class_objects
---@field id uint deterministic id used for foreign keys etc.
---@field entity LuaEntity Entity used as a base object in this example
---@field registration_id uint unit registration ID from factorio framework
local TestClass = {
    class_name = "TestClass",
    --- garbage collection callback; this needs to be part of the userdata table to make it work
    ---@param self any
    __gc = function(self)
        if global.class_objects[self.class_name] then
            assert(global.class_objects[self.class_name][self.id] == nil)
        end
    end
}

---Class setup
TestClass.__index = TestClass
setmetatable(
    TestClass,
    {
        ---parent class; this is what makes the inheritance work
        ---@see http://lua-users.org/wiki/MetatableEvents
        __index = TestClassParent,
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

---Static function to set up required additional globals during on_init
function TestClass.on_init()
    global.class_objects[TestClass.class_name] = {}
end

---Class Constructor
---Use `obj = TestClass(global_data)` for an existing instance.
---Use `obj= TestClass(nil, ... )` for a new instance.
-----> check metatable creation for more details.
---@param entity LuaEntity entity to be wrapped
---@param new boolean do we create a new instance or are we just rebuilding from a saved global
function TestClass:new(new, entity)
    self:log()
    TestClassParent.new(self)
    if new and entity and entity.valid then
        self.entity = entity
        self.id = entity.unit_number
        global.class_objects[self.class_name][self.id] = self
        self:register_unit()
        self:log("unit #" .. self.id .. " created")
    end
end

---Cleanup of globals
function TestClass:destroy()
    self:log("unit #" .. self.id .. " destroyed")
    self:unregister_unit()
    global.class_objects[self.class_name][self.id] = nil
end

---Entity validation
function TestClass:is_valid()
    local valid = (self.entity and self.entity.valid)
    self:log(tostring(valid))
    return valid
end

---Unit registration
---@see https://lua-api.factorio.com/latest/LuaBootstrap.html#LuaBootstrap.register_on_entity_destroyed
function TestClass:register_unit()
    self:log("registering unit #" .. self.id)
    if self:is_valid() then
        self.registration_id = script.register_on_entity_destroyed(self.entity)
        global.unit_registration[self.registration_id] = {
            class_name = self.class_name,
            object_id = self.id
        }
    end
end

---Unit de-registration - only kills our saved reference
---the unit stays registered for the remainder of it's existance as factorio does not offer unregistering
function TestClass:unregister_unit()
    self:log("unregistering unit #" .. self.id)
    global.unit_registration[self.registration_id] = nil
end

return TestClass
