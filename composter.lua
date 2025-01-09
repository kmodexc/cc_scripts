while true do
    for i=1,16 do
        turtle.select(i)
        while turtle.getItemCount(i) > 0 do
            if not turtle.place() then
                turtle.turnLeft()
                turtle.drop()
                turtle.turnRight()
        end
    end
    turtle.turnLeft()
    turtle.turnLeft()
    while turtle.suck() do end
    turtle.turnLeft()
    turtle.turnLeft()
end
    