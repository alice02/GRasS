gnuplot << EOF
  set terminal png
  set output 'public/images/graph-$1.png'
  unset key
  splot 'public/out.dat'
EOF
