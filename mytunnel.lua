length = tonumber(arg[1])
if length == nil then
    print("set length please")
    exit()
end
if turtle.getFuelLevel() <= (3*length) then
    print("not enough fuel")
end
current = 0
while current < length do
    res = turtle.dig()
    if not res then break end
    res = turtle.forward()
    if not res then break end
    current = current + 1
    res = turtle.digUp()
    if not res then break end
end
turtle.turnLeft()
turtle.turnLeft()
while current > 0 do
    turtle.dig()
    if turtle.forward() then
        current = current - 1
    end
end
