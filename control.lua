---@type TestClass
local TestClass = require("__nco-Testmod__.script.TestClass")
-------------------------------------------------------------------------------
--- Variables
--- Is it desync safe to use locals to store references to the class objects in different structure  as long as the class'es object data is global'ized?
-------------------------------------------------------------------------------
---@type table<uint,TestClass>
local TestClass_Instances = {}

-------------------------------------------------------------------------------
--- Event handlers
-------------------------------------------------------------------------------

---Event handler on_init
---@see https://lua-api.factorio.com/latest/Data-Lifecycle.html
local function on_init()
    log("control:on_init")
    global.class_objects = {}
    global.unit_registration = {}

    --class based initialization of sub tables
    TestClass.on_init()
end

---Event handler on_load
---@see https://lua-api.factorio.com/latest/Data-Lifecycle.html
local function on_load()
    log("control:on_load")
    for _, o in pairs(global.class_objects["TestClass"]) do
        local instance = TestClass(o)
        TestClass_Instances[instance.id] = instance
    end
end

---Event handler on_built_entity
---@param event on_built_entity
---@see https://lua-api.factorio.com/latest/events.html#on_built_entity
local function on_built_entity(event)
    log("control:on_built_entity")
    local entity = event.created_entity
    if entity and entity.valid and entity.type == "spider-vehicle" and entity.name == "spidertron" then
        local instance = TestClass(nil, entity)
        TestClass_Instances[instance.id] = instance
    end
end

---main worker for unit validation
---@param _ EventData
local function on_nth_tick_600(_)
    log("control:on_nth_tick_300")
    local key, obj = next(TestClass_Instances)
    while key do
        if obj:is_valid() == false then
            TestClass_Instances[key]:destroy()
            TestClass_Instances[key] = nil
        end
        key, obj = next(TestClass_Instances, key)
    end
end

-------------------------------------------------------------------------------
--- Event handler on_entity_destroyed
---@param event on_entity_destroyed
local function on_entity_destroyed(event)
    log("control:on_entity_destroyed")
    local unit_data = global.unit_registration[event.registration_number]
    if unit_data and global.class_objects[unit_data.class_name] then
        TestClass_Instances[unit_data.object_id]:destroy() -- we need to either nil the instance-data global-member to call destroy from gc or manually call it
        TestClass_Instances[unit_data.object_id] = nil
    end
end

-------------------------------------------------------------------------------
--- Event registration
-------------------------------------------------------------------------------

local ev = defines.events
script.on_init(on_init)
script.on_load(on_load)
script.on_nth_tick(600, on_nth_tick_600)
script.on_event(ev.on_entity_destroyed, on_entity_destroyed)
script.on_event(
    {
        ev.on_built_entity,
        ev.script_raised_built,
        ev.on_robot_built_entity
    },
    on_built_entity
)
