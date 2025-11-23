SMODS.Rank {
  key = 'creepycard',
  card_key = 'CREEPYCARD',
  shorthand = 'T',

  hc_atlas = 'creepyJ',
  lc_atlas = 'creepyJ',
  pos = { x = 0 },

  config = { xmult = 1.5 },

  straight_edge = false,
  next = { 'creepycard' },
  nominal = 0,
  face = false,
  in_pool = function(self, args) return not args.initial_deck end,
}