local elements_by_box = setmetatable({}, {__mode = 'k'})
local removed = setmetatable({}, {__mode = 'k'})
local unpack_values = table.unpack or unpack

local init_ref = UIElement.init
function UIElement:init(parent, box, ...)
    local result = HNDS.pack(init_ref(self, parent, box, ...))
    if box then
        local elements = elements_by_box[box]
        if not elements then
            elements = setmetatable({}, {__mode = 'k'})
            elements_by_box[box] = elements
        end
        elements[self] = true
    end
    removed[self] = nil
    return unpack_values(result, 1, result.n)
end

local element_remove_ref = UIElement.remove
function UIElement:remove(...)
    if removed[self] then return end
    removed[self] = true
    local elements = self.UIBox and elements_by_box[self.UIBox]
    if elements then elements[self] = nil end
    return element_remove_ref(self, ...)
end

local box_remove_ref = UIBox.remove
function UIBox:remove(...)
    if removed[self] then return end
    removed[self] = true
    local elements = elements_by_box[self]
    local result = HNDS.pack(box_remove_ref(self, ...))
    if elements then
        local remaining = {}
        for element in pairs(elements) do remaining[#remaining + 1] = element end
        for _, element in ipairs(remaining) do
            if not removed[element] and element.UIBox == self then element:remove() end
        end
        elements_by_box[self] = nil
    end
    return unpack_values(result, 1, result.n)
end

local set_values_ref = UIElement.set_values
function UIElement:set_values(transform, recalculate, ...)
    return set_values_ref(self, transform, recalculate or self.T ~= nil, ...)
end
