# Frontend Dev Docs

## Need to know

### `jQuery.fixed-table-headers`

- it is a [magic plugin](http://fixedheadertable.com) that takes care of fixed headers on tables
- it only works correctly if the table is actually visible
- our js never inits a (somehow) hidden table, so:
- if we ever `.show()` the table (or parent), **we need to initialize it ourselves!**
    - reason: `jQuery` does not have an `.on('show)` event we could hook into
    - for convienice, the correct function call is attached to the DOM element, use it like this:  
      ````js
      // find the table
      var thetable = $('.laterTableInit');
      // call attach function with el as arg
      selftable.get(0)._initTable(thetable);
      ````