using Graphs
using DataStructures

export Estatus, TNode, LRAGraph

struct Estatus
    lazy::Int
    real::Int
    has_evaluated:: Bool
end

struct TNode
    id::Int
    parent::Any
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
    push!(g.status, Estatus(lazy, real, false))
end

function getGraph()
    open("input.txt") do file
        nV = parse(Int, readline(file))
        nE = parse(Int, readline(file))
        dept = parse(Int, readline(file))
        dest = parse(Int, readline(file))
        alpha = parse(Int, readline(file))

        g = LRAGraph(simple_graph(nV),
                    Estatus[],
                    Dict(),
                    dept,
                    dest,
                    alpha,
                    SortedSet{TNode}(),
                    SortedSet{TNode}(),
                    SortedSet{TNode}(),
                    SortedSet{TNode}())

        for i in 1:nE
            from = parse(Int, readline(file))
            to = parse(Int, readline(file))
            real = parse(Int, readline(file))
            lazy = parse(Int, readline(file))
            # if (real == 0x3f3f3f3f)
            #     real = Inf
            # end
            add_edge!(g, from, to, lazy, real)
            add_edge!(g, to, from, lazy, real)
        end
        return g
    end
end

# get tree node of id
function getNode(graph::LRAGraph, id::Int)
    @assert isInTree(graph, id) "id:$(id) is not in tree"
    return graph.tree[id]
end

# get parent node of id
function getParNode(graph::LRAGraph, id::Int)
    parEdg = getNode(graph, id).parent
    if (parEdg == nothing)
        return TNode(0, nothing, 0, 0, 0)
    end
    return getNode(graph, source(parEdg))
end

function updateTree!(graph::LRAGraph, node::TNode)
    @assert node.id == graph.dept || isInTree(graph, source(node.parent))
    graph.tree[node.id] = node
end

function isInTree(graph::LRAGraph, id::Int)
    return haskey(graph.tree, id)
end

# delete subtree rooted at id. and return an array containing all id in the subtree.
function takeOut!(graph::LRAGraph, id::Int, par::Int = 0)
    if (!isInTree(graph, id))
        return []
    end

    oldNode = getNode(graph, id)
    if (in(oldNode, graph.frontier))
        delete!(graph.frontier, oldNode)
    end
    if (in(oldNode, graph.extend))
        delete!(graph.extend, oldNode)
    end

    ret = [id]
    for e in out_edges(id, graph.graph)
        if (isInTree(graph, target(e)) &&
            getParNode(graph, target(e)).id == id)
            append!(ret, takeOut!(graph, target(e)))
        end
    end
    delete!(graph.tree, id)
    return ret
end

# we are using two directed edges to represent an undirected edge.
# make sure these two edges are adjacent in edge array.
function siblingEdgeId(index::Int)
    return ((index-1) ⊻ 1) + 1
end

function realEval(graph::LRAGraph, edge::Graphs.Edge)
    index = edge_index(edge, graph.graph)
    real = graph.status[index].real
    graph.status[index] = Estatus(real, real, true)
    graph.status[siblingEdgeId(index)] = Estatus(real, real, true)
    return real
end

function lazyEval(graph::LRAGraph, edge::Graphs.Edge)
    index = edge_index(edge, graph.graph)
    return graph.status[index].lazy
end

# return a new Tnode by a parent node and an edge.
function getNewNode(graph::LRAGraph, parNode::TNode, edge::Graphs.Edge)
    @assert parNode.budget < graph.alpha "node $(target(edge)) budget exceeded"
    @assert lazyEval(graph, edge) != Inf
    return TNode(target(edge),
                edge,
                parNode.cost,
                parNode.lazy + lazyEval(graph, edge),
                parNode.budget + 1)
end
