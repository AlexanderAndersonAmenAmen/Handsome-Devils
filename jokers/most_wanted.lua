-- Pick a random discovered joker key for Most Wanted targeting
local function get_most_wanted_multiplier(total_jokers)
	if total_jokers > 800 then return 24 end
	if total_jokers > 500 then return 16 end
	if total_jokers > 300 then return 12 end
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
	config = { extra = { target = nil, multiplier = 8 } },
	loc_vars = function(self, info_queue, card)
		local target_name
		if G.STAGE ~= G.STAGES.RUN then
			local random_target, _ = pick_discovered_joker_key('hnds_most_wanted_collection')
			target_name = random_target and localize({ type = 'name_text', key = random_target, set = 'Joker' }) or localize("k_hnds_wanted")
		else
			target_name = card.ability.extra.target and localize({ type = 'name_text', key = card.ability.extra.target, set = 'Joker' }) or localize("k_hnds_wanted")
		end
		return {
			vars = {
				target_name,
				card.ability.extra.multiplier or 4,
			},
		}
	end,
	set_ability = function(self, card, initial, delay_sprites)
		-- Always calculate multiplier based on collection size
		local _, total_jokers = get_discovered_joker_pool()
		card.ability.extra.multiplier = get_most_wanted_multiplier(total_jokers)
		
		-- Initialize target from discovered Jokers only during a run
		if G.STAGE == G.STAGES.RUN then
			local target, _ = pick_discovered_joker_key('hnds_most_wanted')
			card.ability.extra.target = target
		end
	end,
	calculate = function(self, card, context)
		if context.buying_card and context.card and card.ability.extra.target and
			context.card.config and context.card.config.center and context.card.config.center.key == card.ability.extra.target then
			SMODS.destroy_cards(card)
			return nil, true
		end

		if context.modify_weights then
			for _, v in ipairs(context.pool) do
				if v.key == card.ability.extra.target then
					v.weight = (v.weight or 1) * (card.ability.extra.multiplier or 1)
				end
			end
		end

		if context.starting_shop and not card.ability.extra.target then
			local target, total_jokers = pick_discovered_joker_key('hnds_most_wanted_fallback', card.ability.extra.target)
			card.ability.extra.target = target
			card.ability.extra.multiplier = get_most_wanted_multiplier(total_jokers)
		end
	end,
	attributes = { "joker", "passive", }
})
