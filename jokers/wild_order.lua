function HNDS.wild_order_suit()
    return G and G.GAME and G.GAME.current_round
        and G.GAME.current_round.hnds_wild_order_suit or "Spades"
end

function HNDS.reset_wild_order_suit()
    local round = G.GAME.current_round
    local old = HNDS.wild_order_suit()
    local suits = {}
    for _, suit in ipairs({ "Spades", "Hearts", "Clubs", "Diamonds" }) do
        if suit ~= old then suits[#suits + 1] = suit end
    end
    round.hnds_wild_order_suit = pseudorandom_element(suits, pseudoseed("hnds_wild_order"))
end

function HNDS.wild_order_active()
    for _, joker in ipairs(G and G.jokers and G.jokers.cards or {}) do
        if not joker.debuff and not joker.REMOVED and not joker.removed
            and joker.config.center.key == "j_hnds_wild_order" then return true end
    end
    return false
end

function HNDS.wild_order_next_card(deck, discarded_only)
    if not HNDS.wild_order_active() then return nil end
    for i = #deck.cards, 1, -1 do
        local card = deck.cards[i]
        if not card.removed and not card.REMOVED
            and (not discarded_only or card.ability.discarded)
            and card:is_suit(HNDS.wild_order_suit()) then return card end
    end
end

local suit_frames = { Diamonds = 0, Hearts = 1, Clubs = 2, Spades = 3 }

local function in_collection(card)
    if card.area and card.area.config and card.area.config.collection then return true end
    for _, area in pairs(G and G.your_collection or {}) do
        if card.area == area then return true end
    end
    return not (G and G.STAGES and G.STAGE == G.STAGES.RUN)
end

local function apply_sprite(card, suit)
    local sprite = card and card.children and card.children.center
    if not (sprite and sprite.set_sprite_pos) then return false end
    local key = "hnds_Jokers"
    local atlas = SMODS.get_atlas and SMODS.get_atlas(key)
        or G.ASSET_ATLAS and G.ASSET_ATLAS[key]
    if not atlas then return false end
    local x = suit and (6 + (suit_frames[suit] or 3)) or 7
    local y = suit and 8 or 6
    if sprite.atlas ~= atlas or not sprite.sprite_pos
        or sprite.sprite_pos.x ~= x or sprite.sprite_pos.y ~= y then
        sprite.atlas = atlas
        sprite:set_sprite_pos({ x = x, y = y })
    end
    return true
end

local function update_wild_order_sprite(card, initial)
    if not card then return end
    local state = card.hnds_wild_order_flip
    if in_collection(card) then
        if state and state.turned and card.facing == "back" then card:flip() end
        card.hnds_wild_order_flip = nil
        card.hnds_wild_order_suit = nil
        apply_sprite(card)
        return
    end
    local suit = HNDS.wild_order_suit()
    if state then
        state.target = suit
        apply_sprite(card, card.hnds_wild_order_suit)
        return
    end
    if initial or not card.hnds_wild_order_suit then
        if apply_sprite(card, suit) then card.hnds_wild_order_suit = suit end
        return
    end
    if card.hnds_wild_order_suit == suit then
        apply_sprite(card, suit)
        return
    end
    if card.facing ~= "front" or not G.E_MANAGER then
        if apply_sprite(card, suit) then card.hnds_wild_order_suit = suit end
        return
    end
    state = { target = suit, game = G.GAME }
    card.hnds_wild_order_flip = state
    G.E_MANAGER:add_event(Event({
        trigger = "after", delay = 0.15,
        func = function()
            if card.hnds_wild_order_flip ~= state then return true end
            if card.removed or card.REMOVED or G.GAME ~= state.game or in_collection(card) then
                card.hnds_wild_order_flip = nil
                return true
            end
            if card.facing == "front" then
                card:flip()
                play_sound("card1", 1)
                card:juice_up(0.3, 0.3)
                state.turned = true
            end
            G.E_MANAGER:add_event(Event({
                trigger = "after", delay = 0.15,
                func = function()
                    if card.hnds_wild_order_flip ~= state then return true end
                    if not card.removed and not card.REMOVED and G.GAME == state.game then
                        local target = HNDS.wild_order_suit()
                        if in_collection(card) then
                            apply_sprite(card)
                            card.hnds_wild_order_suit = nil
                        elseif apply_sprite(card, target) then
                            card.hnds_wild_order_suit = target
                        end
                        if state.turned and card.facing == "back" then
                            card:flip()
                            play_sound("tarot2", 1, 0.6)
                            card:juice_up(0.3, 0.3)
                        end
                    end
                    card.hnds_wild_order_flip = nil
                    return true
                end,
            }))
            return true
        end,
    }))
end

SMODS.Joker({
    key = "wild_order",
    atlas = "Jokers",
    pos = { x = 7, y = 6 },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    set_sprites = function(self, card, front)
        update_wild_order_sprite(card, true)
    end,
    update = function(self, card, dt)
        update_wild_order_sprite(card)
    end,
    loc_vars = function(self, info_queue, card)
        local suit = HNDS.wild_order_suit()
        return { vars = { localize(suit, "suits_singular"), colours = { G.C.SUITS[suit] } } }
    end,
    attributes = { "draw", "suits" },
})
