if has_item?('hammer')
  if has_item?('nails')
    fade_out
    start_dialogue('bridge_fix')
    get_entity('bridge').tile_id = 146
    fade_in
    dialogue(:middle, "Fixed the bridge!")
    done!
  else
    dialogue(:bottom, "Hmm, I could fix this if I had some nails.", player)
  end
elsif has_item?('nails')
  dialogue(:bottom, "Now I need a hammer.", player)
else
  dialogue(:bottom, "Oh dear, the bridge is broken!", player)
end
