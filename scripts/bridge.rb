if player.inventory.any? { |i| i.name == 'hammer' }
  fade_out
  start_dialogue('bridge_fix')
  entity.tile_id += 1
  fade_in
  done!
else
  start_dialogue('bridge_broken')
end
