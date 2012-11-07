Visualization.Functions.bbox = (svg_elements) ->
  _.chain(svg_elements)
    .map((e)-> e.getBBox())
    .reduce(
      ((A,rect)->[Math.min(A[0],rect.x),Math.min(A[1],rect.y),Math.max(A[2],rect.x+rect.width),Math.max(A[3],rect.y+rect.height)])
      ,[Number.MAX_VALUE,Number.MAX_VALUE,Number.MIN_VALUE,Number.MIN_VALUE])
    .value()

Visualization.Functions.box_add= (box,val)->
  [ box[0]+val[0], box[1]+val[1], box[2]+val[2], box[3]+val[3] ]


Visualization.Functions.center_of_box = (box) ->
  [box[0]+(box[2]-box[0])/2, box[1]+(box[3]-box[1])/2]


Visualization.Functions.is_very_modern_browser= ->
  (BrowserDetection.name() is 'Chrome' and BrowserDetection.major_version() >= 20) or (BrowserDetection.name() is 'Safari' and BrowserDetection.major_version() >= 6)
