(function($) { 
	$.fn.flickrmenu = function(options) { 
	
		var defaults = {
			headClass: "head_menu",
			subClass: "sub_menu",
			arrowClass: "arrow",
			arrowPic: "arrow.png",
			arrowPicA: "arrow_select.png",
			arrowPicH: "arrow_hover.png",
		};
		
		var options = $.extend(defaults, options); 
	
		return this.each(function() {

			var head_class = options.headClass;
			var sub_class = options.subClass;
			var arrow_class = options.arrowClass;
			var arrow = options.arrowPic;
			var arrow_select = options.arrowPicA;
			var arrow_hover = options.arrowPicH;
			
			var menu_id = this.id;			
			var obj = $(this);
			var headlevels = $('.' + head_class, obj);
			var arrows = $('.' + arrow_class, obj)
			
			arrows.click(function() {
				$('span.' + head_class).removeClass('active');
				submenu = $(this).parent().parent().find('div.' + sub_class);
				
				if(submenu.css('display')=="block"){
					$(this).parent().removeClass("active"); 	
					submenu.hide(); 		
					$(this).attr('src', arrow_hover);									
				}else{
					$(this).parent().addClass("active"); 	
					submenu.fadeIn(); 		
					$(this).attr('src', arrow_select);	
				}
				
				$('div.' + sub_class + ':visible').not(submenu).hide();
				$('img.' + arrow_class).not(this).attr('src', arrow);
				
			})
			.mouseover(function(){ $(this).attr('src', arrow_hover); })
			.mouseout(function(){ 
				if($(this).parent().parent().find('div.' + sub_class).css('display')!="block"){
					$(this).attr('src', arrow);
				}else{
					$(this).attr('src', arrow_select);
				}
			});
			
			
			$('span.' + head_class).mouseover(function(){ 
				$(this).addClass('over')
			}).mouseout(function(){ 
				$(this).removeClass('over') 
			});

			$('div.' + sub_class).mouseover(function(){ 
				$(this).fadeIn(); 
			}).blur(function(){ 
				$(this).hide();
				$('span.' + head_class).removeClass('active');
			});
			
			$(document).click(function(event){ 		
				var target = $(event.target);
				if (target.parents('#' + menu_id).length == 0) {
					$('#'+ menu_id + ' span.' + head_class).removeClass('active');
					$('#'+ menu_id + ' div.' + sub_class).hide();
					$('#'+ menu_id + ' img.' + arrow_class).attr('src', arrow);
				}
			});
		});
	}; 
})(jQuery);