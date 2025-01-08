/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let getRailsCSRFToken;
module.exports = (getRailsCSRFToken= () => __guardMethod__(__guardMethod__(document, 'querySelector', o1 => o1.querySelector('meta[name="csrf-token"]')), 'getAttribute', o => o.getAttribute('content')));

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}