function grids_load(width,height)
    gridcanvas = love.graphics.newCanvas(width,height)
    for i = -180 / 3, 180 / 3 do
        love.graphics.setCanvas(gridcanvas)
        local precolor = love.graphics.getColor()
        love.graphics.setColor(255, 255, 255, 0.3)
        for i2 = -180 / 3, 180 / 3 do
            love.graphics.rectangle("line", i * 32, i2 * 32, 32, 32)
        end
		love.graphics.setColor(255, 255, 255, 1)
    end
    love.graphics.setCanvas()
end

grids_load(1280,1280)

function grids_draw()
    love.graphics.draw(gridcanvas)
end
