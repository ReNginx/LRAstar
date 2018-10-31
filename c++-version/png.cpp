#include <cstdio>
#include <cstdlib>
#include <algorithm>
#include <iostream>

using namespace std;
int n, m;
int main() {
    freopen("input.txt", "r", stdin);
    freopen("g.dot", "w", stdout);
    cout << "graph ER {" << endl;
    cout << "rankdir=LR;" << endl;
    
    cin >> n >> m;
    for (int i = 1; i <= m; ++i) {
	int u, v, w, z;
	cin >> u >> v >> w >> z;
	printf("%d -- %d [label=\"%d,%d\"]%c\n", u, v, w, z, i != m ? ';' : ';');
    }
    cin >> n >> m;
    printf("label=\"dept:%d, dest:%d\"}", n, m);
    
    fclose(stdout);
    system("dot -Tpng g.dot -o g.png");
}
