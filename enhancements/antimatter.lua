SMODS.Enhancement({
	key = "antimatter",
	atlas = "Extras",
	pos = { x = 2, y = 1 },
	config = { extra = { base = 1, odds = 4, stacks = 0 } },
	loc_vars = function(self, info_queue, card)
		local numerator, denominator =
			SMODS.get_probability_vars(card, card.ability.extra.base, card.ability.extra.odds, "hnds_antimatter")
		return {
			vars = {
				numerator,
				denominator,
				(
					card.ability.extra.stack_choice
					and localize({ type = "name_text", set = "Enhanced", key = card.ability.extra.stack_choice })
				) or localize("k_none"),
				card.ability.extra.stacks,
			},
		}
	end,
	weight = 2.5,
})

local setabilityref = Card.set_ability
---@diagnostic disable-next-line: duplicate-set-field
function Card:set_ability(center, initial, delay_sprites)
	if
		center
		and self.config.center.key == "m_hnds_antimatter"
		and center.key ~= "m_hnds_antimatter"
		and self.ability
		and (self.ability.extra.stack_choice == nil or self.ability.extra.stack_choice == center.key)
	then
		if
			SMODS.pseudorandom_probability(self, "hnds_antimatter", self.ability.extra.base, self.ability.extra.odds)
		then
			self.getting_sliced = true
			G.E_MANAGER:add_event(Event({
				func = function()
					self:start_dissolve(G.C.DARK_EDITION)
				end,
			}))
		elseif center.set == "Enhanced" then
			if center.config.bonus then
				self.ability.bonus = (self.ability.bonus or 0) + center.config.bonus
			end
			if center.config.mult then
				self.ability.mult = (self.ability.mult or 0) + center.config.mult
			end
			if center.config.h_chips then
				self.ability.h_chips = (self.ability.h_chips or 0) + center.config.h_chips
			end
			if center.config.h_mult then
				self.ability.h_chips = (self.ability.h_mult or 0) + center.config.h_mult
			end
			if center.config.x_mult or center.config.Xmult then
				self.ability.x_mult = (self.ability.h_x_mult or 0) + (center.config.x_mult or center.config.Xmult)
			end
			if center.config.x_chips then
				self.ability.x_chips = (self.ability.x_chips or 0) + center.config.x_chips
			end
			if center.config.h_x_mult then
				self.ability.h_x_mult = (self.ability.h_x_mult or 0) + center.config.h_x_mult
			end
			if center.config.h_x_chips then
				self.ability.h_x_chips = (self.ability.h_x_chips or 0) + center.config.h_x_chips
			end
			if center.config.p_dollars then
				self.ability.p_dollars = (self.ability.p_dollars or 0) + center.config.p_dollars
			end
			if center.config.h_dollars then
				self.ability.h_dollars = (self.ability.h_dollars or 0) + center.config.h_dollars
			end
			if center.config.repetitions then
				self.ability.repetitions = (self.ability.repetitions or 0) + center.config.repetitions
			end
			if self.ability and self.ability.extra then
				self.ability.extra.base = self.ability.extra.base + 0
				self.ability.extra.stack_choice = center.key
				self.ability.extra.stacks = self.ability.extra.stacks + 1
			end
		end
	else
		setabilityref(self, center, initial, delay_sprites)
	end
end
