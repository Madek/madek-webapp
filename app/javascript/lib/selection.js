/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import f from 'lodash'

const toExport = {
  createEmpty(callback) {
    return {
      selection: [],

      contains(resource) {
        return !!f.find(this.selection, { uuid: resource.uuid })
      },

      toggle(resource) {
        if (this.contains(resource)) {
          return this.remove(resource)
        } else {
          return this.add(resource)
        }
      },

      add(resource) {
        if (!this.contains(resource)) {
          this.selection.push(resource)
        }
        return callback()
      },

      empty() {
        return f.isEmpty(this.selection)
      },

      remove(resource) {
        this.selection = f.filter(this.selection, r => r.uuid !== resource.uuid)
        return callback()
      },

      toggleAll(all) {
        if (this.empty()) {
          this.selection = f.map(all, r => r)
        } else {
          this.selection = []
        }
        return callback()
      },

      clear() {
        this.selection = []
        return callback()
      },

      first() {
        if (this.length() < 1) {
          return null
        } else {
          return this.selection[0]
        }
      },

      length() {
        return f.size(this.selection)
      }
    }
  }
}

module.exports = toExport
