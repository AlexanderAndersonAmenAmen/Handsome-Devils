function HNDS.get_most_wanted_multiplier(total_jokers)
	if total_jokers > 800 then return 12 end
	if total_jokers > 500 then return 8 end
	if total_jokers > 300 then return 6 end
	return 4
end

function HNDS.get_discovered_joker_pool(previous_key)
	local pool = {}
	local total_jokers = 0
	for _, center in ipairs((G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker) or {}) do
		if center and not center.hidden and center.key and center.key ~= 'j_hnds_most_wanted' then
			total_jokers = total_jokers + 1
			if center.discovered and center.key ~= previous_key then
				pool[#pool + 1] = center.key
			end
		end
	end
	return pool, total_jokers
end

function HNDS.pick_discovered_joker_key(seed, previous_key)
	local pool, total_jokers = HNDS.get_discovered_joker_pool(previous_key)
	if #pool == 0 then return nil, total_jokers end
	return pseudorandom_element(pool, pseudoseed(seed)), total_jokers
end

SMODS.Joker({
	key = "most_wanted",
	atlas = "Jokers",
	pos = { x = 0, y = 4 },
	rarity = 1,
	cost = 3,
	unlocked = false,
	discovered = false,
	unlock_condition = { type = "hnds_joker_unlock", key = "most_wanted" },
	locked_loc_vars = function(self)
		return HNDS.joker_locked_loc_vars("most_wanted")
	end,
	check_for_unlock = function(self, args)
		return HNDS.joker_unlock_condition_met("most_wanted", args)
	end,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = false,
	perishable_compat = true,
	config = { extra = { target = nil, target_edition = nil, multiplier = 4 } },

	loc_vars = function(self, info_queue, card)
		local target_name
		local edition_name = ""
		
		if card.ability.extra.target_edition then
			edition_name = localize({ type = 'name_text', key = card.ability.extra.target_edition, set = 'Edition' }) .. " "
		end

		if G.STAGE ~= G.STAGES.RUN then
			local random_target, _ = HNDS.pick_discovered_joker_key('hnds_most_wanted_collection')
			target_name = random_target and localize({ type = 'name_text', key = random_target, set = 'Joker' }) or localize("k_hnds_wanted")
		end

		local full_target_string = edition_name .. (target_name or (card.ability.extra.target and localize({ type = 'name_text', key = card.ability.extra.target, set = 'Joker' })) or localize("k_hnds_wanted"))
		
		return {
			vars = {
				full_target_string,
				card.ability.extra.multiplier or 4,
			},
		}
	end,
	set_ability = function(self, card, initial, delay_sprites)
		local _, total_jokers = HNDS.get_discovered_joker_pool()
		card.ability.extra.multiplier = HNDS.get_most_wanted_multiplier(total_jokers)
		
		if G.STAGE == G.STAGES.RUN then
			local target, _ = HNDS.pick_discovered_joker_key('hnds_most_wanted')
			card.ability.extra.target = target
			
			local ed_pool = {'e_foil', 'e_holo', 'e_polychrome'}
			card.ability.extra.target_edition = pseudorandom_element(ed_pool, 'most_wanted_edition_init')
		end
	end,
	calculate = function(self, card, context)
		if context.selling_self and not context.blueprint and G.STATE == G.STATES.SHOP and G.shop_jokers and G.shop_jokers.cards then
			for _, shop_card in ipairs(G.shop_jokers.cards) do
				if shop_card.config and shop_card.config.center and shop_card.config.center.key == card.ability.extra.target then
					shop_card.cost = 0
					shop_card.val = 0
					if shop_card.hud_item then shop_card.hud_item:realign() end
				end
			end
		end

		-- 1620a shop-card context: react at the moment the target is actually
		-- inserted into the shop. The starting/reroll block below remains as a
		-- compatibility fallback for unusual shop-generation paths.
		if context.modify_shop_card and context.card and card.ability.extra.target then
			local shop_card = context.card
			if shop_card.config and shop_card.config.center
				and shop_card.config.center.key == card.ability.extra.target
			then
				if not shop_card.hnds_most_wanted_announced then
					shop_card.hnds_most_wanted_announced = true
					if hnds_config and hnds_config.enableCustomSounds then
						play_sound('hnds_wp_buy_inshop', 1, 0.75)
					end
				end
				if not shop_card.edition and card.ability.extra.target_edition then
					local ed_key = card.ability.extra.target_edition:gsub("^e_", "")
					shop_card:set_edition({ [ed_key] = true }, false, false)
					shop_card:juice_up()
				end
			end
		end

		if context.modify_weights and context.pool_types and context.pool_types.Joker then
			for _, v in ipairs(context.pool) do
				if v.key == card.ability.extra.target then
					v.weight = (v.weight or 1) * (card.ability.extra.multiplier or 1)
				end
			end
		end


		if (context.starting_shop or context.reroll_shop) and G.shop_jokers and G.shop_jokers.cards then
			G.E_MANAGER:add_event(Event({
				func = function()
					for _, shop_card in ipairs(G.shop_jokers.cards) do

						if shop_card.config and shop_card.config.center and shop_card.config.center.key == card.ability.extra.target then
							if not shop_card.hnds_most_wanted_announced then
								shop_card.hnds_most_wanted_announced = true
								if hnds_config and hnds_config.enableCustomSounds then
									play_sound('hnds_wp_buy_inshop', 1, 0.75)
								end
							end

							if not shop_card.edition and card.ability.extra.target_edition then
								local ed_key = card.ability.extra.target_edition:gsub("^e_", "")
								shop_card:set_edition({[ed_key] = true}, false, false)
								shop_card:juice_up()
							end
						end
					end
					return true
				end
			}))
		end

		if context.starting_shop and not card.ability.extra.target then
			local target, total_jokers = HNDS.pick_discovered_joker_key('hnds_most_wanted_fallback', card.ability.extra.target)
			card.ability.extra.target = target
			card.ability.extra.multiplier = HNDS.get_most_wanted_multiplier(total_jokers)
			
			local ed_pool = {'e_foil', 'e_holo', 'e_polychrome'}
			card.ability.extra.target_edition = pseudorandom_element(ed_pool, 'most_wanted_edition_fallback')
		end
	end,
	attributes = { "joker", "passive", }
})