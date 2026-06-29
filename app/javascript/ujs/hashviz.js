/*
 * hashviz: build visual hash from input texts (used on error pages)
 * ujs usage: an svg is inserted in every <el data-hashviz-container="foo"> using
 * text from first <el data-hashviz-target="foo"> as input for the hash
 */
import hashVizSVG from '../lib/hashviz-svg.js'

export default () => {
  document.querySelectorAll('[data-hashviz-container]').forEach(container => {
    const name = container.dataset.hashvizContainer
    const target = document.querySelector(`[data-hashviz-target="${name}"]`)
    if (!target) return
    const text = target.textContent
    const svg = hashVizSVG(text)
    container.innerHTML = ''
    container.appendChild(svg)
  })
}
