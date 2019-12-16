BackgroundState = Class{__includes = PlayState}

function BackgroundState:init(levelnum)
    local level = generateLevel(levelnum)
    self.points = level.points

    nodeNumbers = {}
    for i = 1, #self.points do
        table.insert(nodeNumbers, i)
    end

    self.currentFrame = PlayStateDataFrame()
    self.currentFrame.graph = Graph(nodeNumbers)
    self.rotation = 0
    self.projected = deepcopy(self.points)
    self.currentFrame.cycles = {}

    self:updateAvailableEdges()
    while #self.availableEdges > 0 do
        edge = self.availableEdges[math.random(1, #self.availableEdges)]
        self.currentFrame.graph:add_edge(edge[1], edge[2])
        self:updateAvailableEdges()
    end
    self.currentFrame.cycles = minimum_cycle_basis(self.currentFrame.graph, self.points)

    local colors = {}
    for i = 1, 10 do
        table.insert(colors, {math.random(1, 255), math.random(1, 255), math.random(1, 255), 200})
    end

    self.colorAllocation = {}
    for i, c in pairs(self.currentFrame.cycles) do
        self.colorAllocation[c] = colors[math.random(#colors)]
    end
    self.backgroundColor = colors[math.random(#colors)]
end

function BackgroundState:updateAvailableEdges()
    self.availableEdges = {}
    for n1 = 1, #self.points do
        for n2 = n1 + 1, #self.points do
            if n1 ~= n2 and self:validLine({n1, n2}) then
                table.insert(self.availableEdges, {n1, n2})
            end
        end
    end
end

function BackgroundState:update(dt)
    if gSettings['showBackground'] then
        mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
        -- code to rotate mouse

        self.rotation = (self.rotation + 0.2 * dt)%(2 * math.pi)

        if mouseX and mouseY then
            local s = math.sin(-self.rotation)
            local c = math.cos(-self.rotation)

            mouseX = mouseX - VIRTUAL_WIDTH / 2
            mouseY = mouseY - VIRTUAL_HEIGHT / 2

            local xnew = mouseX * c - mouseY * s
            local ynew = mouseX * s + mouseY * c

            mouseX = xnew + VIRTUAL_WIDTH / 2
            mouseY = ynew + VIRTUAL_HEIGHT / 2
            self.projected = {}
            for i, point in pairs(self.points) do
                local vec_x = mouseX - point[1]
                local vec_y = mouseY - point[2]
                local scale = POINT_MOVE_RADIUS / point_length(point[1], point[2], mouseX, mouseY)
                table.insert(self.projected, {point[1] + vec_x * scale, point[2] + vec_y * scale})
            end
        end
    end
end

function BackgroundState:render(position)
    if gSettings['showBackground'] then

        self.position = position

        -- code to rotate
        love.graphics.translate(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2)
        love.graphics.rotate(self.rotation)
        love.graphics.translate(-VIRTUAL_WIDTH / 2, - VIRTUAL_HEIGHT / 2)

        love.graphics.translate(self.position.x, self.position.y)
        love.graphics.clear(255, 255, 255, 255)

        for i, cycle in pairs(self.currentFrame.cycles) do
            love.graphics.setColor(self.colorAllocation[cycle])
            local vertices = getVertices(cycle, self.projected)
            local function polygonStencilFunction()
                if convex then
                    love.graphics.polygon('fill', vertices)
                else
                    triangles = love.math.triangulate(vertices)
                    for i, polygon_triangle in pairs(triangles) do
                        love.graphics.polygon('fill', polygon_triangle)
                    end
                end
            end

            love.graphics.stencil(polygonStencilFunction, "replace", 1, false)

            love.graphics.setStencilTest("greater", 0)
            love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
            love.graphics.setStencilTest()
        end

        love.graphics.setColor(0, 0, 0)

        shiftX = 100
        shiftY = gFonts['medium']:getHeight()

        for i, line in pairs(self.currentFrame.graph.edges) do
            love.graphics.line(self.projected[line[1]][1], self.projected[line[1]][2], self.projected[line[2]][1], self.projected[line[2]][2])
        end

        for i, point in pairs(self.projected) do
            if self.selected == i then
                love.graphics.setColor(255, 0, 0)
            else
                love.graphics.setColor(0, 0, 0)
            end
            love.graphics.setFont(gFonts['small'])
            love.graphics.circle('fill', point[1], point[2], 5)
        end
        love.graphics.translate(-self.position.x, - self.position.y)

        -- code to de-rotate
        love.graphics.translate(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2)
        love.graphics.rotate(-self.rotation)
        love.graphics.translate(-VIRTUAL_WIDTH / 2, - VIRTUAL_HEIGHT / 2)
    else
        love.graphics.clear(255, 255, 255, 255)
    end
end
