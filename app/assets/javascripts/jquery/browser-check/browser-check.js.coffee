###

Browser Check

This script checks if the current browser is supported and displays a warning message if not
Browser name will be checked case insensitive and version will be checked >= as float
 
@dependencies: browser-detection
 
###

supported_browser = [
  {name: "Firefox", version: 4.0},
  #{name: "Opera", version: 10.0},
  #{name: "Internet Explorer", version: 7},
  #{name: "Chrome", version: 10},
  #{name: "Safari", version: 5.0},
]

warning_height = 250
warning_width = 600

warning_title = "<div class='page_title_left' style='padding-left: 0'><div style='margin-right: 12px;' class='icon_me'/>Hinweis</div><div class='clear'></div>"
warning_text = "<p>Ihr Browser wird von dieser Applikation momentan noch nicht unterstützt!</p><br/><p><strong>Es wird empfohlen</strong> für die Benutzung dieser Applikation den <a style='color: grey' target='_blank' href='http://www.mozilla.org/firefox' title='Firefox-Browser herunterladen!'>Firefox-Browser</a> mindestens in Version 4.0 zu verwenden.</p>"  
warning_interaction = "<div style='position: absolute; bottom: 20px; right: 20px;'><button id='warning_button' style='background: #EEE;border: 1px solid grey; -moz-border-radius: 4px; -webkit-border-radius: 4px; border-radius: 4px;padding: 6px 8px 4px 8px; font-size: 1.1em; font-weight: bold; color: #444444;' type='button'>Ok, trotzdem weiter</button></div>"
warning_content = "<div style='display: block; position: relative; padding: 22px 22px'>"+warning_title+warning_text+"</div>"+warning_interaction
warning_bar = "<div id ='not_supported_warning_bar' style='height: 18px; z-index: 9999; display: block; position: fixed; top: 0; width: 100%; background: #e00000; border-bottom: 1px solid black; color: white; padding: 2px 2px 2px 24px; text-align: center;'><strong>Hinweis:</strong> Ihr Browser wird momentan noch nicht unterstützt. <a style='color: #DCC' target='_blank' href='http://www.mozilla.org/firefox' title='Firefox-Browser herunterladen!'>Firefox-Browser <img src='https://static-cdn.addons.mozilla.net/media/img/app-icons/med/firefox.png' width='12px' height='12px'/></a> wird empfohlen!</div>"
warning_bar_spacer = "<div id='not_supported_warning_bar_spacer' style='display: block; position: relative; top: 0; height: 18px;'></div>"

$ ->
  if ! BrowserDetection.is_supported(supported_browser)
    if ! document.cookie.match(/_MAdeK_browser_warning\=1/)
      overlay_style = "width: "+$(window).width()+"px; height: "+$(window).height()+"px; display: block; position: fixed; top: 0; left: 0; background: #000; z-index: 9999;"
      overay_opacity = "filter: alpha(opacity=0.7); -moz-opacity: 0.7; -khtml-opacity: 0.7; opacity: 0.7; "
      overlay = $("<div id='not_supported_overlay' style='"+overlay_style+overay_opacity+"'></div>")
      warning_style = "border: 3px solid #e00000; width: "+warning_width+"px; height: "+warning_height+"px; background: white; display: block; position: fixed; top: "+parseInt(($(window).height()/2)-warning_height)+"px; left: "+parseInt(($(window).width()/2)-warning_width/2)+"px; z-index: 10000;"
      warning_border_style = "-moz-border-radius: 10px; -webkit-border-radius: 10px; border-radius: 10px;"
      warning_shadow_style = "-moz-box-shadow: 0 0 8px #000; -webkit-box-shadow: 0 0 8px #000; box-shadow: 0 0 8px #000;"
      warning = $("<div id='not_supported_warning' style='"+warning_style+warning_border_style+warning_shadow_style+"'>"+warning_content+"</div>")
      $("body").append(overlay)
      $("body").append(warning)
      $("#warning_button").click ->
        date = new Date(99999999999999)
        document.cookie = "_MAdeK_browser_warning=1; expires="+date.toGMTString()+"; path=/";
        $("#not_supported_overlay").remove()
        $("#not_supported_warning").remove()
        $("body").prepend(warning_bar_spacer).prepend(warning_bar)
        $("#not_supported_warning_bar").css("top", -$("#not_supported_warning_bar").outerHeight()).animate({top: 0})
        $("#not_supported_warning_bar_spacer").height(0).animate({height: 18})
    else
      $("body").prepend(warning_bar_spacer).prepend(warning_bar)
      

$(window).bind 'resize', ->
  $("#not_supported_overlay").css("width", $(window).width()+"px")
                             .css("height", $(window).height()+"px")
  $("#not_supported_warning").css("top", parseInt(($(window).height()/2)-warning_height)+"px")
                             .css("left", parseInt(($(window).width()/2)-warning_width/2)+"px")       
