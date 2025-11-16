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
