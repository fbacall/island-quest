if has_item?('spade')
  fade_out
  play_sound('bush_cut')
  wait
  get_entity('buried_treasure').tile_id += 1
  fade_in
  dialogue(:middle, "Dug up the treasure!")
  done!
else
  dialogue(:middle, "X marks the spot...")
end
