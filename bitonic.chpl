/*
To run simply compile this file with
> chpl bitonic.chpl
> ./bitonic

Customize the output by running
> ./bitonic --size=32 // change array size
> ./bitonic --num_range=2 // change range of numbers
> ./bitonic --bitonic_verbose=true // print the arrays

Example
> ./bitonic --bitonic_verbose=true --size=8 --num_range=2

Begin to sort a random array of size 8
Time used to generate random numbers: 0.000504
1 0 1 0 1 1 0 1

Time used to do bitonic sort: 0.000936
0 0 0 1 1 1 1 1

Is the sorting correct: Yes

*/
use BitOps;
use Random;
use Time;

config const size: int = 16;
config const num_range: int = 1000;
config const bitonic_verbose: bool = false;

// Checks if the an array is bitonic
proc check_bitonic(ref A, n) {
    var minimum = A[0];
    var min_index = 0;
    var maximum = A[0];
    var max_index = 0;
    for i in 1..n-1 do {
        if minimum > A[i] then {
            minimum = A[i];
            min_index = i;
        } else if maximum < A[i] {
            maximum = A[i];
            max_index = i;
        }
    }

    var changes = 0;
    var pos = (min_index+1) % n;
    const end_pos = ((min_index-1) % n + n) % n;   // may have negative value

    while pos != end_pos do {
        // if detects turning point of a non-decreasing sequence
        if changes == 0 && A[pos] < A[((pos-1)%n+n)%n] then
            changes += 1;
        // if detects turning point of a non-increasing sequence
        else if changes == 1 && A[pos] > A[((pos-1)%n+n)%n] then
            return false;
        
        pos = (pos + 1) % n;
    }
    return true;
}

proc bitonic_merge(ref A, start, end, mode: bool=false) {
    if start >= end then return;

    var mid = (start+end)/2;
    
    //descending
    if mode then {
        forall (i, j) in zip(start..mid, 1..) do {
            if A[i] < A[mid+j] then A[i] <=> A[mid+j];
        } 
    }
    // ascending
    else {
        forall (i, j) in zip(start..mid, 1..)do {
            if A[i] > A[mid+j] then A[i] <=> A[mid+j];
        }
    }

    cobegin {
        bitonic_merge(A, start, mid, mode);
        bitonic_merge(A, mid+1, end, mode);
    }
}

proc gen_bitonic_sequence(ref A, start, end) {
    if end - start <= 1 then return;
    else {
        var mid = (start+end)/2;
        cobegin {
            gen_bitonic_sequence(A, start, mid);
            gen_bitonic_sequence(A, mid + 1, end);
        }
        cobegin {
            bitonic_merge(A, start, mid, false);
            bitonic_merge(A, mid+1, end, true);
        }
    }
}

proc bitonic_sort(ref A, n) {
    if n < 3 then halt("n must be greater or equal to 3");
    else if popcount(n) > 1 then halt("n must be a power of 2");

    gen_bitonic_sequence(A, 0, n-1);
    bitonic_merge(A, 0, n-1);
}

proc main() {
    var timer: Timer;
    timer.start();
    writeln("Begin to sort a random array of size ", size);
    var A:[0..size-1] int;

    // initializes A with random numbers
    fillRandom(A);
    forall elem in A {
        elem = elem % num_range;
        if num_range > 0 && elem < 0 then elem = -elem;
    }
    writeln("Time used to generate random numbers: ", timer.elapsed());
    timer.clear();
    if bitonic_verbose then writeln(A);
    writeln();

    bitonic_sort(A, size);
    writeln("Time used to do bitonic sort: ", timer.elapsed());
    timer.stop();
    if bitonic_verbose then writeln(A);
    writeln();

    if bitonic_verbose then {
        write("Is the sorting correct: ");
        if check_bitonic(A, size) then writeln("Yes");
        else writeln("No");
        writeln();
    }
}