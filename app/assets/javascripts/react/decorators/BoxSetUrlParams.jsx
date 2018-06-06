import f from 'lodash'
import setUrlParams from '../../lib/set-params-for-url.coffee'


module.exports = (url, ...params) => {

  var p = params.map(
    (param) => {
      return f.fromPairs(
        f.map(
          param,
          (val, key) => {
            if(key === 'list') {
              return [
                key,
                f.fromPairs(
                  f.compact(
                    f.map(
                      val,
                      (v, k) => {
                        if(f.includes(['accordion', 'filter'], k)) {
                          if(v == null) {
                            return
                          }
                          return [k, typeof v === 'object' ? JSON.stringify(v) : v]
                        }
                        return [k, v]
                      }
                    )
                  )
                )
              ]
            }
            return [key, val]
          }
        )
      )
    }
  )

  return setUrlParams(url, ...p)

}
