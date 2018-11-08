import numpy as np
import math
import heapq

ang_gap = 30
dis_gap = 2

import matplotlib.pyplot as plt
import matplotlib as mpl

ax = plt.gca() # get current axes
ax.set_aspect(1.0)

class segment:
    def __init__(self, p1, p2):
        self.p1 = np.array(p1)
        self.p2 = np.array(p2)
        self.d = self.p2 - self.p1

    def intersect(self, seg):
        return np.cross(((seg.p1 - self.p1).reshape(1,-1)), self.d.T) * np.cross(((seg.p2 - self.p1).reshape(1,-1)), self.d.T) < 0 \
               and np.cross(((self.p1 - seg.p1).reshape(1,-1)), seg.d.T) * np.cross(((self.p2 - seg.p1).reshape(1,-1)), seg.d.T) < 0

class robot:
    d = math.sqrt(5) # dist from center to corner.

    def __init__(self, x, y, th):
        self.x = x
        self.y = y
        self.th = th

    def get_seg_list(self):
        pts = []
        for i in [45, 135, -135, -45]:
            ang = (self.th + i) / 180 * math.pi
            pts.append((self.x + robot.d * math.cos(ang), self.y + robot.d * math.sin(ang)))

        return [segment(pts[i], pts[(i+1)%4]) for i in range(4)]

    def get_pos(self):
        return (self.x, self.y, self.th)

    def set_pos(self, x, y, th):
        self.x = x
        self.y = y
        self.th = th

    def is_collide(self, obs):
        for self_seg in self.get_seg_list():
            for seg in obs.get_seg_list():
                if self_seg.intersect(seg):
                    return True
        return False

class obstacle:
    def __init__(self,seg_list):
        self.seg_list = seg_list

    def get_seg_list(self):
        return self.seg_list

def advance(x, y, th, d, nth):
    nx = int(round(x + d * math.cos(nth/180*math.pi)))
    ny = int(round(y + d * math.sin(nth/180*math.pi)))
    return (nx, ny, nth-360 if nth >= 360 else nth)

def show_seg(seg):
    ax.plot([seg.p1[0], seg.p2[0]], [seg.p1[1], seg.p2[1]], color="blue")

def show_obj(obj):
    seg_list = obj.get_seg_list()
    for seg in seg_list:
        show_seg(seg)

def dist(p1, p2):
    return math.sqrt((p1[0]-p2[0])**2 + (p1[1]-p2[1])**2)

def astar(obs, rob, target = (1, 0.50, 180)):
    q = []
    heapq.heappush(q, (dist(rob.get_pos(), target), 0, rob.get_pos()))
    visited = {rob.get_pos(): False}
    flag = True

    while len(q) > 0 and flag:
        cur = heapq.heappop(q)
        print(cur)
        di= cur[1]
        cur = cur[2]

        for ang in range(0, 360, ang_gap):
            nxt = advance(cur[0], cur[1], cur[2], dis_gap, ang+cur[2])
            rob.set_pos(*nxt)
            if not(left <= nxt[0] and nxt[0] <= right and bottom <= nxt[1] and nxt[1] <= top):
                continue
            if not rob.is_collide(obs) and nxt not in visited:
                visited[nxt] = cur
                if dist(nxt, target) < 0.5:
                    flag = False
                    break
                heapq.heappush(q, (dist(nxt, target)+di+dist(nxt, cur), di+dist(nxt, cur), nxt))
                show_seg(segment((cur[0], cur[1]), (nxt[0], nxt[1])))

    if not flag:
        while visited[nxt] != False:
            rob.set_pos(nxt[0], nxt[1], nxt[2])
            show_obj(rob)
            nxt = visited[nxt]
            print(nxt)


if __name__ == "__main__":
    # top = 1000
    # bottom = -1000
    # left = -1000
    # right = 1000
    # top = 2.5
    # bottom = -3
    # left = -3
    # right = 2.5
    top = 55
    bottom = 0
    left = 0
    right = 55
    p1 = (0,0)
    p2 = (0,40)
    p3 = (40,0)
    p4 = (0, 14)
    p5 = (2, 14)
    p6 = (8, 14)
    p7 = (40, 14)
    p8 = (10, 14)
    p9 = (10, 40)
    target = (10, 5, 180)

    obs = obstacle([segment(p1, p2),
                    segment(p1, p3),
                    segment(p6, p7),
                    segment(p4, p5),
                    segment(p8, p9)])

    show_obj(obs)


    id = dict()
    rid = dict()
    edg = []
    cnt = 0
    for i in np.arange(bottom, top, 1):
        for j in np.arange(left, right, 1):
            for ang in np.arange(0, 360, 30):
                cnt += 1
                id[(i,j,ang)] = cnt
                rid[cnt] = (i,j,ang)

    n = int(input())*2
    s = set()
    for k in range(n):
        [x,y] = [int(x) for x in input().split()]
        print(x,y)
        px = rid[x]
        py = rid[y]
        s.add((px[0],px[1], py[0],py[1]))

    for x in s:
        show_seg(segment((x[0],x[1]),(x[2],x[3])))

    plt.show()
