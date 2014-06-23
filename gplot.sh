gnuplot << EOF
  set terminal png
  set output 'public/images/graph-$1.png'
  unset key
  splot 'public/out.dat' w pm3d
EOF
