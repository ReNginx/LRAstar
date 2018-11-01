using Graphs
using DataStructures

export Estatus, TNode, LRAGraph, get_graph

struct Estatus
    lazy::Int
    real::Int
    has_evaluated:: Bool
end

struct TNode
    id::Int
    parent
    cost::Int
    lazy::Int
    budget::Int
end

struct LRAGraph
    graph::Graphs.GenericGraph
    status::Array{Estatus}
    tree::Dict{Int, TNode}
    dept::Int
    dest::Int
    alpha::Int
    frontier::SortedSet{TNode}
    rewire::SortedSet{TNode}
    update::SortedSet{TNode}
    extend::SortedSet{TNode}
end

function Base.hash(x::TNode)
    return hash(x.id)
end

function Base.isequal(x::TNode, y::TNode)
    return hash(x) == hash(y)
end

function Base.isless(x::TNode, y::TNode)
    cost_x = x.cost + x.lazy
    cost_y = y.cost + y.lazy
    return cost_x == cost_y ? x.id < y.id : cost_x < cost_y
end

function Graphs.add_edge!(g::LRAGraph, source, target, lazy, real)
    add_edge!(g.graph, source, target)
    push!(g.Estatus, Estatus(lazy, real, false))
end

function get_graph()
    nV = read(STDIN, Int)
    nE = read(STDIN, Int)
    dept = read(STDIN, Int)
    dest = read(STDIN, Int)
    alpha = read(STDIN, Int)

    g = LRAGraph(simple_graph(nV),
                Estatus[], Set(),
                dept,
                dest,
                alpha,
                SortedSet(),
                SortedSet(),
                SortedSet(),
                SortedSet())

    for i in 1:nE
        from = read(STDIN, Int)
        to = read(STDIN, Int)
        lazy = read(STDIN, Int)
        real = read(STDIN, Int)
        add_edge!(g, from, to, lazy, real)
    end
    return g
end

# get tree node of id
function getNode(graph::LRAGraph, id::Int)
    return graph.tree[id]
end

# get parent node of id
function getParNode(graph::LRAGraph, id::Int)
    parEdg = getNode(graph, id).parent
    return getNode(graph, source(parEdg))
end

function updateTree!(graph::LRAGraph, node::TNode)
    graph.tree[node.id] = node
end

function isInTree(graph::LRAGraph, id::Int)
    return haskey(graph.tree, id)
end

# delete subtree rooted at id. and return an array containing all id in the subtree.
function takeOut!(graph::LRAGraph, id::Int)
    if (!isInTree(graph, id))
        return []
    end
    delete!(graph.tree, id)
    ret = [id]
    for e in out_edges(id)
        if (isInTree(graph, target(e)) &&
            getParNode(graph, target(e)).id == id)
            append!(ret, takeOut!(graph, target(e)))
        end
    end
    return ret
end

function realEval()

end

function lazyEval()

end
