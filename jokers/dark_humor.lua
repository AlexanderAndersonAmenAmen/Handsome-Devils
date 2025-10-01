SMODS.Joker({
	key = "dark_humor",
	rarity = 2,
	config = { extra = { chips = 0, mult = 0 } },
	atlas = "Jokers",
	pos = { x = 0, y = 0 },
	cost = 6,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	perishable_compat = false,
	demicoloncompat = true,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips, card.ability.extra.mult } }
	end,
	calculate = function(self, card, context)
		if (context.before or context.forcetrigger) and #G.hand.cards > 0 then
			local destructable_cards = {}
			for _, playing_card in ipairs(G.hand.cards) do
				if not SMODS.is_eternal(playing_card, card) then
					destructable_cards[#destructable_cards + 1] = playing_card
				end
			end
			if #destructable_cards > 0 then
				local target = pseudorandom_element(destructable_cards, "hnds_dark_humor") or {} --to stop vscode from screaming at me, the 'or' doesnt actually change anything
				card.ability.extra.chips = card.ability.extra.chips
					+ target:get_chip_bonus()
					+ target:get_chip_h_bonus()
				card.ability.extra.mult = card.ability.extra.mult + target:get_chip_mult() + target:get_chip_h_mult()
				if SMODS.has_enhancement(target, "m_lucky") then
					card.ability.extra.mult = card.ability.extra.mult - target.ability.mult
				end
				SMODS.destroy_cards(target)
				SMODS.calculate_effect({ message = localize("k_upgrade_ex") }, card)
			end
		end
		if context.joker_main or context.forcetrigger then
			return {
				chips = card.ability.extra.chips,
				mult = card.ability.extra.mult,
			}
		end
	end,
})
