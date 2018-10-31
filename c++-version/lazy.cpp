#include <cstdio>
#include <cstdlib>
#include <algorithm>
#include <set>
#include <cassert>
#include <iostream>
#include <queue>
#define prt(x) printf("u:%d p:%d c:%d l:%d b:%d\n", x.u, x.p, x.c, x.l, x.b)
using namespace std;
const int maxn = 2e5 + 10, maxm = 4e5 + 10, inf = 0x3f3f3f3f, alpha = 50;

//PLEASE NOTE HERE.
struct node{
    int u, p, c, l, b; // a little bit different here, p is the edge index from u-parent to u.
    friend bool operator < (node x, node y) { 
	return x.c + x.l ==  y.c + y.l ? x.u < y.u : x.c + x.l <  y.c + y.l ;
    }
} tau[maxn];

int cnt = 0;

struct edge{
    int from, to, nxt, wgt, lzy; //wgt is real weight, lzy is lazy eval 
    bool flag = true;
    edge *par; //partner edge

    edge() {}

    edge (int _from, int _to, int _nxt, int _wgt, int _lzy) {
	from = _from;
	to = _to;
	nxt = _nxt;
	wgt = _wgt;
	lzy = _lzy;
    }
    
    int w() { // take a look at this 
	if (flag) {
	    //system("sleep 0.01");
	    //cout << ++cnt << endl;
	    ++cnt; // this edge is evaluated
	    flag = par->flag = false;
	    lzy = wgt;
	    par->lzy = par->wgt; // edge is undirected, and is represented by two directed edges.
	}
	return wgt;
    }

    int w_() {
	return lzy;
    }
} e[maxm];

int n, m, edg=1;
int dept, dest;
int last[maxn];
int inTree[maxn], vis[maxn];

set<node> front, ext, upd, rwre;
queue<int> q;


void prtall() {
    cout << "+++++++++++++++++++++\n";
    for (int i = 1; i <= n; ++i)
	prt(tau[i]);
    cout << "+++++++++++++++++++++\n";    
}

void prttre() {
    cout << "*********************\n";
    for (int i = 1; i <= n; ++i)
	printf("node:%d  pre:%d  val:%d\n",i, e[tau[i].p].from, e[tau[i].p].w_());
    cout << "*********************\n";    
}

// print out the route.
void prte(int x) {
    if (x == 0) return;
    if (x == dept) {
	printf("node:%d dist:%d+%d=%d\n", x, tau[x].c, tau[x].l, tau[x].c+tau[x].l);
	return;
    }
    prte(e[tau[x].p].from);
    printf("node:%d dist:%d+%d=%d\n", x, tau[x].c, tau[x].l, tau[x].c+tau[x].l);
} 

void add_edge(int u, int v, int w, int s) {
    e[++edg] = (edge){u, v, last[u], w, s}; last[u] = edg;
    e[++edg] = (edge){v, u, last[v], w, s}; last[v] = edg;
    e[edg].par = &e[edg-1];
    e[edg-1].par = &e[edg];
}

void eval(int u) {
    int edg_label = 0;
    for (; u; u = e[tau[u].p].from) {
	if (tau[e[tau[u].p].from].b == 0) { // backtracking to find border node.
	    edg_label = tau[u].p;
	    break;
	}
    }
  
    if (edg_label == 0) 
	assert(false);
  
    edge &_e = e[edg_label];
    if (_e.w() != inf) { // if the edge exists.
	tau[_e.to] = {_e.to, edg_label, tau[_e.from].c+_e.w(), 0, 0};
	upd.insert(tau[_e.to]); // its subtree need update
	if (_e.to == dest)
	    return;
    } else {
	/**
	   this part is a little bit confusing.
	   this block correspond to line 1~10 in Algorithm 5 in the paper.
	 **/
	while (q.size()) q.pop(); // subtree need rewire
    
	q.push(_e.to);
	while (q.size()) {
	    int _u = q.front();
	    q.pop();
	    vis[_u] = 0;
	    node &t = tau[_u];
	    if (front.count(t))
		front.erase(front.find(t));
	    t = {_u, t.p, inf, inf, inf}; // clear up nodes T_rewire
      
	    for (int i = last[_u]; i; i = e[i].nxt) { 
		node &_t = tau[e[i].to];
		if (inTree[_t.u] && e[_t.p].from == _u && vis[_t.u] == 0) {	  
		    q.push(_t.u);
		    vis[_t.u] = 1;
		}
	    }
	}

	q.push(_e.to);
    	
	while (q.size()) {
	    int _u = q.front();
	    q.pop();      
	    vis[_u] = 0;
	    inTree[_u] = 0;
    
	    node &t = tau[_u];
	    t.p = 0;
	    for (int i = last[_u]; i; i = e[i].nxt) { 
		node &_t = tau[e[i].to];
		if (inTree[_t.u] && _t.b < alpha && e[_t.p].from != _u) // if _u is not its father.
		    if (t.c + t.l > _t.c + _t.l + e[i].w_()) { // new parent is better, new parent has to be a node outside the subtree.
			t =  {_u,
			      i^1,
			      _t.c,
			      _t.l + e[i].w_(),
			      _t.b+1};
		    }

		if (inTree[_t.u] && e[_t.p].from == _u && vis[_t.u] == 0)  {
		    q.push(_t.u);
		    vis[_t.u] = 1;
		}
	    }
	    rwre.insert(t);
	}
    }
}

