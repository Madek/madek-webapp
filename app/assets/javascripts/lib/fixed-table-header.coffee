###

FixedTableHeader

- makes fixed header on header with class `fixed-table-header`
- if the table is initially hidden, calculations are wrong!
    - we need to take care of those separately

###

# actual init function
initFHT = (table) ->
  table.fixedHeaderTable
    height: if table.hasClass("medium") then 260 else 400

# init now or later
jQuery -> 
  for table in $("table.fixed-table-header")
    do (table)->
      table = $ table
      
      if table.is(':visible')
        initFHT table
      else
        # we find out which element is actually hidden (if we ever use events):
        
        # is table hidden because of hidden parent?
        hiddenEl = table.parents().closest(':hidden')
        
        # if not, it is the table itself!
        hiddenEl = table if hiddenEl?
        
        hiddenEl.addClass('laterTableInit') # just to find it later
        hiddenEl.get(0)._initTable = initFHT # attach function
