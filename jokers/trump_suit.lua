function HNDS.trump_suit()
    return G and G.GAME and G.GAME.current_round
        and G.GAME.current_round.hnds_trump_suit or "Spades"
end

function HNDS.reset_trump_suit()
    local choices = {}
    for _, suit in ipairs({ "Spades", "Hearts", "Clubs", "Diamonds" }) do
        if suit ~= HNDS.trump_suit() then choices[#choices + 1] = suit end
    end
    G.GAME.current_round.hnds_trump_suit = pseudorandom_element(choices, pseudoseed("hnds_trump_suit"))
end

local suit_frames = { Spades = 0, Hearts = 1, Clubs = 2, Diamonds = 3 }

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
    local x = 5 + (suit and (suit_frames[suit] or 0) or 0)
    local y = 7
    if sprite.atlas ~= atlas or not sprite.sprite_pos
        or sprite.sprite_pos.x ~= x or sprite.sprite_pos.y ~= y then
        sprite.atlas = atlas
        sprite:set_sprite_pos({ x = x, y = y })
    end
    return true
end

local function update_trump_suit_sprite(card, initial)
    if not card then return end
    local state = card.hnds_trump_suit_flip
    if in_collection(card) then
        if state and state.turned and card.facing == "back" then card:flip() end
        card.hnds_trump_suit_flip = nil
        card.hnds_trump_suit_suit = nil
        apply_sprite(card)
        return
    end
    local suit = HNDS.trump_suit()
    if state then
        state.target = suit
        apply_sprite(card, card.hnds_trump_suit_suit)
        return
    end
    if initial or not card.hnds_trump_suit_suit then
        if apply_sprite(card, suit) then card.hnds_trump_suit_suit = suit end
        return
    end
    if card.hnds_trump_suit_suit == suit then
        apply_sprite(card, suit)
        return
    end
    if card.facing ~= "front" or not G.E_MANAGER then
        if apply_sprite(card, suit) then card.hnds_trump_suit_suit = suit end
        return
    end
    state = { target = suit, game = G.GAME }
    card.hnds_trump_suit_flip = state
    G.E_MANAGER:add_event(Event({
        trigger = "after", delay = 0.15,
        func = function()
            if card.hnds_trump_suit_flip ~= state then return true end
            if card.removed or card.REMOVED or G.GAME ~= state.game or in_collection(card) then
                card.hnds_trump_suit_flip = nil
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
                    if card.hnds_trump_suit_flip ~= state then return true end
                    if not card.removed and not card.REMOVED and G.GAME == state.game then
                        local target = HNDS.trump_suit()
                        if in_collection(card) then
                            apply_sprite(card)
                            card.hnds_trump_suit_suit = nil
                        elseif apply_sprite(card, target) then
                            card.hnds_trump_suit_suit = target
                        end
                        if state.turned and card.facing == "back" then
                            card:flip()
                            play_sound("tarot2", 1, 0.6)
                            card:juice_up(0.3, 0.3)
                        end
                    end
                    card.hnds_trump_suit_flip = nil
                    return true
                end,
            }))
            return true
        end,
    }))
end

SMODS.Joker({
    key = "trump_suit",
    atlas = "Jokers", pos = { x = 5, y = 7 },
    rarity = 2, cost = 6, unlocked = true, discovered = false,
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    set_sprites = function(self, card) update_trump_suit_sprite(card, true) end,
    update = function(self, card) update_trump_suit_sprite(card) end,
    loc_vars = function(self, info_queue, card)
        local suit = HNDS.trump_suit()
        return { vars = { localize(suit, "suits_singular"), colours = { G.C.SUITS[suit] } } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card
            and not context.other_card.debuff and context.other_card:is_suit(HNDS.trump_suit()) then
            return { repetitions = 1, message = localize("k_again_ex"), card = card }
        end
    end,
    attributes = { "retrigger", "suits" },
})
