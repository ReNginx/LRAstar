using Graphs
include("lragraph.jl")

function getNewNode(graph::LRAGraph, parNode::TNode, e)
    return TNode(target(e),
                e,
                parNode.cost,
                parNode.lazy + lazyEval(graph, e),
                parNode.budget + 1)
end

function evaluate!(graph::LRAGraph, node::TNode)
    parNode = getParNode(graph, node)
    while (parNode.budget != 0)
        node = parNode
        parNode = getParNode(graph, node)
    end

    edgToEval = node.parent
    realEdgCost = realEval(graph, edgToEval)

    if (realEdgCost != Inf)
        newChildNode = getNewNode(graph, parNode, edgToEval) # note after real eval, lazy eval also eval to real weight.
        updateTree!(graph, newChildNode)
        push!(graph.update, newChildNode)
    else
        treeRewire = takeOut!(graph, node.id)
        return treeRewire
    end
    return []
end

function DataStructures.update!(graph::LRAGraph)
    while (length(graph.update) > 0)
        node = pop!(graph.update)
        edgesToChild = [e
                        for e in out_edges(graph.graph, node.id)
                        if (isInTree(graph, target(e)) &&
                            getParNode(graph, target(e)).id == node.id)]

        if (length(edgesToChild) == 0)
            push!(graph.extend, node)
        else
            for edge in edgesToChild
                childNode = getNode(target(edge))
                if (childNode.budget == graph.alpha)
                    delete!(graph.frontier, childNode)
                end
                newChildNode = getNewNode(graph, node, edge)
                updateTree!(graph, newChildNode)
                push!(graph.update, newChildNode)
            end
        end
    end
end

function rewire(graph::LRAGraph, treeRewire::Array)
    for v in treeRewire
        newNodes = [getNewNode(graph, source(e), e)
                    for e in in_edges(v)
                    if (isInTree(graph, source(e)) &&
                        getNode(graph, source(e)).budget < graph.alpha)]

        if (length(newNodes) == 0)
            continue
        end
        minNewNode = minimum(newNodes)
        if (!isInTree(graph, v) || minNewNode < getNode(graph, v))
            updateTree!(graph, minNewNode)
            push!(graph.rewire, minNewNode)
        end
    end

    while (length(graph.rewire) > 0)
        node = pop!(graph.rewire)

        for e in out_edges(node.id)
            v = target(e)
            newNode = getNewNode(graph, node, e)
            if (!isInTree(graph, v || newNode < getNode(graph, v)))
                updateTree!(graph, newNode)
                if (newNode.budget < graph.alpha)
                    push!(graph.rewire, newNode)
                end
            end
        end
    end
end

function extend!(graph::LRAGraph)
    while (length(graph.extend) > 0)
        node = pop!(graph.extend)
        if (node.id == graph.dest)
            push!(graph.frontier, node)
            return
        end

        for e in out_edges(node.id)
            leval = lazyEval(graph, e)
            if (leval == Inf)
                continue
            end
            if (isInTree(graph, target(e)))
                childNode = getNode(graph, target(e))
                curCost = childNode.cost + childNode.lazy
                newCost = node.cost + node.lazy + leval
                if (curCost < newCost ||
                    curCost == newCost && childNode.budget > node.budget+1)
                    continue
                end
            end

            takeOut!(graph, target(e)) # take out the subtree of root target(e)
            newChildNode = getNewNode(graph, node, e)
            updateTree!(graph, newChildNode)
            if (newChildNode.budget == graph.alpha)
                push!(graph.frontier, newChildNode)
            else
                push!(graph.extend, newChildNode)
            end
        end
    end
end

function LRA(graph::LRAGraph)::Bool
    push!(graph.inTree,
        TNode(graph.dest, 0, 0, 0, 0)) # add start to the shortestPathTree

    push!(graph.extend, getNode(graph, graph.dest))
    extend!(graph)

    if (graph.dest == graph.dept)
        print("Distance is 0")
        return true
    end

    while (length(graph.frontier) > 0)
        node = pop!(graph.frontier)

        treeRewire = evaluate!(graph, node)

        if (in(graph.tree, graph.dest) &&
            in(graph.update, getNode(graph.dest)))
            return true
        end

        update!(graph)
        rewrire!(graph, treeRewire)
        extend!(graph)
    end
end

function main()
    graph = get_graph()
    LRA(graph)
    print("Distances is $(getNode(graph, graph.dest).cost)")
end
