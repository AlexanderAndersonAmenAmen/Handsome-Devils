-- Pick a random discovered joker key for Most Wanted targeting
local function get_most_wanted_multiplier(total_jokers)
	if total_jokers > 800 then return 12 end
	if total_jokers > 500 then return 8 end
	if total_jokers > 300 then return 6 end
	return 4
end

local function get_discovered_joker_pool(previous_key)
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
	if #pool == 0 then
		for _, center in ipairs((G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker) or {}) do
			if center and not center.hidden and center.key and center.key ~= 'j_hnds_most_wanted' and center.discovered then
				pool[#pool + 1] = center.key
			end
		end
	end
	return pool, total_jokers
end

local function pick_discovered_joker_key(seed, previous_key)
	local pool, total_jokers = get_discovered_joker_pool(previous_key)
	if #pool == 0 then return nil, total_jokers end
	return pseudorandom_element(pool, pseudoseed(seed)), total_jokers
end

HNDS.most_wanted_on_shop_create_card = function(created_card, args)
	if not (created_card and args and args.area == G.shop_jokers) then return end
	if not (created_card.config and created_card.config.center and created_card.config.center.set == 'Joker') then return end
	if created_card.config.center.key == 'j_hnds_wait_what' then return end
	if not (G and G.GAME and G.GAME.hnds_most_wanted_key) then return end
	if created_card.config.center.key == G.GAME.hnds_most_wanted_key then return end

	local pool = {}
	for _, v in ipairs(G.P_CENTER_POOLS.Joker or {}) do
		if v and not v.hidden and v.key then
			pool[#pool + 1] = v.key
		end
	end

	local multiplier = (G.GAME.hnds_most_wanted_mult or 4) - 1
	for i = 1, math.max(0, multiplier) do
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
	config = { extra = { target = nil, multiplier = 4 } },
	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.extra.target and localize({ type = 'name_text', key = card.ability.extra.target, set = 'Joker' }) or localize('k_none'),
				card.ability.extra.multiplier or 4,
			}
		}
	end,
	set_ability = function(self, card, initial, delay_sprites)
		-- Initialize target from discovered Jokers in collection
		if G.STAGE == G.STAGES.RUN then
			local target, total_jokers = pick_discovered_joker_key('hnds_most_wanted')
			card.ability.extra.target = target
			card.ability.extra.multiplier = get_most_wanted_multiplier(total_jokers)
			G.GAME.hnds_most_wanted_key = card.ability.extra.target
			G.GAME.hnds_most_wanted_mult = card.ability.extra.multiplier
		end
	end,
	calculate = function(self, card, context)
		if context.buying_card and context.card and card.ability.extra.target and
			context.card.config and context.card.config.center and context.card.config.center.key == card.ability.extra.target then
			SMODS.destroy_cards(card)
			G.GAME.hnds_most_wanted_key = nil
			G.GAME.hnds_most_wanted_mult = nil
			return nil, true
		end

		if context.setting_blind and not card.ability.extra.target then
			local target, total_jokers = pick_discovered_joker_key('hnds_most_wanted_fallback', card.ability.extra.target)
			card.ability.extra.target = target
			card.ability.extra.multiplier = get_most_wanted_multiplier(total_jokers)
			G.GAME.hnds_most_wanted_key = card.ability.extra.target
			G.GAME.hnds_most_wanted_mult = card.ability.extra.multiplier
		elseif context.setting_blind then
			G.GAME.hnds_most_wanted_key = card.ability.extra.target
			G.GAME.hnds_most_wanted_mult = card.ability.extra.multiplier
		end
	end,
})
