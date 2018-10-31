#include <cstdio>
#include <cstdlib>
#include <algorithm>
#include <iostream>
#include <queue>
using namespace std;

const int maxn = 2e5 + 10, maxm = 4e5 + 10, inf = 0x3f3f3f3f;
int cnt;
struct edge{
  int from, to, nxt, wgt, shw; //wgt is real, shw is temp
  bool flag = true;
  edge *par;

  edge() {}

  edge (int _from, int _to, int _nxt, int _wgt, int _shw) {
    from = _from;
    to = _to;
    nxt = _nxt;
    wgt = _wgt;
    shw = _shw;
  }
  int w() { // take a look at this 
    if (flag) {
      //system("sleep 0.01");
      ++cnt;
      flag = par->flag = false;
      shw = wgt;
      par->shw = par->wgt;
    }
    return wgt;
  }

  int w_() {
    return shw;
  }
} e[maxm];

int last[maxn], vis[maxn], d[maxn], pre[maxn];
int n, m, dept, dest, edg=1, sz;
priority_queue<pair<int, int> > q;

void add_edge(int u, int v, int w, int s) {
    e[++edg] = {u, v, last[u], w, s}; last[u] = edg;
    e[++edg] = {v, u, last[v], w, s}; last[v] = edg;
    e[edg].par = &e[edg-1];
    e[edg-1].par = &e[edg];
}

void prte(int x) {
  if (x == dept) {
    printf("node:%d dist:%d\n", x, d[x]);
    return;
  }
  prte(pre[x]);
  printf("node:%d dist:%d\n", x, d[x]);  
}

void Dijkstra() {    
    for (int i = 1; i <= n; i++)
      d[i] = inf;
    q.push(make_pair(d[dept] = 0, dept));
    while (!q.empty()) {
      int now = q.top().second;
      q.pop();
      if (vis[now])
	continue;
      vis[now] = true;
      if (now == dest) 
	break;
      for (int i = last[now], j; i; i = e[i].nxt)
	if (d[now] + e[i].w() < d[j = e[i].to]) {
	  d[j] = d[now] + e[i].w();
	  pre[j] = now;
	  q.push(make_pair(-d[j], j));
	}
    }
    //prte(dest);
    printf("%d\n", d[dest]);
    // for (int i = 1; i <= n; ++i)
    //   printf("node:%d dist:%d\n", i, d[i]);
}

int main() {
    freopen("input.txt", "r", stdin);
    scanf("%d %d", &n, &m);
    
    for (int i = 1, u, v, w, s; i <= m; ++i) {
	scanf("%d %d %d %d", &u, &v, &w, &s);
	add_edge(v, u, w, s);
    }

    scanf("%d %d", &dept, &dest);

    Dijkstra();

    cout << cnt;
}
