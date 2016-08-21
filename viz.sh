#!/usr/bin/env gnuplot
load 'config.gp'

set offsets 1.1, 1.1, 1.1, 1.1

set output 'x.png'

plot './data.dat' using 1:2:3 with points pointtype 109 pointsize 2 palette

