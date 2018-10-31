#include <iostream>
#include <algorithm>

using namespace std;

int main() {
  while (true) {
      system("./gen");
      system("./astar");
      system("./lazy");
      getchar();
    // system("./dijk > d.txt");
    // system("./astar > a.txt");
    // if (system("diff d.txt a.txt")) {
    //   cout << "fail\n";
    //   exit(0);
    // }
    // cout << "OK\n";
  }
}
