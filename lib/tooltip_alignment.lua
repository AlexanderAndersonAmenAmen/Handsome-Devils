local align_ref = Card.align_h_popup
function Card:align_h_popup(...)
    local alignment = align_ref(self, ...)
    if type(alignment) ~= 'table' then return alignment end
    local definition = self.config and self.config.h_popup
    local room = G.ROOM and G.ROOM.T
    local cache = self.hnds_tooltip_alignment_cache
    if not cache or cache.definition ~= definition or cache.area ~= self.area
        or cache.major ~= alignment.major or cache.room_w ~= (room and room.w)
        or cache.room_h ~= (room and room.h) then
        cache = {
            definition = definition, area = self.area, major = alignment.major,
            room_w = room and room.w, room_h = room and room.h,
            type = alignment.type, align = alignment.align, lr_clamp = alignment.lr_clamp,
            x = alignment.offset and alignment.offset.x,
            y = alignment.offset and alignment.offset.y,
        }
        self.hnds_tooltip_alignment_cache = cache
    end
    alignment.type, alignment.align, alignment.lr_clamp = cache.type, cache.align, cache.lr_clamp
    if alignment.offset then alignment.offset.x, alignment.offset.y = cache.x, cache.y end
    return alignment
end

local stop_ref = Card.stop_hover
function Card:stop_hover(...)
    self.hnds_tooltip_alignment_cache = nil
    return stop_ref(self, ...)
end

local function make_passive(node)
    if node.states then
        for _, state in ipairs({'collide', 'hover', 'drag'}) do
            if node.states[state] then node.states[state].can = false end
        end
    end
    for _, child in pairs(node.children or {}) do make_passive(child) end
end

local show_ref = G.FUNCS.show_infotip
G.FUNCS.show_infotip = function(element, ...)
    local results = HNDS.pack(show_ref(element, ...))
    local info = element.children and element.children.info
    if info and element.hnds_passive_infotip ~= info then
        element.hnds_passive_infotip = info
        make_passive(info)
    end
    return (table.unpack or unpack)(results, 1, results.n)
end
