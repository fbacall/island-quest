if player.inventory.any? { |i| i.name == 'hammer' }
  start_dialogue('bridge_fix')
  entity.tile_id += 1
  done!
else
  start_dialogue('bridge_broken')
end
