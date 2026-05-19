SMODS.Shader({key = "transparent", path = "transparent.fs"})

SMODS.DrawStep({ -- for drawing semi-transparent shader on circus joker
	key = "hnds_circus_cardarea_shader",
	order = 15,
	func = function(card, layer)
		if card.hnds_circus or (G.hnds_circus_joker and card.area == G.hnds_circus_joker) then
			if card.children.center then card.children.center:draw_shader('hnds_transparent') end
			if card.children.front and not card:should_hide_front() then
				card.children.front:draw_shader('hnds_transparent')
			end
		end
	end,
})

SMODS.Back({
	key = "circus",
	pos = { x = 1, y = 1 },
	atlas = "Extras",
	config = { extra = { } },
	unlocked = true,
	loc_vars = function(self, info_queue, back)
		if G.GAME and G.GAME.hnds_circus_joker_key then
			return { vars = { localize({type = 'name_text', key = G.GAME.hnds_circus_joker_key, set = 'Joker'}), colours = {G.C.ORANGE} }}
		else
			return { vars = { localize('k_none'), colours = {G.C.RED} }}
		end
	end
})
