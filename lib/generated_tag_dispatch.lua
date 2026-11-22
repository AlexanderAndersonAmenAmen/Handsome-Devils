-- add_tag only inserts HUD/state; the vanilla immediate pass normally runs
-- at blind selection. Tags created by Jokers mid-round need their own pass.
-- Never force shop/round-start/pack tags outside their native context.
local add_ref = add_tag
function add_tag(tag, ...)
    local loading = tag and tag.from_load
    local result = HNDS.pack(add_ref(tag, ...))
    local game = G and G.GAME
    local api = HNDS.mp_backend and HNDS.mp_backend()
    local spectator = api and api.SPECTATOR
    if spectator and (spectator.is_spectating or spectator.is_spectator_role) then
        return (table.unpack or unpack)(result, 1, result.n)
    end
    local immediate = tag and ((tag.config and tag.config.type == 'immediate')
        or tag.key == 'tag_hnds_mystery_tag' or tag.key == 'tag_hnds_extinction_tag')
    if not loading and game and immediate and not tag.triggered and G.E_MANAGER then
        G.E_MANAGER:add_event(Event({
            blocking = false,
            func = function()
                if G.GAME ~= game or tag.triggered then return true end
                for _, owned in ipairs(game.tags or {}) do
                    if owned == tag then
                        tag:apply_to_run({type = 'immediate'})
                        break
                    end
                end
                return true
            end,
        }))
    end
    return (table.unpack or unpack)(result, 1, result.n)
end
