
top = 5.5
bottom = 0
left = 0
right = 5.5
ang_gap = 30
dis_gap = 0.2
nV = 0
id = Dict()

for i in bottom : 0.1 : top,
    j = left : 0.1 : right,
    ang = 0 : ang_gap : 359
    cnt += 1
    id[(i, j, ang)] = cnt
end


g = simple_graph(nV)
