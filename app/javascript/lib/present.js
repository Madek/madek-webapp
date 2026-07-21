import { isEmpty, isNumber, isBoolean, isFunction } from 'lodash-es'

// Port of `active-lodash`'s `present` / `presence` (see node_modules/active-lodash/dist/additions.js).
// Behavior — for parity, not Rails semantics:
//   null / undefined         → false
//   0, NaN, true, false, fn  → true   (primitive types short-circuit)
//   ''                       → false, non-empty string → true
//   [] / {}                  → false, non-empty       → true
//   whitespace-only string   → true   (lodash isEmpty checks length, not trim)
//   new Date()               → false  (lodash treats Dates as empty; kept for parity)
export const present = (val) =>
  val != null && (!isEmpty(val) || isNumber(val) || isBoolean(val) || isFunction(val))

export const presence = (val) => (present(val) ? val : undefined)
