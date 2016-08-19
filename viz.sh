#!/usr/bin/env gnuplot
set terminal png size 440,220 enhanced font 'Source Code Pro for Powerline,10'
set output 'x.png'
set samples 300
set encoding utf8
set title "Experimenting with\nK-Means by \\@otobrglez"
set xlabel "x"
set ylabel "y"
set autoscale fix
set size square
set datafile separator ","
set tics scale 0.50
set key samplen 5 spacing 1 font ",4"

unset colorbox
unset key
unset xtics
unset ytics
unset ztics
unset xlabel
unset ylabel
unset label
# unset border

set xrange [*:]
set yrange [*:]
set palette defined ( 0 '#E41A1C',\
    	    	      1 '#377EB8',\
                      2 '#4DAF4A',\
                      3 '#984EA3',\
                      4 '#FF7F00',\
                      5 '#FFFF33',\
                      6 '#A65628',\
                      7 '#F781BF' )
# test palette

# set offsets 1.1, 1.1, 1.1, 1.1

plot './data.dat' using 1:2:3 with points pointtype 109 pointsize 2 palette
