// just a quick and dirty test using the 'people search' JSON API
window.log=[];

// multi-source searching adapter lib:
Bloodhound = require('typeahead.js/dist/bloodhound.js').noConflict()

var peopleApi = new Bloodhound({
  // FIXME: datumTokenizer
  // - 'sch' has results but doesnt show)
  // - also the function is never called o_O
  datumTokenizer: function(d) {
    console.log(d);
    throw 'wtf';
    return Bloodhound.tokenizers.whitespace(d.name)
  },
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  // FIXME: also never called o_O
  identify: function (d) {
    console.log(d);
    return d.uuid
  },
  remote: {
    url: '/people.json?search_term=%QUERY',
    wildcard: '%QUERY',
    transform: function (json) {
      console.log('search result:', json);
      return json;
    }
  }
});

module.exports = function () {
  $('[data-autocomplete="person"]').each(function () {
      $input = $(this);
      // add the visual representation of the selected value:
      uiList = $('<ul class="multi-select-visual-list ui-tag-cloud elipsed"></ul>');
      $input.before(uiList);


      updateUiList = function (e, dat) {
        console.log('selected:', dat);
        person_tag = $('<li class="ui-tag-cloud-item">'
          + '<a class="ui-tag-button" href="'+dat.url+'">'
          + dat.name+'</a></li>'
        )
        // tmp: just 1 value allowed
        uiList.html(person_tag);
        // also clear the input field
        $input.typeahead('val', '');
      }

      // init typeahead autocompletion
      $input.typeahead({
        hint: false,     // show best-match inside input field?
        highlight: false, // highlight sub-string matches?
        minLength: 1,    // how many chars to type before suggesting?
        classNames: {
          wrapper: 'multi-select-input',
          input: 'multi-select-input',
          hint: 'ui-autocomplete-hint',
          menu: 'ui-autocomplete ui-menu',
          cursor: 'ui-autocomplete-cursor',
          suggestion: 'ui-menu-item'
        }
      },
      {
        name: 'api',
        source: peopleApi,
        key: 'name',
        displayKey: 'name'
      }) // add events
      .on('typeahead:select', updateUiList)
      .on('typeahead:autocomplete', updateUiList)
      .on('typeahead:render', function (event,b,c,d) {
        console.log('render', b, c, d);
      });
  });
}