void update() {
    while (upd.size()) {
	node t = *upd.begin();
	upd.erase(upd.begin());
	bool succ_empty = true; 
	if (t.u != dest)
	    for (int i = last[t.u]; i; i = e[i].nxt) {
		node &_t = tau[e[i].to];
      
		if (inTree[_t.u] && e[_t.p].from == t.u) {
		    succ_empty = false;
		    if (_t.b == alpha) 
			front.erase(_t);
		    _t = {_t.u,
			  i,
			  t.c,
			  t.l+e[i].w_(),
			  t.b+1};
		    upd.insert(_t);
		}
	    }
	if (succ_empty)
	    ext.insert(t);
    }
}

void rewire() {
    while (rwre.size()) {
	node t = *rwre.begin();
	rwre.erase(rwre.begin());
	if (t < tau[t.u] || t < tau[t.u])
	    continue;
	if (!t.p) continue;

	inTree[t.u] = 1;

	if (t.b == alpha || t.u == dest) {
	    if (t.c + t.l < inf)
		front.insert(t);
	    continue;
	}

	if (t.b < alpha)
	    ext.insert(t);
	else
	    continue;
	
	for (int i = last[t.u]; i; i = e[i].nxt) {
	    node &_t = tau[e[i].to];
	    if (rwre.count(_t)) {
		if (t.c + t.l + e[i].w_() < _t.c + _t.l) {
		    rwre.erase(rwre.find(_t));
		    _t = {_t.u,
			  i,
			  t.c,
			  t.l+e[i].w_(),
			  t.b+1};
		    rwre.insert(_t);
		}
	    }
	}
    }
}

void extend() {
    while (ext.size()) {
	node t = *ext.begin();
	ext.erase(ext.begin());
	if (t.u == dest)
	    front.insert(t);
	else {
	    for (int i = last[t.u]; i; i = e[i].nxt) {
		node _t; // a temp node
		node &__t = tau[e[i].to]; 
		
		if (e[i].w_() == inf)
		    continue;

		_t = {__t.u,
		      i,
		      t.c,
		      t.l+e[i].w_(),
		      t.b+1};

		if (_t.c + _t.l > __t.c + __t.l)
		    continue;

		if (inTree[_t.u]) {
		    while (q.size()) q.pop();
		    q.push(_t.u);
		    
		    while (q.size()) {
			int u = q.front();
			inTree[u] = 0;
			q.pop();
			
			if (front.count(tau[u]))
			    front.erase(front.find(tau[u]));
			if (ext.count(tau[u]))
			    ext.erase(ext.find(tau[u]));
		    
			tau[u] = {u, 0, inf, inf, inf};
			for (int i = last[u]; i; i = e[i].nxt)
			    if (inTree[e[i].to] && e[tau[e[i].to].p].from == u)
				q.push(e[i].to);
		    }
		}
		
		__t = _t;
		if (__t.c + __t.l < inf) {// __.t.c + __t.l >= inf imply __t.c is not in the tree.		    		    
		    inTree[e[i].to] = 1;
		    if (__t.b == alpha)
			front.insert(__t);
		    else
			ext.insert(__t);
		}
	    }
	}	
    }
}
    
void LRA() {
    inTree[dept] = 1;
    for (int i = 1; i <= n; ++i)
	tau[i] = {i, 0, inf, inf, inf};
    tau[dept] = {dept, 0, 0, 0, 0};
    ext.insert(tau[dept]);
    extend();

    if (dept == dest) {
	cout << 0 << endl;
	return;
    }
    
    while (front.size()) {
	node t = *front.begin();
	front.erase(front.begin()); // get a frontier node

	//prt(t);
	// prtall();
	// prttre();
	// printf("\n\n\n\n");

	eval(t.u); // eval first lazy edge along the way to the root.

	if (upd.count(tau[dest])) 
	    break;

	update();
	rewire();
	extend();

	// prtall();
	// prttre();
	// printf("\n\n\n\n");
    }
    
    if (tau[dest].c+tau[dest].l < inf)
	assert(tau[dest].l == 0);
    prte(dest);
    printf("%d\n", min(inf, tau[dest].c+tau[dest].l)); 
    // for (int i = 1; i <= n; ++i)
    //   printf("node:%d dist:%d\n", i, tau[i].c + tau[i].l);
}

int main() {
    freopen("input.txt", "r", stdin);
    scanf("%d %d", &n, &m);
    
    for (int i = 1, u, v, w, s; i <= m; ++i) {
	scanf("%d %d %d %d", &u, &v, &w, &s);
	add_edge(v, u, w, s);
    }

    scanf("%d %d", &dept, &dest);
    LRA();
    cout << cnt << endl;
}
