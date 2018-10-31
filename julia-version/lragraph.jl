module LRARelated
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
        parent::Int
        cost::Int
        lazy::Int
        budget::Int
    end

    struct LRAGraph
        graph::Graphs.GenericGraph
        Estatus::Array{Estatus}
        Tree::Set{Estatus}
        dept::Int
        dest::Int
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
        g = LRAGraph(simple_graph(nV),
                    Estatus[], Set(),
                    dept,
                    dest,
                    SortedSet(),
                    SortedSet(),
                    SortedSet(),
                    SortedSet())

        for i in 1:nE
            from = read(STDIN, Int)
            to = read(STDIN, Int)
            lazy = read(STDIN, Int)
            real = read(STDIN, Int)
            add_edge!(g, from, to , lazy, real)
        end
        return g
    end
end
