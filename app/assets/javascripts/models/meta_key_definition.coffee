class MetaKeyDefinition

  constructor: (data)->
    for k,v of data
      @[k] = v
    @

  getKeyByName: (metaKeyName)-> _.find @meta_keys, (key) -> key.name is metaKeyName


window.App.MetaKeyDefinition = MetaKeyDefinition