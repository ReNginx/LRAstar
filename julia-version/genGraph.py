import numpy as np
import turtle as tl
import math
import heapq

ang_gap = 30
dis_gap = 1

class segment:
    def __init__(self, p1, p2):
        self.p1 = np.array(p1)
        self.p2 = np.array(p2)
        self.d = self.p2 - self.p1

    def intersect(self, seg):
        return np.cross(((seg.p1 - self.p1).reshape(1,-1)), self.d.T) * np.cross(((seg.p2 - self.p1).reshape(1,-1)), self.d.T) < 0 \
               and np.cross(((self.p1 - seg.p1).reshape(1,-1)), seg.d.T) * np.cross(((self.p2 - seg.p1).reshape(1,-1)), seg.d.T) < 0

class robot:
    d = math.sqrt(0.5)*10 # dist from center to corner.

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
    tl.setpos(seg.p1)
    tl.pendown()
    tl.goto(seg.p2)
    tl.penup()

def show_obj(obj):
    seg_list = obj.get_seg_list()
    tl.penup()
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

        #tl.goto(cur[0]*100, cur[1]*100)
#         tl.pendown()
#         tl.penup()

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
    tl.setworldcoordinates(left,bottom,right,top)
    tl.speed(0)
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
    edg = []
    cnt = 0
    for i in np.arange(bottom, top, dis_gap):
        for j in np.arange(left, right, dis_gap):
            for ang in np.arange(0, 360, ang_gap):
                cnt += 1
                id[(i,j,ang)] = cnt
                print(i,j,ang)

    #print(id(1, 55, 60))
    for i in np.arange(bottom, top, dis_gap):
        print(i)
        for j in np.arange(left, right, dis_gap):
            for ang in np.arange(0, 360, ang_gap):
                cur = (i,j,ang)
                idCur = id[cur]
                for newAng in np.arange(0, 360, ang_gap):
                    nxt = advance(cur[0], cur[1], cur[2], dis_gap, newAng+cur[2])

                    if not(left <= nxt[0] and nxt[0] < right and bottom <= nxt[1] and nxt[1] < top):
                        continue
                    idNxt = id[nxt]
                    if (idNxt < idCur):
                        continue
                    lazy = round(dist(cur, nxt))
                    real = lazy
                    rob = robot(i,j,ang)
                    if (rob.is_collide(obs)):
                        real = 0x3f3f3f3f

                    rob.set_pos(*nxt)

                    if rob.is_collide(obs):
                        real = 0x3f3f3f3f
                    # if (real != 0x3f3f3f3f):
                    #     show_seg(segment((cur[0], cur[1]), (nxt[0], nxt[1])))
                    edg.append((idCur, idNxt, real, lazy))

    f= open("input.txt","w")
    print(len(id), file=f)
    print(len(edg), file=f)
    print(id[(30,30,0)], file=f)
    print(id[(10,6,180)], file=f)
    print(10,file=f)
    for e in edg:
        for i in range(4):
            print(e[i], file=f)
    f.close()
