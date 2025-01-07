require("movement")

length = tonumber(arg[1])
for i=0,length do
move_to(0,i)
turtle.placeUp()
end
move_to(0,0)
