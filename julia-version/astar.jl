using Graphs
include("lragraph.jl")

function evaluate!(graph::LRAGraph, node::TNode)
    parNode = getParNode(graph, node.id)
    while (parNode.budget != 0)
        node = parNode
        parNode = getParNode(graph, node.id)
    end

    edgToEval = node.parent
    realEdgCost = realEval(graph, edgToEval)

    if (realEdgCost != INF)
        newChildNode = TNode(node.id, edgToEval, parNode.cost+realEdgCost, 0, 0)
        updateTree!(graph, newChildNode)
        push!(graph.update, newChildNode)
    else
        treeRewire = takeOut!(graph, node.id)
        return treeRewire
    end
    return []
end

function prtPath(graph, id)
    if (id != graph.dept)
        prtPath(graph, getParNode(graph, id).id)
        #println("Edge from parent to current node: $(getNode(graph, id).parent)\nDistance from dept to current node:$(getNode(graph, id).cost)\n")
        println("$(id) $(getParNode(graph, id).id)")
    end
end

function DataStructures.update!(graph::LRAGraph)
    while (!isempty(graph.update))
        node = pop!(graph.update)
        @assert isInTree(graph, node.id)
        for e in out_edges(node.id, graph.graph)
            if (isInTree(graph, target(e)) &&
                getParNode(graph, target(e)).id == node.id)
            end
        end
        edgesToChild = [e
                        for e in out_edges(node.id, graph.graph)
                        if (isInTree(graph, target(e)) &&
                            getParNode(graph, target(e)).id == node.id)]

        if (length(edgesToChild) == 0 || node.id == graph.dest)
            @assert isInTree(graph, node.id)
            push!(graph.extend, node)
        else
            for edge in edgesToChild
                childNode = getNode(graph, target(edge))
                if (childNode.budget == graph.alpha &&
                    in(childNode, graph.frontier) == 1)
                    delete!(graph.frontier, childNode)
                end
                newChildNode = getNewNode(graph, node, edge)
                updateTree!(graph, newChildNode)
                if (newChildNode.budget < graph.alpha)
                    push!(graph.update, newChildNode)
                end
            end
        end
    end
end

function rewire!(graph::LRAGraph, treeRewire::Set)
    for v in treeRewire
        newNodes = [getNewNode(graph, getNode(graph, source(e)), e)
                    for e in in_edges(v, graph.graph)
                    if (isInTree(graph, source(e)) &&
                        !in(source(e), treeRewire) &&
                        lazyEval(graph, e) != INF &&
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

    while (!isempty(graph.rewire))
        node = pop!(graph.rewire)

        if (node.budget == graph.alpha || node.id == graph.dest)
            @assert isInTree(graph, node.id)
            push!(graph.frontier, node)
            continue
        end

        if (node.budget < graph.alpha)
            push!(graph.extend, node)
        end
        for e in out_edges(node.id, graph.graph)
            if (lazyEval(graph, e) == INF || !in(target(e), treeRewire))
                continue
            end
            v = target(e)
            newNode = getNewNode(graph, node, e)
            inTree = isInTree(graph, v)
            if (!inTree || newNode < getNode(graph, v))
                if (inTree)
                    oldNode = getNode(graph, v)
                    if (in(oldNode, graph.rewire))
                        delete!(graph.rewire, oldNode)
                    end
                end
                updateTree!(graph, newNode)
                push!(graph.rewire, newNode)
            end
        end
    end
end

function extend!(graph::LRAGraph)
    while (!isempty(graph.extend))
        node = pop!(graph.extend)
        if (node.id == graph.dest)
            @assert isInTree(graph, node.id)
            push!(graph.frontier, node)
            return
        end

        for e in out_edges(node.id, graph.graph)
            leval = lazyEval(graph, e)
            if (leval == INF)
                continue
            end
            if (isInTree(graph, target(e)))
                childNode = getNode(graph, target(e))
                curCost = childNode.cost + childNode.lazy
                newCost = node.cost + node.lazy + leval
                if (curCost < newCost ||
                    (curCost == newCost && childNode.budget <= node.budget+1))
                    continue
                end

                oldNode = getNode(graph, target(e))
                @assert isInTree(graph, source(e))
                takeOut!(graph, target(e), source(e)) # take out the subtree of root target(e)
                @assert isInTree(graph, node.id) "$(oldNode)"
            end


            newChildNode = getNewNode(graph, node, e)
            updateTree!(graph, newChildNode)
            if (newChildNode.budget == graph.alpha)
                @assert isInTree(graph, newChildNode.id)
                push!(graph.frontier, newChildNode)
            else
                @assert isInTree(graph, newChildNode.id)
                push!(graph.extend, newChildNode)
            end
        end
    end
end

function LRA(graph::LRAGraph)::Bool
    updateTree!(graph, TNode(graph.dept, nothing, 0, 0, 0))
    push!(graph.extend, getNode(graph, graph.dept))
    extend!(graph)

    if (graph.dest == graph.dept)
        print("Distance is 0")
        return true
    end

    while (!isempty(graph.frontier))
        node = pop!(graph.frontier)
        treeRewire = evaluate!(graph, node)

        if (isInTree(graph, graph.dest) &&
            in(getNode(graph, graph.dest), graph.update))
            return true
        end

        update!(graph)
        rewire!(graph, Set(treeRewire))
        extend!(graph)
    end

    return false
end

function checkPar(graph, node)
    par = getParNode(graph, node.id)
    evl = lazyEval(graph, node.parent)
    @assert node.cost + node.lazy == par.cost + par.lazy + evl  "$(node)\n$(par)\n$(evl)"
end

function main()
    graph = getGraph()
    if (LRA(graph))
        prtPath(graph, graph.dest)
        # println("distance from dept to dest: $(getNode(graph, graph.dest).cost)")
        # println("""number of evaled edges: $(graph.evaledEdgeCounter["total"])""")
        open("res.txt", "w") do f
            write(f, "$(graph.evaledEdgeCounter["total"])\n")
            for e in edges(graph.graph)
                index = edge_index(e, graph.graph)
                if (graph.status[index].has_evaluated)
                    write(f, "$(source(e)) $(target(e))\n")
                end
            end
        end
    else
        println("Fail to find a path")
    end
end
