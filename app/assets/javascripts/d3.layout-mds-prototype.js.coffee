d3.layout.mdsprototype= ->

  n = m = null
  needs_initialization = true
  nodes = []
  links = []
  link_distance = 100
  index_id_map = {}
  id_index_map = {}
  A = [] # adjacency matrix
  D = [] # target distance, i.e. graph theoretic distance
  W = [] # weight 

  # convenience function to loop over the matrix
  loop_m = (n,f) -> 
    for i in [1 .. n-1]
      for j in [0 .. i-1]
        f(i,j)

  # convenience function for getting matix values by arbitrary index 
  mvalue = (M,i,j)->
    if i > j
      M[i][j]
    else if i < j
      M[j][i]
    else
      throw new Error "this should never happen"


  create_empty_nx0 = (n)->
    A=[]
    for i in [0 .. n-1]
      A[i] = []
    A

  clone_2d_array = (A) ->
    B=[]
    for i in [0 .. A.length-1]
      B[i]= A[i].slice 0
    B

  floyd_warshall = (A) ->
    D = clone_2d_array A
    for k in [0 .. n-1]
      for i in [1 .. n-1]
        for j in [0 .. i-1]
          if j < k < i  
            D[i][j] = Math.min D[i][j], D[i][k] + D[k][j] 
    D


  replace_infinite_values = (A) ->
    D = clone_2d_array A
    max_dist = 0
    for i in [1 .. n-1]
      for j in [0 .. i-1]
        max_dist = Math.max max_dist, D[i][j] if isFinite(D[i][j])
    max_dist = max_dist + max_dist * 1/3
    for i in [1 .. n-1]
      for j in [0 .. i-1]
        D[i][j] = max_dist if not isFinite(D[i][j])
    D

  compute_weight_matrix = (D)->
    W = create_empty_nx0 n
    loop_m n,(i,j) -> W[i][j] = Math.pow((1/D[i][j]),2)
    W


  set_initial_coordinates_if_not_present = ->

    d = Math.ceil(Math.sqrt(n)) 

    for k in [0 .. n-1]
      i = k % d
      j = Math.floor(k / d)
      node = nodes[k]
      node.x = i unless node.x?
      node.y = j unless node.y?
 

  initialize = ->
    # once done remove A completely, it is essentially for prototyping/debugging
    n = nodes.length
    m = links.length
    A = create_empty_nx0 n
    for i in [0..n-1]
      id_index_map[nodes[i].id] = i 
      index_id_map[i]=nodes[i].id

    for i in [1..n-1]
      for j in [0..i-1]
        A[i][j]= Number.POSITIVE_INFINITY
   
    for link in links
      i = Math.max id_index_map[link.source.id], id_index_map[link.target.id]
      j = Math.min id_index_map[link.source.id], id_index_map[link.target.id]
      A[i][j] = if typeof link_distance is 'number' then link_distance else link_distance(link)
    
    needs_initialization = false

    D = floyd_warshall A

    D = replace_infinite_values D

    W = compute_weight_matrix D

    set_initial_coordinates_if_not_present()

    event.initalization_done()


  layout = ->

    # jiggling prevents problems with bad initial layout but should not show
    # (much) randomness in the resulting layout
    for node in nodes 
      node.x += (Math.random()-0.5) / 10000000
      node.y += (Math.random()-0.5) / 10000000

    # current distance 
    CD = create_empty_nx0 n
    loop_m n,(i,j)->
      ni = nodes[i]
      nj = nodes[j]
      CD[i][j] = Math.sqrt( Math.pow(ni.x - nj.x,2) + Math.pow(ni.y - nj.y,2) )
    
    new_pos = {x:[],y:[]}

    for i in [0..n-1]
      sum_wi = 0
      for j in [0..n-1] when i isnt j
        sum_wi += mvalue W,i,j 
      for d in ['x','y']
        numerator = 0
        for j in [0..n-1] when i isnt j
          pi = nodes[i][d]
          pj = nodes[j][d]
          numerator += mvalue(W,i,j) * ( pj + mvalue(D,i,j) * (pi-pj)/( mvalue(CD,i,j)))

        new_pos[d][i] =  numerator / sum_wi

    for node in nodes
      node.x = new_pos.x[id_index_map[node.id]]
      node.y = new_pos.y[id_index_map[node.id]]


  event = d3.dispatch("tick", "initalization_done", "iteration_start", "iteration_end")
 
  mdsprototype = 
    nodes: (x)-> if x? then nodes = x; needs_initialization=true; mdsprototype else nodes
    links: (x)-> if x? then links = x; needs_initialization=true; mdsprototype else links 
    link_distance: (x)-> if x? then link_distance = x; needs_initialization=true; mdsprototype else link_distance

    tick: () ->
      initialize() if needs_initialization
      layout()
      event.tick()

    start: ->
    stop: ->


  d3.rebind(mdsprototype,event,"on")


