HNDS.excommunicado_on_reset_blinds = function(only_slot)
	if not (G and G.GAME and next(SMODS.find_card('j_hnds_excommunicado'))) then return end

	G.GAME.hnds_excomm_boss_cycle = G.GAME.hnds_excomm_boss_cycle or {}
	G.GAME.hnds_excomm_selected = G.GAME.hnds_excomm_selected or {}
	G.GAME.hnds_excomm_locked = G.GAME.hnds_excomm_locked or {}

	local ante_key = (G.GAME.round_resets and G.GAME.round_resets.ante) or -1
	local selected_for_ante = G.GAME.hnds_excomm_selected[ante_key]
	local locked_for_ante = G.GAME.hnds_excomm_locked[ante_key] or {}
	G.GAME.hnds_excomm_locked[ante_key] = locked_for_ante

	-- Determine which slots are still upcoming (not yet defeated).
	-- blind_on_deck tells us what the player is about to face:
	--   'Small' → neither defeated yet
	--   'Big'   → Small already defeated
	--   'Boss'  → both Small and Big defeated
	local on_deck = G.GAME.blind_on_deck
	local small_alive = (on_deck == 'Small' or on_deck == nil) and not locked_for_ante.Small
	local big_alive = (on_deck == 'Small' or on_deck == 'Big' or on_deck == nil) and not locked_for_ante.Big

	-- If only_slot is specified, only touch that specific slot
	if only_slot then
		if only_slot ~= 'Small' then small_alive = false end
		if only_slot ~= 'Big' then big_alive = false end
	end

	local function is_excluded_boss(key, blind_cfg)
		if not blind_cfg then return true end
		if blind_cfg.showdown then return true end
		if blind_cfg.boss and blind_cfg.boss.showdown then return true end
		if blind_cfg.boss and blind_cfg.boss.min and blind_cfg.boss.max and
			blind_cfg.boss.min >= 8 and blind_cfg.boss.min == blind_cfg.boss.max and blind_cfg.boss.min % 8 == 0 then
			return true
		end
		local lowered_key = string.lower(tostring(key or ''))
		if string.find(lowered_key, 'showdown', 1, true) then return true end
		if string.find(lowered_key, 'final', 1, true) then return true end
		return false
	end

	local function pick_boss()
		if #G.GAME.hnds_excomm_boss_cycle == 0 then
			local pool = {}
			for k, v in pairs(G.P_BLINDS or {}) do
				if v and v.boss and not is_excluded_boss(k, v) then
					pool[#pool + 1] = k
				end
			end
			pseudoshuffle(pool, pseudoseed('hnds_excomm_cycle'))
			G.GAME.hnds_excomm_boss_cycle = pool
		end
		return table.remove(G.GAME.hnds_excomm_boss_cycle, 1)
	end

	if G.GAME.round_resets and G.GAME.round_resets.blind_choices then
		if selected_for_ante then
			if selected_for_ante.Small and not locked_for_ante.Small then
				local cfg = G.P_BLINDS[selected_for_ante.Small]
				if not cfg or is_excluded_boss(selected_for_ante.Small, cfg) then
					selected_for_ante.Small = nil
				end
			end
			if selected_for_ante.Big and not locked_for_ante.Big then
				local cfg = G.P_BLINDS[selected_for_ante.Big]
				if not cfg or is_excluded_boss(selected_for_ante.Big, cfg) then
					selected_for_ante.Big = nil
				end
			end
		end

		if not selected_for_ante then
			selected_for_ante = {}
			if small_alive then selected_for_ante.Small = pick_boss() end
			if big_alive then selected_for_ante.Big = pick_boss() end
			G.GAME.hnds_excomm_selected[ante_key] = selected_for_ante
		else
			if small_alive and not selected_for_ante.Small then selected_for_ante.Small = pick_boss() end
			if big_alive and not selected_for_ante.Big then selected_for_ante.Big = pick_boss() end
		end

		-- Only overwrite blind choices for slots that haven't been defeated or locked
		if small_alive and selected_for_ante.Small and G.P_BLINDS[selected_for_ante.Small] then
			G.GAME.round_resets.blind_choices.Small = selected_for_ante.Small
		end
		if big_alive and selected_for_ante.Big and G.P_BLINDS[selected_for_ante.Big] then
			G.GAME.round_resets.blind_choices.Big = selected_for_ante.Big
		end
	end
end

HNDS.excommunicado_on_set_blind = function(blind_obj, blind)
	if not (blind_obj and G and G.GAME and G.GAME.round_resets) then return end
	if not next(SMODS.find_card('j_hnds_excommunicado')) then return end

	G.GAME.current_round = G.GAME.current_round or {}
	G.GAME.current_round.hnds_excomm_skip_ante = nil

	local slot = (G.GAME and G.GAME.blind_on_deck) or blind
	if slot == 'Boss' then
		G.GAME.current_round.hnds_excomm_slot = nil
		G.GAME.current_round.hnds_excomm_ante_at_set = nil
		return
	end
	if slot ~= 'Small' and slot ~= 'Big' then
		local keys = {
			G.GAME.round_resets.ante,
			G.GAME.round_resets.blind_ante,
		}
		for _, k in ipairs(keys) do
			local selected = G.GAME.hnds_excomm_selected and G.GAME.hnds_excomm_selected[k or -1]
			if selected then
				if selected.Small == blind then slot = 'Small' end
				if selected.Big == blind then slot = 'Big' end
			end
		end
		if G.GAME.round_resets and G.GAME.round_resets.blind_choices then
			if G.GAME.round_resets.blind_choices.Small == blind then slot = 'Small' end
			if G.GAME.round_resets.blind_choices.Big == blind then slot = 'Big' end
		end
	end
	if slot ~= 'Small' and slot ~= 'Big' then
		if G.GAME.current_round then
			G.GAME.current_round.hnds_excomm_slot = nil
			G.GAME.current_round.hnds_excomm_ante_at_set = nil
			G.GAME.current_round.hnds_excomm_skip_ante = nil
		end
		return
	end

	G.GAME.current_round = G.GAME.current_round or {}
	G.GAME.current_round.hnds_excomm_slot = slot
	G.GAME.current_round.hnds_excomm_ante_at_set = G.GAME.round_resets and G.GAME.round_resets.ante
end

SMODS.Joker({
	key = "excommunicado",
	atlas = "Jokers",
	pos = { x = 3, y = 4 },
	rarity = 3,
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	demicoloncompat = true,
	eternal_compat = true,
	perishable_compat = true,
	-- When Excommunicado enters the deck (Judgement, tags, etc.),
	-- immediately swap upcoming blinds if we're in blind selection.
	add_to_deck = function(self, card, from_debuff)
		if not from_debuff and G and G.GAME and G.GAME.round_resets
			and G.GAME.round_resets.blind_choices
			and HNDS and HNDS.excommunicado_on_reset_blinds then
			HNDS.excommunicado_on_reset_blinds()
		end
	end,
	calculate = function(self, card, context)
		if context.end_of_round and context.main_eval and G.GAME and G.GAME.round_resets and G.GAME.current_round then
			local slot = G.GAME.current_round.hnds_excomm_slot
			local ante_at_set = G.GAME.current_round.hnds_excomm_ante_at_set
			if context.beat_boss and (slot == 'Small' or slot == 'Big') then
				G.GAME.current_round.hnds_excomm_skip_ante = true
			end
			if (slot == 'Small' or slot == 'Big') and ante_at_set and G.GAME.round_resets.ante and G.GAME.round_resets.ante > ante_at_set then
				G.GAME.round_resets.ante = ante_at_set
				if G.GAME.round_resets.blind_ante then
					G.GAME.round_resets.blind_ante = ante_at_set
				end
			end
		end
		-- Blind win: add a random tag
		if context.end_of_round and context.main_eval then
			add_tag(HNDS.poll_tag('hnds_excommunicado'))
			card:juice_up()
			return { message = localize('k_hnds_plus_tag'), colour = G.C.GREEN }
		end
	end,
})
