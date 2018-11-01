#include <cstdio>
#include <cstdlib>
#include <set>
#include <algorithm>
#include <string>
#define ind(x, y) (c*(x-1) + (y))
using namespace std;

const int maxn = 2e5 + 10, inf = 0x3f3f3f3f, maxw = 1000;
typedef pair<int, int> pii;
// int n = 2000, m = 60000;
// int f[maxn];
// set<pair<int, int> > s;
int r = 50, c = 50;
int main() {
    srand(time(0));
    freopen("input.txt", "w", stdout);
    
    // printf("%d %d\n", n, m);

    // for (int i = 2; i <= n; ++i)
    // 	f[i] = rand() % (i-1) + 1;

    // for (int i = 2; i <= n; ++i) {
    // 	int w = rand() % maxw+1;
    // 	printf("%d %d %d %d\n", i, f[i], w, w);
    // 	s.insert(pii(min(i, f[i]), max(i, f[i])));
    // }

    // for (int i = 1; i <= m-n+1; ++i) {
    // 	int lw = rand() % maxw+1;
    // 	int w = rand() % 10 < 3 ? inf : lw;
    // 	int x = rand() % n+1, y = rand() % n+1;
    // 	for (; s.count(pii(min(x,y), max(x,y))) != 0; x = rand() % n+1, y = rand() % n+1);
    // 	s.insert(pii(min(x,y), max(x,y)));
    // 	printf("%d %d %d %d\n", x, y, w, lw);
    // }
    // printf("%d %d\n", 1, rand() % n + 1);

    printf("%d\n%d\n", r*c, 2*r*c - r - c);
    printf("%d\n%d\n", 1, rand() %(r*c)+1);
    printf("%d\n", 5);
    
    for (int i = 1; i < r; ++i)
      for (int j = 1; j <= c; ++j) {
    	int lw = rand() % maxw+1;
    	int w = rand() % 10 < 3 ? inf : lw;
    	printf("%d\n%d\n%d\n%d\n", ind(i,j), ind(i+1, j), w, lw);
      }
    for (int i = 1; i < c; ++i)
      for (int j = 1; j <= r; ++j) {
    	int lw = rand() % maxw+1;
    	int w = rand() % 10 < 3 ? inf : lw;
    	printf("%d \n%d\n%d\n%d\n", ind(j,i), ind(j, i+1), w, lw);
      }
}

