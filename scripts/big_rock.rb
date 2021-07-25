if has_item?('pickaxe')
  fade_out
  play_sound('bush_cut')
  wait
  get_entity('big_rock').tile_id += 1
  fade_in
  dialogue(:middle, "Destroyed the rock!")
  done!
else
  dialogue(:middle, "This big rock is blocking the way...")
end
