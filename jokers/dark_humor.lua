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
				if target.edition and target.edition.chips then card.ability.extra.chips = card.ability.extra.chips + target.edition.chips end
				if SMODS.has_enhancement(target, "m_lucky") then
					card.ability.extra.mult = card.ability.extra.mult + target:get_chip_mult() + target:get_chip_h_mult() - (SMODS.pseudorandom_probability(target, "m_lucky", 1, 5) and 0 or target.ability.mult)
				else
					card.ability.extra.mult = card.ability.extra.mult + target:get_chip_mult() + target:get_chip_h_mult()
				end
				if target.edition and target.edition.mult then card.ability.extra.mult = card.ability.extra.mult + target.edition.mult end
				SMODS.destroy_cards(target)
				return { message = localize("k_upgrade_ex") }
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
