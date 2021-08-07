door = get_entity('house_door')
witch = get_entity('witch')
stop(player)
move(player, door.x, door.y - 32)
move(player, door.x, door.y - 28)
play_sound('open')
door.tile_id += 1
witch.visible = true
move(witch, door.x, door.y - 8)

def player_name
  ['Wilfred', 'Milton', 'Matthew', 'Maxwell' ,'Alfred', 'Francis', 'Mango', 'Francis'].sample
end

if has_item?('snorkel')
  dialogue(:top, "#{player_name}! Have you explored the north-eastern islet yet?", witch)
elsif has_item?('ring')
  dialogue(:bottom, "I found this ring.", player)
  dialogue(:top, "Gee whiz! My old ring! Thanks a bunch, #{player_name}!", witch)
  remove_item('ring')
  dialogue(:top, "Hmm, let me see if I have something for you.", witch)
  clear_dialogue
  move(witch, door.x, door.y)
  witch.visible = false
  wait(120)
  witch.visible = true
  move(witch, door.x, door.y - 8)
  dialogue(:top, "This'll let you swim out into the deeper water, who knows what you'll find out there!", witch)
  ItemEntity.new('snorkel', 181).interact
elsif has_item?('pickaxe')
  if has_item?('spade')
    dialogue(:top, "Nothing like a refreshing swim, right #{player_name}?", witch)
  elsif has_item?('flippers')
    dialogue(:top, "#{player_name}! So you found some flippers, huh? Why not go for a swim?", witch)
  else
    dialogue(:top, "Howdy #{player_name}! Did you find some rocks to bash yet?", witch)
    dialogue(:bottom, "Not yet.", player)
    dialogue(:top, "Well, what are you waiting for?!", witch)
  end
else
  dialogue(:bottom, "Hi.", player)
  dialogue(:top, "Well, who do we have here?", witch)
  dialogue(:bottom, "My name's Manfred von Mannheim, I woke up on the beach without a clue as to how I got here.", player)
  dialogue(:top, "#{player_name} is it? Oh deary me. That happens sometimes.", witch)
  dialogue(:bottom, "Do you know how I can get back home?", player)
  dialogue(:top, "Look, #{player_name}, whenever I find myself in a pickle, I take my old pickaxe and go and whack some rocks.", witch)
  dialogue(:top, "Really clears the mind!", witch)
  dialogue(:bottom, "Umm..", player)
  dialogue(:top, "Give it a try!", witch)
  ItemEntity.new('pickaxe', 182).interact
end

move(witch, door.x, door.y)
witch.visible = false
play_sound('open')
door.tile_id -= 1
