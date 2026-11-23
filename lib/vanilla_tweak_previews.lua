-- Isolated visual objects: never instantiate a gameplay Card/Tag/Blind, call
-- loc_vars, or temporarily replace global centers/localization for a tooltip.
local art = assert(SMODS.load_file('lib/vanilla_tweak_art.lua'))()
assert(SMODS.load_file('lib/vanilla_tweak_native_tooltips.lua'))()

function HNDS.vanilla_tweak_preview(entry, modded, wrap)
    local info = assert(art[entry.key], 'Missing tweak preview: ' .. entry.key)
    local atlas, pos = info.atlas, info.pos
    if modded then
        local center = (G.P_CENTERS and G.P_CENTERS[info.key])
            or (G.P_TAGS and G.P_TAGS[info.key])
            or (G.P_BLINDS and G.P_BLINDS[info.key])
            or (G.P_STAKES and G.P_STAKES[info.key])
        if center then atlas, pos = center.atlas or atlas, center.pos or pos end
    end
    local square = info.atlas == 'tags' or info.atlas == 'chips' or info.atlas == 'blind_chips'
    -- Match each entity's native collection dimensions, not a scaled thumbnail.
    local h = square and (info.atlas == 'blind_chips' and 1.3 or info.atlas == 'tags' and 0.8 or 0.5) or G.CARD_H
    local w = square and h or G.CARD_W
    local obj = SMODS.create_sprite(0, 0, w, h, atlas, { x = pos.x, y = pos.y })
    obj:define_draw_steps({
        { shader = 'dissolve', shadow_height = 0.05 },
        { shader = 'dissolve' },
    })
    obj.float = true
    obj.states.hover.can, obj.states.drag.can, obj.states.collide.can = true, true, true
    obj.config = { force_focus = true, hnds_tweak_preview = true }
    obj.hover = function(self)
        if self.hovering or self.states.drag.is then return end
        self.hovering, self.hover_tilt = true, 1.5
        self:juice_up(0.04, 0.02)
        self.config.h_popup = HNDS.vanilla_tweak_native_popup(self, entry, modded)
        self.config.h_popup_config = { align = 'tm', offset = { x = 0, y = -0.15 }, parent = self }
        Node.hover(self)
    end
    obj.stop_hover = function(self)
        self.hovering, self.hover_tilt = false, 0
        Node.stop_hover(self)
    end
    -- UI objects normally follow a parent. Detach only while dragging and
    -- restore that role on release, so previews return to their own column.
    obj.drag = function(self, offset)
        if not self.hnds_home_role then
            self.hnds_home_role = self.role
            self:set_role({ role_type = 'Major' })
            self:stop_hover()
        end
        Moveable.drag(self, offset)
    end
    obj.stop_drag = function(self)
        Node.stop_drag(self)
        if self.hnds_home_role then
            self:set_role(self.hnds_home_role)
            self.hnds_home_role = nil
        end
    end
    local remove = obj.remove
    obj.remove = function(self)
        if self.hnds_preview_removed then return end
        self.hnds_preview_removed = true
        self:stop_hover()
        local controller = G.CONTROLLER
        if controller and controller.dragging and controller.dragging.target == self then
            controller.dragging.target = nil
        end
        return remove(self)
    end
    return { n = G.UIT.R, config = { align = 'cm', minh = G.CARD_H + 0.1, padding = 0.02 }, nodes = {
        { n = G.UIT.O, config = { object = obj, focus_with_object = true } },
    }}
end
