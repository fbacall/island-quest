if has_item?('hammer')
  if has_item?('nails')
    fade_out
    5.times do
      play_sound('footstep')
      wait
    end
    get_entity('bridge').tile_id += 1
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
