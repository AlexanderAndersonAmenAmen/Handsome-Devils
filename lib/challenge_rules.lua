_G.HNDS_CHALLENGE_RULES_LOADED = true


function HNDS.is_challenge(key)
	return G and G.GAME and G.GAME.challenge == 'c_hnds_'..key
end


	if G and G.FUNCS and type(G.FUNCS.cash_out) == 'function' and not G.FUNCS._hnds_wrapped_cash_out then
		G.FUNCS._hnds_wrapped_cash_out = true
		local cash_out_ref = G.FUNCS.cash_out
		function G.FUNCS.cash_out(e, delay_seconds, ...)
		if not HNDS.is_challenge('dark_ritual') then
			return cash_out_ref(e, delay_seconds, ...)
		end

		stop_use()
		if G.round_eval then
			e.config.button = nil
			G.round_eval.alignment.offset.y = G.ROOM.T.y + 15
			G.round_eval.alignment.offset.x = 0
			G.deck:shuffle('cashout'..G.GAME.round_resets.ante)
			G.deck:hard_set_T()
			delay(0.3)
			G.E_MANAGER:add_event(Event({
				trigger = 'immediate',
				func = function()
					if G.round_eval then
						G.round_eval:remove()
						G.round_eval = nil
					end
					G.GAME.current_round.jokers_purchased = 0
					G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
					G.GAME.current_round.hands_left = (math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands))

					G.STATE = G.STATES.BLIND_SELECT
					G.STATE_COMPLETE = false
					return true
				end
			}))
			ease_dollars(G.GAME.current_round.dollars)
			G.E_MANAGER:add_event(Event({
				func = function()
					G.GAME.previous_round.dollars = G.GAME.dollars
					return true
				end
			}))
			play_sound('coin7')
			G.VIBRATION = G.VIBRATION + 1
		end
		return
	end
end


function HNDS.try_devils_round_curse(card)
	if not HNDS.is_challenge('devils_round') then return end
	if not (card and card.config and card.config.center and card.config.center.set == 'Joker') then return end
	if card.ability and card.ability.hnds_eternal_copy_created then return end
	if not (apply_curse and type(apply_curse) == 'function') then return end
	apply_curse(card)
end

