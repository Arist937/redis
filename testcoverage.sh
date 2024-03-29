#!/bin/bash

# Check if .gcda files already exist
gcda_files=$(find "src" -type f -name "*.gcda")

if [ -z "$gcda_files" ]; then
    echo "Running make gcov and make test..."

    # Compiling Redis with gcov support
    make gcov
    if [ $? -ne 0 ]; then
        echo "Compilation with gcov support failed. Exiting..."
        exit 1
    fi

    # Running Redis tests
    make test
fi

# Proceed with generating test coverage reports
echo "Generating test coverage reports..."

# Change to the directory where .gcda files are expected to be generated
cd "src"

# Find and process each .gcda file in the current directory
output_file="../testcoverage.txt"
echo -e "Test Coverage Report\n" > $output_file

for gcda_file in *.gcda; do
    gcda_base=$(basename "$gcda_file" .gcda)
    echo "Processing $gcda_base..."

    gcov_output=$(gcov $gcda_base | sed -n '2p')
    if [ -n "$gcov_output" ]; then
        prefix="Lines executed:"
        percentage="${gcov_output#$prefix}"

        # Run gcov on gcda file
        echo "$gcda_base: $percentage lines" >> $output_file 2> "/dev/null"
    fi
done

echo "Test coverage reports generated to testcoverage.txt."