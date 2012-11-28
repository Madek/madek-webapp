//= require active_admin/base

$(document).ready(function(){
  $(".index_table tbody").has(".handler").sortable({
    handle: '.handler',
    axis: 'y',
    update: function(event, ui){
      $.ajax({
        url: $(event.target).find(".handler").data("url"),
        type: 'PUT',
        data: $(event.target).sortable('serialize'),
        success: function(){
          $(event.target).find("td").effect("highlight", {}, 2000);
        }
      });
    }
  });
});