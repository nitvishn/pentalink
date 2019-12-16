function generateLevel(n)
    local level = {
        ['points'] = {},
        ['edges'] = {}
    }
    -- if n == 1 then
    --     level = {
    --         ['points'] = {
    --             {2 / 10 * VIRTUAL_WIDTH, 1 / 6 * VIRTUAL_HEIGHT},
    --             {4 / 10 * VIRTUAL_WIDTH, 1 / 6 * VIRTUAL_HEIGHT},
    --
    --             {6 / 10 * VIRTUAL_WIDTH, 1 / 6 * VIRTUAL_HEIGHT},
    --             {8 / 10 * VIRTUAL_WIDTH, 1 / 6 * VIRTUAL_HEIGHT},
    --
    --             {2 / 10 * VIRTUAL_WIDTH, 5 / 6 * VIRTUAL_HEIGHT},
    --             {4 / 10 * VIRTUAL_WIDTH, 5 / 6 * VIRTUAL_HEIGHT},
    --
    --             {6 / 10 * VIRTUAL_WIDTH, 5 / 6 * VIRTUAL_HEIGHT},
    --             {8 / 10 * VIRTUAL_WIDTH, 5 / 6 * VIRTUAL_HEIGHT},
    --
    --             {1 / 10 * VIRTUAL_WIDTH, 3 / 12 * VIRTUAL_HEIGHT},
    --             {1 / 10 * VIRTUAL_WIDTH, 9 / 12 * VIRTUAL_HEIGHT},
    --
    --             {5 / 10 * VIRTUAL_WIDTH, 3 / 12 * VIRTUAL_HEIGHT},
    --             {5 / 10 * VIRTUAL_WIDTH, 9 / 12 * VIRTUAL_HEIGHT},
    --
    --             {9 / 10 * VIRTUAL_WIDTH, 3 / 12 * VIRTUAL_HEIGHT},
    --             {9 / 10 * VIRTUAL_WIDTH, 9 / 12 * VIRTUAL_HEIGHT}
    --         },
    --         ['edges'] = {
    --         }
    --     }
    if n == 1 then
        level = {
            ['points'] = {
                {2 / 8 * VIRTUAL_WIDTH, 1 / 8 * VIRTUAL_HEIGHT},
                {3 / 8 * VIRTUAL_WIDTH, 1 / 8 * VIRTUAL_HEIGHT},

                {5 / 8 * VIRTUAL_WIDTH, 1 / 8 * VIRTUAL_HEIGHT},
                {6 / 8 * VIRTUAL_WIDTH, 1 / 8 * VIRTUAL_HEIGHT},
                --

                {2 / 8 * VIRTUAL_WIDTH, 4 / 8 * VIRTUAL_HEIGHT},
                {3 / 8 * VIRTUAL_WIDTH, 4 / 8 * VIRTUAL_HEIGHT},

                {5 / 8 * VIRTUAL_WIDTH, 4 / 8 * VIRTUAL_HEIGHT},
                {6 / 8 * VIRTUAL_WIDTH, 4 / 8 * VIRTUAL_HEIGHT},
                --

                {2 / 8 * VIRTUAL_WIDTH, 7 / 8 * VIRTUAL_HEIGHT},
                {3 / 8 * VIRTUAL_WIDTH, 7 / 8 * VIRTUAL_HEIGHT},

                {5 / 8 * VIRTUAL_WIDTH, 7 / 8 * VIRTUAL_HEIGHT},
                {6 / 8 * VIRTUAL_WIDTH, 7 / 8 * VIRTUAL_HEIGHT},


                -- vertical bars
                {1 / 8 * VIRTUAL_WIDTH, 2 / 8 * VIRTUAL_HEIGHT},
                {1 / 8 * VIRTUAL_WIDTH, 3 / 8 * VIRTUAL_HEIGHT},

                {1 / 8 * VIRTUAL_WIDTH, 5 / 8 * VIRTUAL_HEIGHT},
                {1 / 8 * VIRTUAL_WIDTH, 6 / 8 * VIRTUAL_HEIGHT},


                {4 / 8 * VIRTUAL_WIDTH, 2 / 8 * VIRTUAL_HEIGHT},
                {4 / 8 * VIRTUAL_WIDTH, 3 / 8 * VIRTUAL_HEIGHT},

                {4 / 8 * VIRTUAL_WIDTH, 5 / 8 * VIRTUAL_HEIGHT},
                {4 / 8 * VIRTUAL_WIDTH, 6 / 8 * VIRTUAL_HEIGHT},


                {7 / 8 * VIRTUAL_WIDTH, 2 / 8 * VIRTUAL_HEIGHT},
                {7 / 8 * VIRTUAL_WIDTH, 3 / 8 * VIRTUAL_HEIGHT},

                {7 / 8 * VIRTUAL_WIDTH, 5 / 8 * VIRTUAL_HEIGHT},
                {7 / 8 * VIRTUAL_WIDTH, 6 / 8 * VIRTUAL_HEIGHT},
            },
            ['edges'] = {
            }
        }
    elseif n == 2 then
        level = {
            ['points'] = {
                {1 / 12 * VIRTUAL_WIDTH, 4 / 8 * VIRTUAL_HEIGHT},
                {2 / 12 * VIRTUAL_WIDTH, 2 / 8 * VIRTUAL_HEIGHT},
                {3 / 12 * VIRTUAL_WIDTH, 1 / 8 * VIRTUAL_HEIGHT},
                {4 / 12 * VIRTUAL_WIDTH, 1 / 8 * VIRTUAL_HEIGHT},
                {5 / 12 * VIRTUAL_WIDTH, 4 / 8 * VIRTUAL_HEIGHT},
                {6 / 12 * VIRTUAL_WIDTH, 3 / 8 * VIRTUAL_HEIGHT},
                {7 / 12 * VIRTUAL_WIDTH, 4 / 8 * VIRTUAL_HEIGHT},
                {6 / 12 * VIRTUAL_WIDTH, 5 / 8 * VIRTUAL_HEIGHT},
                {8 / 12 * VIRTUAL_WIDTH, 1 / 8 * VIRTUAL_HEIGHT},
                {9 / 12 * VIRTUAL_WIDTH, 1 / 8 * VIRTUAL_HEIGHT},
                {10 / 12 * VIRTUAL_WIDTH, 2 / 8 * VIRTUAL_HEIGHT},
                {11 / 12 * VIRTUAL_WIDTH, 4 / 8 * VIRTUAL_HEIGHT},
                {10 / 12 * VIRTUAL_WIDTH, 6 / 8 * VIRTUAL_HEIGHT},
                {9 / 12 * VIRTUAL_WIDTH, 7 / 8 * VIRTUAL_HEIGHT},
                {8 / 12 * VIRTUAL_WIDTH, 7 / 8 * VIRTUAL_HEIGHT},
                {4 / 12 * VIRTUAL_WIDTH, 7 / 8 * VIRTUAL_HEIGHT},
                {3 / 12 * VIRTUAL_WIDTH, 7 / 8 * VIRTUAL_HEIGHT},
                {2 / 12 * VIRTUAL_WIDTH, 6 / 8 * VIRTUAL_HEIGHT},
            },
            ['edges'] = {
                {3, 4},
                {5, 6},
                {6, 7},
                {7, 8},
                {5, 8},
                {9, 10},
                {14, 15},
                {16, 17}
            }
        }
        return level
    elseif n == NUM_LEVELS then
        nPoints = RANDOM_LEVEL_POINTS
        level = {
            ['points'] = {},
            ['edges'] = {}
        }
        for i = 1, nPoints do
            table.insert(level.points, {math.random(0, VIRTUAL_WIDTH), math.random(0, VIRTUAL_HEIGHT)})
        end

        return level
    end

    for i = 1, #level.points, 2 do
        table.insert(level.edges, {i, i + 1})
    end
    return level
end
