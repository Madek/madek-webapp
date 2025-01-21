/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
module.exports = () => {
  const metaTag =
    typeof document !== 'undefined' && document.querySelector('meta[name="csrf-token"]')
  return metaTag ? metaTag.getAttribute('content') : null
}
