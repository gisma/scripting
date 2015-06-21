#!/bin/bash
a=1
for a in [0-9]*.txt; do
echo "mv $a `printf %04d.%s ${a%.*} ${a##*.}`"
done
