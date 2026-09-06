extern Image puzzle_mask;

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    vec4 mask = Texel(puzzle_mask, texture_coords);
    return vec4(tex.rgb * colour.rgb, tex.a * mask.a * colour.a);
}
