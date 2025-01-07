current_x = 0
current_y = 0
dir_x = 0
dir_y = 1

function turnLeft()
    tmp_dx = dir_x
    tmp_dy = dir_y
    dir_x = -tmp_dy
    dir_y = tmp_dx
    turtle.turnLeft()
end

function turnRight()
    tmp_dx = dir_x
    tmp_dy = dir_y
    dir_x = tmp_dy
    dir_y = -tmp_dx
    turtle.turnRight()
end

function set_dir(dx,dy)
    while dx ~= dir_x or dy ~= dir_y do
        turnLeft()
    end
end
 
function move_back_to ( y )
    while dir_y ~= -1 do
        turnLeft()
    end
    while current_y > y do
        turtle.dig()
        res = turtle.forward()
        if res then
            current_y = current_y - 1
        end
    end
end
 
function move_forward_to ( y )
    while dir_y ~= 1 do
        turnLeft()
    end
    while current_y < y do
        turtle.dig()
        res = turtle.forward()
        if res then
            current_y = current_y + 1
        end
    end 
end
 
function move_left_to ( x )
    while dir_x ~= -1 do
        turnLeft()
    end
    while current_x > x do
        turtle.dig()
        res = turtle.forward()
        if res then 
            current_x = current_x - 1
        end
    end
end
 
function move_right_to ( x )
    while dir_x ~= 1 do
        turnRight()
    end
    while current_x < x do
        turtle.dig()
        res = turtle.forward()
        if res then
            current_x = current_x + 1
        end
    end
end
 
function move_to ( x , y )
    if x > current_x then
        move_right_to(x)
    end
    if x < current_x then
        move_left_to(x)
    end
    if y > current_y then
        move_forward_to(y)
    end
    if y < current_y then
        move_back_to(y)
    end
end

current_z = 0
function move_z_to(z)
    while current_z < z do
        if not turtle.up() then
            turtle.digUp()
        else
            current_z = current_z + 1
        end
    end
    while current_z > z do
        if not turtle.down() then
            turtle.digDown()
        else
            current_z = current_z - 1
        end
    end
end
