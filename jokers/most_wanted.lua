-- Pick a random owned joker key for Most Wanted targeting
local function pick_owned_joker_key(card, seed, previous_key)
	local pool = {}
	if not (G and G.jokers and G.jokers.cards) then return nil end
	for _, j in ipairs(G.jokers.cards) do
		if j and j ~= card and j.config and j.config.center and j.config.center.key then
			local k = j.config.center.key
			if k ~= 'j_hnds_most_wanted' and k ~= previous_key then
				pool[#pool + 1] = k
			end
		end
	end
	if #pool == 0 then
		for _, j in ipairs(G.jokers.cards) do
			if j and j ~= card and j.config and j.config.center and j.config.center.key then
				local k = j.config.center.key
				if k ~= 'j_hnds_most_wanted' then
					pool[#pool + 1] = k
				end
			end
		end
	end
	if #pool == 0 then return nil end
	return pseudorandom_element(pool, pseudoseed(seed))
end

HNDS.most_wanted_on_shop_create_card = function(created_card, args)
	if not (created_card and args and args.area == G.shop_jokers) then return end
	if not (created_card.config and created_card.config.center and created_card.config.center.set == 'Joker') then return end
	if created_card.config.center.key == 'j_hnds_wait_what' then return end
	if not (G and G.GAME and G.GAME.hnds_most_wanted_key) then return end
	if created_card.config.center.key == G.GAME.hnds_most_wanted_key then return end

	local pool = {}
	for _, v in ipairs(G.P_CENTER_POOLS.Joker or {}) do
		if v and not v.hidden then
			pool[#pool + 1] = v.key
		end
	end

	for i = 1, 3 do
		if pseudorandom_element(pool, pseudoseed('hnds_most_wanted' .. i .. 'shop')) == G.GAME.hnds_most_wanted_key then
			created_card:set_ability(G.P_CENTERS[G.GAME.hnds_most_wanted_key], true, true)
			break
		end
	end
end

SMODS.Joker({
	key = "most_wanted",
	atlas = "Jokers",
	pos = { x = 0, y = 4 },
	rarity = 1,
	cost = 3,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = false,
	perishable_compat = true,
	config = {
		extra = {
			target = nil,
		}
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.target and localize({ type = 'name_text', key = card.ability.extra.target, set = 'Joker' }) or localize('k_none') } }
	end,
	set_ability = function(self, card, initial, delay_sprites)
		-- Initialize target from currently owned Jokers
		if G.STAGE == G.STAGES.RUN then
			card.ability.extra.target = pick_owned_joker_key(card, 'hnds_most_wanted')
			G.GAME.hnds_most_wanted_key = card.ability.extra.target
			card.ability.extra.last_ante = (G.GAME.round_resets and G.GAME.round_resets.ante) or 0
		end
	end,
	calculate = function(self, card, context)
		if context.buying_card and context.card and card.ability.extra.target and
			context.card.config and context.card.config.center and context.card.config.center.key == card.ability.extra.target then
			SMODS.destroy_cards(card)
			G.GAME.hnds_most_wanted_key = nil
			return nil, true
		end

		-- Choose a fresh target each ante from owned Jokers
		if context.setting_blind then
			local ante = (G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 0
			if card.ability.extra.last_ante ~= ante then
				card.ability.extra.target = pick_owned_joker_key(card, 'hnds_most_wanted' .. tostring(ante), card.ability.extra.target)
				card.ability.extra.last_ante = ante
			end
		end
		if context.setting_blind and not card.ability.extra.target then
			card.ability.extra.target = pick_owned_joker_key(card, 'hnds_most_wanted_fallback')
			G.GAME.hnds_most_wanted_key = card.ability.extra.target
		elseif context.setting_blind then
			G.GAME.hnds_most_wanted_key = card.ability.extra.target
		end
	end,
})
