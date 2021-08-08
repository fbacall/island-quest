if has_item?('spade')
  fade_out
  play_sound('bush_cut')
  wait
  get_entity('buried_treasure').tile_id += 1
  fade_in
  dialogue(:middle, "Dug up the treasure!")
  dialogue(:bottom, "Wow, a shiny gold ring!", player)
  clear_dialogue
  ItemEntity.new('ring', tile_id: 214).interact
  done!
else
  dialogue(:middle, "X marks the spot...")
end
