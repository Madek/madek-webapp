import setUrlParams from '../../lib/set-params-for-url.js'

const BoxSetUrlParams = (url, ...params) => {
  const p = params.map(param => {
    return Object.fromEntries(
      Object.entries(param).map(([key, val]) => {
        if (key === 'list') {
          return [
            key,
            Object.fromEntries(
              Object.entries(val)
                .map(([k, v]) => {
                  if (['accordion', 'filter'].includes(k)) {
                    if (v == null) {
                      return null
                    }
                    return [k, typeof v === 'object' ? JSON.stringify(v) : v]
                  }
                  return [k, v]
                })
                .filter(Boolean)
            )
          ]
        }
        return [key, val]
      })
    )
  })

  return setUrlParams(url, ...p)
}

export default BoxSetUrlParams
module.exports = BoxSetUrlParams
