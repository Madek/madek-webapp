((root)->

  # convenience function to loop over the matrix
  loop_m = (n,f) -> 
    for i in [0 .. n-1]
      for j in [0 .. n-1]
        if i isnt j
          f(i,j)

  square = (x) ->
    x * x

  clone_2d_array = (A) ->
    B=[]
    for i in [0 .. A.length-1]
      B[i]= A[i].slice 0
    B

  create_empty_nxn = (n)->
    A= new Array(n)
    for i in [0 .. n-1]
      A[i] = new Array(n)
    A

  floyd_warshall = (A) ->
    n = A.length
    D = clone_2d_array A
    for k in [0 .. n-1]
      for i in [0 .. n-1]
        for j in [0 .. n-1]
          if j isnt k isnt i  
            D[i][j] = Math.min D[i][j], D[i][k] + D[k][j] 
    D

  replace_infinite_values = (A,edge_length,component_separation) ->
    n = A.length
    D = clone_2d_array A
    loop_m n,(i,j) ->
      D[i][j] = (edge_length * component_separation) if not isFinite(D[i][j])
    D

  weight_matrix = (D)->
    n = D.length
    W = create_empty_nxn n
    loop_m n,(i,j) -> W[i][j] = square(1/D[i][j])
    W


  compute_new_layout = (M_dist, M_target, M_weight, current_pos)->
    n = M_dist.length
    C = M_dist; D = M_target; W = M_weight
    new_pos = {x:[],y:[]}
    for i in [0..n-1]
      sum_wi = 0
      for j in [0..n-1] when i isnt j
        sum_wi += W[i][j] 
      for d in ['x','y']
        numerator = 0
        for j in [0..n-1] when i isnt j
          pi = current_pos[d][i] 
          pj = current_pos[d][j]
          numerator += W[i][j] * ( pj + D[i][j] * (pi-pj)/ C[i][j])
        new_pos[d][i] =  numerator / sum_wi
    new_pos

  stress = (C,D) ->
    n = C.length
    sum = 0 
    loop_m n, (i,j) ->
      sum += square( D[i][j] - C[i][j]) / square(D[i][j])
    sum

  distance_matrix = (pos_arr) ->
    n = pos_arr.x.length
    M = create_empty_nxn n
    loop_m n, (i,j) ->
      M[i][j] = Math.sqrt( square(pos_arr['x'][i] - pos_arr['x'][j]) + square(pos_arr['y'][i] - pos_arr['y'][j]) )
    M 

  root.MDSCoreLayouter =
    compute_new_layout: compute_new_layout
    create_empty_nxn: create_empty_nxn
    distance_matrix: distance_matrix
    floyd_warshall: floyd_warshall
    loop_m: loop_m
    replace_infinite_values: replace_infinite_values
    stress: stress
    weight_matrix: weight_matrix


    )(if self? then self else window)

