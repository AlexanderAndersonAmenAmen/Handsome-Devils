SMODS.Joker({
	key = "wait_what",
	atlas = "Jokers",
	pos = { x = 4, y = 4 },
	rarity = 1,
	cost = 2,
	unlocked = false,
	discovered = false,
	unlock_condition = { type = "hnds_joker_unlock", key = "wait_what", hidden = true },
	locked_loc_vars = function(self)
		return { vars = {} }
	end,
	check_for_unlock = function(self, args)
		return HNDS.joker_unlock_condition_met("wait_what", args)
	end,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { xmult = 4, tag_chance = 6 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult, card.ability.extra.tag_chance } }
	end,
	generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		local in_shop = card.area and card.area.config and card.area.config.type == 'shop'
		local disguised = in_shop and not (card.ability and card.ability.hnds_wait_what_revealed)
		local hidden_collection = not self.discovered and not in_shop

		self.no_main_mod_badge = disguised or hidden_collection
		full_UI_table.name = localize { type = 'name', key = self.key, set = 'Joker' }

		if hidden_collection then
			localize { type = 'unlocks', key = self.key, set = 'Joker', nodes = desc_nodes, vars = {} }
			return
		end

		local key = disguised and 'j_joker' or self.key
		local vars = disguised and { G.P_CENTERS.j_joker.config.mult } or self:loc_vars(info_queue, card).vars
		if disguised then full_UI_table.name = localize { type = 'name', key = key, set = 'Joker' } end
		localize { type = 'descriptions', key = key, set = 'Joker', nodes = desc_nodes, vars = vars }
	end,
	set_card_type_badge = function(self, card, badges)
		badges[#badges + 1] = create_badge(localize('k_common'), G.C.CHIPS, G.C.WHITE, 1.2)
	end,
	update = function(self, card, dt)
		-- Collection cards are static previews. Avoid running shop-disguise sprite
		-- maintenance every frame while the collection screen is left open.
		if card.area and card.area.config and card.area.config.collection then return end
		local dominated_by_shop = card.area and card.area.config and card.area.config.type == 'shop'
		local revealed = card.ability and card.ability.hnds_wait_what_revealed
		local should_disguise = dominated_by_shop and not revealed
		local current_center = card.config and card.config.center
		local target_center = should_disguise and G.P_CENTERS.j_joker or G.P_CENTERS.j_hnds_wait_what
		if current_center ~= target_center then
			card:set_sprites(target_center)
		end
	end,
	set_ability = function(self, card, initial, delay_sprites)
		card:set_sprites(G.P_CENTERS.j_hnds_wait_what)
	end,
	add_to_deck = function(self, card, from_debuff)
		card.ability.hnds_wait_what_revealed = true
		card:set_sprites(G.P_CENTERS.j_hnds_wait_what)
	end,
	calculate = function(self, card, context)
		-- X4 Mult when scoring
		if context.joker_main then
			return { xmult = card.ability.extra.xmult }
		end

		if context.end_of_round and not context.individual and not context.repetition then
			-- Balatro probability math factoring in Oops! All Sixes multiplier modifications
			if pseudorandom('wait_what_tag') < G.GAME.probabilities.normal / card.ability.extra.tag_chance then
				G.E_MANAGER:add_event(Event({
					func = function()
						add_tag(Tag('tag_hnds_extinction_tag'))
						play_sound('generic1')
						return true
					end
				}))
				return {
					message = "Rare Tag!",
					colour = G.C.FILTER,
					card = card
                }
			end
		end
	end,
	joker_display_def = function(JokerDisplay)
		return {
			text = {
				{
					border_nodes = {
						{ text = "X" },
						{ ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
					}
				}
			},
			calc_function = function(card)
				card.joker_display_values.x_mult = card.ability.extra.xmult
			end
		}
	end,
	attributes = { "xmult" }
})