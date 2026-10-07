/**
 * Video.js 10 custom-element registration.
 * Bundled as ESM and loaded with <script type="module"> — not via the IIFE app bundles.
 */
import '@videojs/html/video/player'
import '@videojs/html/video/neutral-skin'
import '@videojs/html/audio/player'
import '@videojs/html/audio/neutral-skin'
// Progressive SD/HD files are not streaming renditions, so the packaged
// quality group never enables itself. Register the radio group we fill in.
import '@videojs/html/ui/menu'
import '@videojs/html/ui/menu-content'
import '@videojs/html/ui/menu-item-indicator'
import '@videojs/html/ui/menu-radio-group'
import '@videojs/html/ui/menu-radio-item'
