import React from 'react'
import f from 'lodash'
import setUrlParams from '../../../lib/set-params-for-url.coffee'
import AppRequest from '../../../lib/app-request.coffee'
import asyncWhile from 'async/whilst'
import { parse as parseUrl } from 'url'
import { parse as parseQuery } from 'qs'
import Moment from 'moment'

import ActivityStream from '../../decorators/UserActivityStream'

Moment.locale('de')

// ui config
const SECTIONS = [ 'created_contents', 'edited_contents', 'shared_contents' ]
const CLUSTER_INTERVAL_MINUTES = 60

// fetching config
const AUTO_FETCH = true
const BATCH_TIME = 7 * 24 * 60 * 60
// 7 days
const LOOP_TIME = 50
// dont fetch more than that to not overload the client
const MAX_ITEMS = 300

class MyTimeline extends React.Component {
  constructor (initialProps) {
    super()
    this.state = {
      isClient: false,
      endOfStream: false,
      shouldFetchPast: AUTO_FETCH,
      ...parseStreamInfo(initialProps.get)
    }
  }
  componentDidMount () {
    this.setState({ isClient: true })

    // if the stream is already empty, otherwise set signal to start fetching
    if (f.isEmpty(this.state.stream)) {
      return
    } else {
      this.setState({ shouldFetchPast: true })
    }

    // start fetching loop into the past
    this.state.shouldFetchPast && asyncWhile(() =>
        this.state.shouldFetchPast && !this.state.endOfStream, loopCallback => {
      this.setState({ fetchingPast: true })
      this._fetchActivityStreamPast(this.props.get.url, (err, res) => {
        if (err) return loopCallback(err)

        const streamInfo = parseStreamInfo(res)
          // if there are no more events, we reached the end
        if (streamInfo.stream.length < 1) {
          this.setState({ fetchingPast: false, endOfStream: true })
            // otherwise, update timestamps and add new items:
        } else {
          const totalStream = this.state.stream.concat(streamInfo.stream)
          this.setState({
            fetchingPast: false,
            shouldFetchPast: totalStream.length < MAX_ITEMS,
            ...streamInfo,
            stream: totalStream
          })
        }
        this._fetchPastLoop = setTimeout(() => loopCallback(), LOOP_TIME)
      })
    }, err => {
      console.debug('Fetch past Loop Ended', err)
      this.setState({ fetchingPast: false, shouldFetchPast: false })
    })
  }

  _fetchActivityStreamPast (baseUrl, callback) {
    const url = setUrlParams(baseUrl, {
      stream: { from: this.state.streamEnd.getTime() / 1000, range: BATCH_TIME }
    })
    this._fetchPastReq = AppRequest({ url, retries: 5 }, (err, res, body) => {
      callback(err, body)
    })
  }

  componentWillUnmount () {
    this._fetchPastLoop && clearTimeout(this._fetchPastLoop)
    this._fetchPastReq &&
      this._fetchPastReq.abort &&
      this._fetchPastReq.abort()
  }

  render (
    { stream, fetchingPast, streamStart, streamEnd, endOfStream } = this.state,
    { props } = this
  ) {
    // aggregation happens on render so it always takes into account all items
    const events = combineActivityItems(stream)
    const endDate = streamEnd || new Date(props.get.config.end_date || 0)
    const nextLink = setUrlParams(props.for_url, {
      stream: { from: endDate.getTime() / 1000 | 0 }
    })

    return (
      <ActivityStream
        events={events}
        isFetchingPast={fetchingPast}
        isEndOfStream={endOfStream}
        isPaginated={props.get.config.paginated}
        startDate={streamStart}
        nextLink={nextLink}
        user={props.get.current_user}
      />
    )
  }
}

module.exports = MyTimeline

// cjs export for compatibility with coffeescript
// how the server data is parsed initially and on updates
const parseStreamInfo = get => {
  const params = parseQuery(parseUrl(get.url).query).stream
  return {
    stream: combineActivityLists(get),
    streamStart: new Date(params.from * 1000),
    streamEnd: new Date(params.to * 1000)
  }
}

// extract items from sections and sort by moment
const combineActivityLists = obj => f
  .chain(SECTIONS)
  .map(s => obj[s])
  .flattenDeep()
  .compact()
  .map(i => ({ ...i, date: Moment(new Date(i.date)) }))
  .sortBy('date')
  .reverse()
  .value()

// group several items if the "belong together"
const combineActivityItems = list => {
  return f.reduce(
    list,
    (result, item, index) => {
      const prevGroup = result.slice(-1)[0]
      const prevResults = result.slice(0, -1)

      const prevType = f.get(prevGroup, [ 0, 'type' ])
      const isSameType = !!prevType && prevType === f.get(item, 'type')

      // NOTE: for object two empties are not considered equal, but are for subject
      const prevObject = f.get(prevGroup, [ 0, 'object' ])
      const isSameObject = !!prevObject &&
        prevObject.url === f.get(item, [ 'object', 'url' ])
      const isSameObjectType = !!prevObject &&
        prevObject.type === f.get(item, [ 'object', 'type' ])

      const prevSubjectUrl = f.get(prevGroup, [ 0, 'subject', 'url' ])
      const isSameSubject = prevSubjectUrl ===
        f.get(item, [ 'subject', 'url' ])

      // same type and object: only add moreDates to existing item
      if (isSameType && isSameObject) {
        const moreDates = prevGroup[0].moreDates || []
        return prevResults.concat([
          [ { ...prevGroup[0], moreDates: moreDates.concat(item.date) } ]
        ])
      }

      // same type: group IF close in times, AND same subject, AND same object type
      if (isSameType && isSameSubject && isSameObjectType) {
        const earliestDate = f.last(prevGroup[0].moreDates) ||
          prevGroup[0].date
        if (isCloseInterval({ from: item.date, to: earliestDate })) {
          return prevResults.concat([ prevGroup.concat(item) ])
        }
      }

      // default: new group with item
      return f.concat(result, [ [ item ] ])
    },
    []
  )
}

// for grouping events that are within a close distance in time
const isCloseInterval = ({ from, to }) =>
  to.diff(from) / 1000 / 60 < CLUSTER_INTERVAL_MINUTES
