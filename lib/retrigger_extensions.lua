-- Retriggers are requests, not charges. Commit only after a useful result.
local unpack_values = table.unpack or unpack
local function key(c) return c and c.config and c.config.center and c.config.center.key end
local function live(c) return c and not c.debuff and not c.removed and not c.REMOVED and not c.getting_sliced end
local pending = setmetatable({}, {__mode = 'k'})
local snapshots = setmetatable({}, {__mode = 'k'})
local in_flight = setmetatable({}, {__mode = 'k'})
HNDS.retrigger_charge_managed = true

function HNDS.retrigger_neighbor(source, direction)
    local cards = G.jokers.cards
    for i, c in ipairs(cards) do
        if c == source then
            i = i + direction
            while cards[i] and key(cards[i]) == 'j_hnds_handsome' and live(cards[i]) do i = i + direction end
            return cards[i]
        end
    end
end

local function blocked(target, ctx)
    local k = key(target)
    if ctx.check or ctx.retrigger_joker or ctx.retrigger_joker_check or ctx.modify_scoring_hand then return true end
    if SMODS.can_context_retrigger and not SMODS.can_context_retrigger(ctx) then return true end
    if k == 'j_rocket' and not ctx.hnds_cashout_payouts then return true end
    if k == 'j_invisible' and not ctx.selling_self then return true end
    if k == 'j_jodiac' and not (ctx.selling_self or ctx.selling_card and ctx.card == target) then return true end
    if ctx.hnds_acquisition then return ctx.hnds_acquisition ~= target end
    if k == 'j_hnds_death' or k == 'j_hnds_demented' or k == 'j_hnds_time_fcked_joker'
        or k == 'j_hnds_arthur' or k == 'j_hnds_handsome' or k == 'j_hnds_walking_joke'
        or k == 'j_hnds_coffee_break' or k == 'j_hnds_jester_in_yellow' then return true end
    if k == 'j_hnds_public_nuisance' then return not ctx.after end
    if k == 'j_hnds_war' or k == 'j_hnds_color_of_madness' or k == 'j_hnds_krusty'
        or k == 'j_hnds_creepy' then return true end
    if k == 'j_hnds_fun_pilled' and (ctx.selling_self or ctx.selling_card) then return true end
    if k == 'j_hnds_big_d' and ctx.setting_blind then return true end
end

function HNDS.request_safe_retriggers(resource, source, context, count, kind)
    local ctx, target = context.other_context, context.other_card
    if not ctx or SMODS.no_resolve or in_flight[resource] or not live(resource) or not live(target) or blocked(target, ctx) then return end
    if ctx.hnds_acquisition and kind == 'joke' then return end -- acquisition is Coffee-only
    local effect = context.other_ret and context.other_ret.jokers
    if effect and effect.no_retrigger then return end
    count = math.max(0, math.floor(count or 0))
    if count == 0 then return end
    local batch = pending[ctx]
    if not batch then batch = {}; pending[ctx] = batch end
    batch[target] = batch[target] or {}
    batch[target][source] = {resource = resource, kind = kind, remaining = count}
    return {repetitions = count, card = source, message = localize('k_again_ex')}
end

local function commit(request)
    if not request or request.remaining <= 0 then return end
    request.remaining = request.remaining - 1
    if request.kind == 'free' then return end
    local center = request.resource.config.center
    if center.hnds_spend_limited_retrigger then center:hnds_spend_limited_retrigger(request.resource) end
end

