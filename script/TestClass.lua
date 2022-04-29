local TestClassParent = require("__nco-Testmod__.script.TestClassParent")

---TestClass to examine loading and re-creating class objects from globals
---@class TestClass : TestClassParent
---@field public __name string class name used for logging and to index global.class_objects
---@field public id uint deterministic id used for foreign keys etc.
---@field private entity LuaEntity Entity used as a base object in this example
---@field private registration_id uint unit registration ID from factorio framework
local TestClass = {
    __name = "TestClass",
}
TestClass = require("__nco-Testmod__.script.Class")(TestClass,TestClassParent)

---Static function to set up required additional globals during on_init
function TestClass.on_init()
    global.class_objects[TestClass.__name] = {}
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
        global.class_objects[self.__name][self.id] = self
        self:register_unit()
        self:log("unit #" .. self.id .. " created")
    end
end

---Cleanup of globals
function TestClass:destroy()
    self:log("unit #" .. self.id .. " destroyed")
    self:unregister_unit()
    global.class_objects[self.__name][self.id] = nil
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
            class_name = self.__name,
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
