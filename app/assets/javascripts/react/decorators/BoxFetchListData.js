import t from '../../lib/i18n-translate.js'
import f from 'active-lodash'
import xhr from 'xhr'
import setUrlParams from '../../lib/set-params-for-url.coffee'
import url from 'url'
import qs from 'qs'

var parseUrl = url.parse
var buildUrl = url.format
var buildQuery = qs.stringify
var parseQuery = qs.parse

module.exports = {

  loadJob(job, callback) {

    job.state = 'loading'

    var currentQuery = parseQuery(
      parseUrl(window.location.toString()).query
    )

    var parsedUrl = parseUrl(job.resource.list_meta_data_url, true)
    delete parsedUrl.search

    var url = setUrlParams(
      buildUrl(parsedUrl),
      currentQuery
    )

    xhr.get(
      {
        url: url,
        json: true
      },
      (err, res, json) => {

        if(err || res.statusCode > 400) {
          job.state = 'initial'
          callback()
          return
        }

        job.resource.list_meta_data = json
        job.state = 'done'

        callback()
      }
    )
  },

  loadJobs(jobQueue, callback) {

    var pendingJobs = f.filter(
      jobQueue,
      (j) => j.state == 'initial'
    )


    f.each(
      pendingJobs,
      (j) => this.loadJob(j, callback)
    )


  },

  todo(jobQueue, resources) {


    var pendingJobs = f.filter(
      jobQueue,
      (j) => j.state != 'done'
    )

    var isPending = (resourceId) => {
      var resource = f.find(
        pendingJobs,
        (j) => j.uuid == resourceId
      )
      return (resource ? true : false)
    }

    var resourcesTodo = f.filter(
      resources,
      (r) => !isPending(r.uuid) && !r.list_meta_data
    )

    var candidates = []
    if(pendingJobs.length < 10) {
      candidates = f.slice(
        resourcesTodo,
        0,
        10 - pendingJobs.length
      )
    }

    return pendingJobs.concat(

      f.map(
        candidates,
        (c) => {
          return {
            state: 'initial',
            uuid: c.uuid,
            resource: c
          }
        }
      )
    )

  }


}
