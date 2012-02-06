/*
 * Video JS
 * 
 * This script implements video js
 * 
 * @dependencies: video.js
 *   
 */

$(document).ready(function() {
  $("video:not('.video-js')").each(function(){
    $(this).addClass('video-js');
    $(this).wrap("<div class='video-js-box' />");
  });
  VideoJS.setupAllWhenReady();
});