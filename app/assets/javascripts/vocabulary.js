window.App.vocabulary = function (config) {
  
  // This includes support for filterbar and slider on 
  // all 'vocabulary' pages (contexts and set/contexts).
  
  // config loks like this:
  // 
  //   var config = {
  //     elements: {
  //       container: '[data-filter-container="terms"]',
  //       filterbar: '[data-filter-control="bar"]',
  //       slider: '[data-filter-control="slider"]'
  //     }
  //   };

  // setup elements
  var container = $(config.elements.container);
  var filterbar = $(config.elements.filterbar);
  var slider = $(config.elements.slider);
  var sliderHandle = slider.find('[data-slider-handle-value]');
  
  // TODO: too css?
  sliderHandle.css({position:'relative'});
  sliderHandle.wrap('<span>').css({overflow:'hidden'});
  
  var state = {
    'mode': filterbar.find('.active').data('filter-mode'),
  };

  // get container height and set fixed value to prevent flicker
  container.css('height', container.height());
  
  // slider
  var setupSlider = function (elm, min, max, onMove, onChange) {
    elm.slider({
      min: min,
      max: max,
      step: 1,
      animate: 'fast',
      change: onChange,
      slide: onMove
    });
  };
  
  // setup the slider (elm, min, max, callback)
  setupSlider(
    $('[data-filter-control="slider"]').find('.ui-slider'), 
    1, 
    container.data('max-usage-count'), 
    // when the slider moves:
    function (event, ui) {
      if (ui.value) {
        var speed = 100;
        var easing = 'swing'; //'easeOutExpo'; // comes from $.UI
        
        if (!sliderHandle.isAnimating) {
          sliderHandle.isAnimating = true;
          
          // slide down
          sliderHandle.animate({top:'0.8em', opacity: 0}, speed, easing)
            // set value
            .text(ui.value)
            // put up
            .animate({top:'-0.8em'}, 0)
            // slide down again
            .animate({top:'0px', opacity: 1}, speed, easing, function () {
              sliderHandle.isAnimating = false;
            });
        } else {
          sliderHandle.text(ui.value);
        }
      }
    },
    // when the slider changes:
    function (event, ui) {
      if (ui.value) {
        filterByCount(ui.value);
      }
    }
  );
  
  // attach filterbar click handler
  filterbar.on("click", function (event) {
    var target = $(event.target);
    var mode = target.data('filter-mode');
    
    // only do it when the mode has changed
    if (mode !== state) {
      state = mode;
      
      // - set visual button state
      filterbar.find('[data-filter-mode]').removeClass('active');
      target.toggleClass('active');
      
      // - do per-button actions
      if (typeof filterbarHandler[mode] === 'function') {
        filterbarHandler[mode]();
      }
    }
    
    // always prevent default browser action
    return false;
  });
  
  // # filterbar mode handlers
  
  // - properties match button's "data-filter-mode"
  var filterbarHandler = {
    'all': function () {
      filterByCount(0);
      slider.hide();
    },
    'used': function () {
      filterByCount(1, 'fade');
      slider.hide();
    },
    'frequent': function () {
      filterByCount(1);
      slider.show();
    }
  };
  
  // # helper functions 
  var filterByCount = function (threshold, filterMode) {
    // find elements below threshold and filter them.
    // `filterMode` is either 'fade' or 'hide'
    
    // get the placeholder (shown when no items in list)
    function handlePlaceholder($element) {
      // if it's parent list is now empty, show placeholder
      var list = $element.parents('ul.ui-tag-cloud');
      var placeholder = list.find('[data-ui-role="empty_list"]');

      if (list.find('li:visible').length === 0) {
        placeholder.show();
      } else {
        placeholder.hide();
      }

    }
    
    function filter(on, $element) {
      // we toggle the parent coz they wrapped in a <li>
      if (on) {
        // handle filtermodes (toggle or fade)
        if (filterMode === 'fade') {
          $element.addClass('disabled');
        } else {
          // hide the tag
          $element.parent().hide(0, function () {
            handlePlaceholder($element);
          });
        }
      } 
      else { // off
        $element.removeClass('disabled');
        $element.parent().show(0, function () {
          handlePlaceholder($element);
        });
      }
    }
    
    container.find('[data-filter-target]').each(function () {
      var count = $(this).data('term-count') || 0;
      filter((count < threshold), $(this));
    });
    
  };

};