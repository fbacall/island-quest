play_sound('open')
get_entity('treasure_chest').tile_id += 1
wait
dialogue(:middle, "Opened the chest..")
done!