local function state_signature(c)
    local seen, out = {}, {}
    local function visit(t, prefix, depth)
        if type(t) ~= 'table' or seen[t] or depth > 4 then return end
        seen[t] = true
        for k,v in pairs(t) do
            if type(v) == 'number' then out[#out+1] = prefix .. tostring(k) .. '=' .. tostring(v)
            elseif type(v) == 'table' then visit(v, prefix .. tostring(k) .. '.', depth+1) end
        end
    end
    visit(c.ability, '', 0); table.sort(out)
    return table.concat(out, ';')
end
local function economy_signature()
    local g, r = G.GAME, G.GAME.current_round or {}
    return table.concat({tostring(g.dollars), tostring(r.discards_left), tostring(r.hands_left),
        tostring(#(g.tags or {})), tostring(g.consumeable_buffer), tostring(g.joker_buffer)}, ':')
end
local function affected_signature()
    local out, seen = {}, {}
    for _, area in ipairs({G.jokers, G.consumeables, G.hand, G.play}) do
        for _, c in ipairs(area and area.cards or {}) do
            if not seen[c] then
                seen[c] = true
                out[#out+1] = tostring(c) .. ':' .. state_signature(c)
            end
        end
    end
    for name, hand in pairs(G.GAME.hands or {}) do out[#out+1] = name .. ':' .. tostring(hand.level) end
    table.sort(out)
    return table.concat(out, '|')
end
local function useful(ret)
    if type(ret) ~= 'table' then return false end
    if ret.hnds_retrigger_success then return true end
    for _, k in ipairs({'dollars','p_dollars','chips','chip_mod','mult','mult_mod','h_mult','level_up','repetitions'}) do
        if ret[k] and ret[k] ~= 0 then return true end
    end
    for _, k in ipairs({'xmult','x_mult','Xmult_mod','xchips','x_chips'}) do
        if ret[k] and ret[k] ~= 0 and ret[k] ~= 1 then return true end
    end
    return false
end
local function message(text, colour) return {message = localize(text), colour = colour or G.C.FILTER, hnds_retrigger_success = true} end
local function snapshot(card, ctx)
    snapshots[ctx] = snapshots[ctx] or {}
    local s = snapshots[ctx][card]
    if not s then s = {}; snapshots[ctx][card] = s end
    return s
end
local function free_joker_slots(selling)
    local used = #G.jokers.cards + (G.GAME.joker_buffer or 0)
    if selling and selling.area == G.jokers then used = used - 1 end
    return math.max(0, G.jokers.config.card_limit - used)
end

function HNDS.queue_acquisition_retrigger(card)
    local game = G.GAME
    G.E_MANAGER:add_event(Event({trigger='after',delay=0,func=function()
        if G.GAME == game and live(card) and card.area == G.jokers then
            SMODS.calculate_context({hnds_acquisition = card})
        end
        return true
    end}))
end
function HNDS.emit_conquest_retrigger(blind)
    SMODS.calculate_context({hnds_conquest_win = blind})
end

local calculate_ref = Card.calculate_joker
local function calculate(card, ctx, ...)
    local k, extra = key(card), card.ability.extra
    local s = snapshot(card, ctx)
    local repeat_call = ctx.retrigger_joker and true or false
    if ctx.hnds_acquisition then
        if ctx.hnds_acquisition ~= card or ctx.blueprint or not live(card) then return end
        if not repeat_call then return message('k_upgrade_ex') end
        if k == 'j_hnds_bizzare_joker' then
            if HNDS.bizarre_extra_child(card) then return message('k_plus_joker') end
        elseif k == 'j_hnds_headless_joker' then
            if HNDS.add_jack_of_lanterns(card, extra.owner_id) then return message('k_hnds_head_added') end
        elseif k == 'j_hnds_ms_fortune' then
            local gain = tonumber(extra.sell_gain) or 15
            G.GAME.hnds_ms_fortune_sell_bonus = (G.GAME.hnds_ms_fortune_sell_bonus or 0) + gain
            HNDS.ms_fortune_sync_all()
            return message('k_val_up', G.C.MONEY)
        end
        return
    end
    if ctx.hnds_conquest_win then
        if k ~= 'j_hnds_conquest' or ctx.blueprint or not live(card) then return end
        if repeat_call then extra.hnds_retrigger_xmult = (extra.hnds_retrigger_xmult or 0) + (extra.xmult_gain or 0.25) end
        return message('k_upgrade_ex', G.C.MULT)
    end
    if ctx.hnds_energized_score then
        if k ~= 'j_hnds_energized' or ctx.blueprint or not live(card) then return end
        if not repeat_call then return message('k_again_ex') end
        local held, scoring = ctx.hnds_energized_score.card, ctx.hnds_energized_score.context
        if not live(held) or held.area ~= G.hand then return end
        local old = HNDS.energized_retrigger_scoring
        HNDS.energized_retrigger_scoring = true
        local clone = {}; for a,b in pairs(scoring) do clone[a]=b end
        local ok, err = pcall(SMODS.score_card, held, clone)
        HNDS.energized_retrigger_scoring = old
        if not ok then error(err) end
        return message('k_again_ex')
    end
    if k == 'j_invisible' and ctx.selling_self and not ctx.blueprint then
        if (card.ability.invis_rounds or 0) < card.ability.extra or not live(card) then return end
        if not repeat_call then
            local pool = {}
            for _, c in ipairs(G.jokers.cards) do
                if c ~= card and not c.removed and not c.REMOVED and not c.getting_sliced
                    and not (c.edition and c.edition.type == 'mp_phantom') then pool[#pool+1]=c end
            end
            if #pool == 0 or free_joker_slots(card) <= 0 then return end
            s.chosen = pseudorandom_element(pool, pseudoseed('invisible'))
        end
        if not s.chosen or s.chosen.removed or s.chosen.REMOVED or free_joker_slots(card) <= 0 then return end
        local copied = copy_card(s.chosen, nil, nil, nil, s.chosen.edition and s.chosen.edition.negative)
        if not copied then return end
        if copied.ability.invis_rounds then copied.ability.invis_rounds=0 end
        copied:add_to_deck(); G.jokers:emplace(copied)
        return message('k_duplicated_ex')
    end
    if k == 'j_hnds_art' and ctx.selling_self and not ctx.blueprint then
        if repeat_call then
            if not s.tag or not G.P_TAGS[s.tag] or HNDS.is_tag_banned(s.tag) then return end
            local tag = HNDS.poll_tag('hnds_art_repeat', {s.tag})
            if tag then add_tag(tag); return message('k_hnds_plus_tag') end
            return
        end
        local result = HNDS.pack(calculate_ref(card, ctx, ...))
        s.tag = card.ability.hnds_art_tag
        return unpack_values(result,1,result.n)
    end
    if k == 'j_jodiac' and (ctx.selling_self or ctx.selling_card and ctx.card == card) and not ctx.blueprint then
        if repeat_call then
            if not s.reward then return end
            for hand in pairs(G.GAME.hands) do SMODS.smart_level_up_hand(card, hand, true, s.levels) end
            return message('k_upgrade_ex', G.C.CHIPS)
        end
        local already = extra.reward_given
        local result=HNDS.pack(calculate_ref(card,ctx,...))
        s.reward = not already and extra.reward_given; s.levels=extra.upgrade_levels or 2
        return unpack_values(result,1,result.n)
    end
    if k == 'j_hnds_public_nuisance' and ctx.after and not ctx.blueprint then
        if repeat_call then return s.money and {dollars=s.money} or nil end
        local result=HNDS.pack(calculate_ref(card,ctx,...));s.money=type(result[1])=='table' and result[1].dollars
        return unpack_values(result,1,result.n)
    end
    if k == 'j_hnds_water_slide' and ctx.pre_discard and not ctx.blueprint then
        if repeat_call then
            if not s.hit then return end
            ease_discard(extra.discards or 1)
            return message('k_hnds_water_slide_discard', G.C.RED)
        end
        local result=HNDS.pack(calculate_ref(card,ctx,...));s.hit=result[1]~=nil
        return unpack_values(result,1,result.n)
    end
    if k == 'j_hnds_head_of_medusa' and ctx.end_of_round and ctx.individual then
        if repeat_call then
            if not s.gain or s.gain <= 0 then return end
            extra.x_mult = extra.x_mult + s.gain
            return message('k_upgrade_ex', G.C.MULT)
        end
        local before=extra.x_mult
        local result=HNDS.pack(calculate_ref(card,ctx,...));s.gain=extra.x_mult-before
        return unpack_values(result,1,result.n)
    end
    if k == 'j_hnds_meme' and ctx.before and not ctx.blueprint then
        if repeat_call then
            if not s.gain or s.gain <= 0 then return end
            extra.chips=extra.chips+s.gain
            return message('k_upgrade_ex',G.C.CHIPS)
        end
        local before=extra.chips
        local result=HNDS.pack(calculate_ref(card,ctx,...));s.gain=extra.chips-before
        return unpack_values(result,1,result.n)
    end
    if k == 'j_hnds_spaghettified_joker' and ctx.end_of_round and ctx.main_eval and not ctx.blueprint then
        if repeat_call then
            local data=s.hand and G.GAME.hands[s.hand]
            if not s.stole or not data or data.level<=0 then return end
            local chips,mult=data.l_chips or 0,data.l_mult or 0
            if chips==0 and mult==0 then return end
            level_up_hand(card,s.hand,nil,-1)
            extra.chips=(extra.chips or 0)+chips;extra.mult=(extra.mult or 0)+mult
            return message('k_hnds_spaghettified')
        end
        s.hand=extra.last_hand
        local result=HNDS.pack(calculate_ref(card,ctx,...));s.stole=result[1]~=nil
        return unpack_values(result,1,result.n)
    end
    return calculate_ref(card,ctx,...)
end

function Card:calculate_joker(ctx,...)
    if type(ctx)~='table' or SMODS.no_resolve then return calculate_ref(self,ctx,...) end
    if not live(self) then return end
    local batch = pending[ctx]
    local request = batch and batch[self] and batch[self][ctx.retrigger_joker]
    if request then
        local resource=request.resource
        if request.remaining<=0 or not live(resource) or not live(self) then return end
        local available=request.kind=='joke' and resource.ability.extra.jokes or resource.ability.extra.sips
        if request.kind~='free' and (available or 0)<=0 then return end
        -- A held-card scoring retrigger can cause nested Joker evaluation.
        if in_flight[resource] then return end
        in_flight[resource]=true
    end
    local before=request and affected_signature()
    local economy=request and economy_signature()
    local jokers,consumables,playing
    if request then jokers,consumables,playing=#G.jokers.cards,#G.consumeables.cards,#(G.playing_cards or {}) end
    local result=HNDS.pack(pcall(calculate,self,ctx,...))
    if request then in_flight[request.resource]=nil end
    if not result[1] then error(result[2]) end
    if request then
        local success=useful(result[2]) or before~=affected_signature()
            or economy~=economy_signature()
            or #G.jokers.cards>jokers or #G.consumeables.cards>consumables or #(G.playing_cards or {})>playing
        -- An animation/triggered flag alone is not proof of a useful change.
        if success then commit(request) else request.remaining=0;return end
    end
    return unpack_values(result,2,result.n)
end

function HNDS.emit_energized_retriggers(held, scoring_context)
    if HNDS.energized_retrigger_scoring then return end
    SMODS.calculate_context({hnds_energized_score={card=held,context=scoring_context}})
end
