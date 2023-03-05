import htsparse/cpp/cpp

let str = """
int main () {
  std::cout << "Hello world";
}
"""

echo parseCppString(str).treeRepr()