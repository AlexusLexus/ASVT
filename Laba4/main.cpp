
#include <iostream>

extern "C" float findMin(float start, float end, int n, float* x_at_min);

int main() {
    float start, end;
    int n = 0;
    float t = 0.0f;

    std::cout << "n: ";
    std::cin >> n;
    std::cout << "x_min: ";
    std::cin >> start;
    std::cout << "x_max: ";
    std::cin >> end;

    float result = findMin(start, end, n, &t);

    printf("min(f(%.2f)) = %f\n", t, result);

    return 0;
}