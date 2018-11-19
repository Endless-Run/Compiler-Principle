int main () {
    int arr[10];
    int i = 0, n, a = 0, b = 1;
    n = read();
    // Generate Fibonacci Sequence
    while(i<n) {
        int c = a + b;
        arr[i] = b;
        a = b;
        b = c;
        i++;
    }
    i = 0;
    arr[2]++;
    while(i<n) {
        write(arr[i]);
        i++;
    }
    return 0;
}
