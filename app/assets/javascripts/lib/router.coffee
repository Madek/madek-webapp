url = require('url')
f = require('active-lodash')
t = require('./i18n-translate.js')
History = require('history/lib/createBrowserHistory')
useBeforeUnload = require('history/lib/useBeforeUnload')

history = useBeforeUnload(History)()

module.exports =
  listen: history.listen
  start: ()-> history.replace(window.location)
  goTo: (path)->
    history.push(url.parse(path)?.path)
  setTo: (location)-> history.replace(location)
  goBack: ()-> history.goBack()

  confirmNavigation: (config = {})-> # NOTE: like `listen`, returns a 'stop' func
    {msg, check} = f.defaults config, {
      msg: t('app_confirm_form_leave_msg'),
      check: (()-> true) }

    # listener for page *navigation* - fn can check the new location if needed
    history.listenBefore((location)->
      if check(location) then return msg)

    # listener for page *leaving* (close/refresh/…)
    # NOTE: browsers show a default text in case of "leaving",
    # BUT anyhow want a non-empty string returned…
    history.listenBeforeUnload(()-> if check() then return msg)
