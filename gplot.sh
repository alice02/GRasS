gnuplot << EOF
  set terminal png
  set output '/home/pi/gomihiroi/grass/public/images/graph-$1.png'
  splot '/home/pi/gomihiroi/grass/public/out.dat'
EOF
