###

FixedTableHeader

###

jQuery -> 
  for table in $("table.fixed-table-header")
    do (table)->
      table = $ table
      table.fixedHeaderTable
        height: if table.hasClass("medium") then 260 else 400
