using DataStructures
using CSV

struct Edge
    to::Int64
    w::Int64
    next::Edge
end

struct Graph
    n::Int64
    m::Int64
    edges::Edge[]
    last::Int64[]
end

function readFile(fileName)
    G.read
    data = CSV.read(fileName,delim=' ')
end


G = readFile("a.csv")
