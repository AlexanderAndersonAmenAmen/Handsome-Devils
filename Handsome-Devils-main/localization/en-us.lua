return {
    descriptions = {
        -- this key should match the set ("object type") of your object,
        -- e.g. Voucher, Tarot, or the key of a modded consumable type
        Joker = {
            -- this should be the full key of your object, including any prefixes
            j_hnds_com = {
                name = 'Color of Madness',
                text = {
                    'If {C:attention}first hand{} of round has',
                    'a scoring card of each {C:attention}suit{},',
                    'enhances scored cards',
                    'into {C:attention}Wild Cards{}',
                }
                -- only needed when this object is locked by default
                -- unlock = {
                    --'This is a condition',
                    --'for unlocking this card',
                --},
            },
            j_hnds_occ = {
                name = 'Occultist',
                text = {
                    'If {C:attention}first hand{} of round has',
                    'a scoring card of each {C:attention}suit{},',
                    'create a {C:tarot}Charm{}, {C:planet}Meteor{}',
                    'or {C:spectral}Etehreal{} {C:attention}Tag{}',
                }
            },
            j_hnds_bsplit = {
                name = 'Banana Split',
                text = {
                    '{X:mult,C:white}X#1#{} Mult,',
                    '{C:green}#2# in 6{} chance to {C:attention}Duplicate{}',
                    'this Joker at end of round',
                    '{C:inactive}(Must have room){}',
                }
            },
            j_hnds_head_of_medusa = {
                name = 'Head of Medusa',
                text = {
                    'This Joker gains {X:mult,C:white}X#2#{} Mult',
                    'per scoring {C:attention}face card{} played,',
                    'enhances scored face cards',
                    'into {C:attention}Stone Cards{}',
                    '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
                }
            },
        },
        Spectral={},
        Voucher={},
    },
    misc = {
        dictionary = {
            k_hnds_petrified = "Petrified!"
        }
    }
}
