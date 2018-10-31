include("lragraph.jl")
using Graphs
using LRARelated

function LRA(graph::LRAGraph)
    push!(graph.inTree,
        Tree_node(graph.dest, 0, 0, 0, 0)) # add start to the shortestPathTree



end

function main()
    graph = get_graph()
    LRA(graph)
end

main()
