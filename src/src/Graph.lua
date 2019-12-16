--[[
    References:
    1. http://web.ist.utl.pt/alfredo.ferreira/publications/12EPCG-PolygonDetection.pdf
    2. https://www.sanfoundry.com/python-program-implement-floyd-warshall-algorithm/
    3. https://stackoverflow.com/questions/38336698/polygon-detection-from-a-set-of-lines
]]

Class = require 'lib/class'
require 'src/Util'

Graph = Class{}

function Graph:init(nodes)
    self.nodes = {}
    self.edges = {}
    for i, node in pairs(nodes) do
        self.nodes[node] = {}
    end
    -- print_r(self.nodes)
end

function Graph:add_edge(n1, n2, c)
    c = c or 1
    table.insert(self.nodes[n1], {n2, c})
    table.insert(self.nodes[n2], {n1, c})
    table.insert(self.edges, {n1, n2, c})
end

function Graph:remove_edge(n1, n2)
    for i = 1, #self.edges do
        if (n1 == self.edges[i][1] and n2 == self.edges[i][2]) or (n1 == self.edges[i][2] and n2 == self.edges[i][1]) then
            self.edges[i] = nil
        end
    end

    for i = 1, #self.nodes[n1] do
        if self.nodes[n1][i][1] == n2 then
            self.nodes[n1][i] = nil
        end
    end

    for i = 1, #self.nodes[n2] do
        if self.nodes[n2][i][1] == n1 then
            self.nodes[n2][i] = nil
        end
    end
end

function Graph:add_node(node)
    self.nodes[node] = {}
end

function floyd_warshall(G)
    distance = {}
    next_v = {}
    for v1 in pairs(G.nodes) do
        distance[v1] = {}
        next_v[v1] = {}
        for v2 in pairs(G.nodes) do
            distance[v1][v2] = 1 / 0
        end
    end

    for v in pairs(G.nodes) do
        for i, n in pairs(G.nodes[v]) do
            distance[v][n[1]] = n[2]
            next_v[v][n[1]] = n[1]
        end
    end

    for v in pairs(G.nodes) do
        distance[v][v] = 0
        next_v[v][v] = nil
    end

    for p in pairs(G.nodes) do
        for v in pairs(G.nodes) do
            for w in pairs(G.nodes) do
                if distance[v][w] > distance[v][p] + distance[p][w] then
                    distance[v][w] = distance[v][p] + distance[p][w]
                    next_v[v][w] = next_v[v][p]
                end
            end
        end
    end

    return {distance, next_v}
end

function all_pairs_shortest_paths(G)
    fw = floyd_warshall(G)
    distance = fw[1]
    next_v = fw[2]

    paths = {}
    for u in pairs(G.nodes) do
        paths[u] = {}
        for v in pairs(G.nodes) do
            paths[u][v] = {}
            p = u
            while next_v[p][v] do
                table.insert(paths[u][v], p)
                p = next_v[p][v]
            end
            table.insert(paths[u][v], v)
        end
    end

    return paths
end

function convert_to_set(tbl)
    set_form = {}
    for i, element in pairs(tbl) do
        set_form[element] = true
    end
    return set_form
end

function testProperty(t1, t2, v)
    -- tests whether v is only element t1 and t2 have in common.
    s1 = convert_to_set(t1)
    s2 = convert_to_set(t2)

    if not(s1[v] and s2[v]) then
        return false
    end

    for i in pairs(s1) do
        if i ~= v then
            if s2[i] then
                return false
            end
        end
    end

    for i in pairs(s2) do
        if i ~= v then
            if s1[i] then
                return false
            end
        end
    end

    return true
end

function combine_paths(a, b, x)
    path = {}
    for i = 1, #a do
        table.insert(path, a[i])
    end

    for i = 2, #b do
        table.insert(path, b[i])
    end

    return path
end

function shouldInsert(cycles, cycle_path)
    for i, cycle in pairs(cycles) do
        if sameElements(cycle, cycle_path) then
            return false
        end
    end
    return true
end

function minimum_cycle_basis(G, points)
    cycles = {}
    Pi = all_pairs_shortest_paths(G)
    for v in pairs(G.nodes) do
        for i, e in pairs(G.edges) do
            x = e[1]
            y = e[2]
            if testProperty(Pi[x][v], Pi[v][y], v) and x ~= v and y ~= v then
                C = combine_paths(Pi[x][v], Pi[v][y], x)
                if shouldInsert(cycles, C) then
                    table.insert(cycles, C)
                end
            end
        end
    end

    local remove = {}

    for i, c in pairs(cycles) do
        for i, e in pairs(G.edges) do
            l = lines_set(c)
            v = getVertices(c, points)
            p1 = points[e[1]]
            p2 = points[e[2]]
            e1_inside = table.contains(c, e[1])
            e2_inside = table.contains(c, e[2])

            if not (table.contains(l, {e[1], e[2]}) or table.contains(l, {e[2], e[1]})) and pointInPolygon(midpoint(p1, p2), v) then
                table.insert(remove, c)
                break
            end
        end

        for i, point in pairs(points) do
            if pointInPolygon(point, getVertices(c, points)) then
                table.insert(remove, c)
                break
            end
        end
    end

    local primitiveCycles = {}

    for i, c in pairs(cycles) do
        if not table.contains(remove, c) then
            table.insert(primitiveCycles, c)
        end
    end

    return primitiveCycles
end

-- G = Graph({1, 2, 3, 4, 5})
--
-- G:add_edge(1, 2)
-- G:add_edge(1, 5)
-- G:add_edge(2, 3)
-- G:add_edge(2, 5)
-- G:add_edge(2, 4)
-- G:add_edge(3, 4)
-- G:add_edge(4, 5)
-- print_r(minimum_cycle_basis(G))
