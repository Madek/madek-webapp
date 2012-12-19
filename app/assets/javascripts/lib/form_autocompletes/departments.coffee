#
# * Department Selection
# *
# * This script provides functionalities for the extended
# * autocomplete field especialy for department selection
# *
#

FormAutocompletes = {} unless FormAutocompletes?
class FormAutocompletes.Departments

  constructor: (options)->
    @el = options.el
    @currentSearchResults = []
    @currentSearchTerm = undefined
    @ignoreList = ["verteilerliste", "Verteilerliste"] # ldap prefixes case insensetive e.g. verteilerliste will remove ldap groups like "Verteilerliste.123"
    @input_el = @el.find("#institutional_affiliation_autocomplete_search")
    do @delegateEvents
    @input_el.autocomplete
      minLength: 0
      source: (request, response)=> response @input_el.data("values")
      select: @selectDepartment
      appendTo: @input_el.closest(".multi-select-input-holder")
    @autocomplete = @input_el.autocomplete "widget"
    @autocomplete.addClass "department-autocomplete"

  delegateEvents: ->
    @input_el.on "focus", @openOnFocus
    @input_el.on "autocompletecreate", @createExtendedAutocomplete
    @input_el.on "autocompletesearch", @searchDepartment
    @input_el.on "autocompleteopen", @openExtendedAutocomplete
    @el.on "click", ".department-autocomplete .ui-navigator", @navigateDeeper
    @el.on "click", ".department-autocomplete .ui-menu-item-department.opened + .ui-navigator", @navigateHigher

  openOnFocus: (event) ->
    $(event.currentTarget).autocomplete "search", ""

  createExtendedAutocomplete: =>
    do @groupAllValues
    @input_el.addClass "department-selection"

  groupAllValues: =>
    allValues = @input_el.data "values"
    groups = {}
    
    # first split the ldap name and save as ldap_name
    $.each allValues, (index, option) ->
      group_elements = []
      
      # match ldap with regexp
      option.ldap = option.label.match(/\w*?\.\w*?\)$/)[0].replace("(", "").replace(")", "")
      
      # split (department_subunit_subunit)
      department_unit = option.ldap.split(".")[0].split("_")
      $.each department_unit, (index, element) ->
        
        # if department unit string size is smaller then 1 char append it to the last value
        if element.length is 1 and group_elements.length
          group_elements[group_elements.length - 1] = group_elements[group_elements.length - 1] + "" + element
        else
          group_elements.push element

      
      # split (.typeOfPersons)
      title = option.label #[#35836615 Pivotal]// option.label.replace(/\(\w*\..*?\)$/, "");
      group_elements.push option.ldap.split(".")[1]
      unit = option.ldap.split(".")[1]
      
      # initialize first element
      first_element = group_elements.shift()
      groups[first_element] = {}  if groups[first_element] is `undefined`
      parent = groups[first_element]
      
      # iterate children
      i = 0

      while i < group_elements.length
        
        # set parent
        parent[group_elements[i]] = {}  if parent[group_elements[i]] is `undefined`
        parent = parent[group_elements[i]]
        i++
      
      # set deepest info
      parent["_info"] = {}
      parent["_info"]["id"] = option.id
      parent["_info"]["title"] = title #[#35836615 Pivotal]// title + "(" + unit + ")";
      parent["_info"]["ldap"] = option.ldap

    
    # recursive fill up of group nodes
    @recursiveFillUp groups
    
    # prepare groups for autocomplete (create autocomplete options)
    allValues = []
    $.each groups, (index, group) ->
      unless group["_info"] is `undefined`
        children = []
        for child of group
          continue  if child is "_info"
          children.push group[child]
          delete group[child]
        
        # prepare autocomplete atributes
        group.ids = group["_info"]["_ids"]
        group.label = group["_info"]["_title"]
        group.ldap = ""
        group.selected = false
        group.children = children
        delete group["_info"]
      
      # when label is ampty dont add to options
      allValues.push group  unless group.label is ""
    
    # save the computed infos on the target
    @input_el.data "values", allValues

  recursiveFillUp: (current_element) =>
    $.each current_element, (index, elements) =>
      if elements["_info"] is undefined
        @recursiveFillUp elements
      else
        
        # depest element till here
        current_element["_info"] = {}  if current_element["_info"] is `undefined`
        
        # prepare ids
        current_element["_info"]["_ids"] = []  if current_element["_info"]["_ids"] is `undefined`
        current_element["_info"]["_ids"].push elements["_info"]["id"]  unless elements["_info"]["id"] is `undefined`
        
        # push current title to possible titles of parent
        current_element["_info"]["_titles"] = []  if current_element["_info"]["_titles"] is `undefined`
        current_element["_info"]["_titles"].push elements["_info"]["title"]

    
    # push ids
    unless current_element["_info"] is `undefined`
      $.each current_element, (index, elements) ->
        if elements["_info"] isnt `undefined` and elements["_info"]["_ids"] isnt `undefined`
          current_element["_info"]["_ids"] = []  if current_element["_info"]["_ids"] is `undefined`
          $.each elements["_info"]["_ids"], (index, id) ->
            current_element["_info"]["_ids"].push id


    
    # compute one single title of list of childrens titles
    if current_element["_info"] and current_element["_info"]["_titles"]
      
      # replace parenthesis on each element first
      $.each current_element["_info"]["_titles"], (index, current_title) =>
        current_element["_info"]["_titles"][index] = @stripUnitsInParenthesis(current_title)

      
      # fill title
      _title = @fillUpTitlte(current_element["_info"]["_titles"])
      current_element["_info"]["_title"] = @stripUnitsInParenthesis(_title)
      current_element["_info"]["_shorttitle"] = current_element["_info"]["_title"].replace(/\(.*?\)$/, "")
      delete current_element["_info"]["_titles"]

  stripUnitsInParenthesis: (title) ->
    title.replace(/\..*?\)/, ")")

  fillUpTitlte: (titles) ->
    matched_title = undefined
    i = 0

    while i < titles.length
      if matched_title is `undefined` or matched_title.length is 0
        matched_title = titles[i]
        
        # if there are not more then 1 element break insted of continue
        if titles.length is 1
          _title = matched_title
          break
        else
          continue
      else if matched_title is titles[i]
        _title = matched_title
        break
      i++
    matched_title

  openExtendedAutocomplete: (event, ui) =>
    @autocomplete.find(".ui-menu-item").addClass("ui-menu-item-department")
    do @addNavigation
    @autocomplete.find("li").each (index, item) -> $(item).remove() if $(item).html().length is 0

  addNavigation: ->
    @autocomplete.find(".ui-menu-item-department").each (i, item) =>

      # continue loop if corner all already has department class
      unless $(item).find(".ui-corner-all").hasClass("department")
        
        # add department class
        $(item).find(".ui-corner-all").addClass "department"
        
        # if current elemetn is selected mark as selected        
        unless @isSelected(item)
          
          # if any child add navigation
          if $(item).data("uiAutocompleteItem")? and @anyChildren $(item).data("uiAutocompleteItem").children
            childrenAsString = (_.map (_.select $(item).data("uiAutocompleteItem").children,(child)-> child._info? and child._info._shorttitle? and child._info._shorttitle.length), (child)-> child._info._shorttitle).join(", ")
            $(item).addClass "has-navigator"
            $(item).after App.render "media_resources/edit/departments/subdepartments", {children: childrenAsString}
            
            # positioning arrows
            $(item).find(".ui-navigator .arrow").each ->
              height = $(this).closest(".ui-navigator").outerHeight()
              $(this).css "top", height / 2 - $(this).outerHeight() / 2

  isSelected: (item) ->
    is_selected = false
    selected_items = $("#institutional_affiliation_autocomplete_search").closest("li").prevAll(".bit-box")
    $.each selected_items, (i_s_item, selected_item) ->
      is_selected = true  if JSON.stringify($(selected_item).data().ids) is JSON.stringify($(item).data("uiAutocompleteItem").ids)

    if is_selected
      $(item).addClass "selected"
      $(item).find(".ui-corner-all").addClass("with-navigator").addClass "department"
      $(item).find(".ui-corner-all").after $("<div class='selected-marker'><div class='icon'></div></div>")
    is_selected

  anyChildren: (children) ->
    return unless children?
    result = false
    $.each children, (i_child, child) ->
      unless child["_info"] is `undefined`
        $.each child, (i_value, value) ->
          result = true  unless i_value is "_info"
    result

  navigateDeeper: (event)=>
    navigator = $(event.currentTarget)
    navigator.addClass "back"
    department = navigator.prev(".ui-menu-item-department")
    department.removeClass("has-navigator").addClass("opened")
    @autocomplete.find(".ui-menu-item-department:not(.opened), .ui-navigator:not(.back)").each -> $(this).remove()
    @addChildren department.data("uiAutocompleteItem").children
    do @addNavigation

  addChildren: (children) ->
    $.each children, (index, child) =>
      
      unless child["_info"] is undefined
        
        if child["_info"]["id"] is undefined
          new_item = $("<li class=\"ui-menu-item ui-menu-item-department\" role=\"presentation\"><a class=\"ui-corner-all\" tabindex=\"-1\"></a></li>")
          label = child["_info"]["_title"]
          $(new_item).find("a").html label
          @autocomplete.append new_item
          
          # prepare for autocomplete
          autocomplete_object = {}
          autocomplete_object.label = label
          autocomplete_object.ids = child["_info"]["_ids"]
          
          # compute children for autocomplete object
          children = []
          $.each child, (i_value, value) ->
            children.push value

          autocomplete_object.children = children
          $(new_item).data "uiAutocompleteItem", autocomplete_object

  navigateHigher: (event) =>
    navigator = $(event.currentTarget)
    navigator.removeClass "back"
    department = navigator.prev(".ui-menu-item-department")
    department.addClass("has-navigator").removeClass("opened")
    navigator.nextAll(".ui-menu-item-department, .ui-navigator").each -> $(this).remove()
    
    higherLevelDepartment = department.prevAll(".ui-menu-item-department")
    unless higherLevelDepartment.length
      do @reset
    else
      @addChildren higherLevelDepartment.data("uiAutocompleteItem").children
      do @addNavigation

  reset: ->
    do @input_el.blur
    do @input_el.focus

  selectDepartment: (event, ui)=>
    department = ui.item
    input = $(event.target)
    holder = input.closest(".multi-select-holder")
    return true if holder.find(".multi-select-tag[data-label='#{department.label}']").length
    index = holder.closest(".ui-form-group").data "index"
    multiselect = holder.find(".multi-select-input-holder")
    multiselect.before App.render "media_resources/edit/multi-select/department", {department: department, index: index}
    input.val ""
    return false

  searchDepartment: (event, ui) =>
    window.setTimeout (=>
      @currentSearchTerm = @input_el.val()
      return true if @currentSearchTerm.length == 0
      @autocomplete.html ""
      
      # search all options      
      for value in @input_el.data("values")
          
        # start searching top levels
        regexp = new RegExp(@currentSearchTerm, "ig")
        if value.label? and value.label.search(regexp) > -1
          
          # prepare value for output
          value["_info"] = {}
          value["_info"]["_title"] = value.label
          value["_info"]["_ids"] = value.ids
          
          # add to search results
          @currentSearchResults.push value
        
        # now go on searching in deeper levels
        if value.children? and value.children.length
          for child in value.children 
            @recursiveSearch child
      
      # create search result elements
      @addChildren @currentSearchResults
      
      # add selectded-marker
      # search if current element is currently selected
      @autocomplete.find(".ui-menu-item-department").each (index, item) => @isSelected item
      
      # force to show search results if there are some
      @autocomplete.show()  if @currentSearchResults.length
      
      # clean currentSearchTerm and results
      @currentSearchResults = []
      @currentSearchTerm = undefined
    ), 30

  recursiveSearch: (target) ->
    
    # break if _info does not exists or _title is empty
    return  if target["_info"] is `undefined`
    return  if target["_info"]["_title"] is `undefined`
    
    # search current title
    regexp = new RegExp(@currentSearchTerm, "ig")
    @currentSearchResults.push target  if target["_info"]["_title"].search(regexp) > -1
    
    # if any children search there as well
    if @anyChildren target
      $.each target, (i, child) =>
        @recursiveSearch child

window.App.FormAutocompletes = {} unless window.App.FormAutocompletes
window.App.FormAutocompletes.Departments = FormAutocompletes.Departments