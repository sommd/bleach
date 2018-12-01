#!/bin/sh

empty() (
    len="$(wc -c)"
    [ "$len" = 0 ]
)

for dir in */; do (
    cd "$dir"
    
    for test in test.*; do
        if [ -x "$test" ]; then
            echo "$test:"
            
            ./"$test" | empty &&
            ./"$test" || echo "Test failed"
        else
            echo "$test: Not executable, skipping..." 1>&2
        fi
    done
) done
