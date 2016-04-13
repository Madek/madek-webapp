# collect top-level components needed for ujs and/or server-side render:
UI =
  RightsManagement: require('./rights-management.cjsx')
  CreateCollection: require('./create-collection.cjsx')
  AskDeleteCollection: require('./ask-delete-collection.cjsx')
  SelectCollection: require('./select-collection.cjsx')
  CollectionResourceSelection: require('./collection-resource-selection.cjsx')
  FormResourceMetaData: require('./form-resource-meta-data.cjsx')
  Uploader: require('./uploader.cjsx')

  UI: require('./ui-components/index.coffee')
  Deco: require('./decorators/index.coffee')

module.exports = UI
