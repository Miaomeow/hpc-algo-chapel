use BitOps;
use Random;
use Time;

config const size: int = 8;
config const num_range: int = 100;
config const prefix_sum_verbose: bool = false;

proc hillisSteele() {

}

proc workEfficient(ref A, start, end, step) {
    if popcount(end) > 1 then halt("n must be a power of 2");
    else if start > end then return;

    forall i in start..end by step do {
        
        A[i] = A[i] + A[i-step/2];
    }

    workEfficient(A, start + step, end, step*2);

    if start == end then return;
    forall i in start+step/2..end-step/2 by step do {
        A[i] = A[i] + A[i-step/2];
    }

}

proc linear(ref A) {

    var prev: int = 0;
    for elem in A do {
        elem = elem + prev;
        prev = elem;
    }

}

proc main() {
    var timer: Timer;
    timer.start();
    writeln("Begin to turn random array of size ", size, " into prefix sum array");
    var A:[1..size] int;

    // initializes A with random numbers
    fillRandom(A);
    forall elem in A {
        elem = elem % num_range;
    }
    writeln("Time used to generate random numbers: ", timer.elapsed());
    writeln();
    timer.clear();

    writeln("Begin to start linear prefix sum calculation");
    var B = A;
    linear(B);
    writeln("Time used to run serial prefix sum is: ", timer.elapsed());
    writeln();
    timer.clear();

    writeln("Begin to start Work-efficient prefix sum calcuation");
    var C = A;
    workEfficient(C, 2, size, 2);
    writeln("Time used to run the work efficient algorithm is ", timer.elapsed());
    if prefix_sum_verbose then writeln(C);
    writeln();

    timer.stop();
}