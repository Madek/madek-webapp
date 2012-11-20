#= require_self
#= require_tree ./

window.Admin.Terms= 
  objects:{}

window.Admin.Terms.init_datatable = ->
  window.Admin.Terms.objects.data_table =

    $('#terms_datatable').dataTable
      bProccessing: true
      bServerSide: true
      sAjaxSource: 'terms/data/'
      aoColumnDefs: [
        { bSortable: false
        , aTargets: ["notsortable"] }
        { bSortable: true
        , aTargets: ["sortable"] }
      ]
      




