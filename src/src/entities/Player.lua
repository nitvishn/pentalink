Player = Class{}

function Player:init(points)
    self.points = points
    self.moveData = {}
    self.area = 0
end

function Player:getShapes()
    shapes = {}
    for move, data in pairs(self.moveData) do
        for i, s in pairs(self.moveData[move]['shapes']) do
            table.insert(shapes, s)
        end
    end
    return shapes
end

function shapepoints(c)
    if #c >= 3 and #c <= 7 then
        return POLYGON_POINTS[#c]
    elseif #c >= 8 then
        return - 9 - 3 * (#c - 8)
    end
end

function Player:update(shapes, move, points_list)
    self.moveData[move] = {}
    self.moveData[move]['shapes'] = shapes
    self.moveData[move]['area'] = 0
    self.moveData[move]['points'] = 0
    for i, c in pairs(shapes) do
        self.area = self.area + shoelace(points_set(c, points_list)) * (PIXEL_AREA_SCALE_FACTOR)
        self.moveData[move]['area'] = self.moveData[move]['area'] + shoelace(points_set(c, points_list)) * (PIXEL_AREA_SCALE_FACTOR)
        self.points = self.points + shapepoints(c)
        self.moveData[move]['points'] = self.moveData[move]['points'] + shapepoints(c)
    end
end
