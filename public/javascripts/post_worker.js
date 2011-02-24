/*
	// progress on transfers from the server to the client (downloads)
	function updateProgress(evt) {
	  if (evt.lengthComputable) {
	    var percentComplete = evt.loaded / evt.total;
	  } else {
	    console.log('Unable to compute progress information since the total size is unknown');		
	  }
	}
*/	

	function transferComplete(evt) {
	  var h = "<p style='margin: 0pt; padding: 0.5em; text-align: left; color: rgb(114, 114, 114);' class='ui-state-default ui-corner-all'><span class='ui-icon ui-icon-circle-check'/>Upload OK!</p>";

		//progressbar// OPTIMIZE
		// $(evt.target.table_row).find("td:last .progressbar").html(h);
		// $(evt.target.table_row).attr("media_entry_id", evt.target.responseText);
		for (var i = 0; i < evt.target.dom_ids.length; i++) {
			$("#upload-table tr#file_"+evt.target.dom_ids[i]).find("td:last .progressbar").html(h);
			$("#upload-table tr#file_"+evt.target.dom_ids[i]).attr("media_entry_id", "-1"); //TODO
		}
	  
	  update_totals();
	}
	
	function transferFailed(evt) {
	  console.log("An error occurred while transferring the file.");
	}
	
	function transferCanceled(evt) {
	  console.log("The transfer has been canceled by the user.");
	}

	onmessage = function(event){
		var requestbody = event.data.boundary + '\r\n'
						+ 'Content-Disposition: form-data; name="authenticity_token"' + '\r\n'
						+ '\r\n'
						+ event.data.auth_token + '\r\n'
						+ event.data.content
						+ event.data.boundary + '--';

		var req = new XMLHttpRequest();
			//progressbar//
//			req.dom_ids = event.data.dom_ids;
		//req.addEventListener("progress", updateProgress, false);  
		req.addEventListener("load", transferComplete, false);  
		req.addEventListener("error", transferFailed, false);  
		req.addEventListener("abort", transferCanceled, false);
		req.open(event.data.method, event.data.action, true);
		req.setRequestHeader("Content-type", event.data.enctype + "; boundary=\"" + event.data.boundaryString + "\"");
		req.setRequestHeader("Content-length", requestbody.length);
		req.sendAsBinary(requestbody);

		return;
	}