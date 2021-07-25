if has_item?('machete')
  fade_out
  play_sound('bush_cut')
  wait
  get_entity('bush').tile_id += 1
  fade_in
  dialogue(:middle, "Chopped down the bush!")
  done!
else
  dialogue(:middle, "This bush is blocking the way...")
end
