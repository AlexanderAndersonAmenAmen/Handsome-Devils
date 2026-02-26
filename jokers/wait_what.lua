SMODS.Joker({
	key = "wait_what",
	atlas = "Jokers",
	pos = { x = 4, y = 4 },
	rarity = 1,
	cost = 2,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	config = { extra = { xmult = 4 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult } }
	end,
	-- Disguise logic: only hide as vanilla Joker when the card is in the shop.
	-- card.area is nil during card creation, so we also check the revealed flag
	-- to keep the disguise intact until purchase. Everywhere else (collection,
	-- joker slots, etc.) the real identity is shown.
	generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		local in_shop = card.area and card.area.config and card.area.config.type == 'shop'
		local disguised = in_shop and not (card.ability and card.ability.hnds_wait_what_revealed)
		local key = disguised and 'j_joker' or self.key
		local vars = disguised and { G.P_CENTERS.j_joker.config.mult } or self:loc_vars(info_queue, card).vars

		self.no_main_mod_badge = disguised

		full_UI_table.name = localize { type = 'name', key = key, set = 'Joker' }
		localize { type = 'descriptions', key = key, set = 'Joker', nodes = desc_nodes, vars = vars }
	end,
	set_card_type_badge = function(self, card, badges)
		badges[#badges + 1] = create_badge(localize('k_common'), G.C.CHIPS, G.C.WHITE, 1.2)
	end,
	-- Sprite control: use update (fires every frame) to swap sprites based on
	-- whether the card is currently in the shop. set_ability fires before the
	-- card is placed in an area, so it cannot reliably detect the shop.
	update = function(self, card, dt)
		local dominated_by_shop = card.area and card.area.config and card.area.config.type == 'shop'
		local revealed = card.ability and card.ability.hnds_wait_what_revealed
		local should_disguise = dominated_by_shop and not revealed
		local current_center = card.config and card.config.center
		local target_center = should_disguise and G.P_CENTERS.j_joker or G.P_CENTERS.j_hnds_wait_what
		if current_center ~= target_center then
			card:set_sprites(target_center)
		end
	end,
	-- On creation / load: always show the real sprite. The update callback
	-- will swap to the disguise once the card is placed in the shop.
	set_ability = function(self, card, initial, delay_sprites)
		card:set_sprites(G.P_CENTERS.j_hnds_wait_what)
	end,
	-- On purchase: mark as revealed and show real sprite
	add_to_deck = function(self, card, from_debuff)
		card.ability.hnds_wait_what_revealed = true
		card:set_sprites(G.P_CENTERS.j_hnds_wait_what)
	end,
	-- X4 Mult when scoring
	calculate = function(self, card, context)
		if context.joker_main then
			return { xmult = card.ability.extra.xmult }
		end
	end,
})
