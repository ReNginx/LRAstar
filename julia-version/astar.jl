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

    if (realEdgCost != Inf)
        newChildNode = TNode(node.id, edgToEval, parNode.cost+realEdgCost, 0, 0)
        #print(newChildNode)
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
        println("   $(getNode(graph, id).parent)     $(getNode(graph, id).budget)")
    end
end

function DataStructures.update!(graph::LRAGraph)
    #println(out_edges(1, graph.graph))
    while (!isempty(graph.update))
        node = pop!(graph.update)
        @assert isInTree(graph, node.id)
        println("begin")
        for e in out_edges(node.id, graph.graph)
            # if (target(e) == 618)
            #     prtPath(graph, 618)
            # end
            println(e)
            if (isInTree(graph, target(e)) &&
                getParNode(graph, target(e)).id == node.id)
            end
        end
        println("end")
        edgesToChild = [e
                        for e in out_edges(node.id, graph.graph)
                        if (isInTree(graph, target(e)) &&
                            getParNode(graph, target(e)).id == node.id)]

        if (length(edgesToChild) == 0 || node.id == graph.dest)
            @assert isInTree(graph, node.id)
            push!(graph.extend, node)
            #println(node)
        else
            for edge in edgesToChild
                childNode = getNode(graph, target(edge))
                if (childNode.budget == graph.alpha &&
                    in(childNode, graph.frontier) == 1)
                    delete!(graph.frontier, childNode)
                end
                if (node.budget == graph.alpha)
                    #prtPath(graph, node.id)
                end
                newChildNode = getNewNode(graph, node, edge)
                #@assert newChildNode.budget < graph.alpha "$(getNode(graph, target(edge))) \n $(node)"
                #@assert newChildNode.budget < getNode(graph, target(edge)).budget "$(prtPath(graph, target(edge)))"
                updateTree!(graph, newChildNode)
                if (newChildNode.budget < graph.alpha)
                    push!(graph.update, newChildNode)
                end
            end
        end
    end
end

function rewire!(graph::LRAGraph, treeRewire::Array)
    for v in treeRewire
        newNodes = [getNewNode(graph, getNode(graph, source(e)), e)
                    for e in in_edges(v, graph.graph)
                    if (isInTree(graph, source(e)) &&
                        lazyEval(graph, e) != Inf &&
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
            push!(graph.frontier, node)
            continue
        end

        for e in out_edges(node.id, graph.graph)
            if (lazyEval(graph, e) == Inf)
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
            push!(graph.frontier, node)
            #println(node)
            return
        end

        for e in out_edges(node.id, graph.graph)
            leval = lazyEval(graph, e)
            if (leval == Inf)
                continue
            end
            if (isInTree(graph, target(e)))
                childNode = getNode(graph, target(e))
                curCost = childNode.cost + childNode.lazy
                newCost = node.cost + node.lazy + leval
                if (curCost < newCost ||
                    curCost == newCost && childNode.budget <= node.budget+1)
                    continue
                end
                
                newChildNode = getNewNode(graph, node, e)
                updateTree!(graph, newChildNode)
                takeOut!(graph, target(e)) # take out the subtree of root target(e)
                @assert isInTree(graph, node.id) "$(target(e))"
            end


            newChildNode = getNewNode(graph, node, e)
            updateTree!(graph, newChildNode)
            if (newChildNode.budget == graph.alpha)
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
        println(node)
        treeRewire = evaluate!(graph, node)

        if (isInTree(graph, graph.dest) &&
            in(getNode(graph, graph.dest), graph.update))
            return true
        end

        update!(graph)
        rewire!(graph, treeRewire)
        extend!(graph)
    end
    # for k in graph.tree
    #     println(k[2])
    # end
    prtPath(graph, graph.dest)
    return false
end

function main()
    graph = getGraph()
    if (LRA(graph))
        print("$(getNode(graph, graph.dest).cost)")
    else
        print("Fail to find a path")
    end
end

main()
