length = tonumber(arg[1])

if length == nil then
    print("set length please")
    exit()
end
if turtle.getFuelLevel() <= (3*length) then
    print("not enough fuel")
end

require("movement")

for i=0,length do
    move_to(0,i)
    turtle.placeDown()
    turtle.turnLeft()
    turtle.place()
    turtle.turnLeft()
    turtle.place()
    turtle.dig()
    turtle.turnLeft()
    turtle.place()
    while not turtle.up() do turtle.digUp() end
    turtle.placeUp()
    turtle.place()
    turtle.turnRight()
    turtle.place()
    turtle.dig()
    turtle.turnRight()
    turtle.place()
    turtle.turnRight()
    turtle.down()
end

move_to(0,0)
