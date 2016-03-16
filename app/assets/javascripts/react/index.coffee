# collect top-level components needed for ujs and/or server-side render:
UI =
  RightsManagement: require('./rights-management.cjsx')
  CreateCollection: require('./create-collection.cjsx')
  SelectCollection: require('./select-collection.cjsx')
  FormResourceMetaData: require('./form-resource-meta-data.cjsx')
  Uploader: require('./uploader.cjsx')

  UI: require('./ui-components/index.coffee')
  Deco: require('./decorators/index.coffee')

module.exports = UI
