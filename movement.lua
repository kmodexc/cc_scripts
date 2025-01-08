current_x = 0
current_y = 0
dir_x = 0
dir_y = 1
dx_gps = 0
dy_gps = 0

function rotate_vec_left(x,y)
    tmp_dx = x
    tmp_dy = y
    x = -tmp_dy
    y = tmp_dx
    return x,y
end

function rotate_vec_right(x,y)
    tmp_dx = x
    tmp_dy = y
    x = tmp_dy
    y = -tmp_dx
    return x,y
end

function turnLeft()
    dir_x,dir_y = rotate_vec_left(dir_x,dir_y)
    dx_gps,dy_gps = rotate_vec_left(dx_gps,dy_gps)
    turtle.turnLeft()
end

function turnRight()
    dir_x,dir_y = rotate_vec_right(dir_x,dir_y)
    dx_gps,dy_gps = rotate_vec_right(dx_gps,dy_gps)
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

function init_gps()
    if dx_gps ~= 0 or dy_gps ~= 0 then
        return
    end
    print("init gps")
    x1,y1,z1 = gps.locate()
    while true do
        if turtle.forward() then
            x2,y2,z2 = gps.locate()
            dx_gps = x2 - x1
            dy_gps = y2 - y1            
        end
    end
    print("gps initialized")
end

function gps_to_local(x,y,z)
    init_gps()
    cgx,cgy,cgz = gps.locate()
    dx = x - cgx
    dy = y - cgy
    dz = z - cgz

    tmp_dgx = dx_gps
    tmp_dgy = dy_gps
    rot_cnt = 0
    while tmp_dgx ~= dir_x or tmp_dgy ~= dir_y do
        turnLeft()
        rot_cnt = rot_cnt + 1
    end

    loc_dx,loc_dy = dx,dy
    for i=1,rot_cnt do
        lox_dx,loc_dy = rotate_vec_left(loc_dx,loc_dy)
    end

    return loc_dx,loc_dy,(dz + current_z)
end

function move_to_gps(x,y,z)
    dx,dy,dz = gps_to_local(x,y,z)
    move_z_to(dz)
    move_to(dx,dy)
end
