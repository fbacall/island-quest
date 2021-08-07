chest = get_entity('treasure_chest')
if chest.tile_id == 97
  play_sound('open')
  chest.tile_id += 1
  wait
else
  ItemEntity.new('fuel', 197).interact
  done!
end