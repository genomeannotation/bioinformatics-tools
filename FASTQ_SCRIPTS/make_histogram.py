#!/usr/bin/env python

import sys
import numpy as np
from bokeh.plotting import figure, show, output_file, vplot

# Check args
if len(sys.argv) != 2:
    sys.stderr.write("usage: make_histogram.py <list_of_read_counts.txt>\n")
    sys.exit()

# Read counts into a list
barcode_counts = []
with open(sys.argv[1], 'r') as counts:
    for line in counts:
        barcode_counts.append(int(line.strip()))

output_file('histogram.html')

p1 = figure(title="Barcode Read Counts",tools="save,box_zoom,pan,ywheel_zoom",
               background_fill="#E8DDCB")

barcode_counts = np.array(barcode_counts)
# TODO manually set bins
hist, edges = np.histogram(barcode_counts, density=False, bins=[0,100,200,300,400,500,600,700,800,900,1000,1500,2000,2500,3000,3500,4000,4500,5000,7500,10000])

p1.quad(top=hist, bottom=0, left=edges[:-1], right=edges[1:],
             fill_color="#036564", line_color="#033649",\
                     )

p1.xaxis.axis_label = 'Number of Reads'
p1.yaxis.axis_label = 'Barcode Count'

show(vplot(p1))
