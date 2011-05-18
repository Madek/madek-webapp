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
	  //var h = "<p style='margin: 0pt; padding: 0.5em; text-align: left; color: rgb(114, 114, 114);' class='ui-state-default ui-corner-all'><span class='ui-icon ui-icon-circle-check'/>Upload OK!</p>";
	  var h = "<span class='ui-icon ui-icon-circle-check'/>Upload OK!";

		//progressbar// OPTIMIZE
		// $(evt.target.table_row).find("td:last .progressbar").html(h);
		// $(evt.target.table_row).attr("media_entry_id", evt.target.responseText);
		for (var i = 0; i < evt.target.dom_ids.length; i++) {
			//$("#upload-table tr#file_"+evt.target.dom_ids[i]).find("td:last .progressbar").html(h);
			$("#upload-table tr#file_"+evt.target.dom_ids[i]).find("td:last .progressbar p").html(h);
			
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

	function transferStart(upload_form, content, dom_ids) {
		var requestbody = boundary + '\r\n'
						+ 'Content-Disposition: form-data; name="authenticity_token"' + '\r\n'
						+ '\r\n'
						+ upload_form.find("[name='authenticity_token']").val() + '\r\n'
						+ content
						+ boundary + '--';

		var req = new XMLHttpRequest();
			//progressbar//
			req.dom_ids = dom_ids;
		//req.addEventListener("progress", updateProgress, false);  
		req.addEventListener("load", transferComplete, false);  
		req.addEventListener("error", transferFailed, false);  
		req.addEventListener("abort", transferCanceled, false);
		req.open(upload_form.attr("method"), upload_form.attr("action"), true);
		req.setRequestHeader("Content-type", upload_form.attr("enctype") + "; boundary=\"" + boundaryString + "\"");
		req.setRequestHeader("Content-length", requestbody.length);
		req.sendAsBinary(requestbody);

		return;
	}

////////////////////////////////////
	var queue = [];
	var boundaryString = '123___AjaxUploader___321';
	var boundary = '--' + boundaryString;
	var reject_new_files = false;
	
	function startXHR(upload_form){
		reject_new_files = true;
		activate_step(2);
		update_totals();

//worker//
//		var worker = new Worker("/javascripts/post_worker.js");
//		worker.onmessage = function(event){ console.log(event.data); }
		
		var content = "";
		var dom_ids = [];
		var readers = new Array(queue.length);
		var j = queue.length;

		for (var i = 0; i < queue.length; i++){
			if(queue[i] == undefined){
				--j;
				continue;	
			}
			
			readers[i] = new FileReader();
			readers[i].readAsBinaryString(queue[i]);
			readers[i].file = queue[i];
				//progressbar//
				//readers[i].dom_id = i;
				dom_ids.push(i);
				table_row = $("#upload-table tr#file_"+i);
				
				//table_row.find("td:last").append("<div class='progressbar'><img src='/images/spinner.gif'></div>");
				table_row.find("td:last").append("<div class='progressbar'><p style='margin: 0pt; padding: 0.5em; text-align: left; color: rgb(114, 114, 114);' class='ui-state-default ui-corner-all'>Uploading...</p></div>");
				
				//readers[i].onloadstart = function(){ table_row.find("td:last").append("<div class='progressbar'><img src='/images/spinner.gif'></div>"); };
			readers[i].onloadend = function(e){
				content += boundary + '\r\n'
//progressbar//
//							+ 'Content-Disposition: form-data; name="dom_id[]"' + '\r\n'
//							+ '\r\n'
//							+ e.target.dom_id + '\r\n'
//							+ boundary + '\r\n'
						+ 'Content-Disposition: form-data; name="uploaded_data[]"; filename="' + e.target.file.name + '"' + '\r\n'
						+ 'Content-Transfer-Encoding: binary' + '\r\n'
						+ 'Content-Type: ' + e.target.file.type + '\r\n' // OPTIMIZE doesn't work for FireFox 3.5
						+ '\r\n'
						+ e.target.result + '\r\n';
//worker//
//				data = {	method: upload_form.attr("method"),
//							action: upload_form.attr("action"), 
//							enctype: upload_form.attr("enctype"), 
//							auth_token: upload_form.find("[name='authenticity_token']").val(),
//							content: content,
//							dom_ids: dom_ids,
//							boundary: boundary,
//							boundaryString: boundaryString };
//				if(--j == 0) worker.postMessage(data);
				if(--j == 0) transferStart(upload_form, content, dom_ids);
			};
		}

		queue = [];
		return;
	}
	
	function append_to_queue(element){
		if(reject_new_files) return;
		for (i = 0; i < element.files.length; i++){
			queue_table_append(element.files[i], queue.push(element.files[i]) - 1);
		}
		element.value = "";
		// TODO $('html, body').animate({ scrollTop: $("#submit_to_2").offset().top}, 1000);
		update_totals();
		return;
	}

//worker//
//	var thumbnail_worker = new Worker("/javascripts/thumbnail_worker.js");
	
	function queue_table_append(file, index){
		// OPTIMIZE refactor to a queue_table_toggle() function
		$("#upload-table tr#nofiles_row").hide();
		$("#submit_to_2").show();

		var kb_size = Number(file.size/1024).toFixed();
		$("#upload-table #totals").before("<tr id='file_"+index+"' media_entry_id=''>\
											<td>" + file.name + "</td>\
											<td><span data-size='"+kb_size+"'>" + $.formatNumber(kb_size, {format:"#,###", locale:"ch"}) + "</span> KB</td>\
											<td><ul id='icons' class='upload_step_1'><li class='ui-state-default ui-corner-all'><span class='ui-icon ui-icon-trash' onclick='queue_table_remove("+index+");'/></li></ul></td>\
										    </tr>");
/* Thumbnail
		var max_kb = 3000;
		if (file.type.match(/image\/(jpeg|gif|png)/) && kb_size < max_kb) {
//worker//
//			thumbnail_worker.postMessage(file);
//			thumbnail_worker.onmessage = function(event){ $("#file_"+index+" td:first").html("<img src='"+event.data+"'>"); }
			var reader = new FileReader();
			reader.onloadstart = function(){ $("#file_"+index+" td:first").html("<img src='/images/spinner.gif'>"); };
			reader.onloadend = function(e){ $("#file_"+index+" td:first").html("<img src='"+e.target.result+"'>"); };
			// OPTIMIZE for tiff: reader.onloadend = function(e){ $("#file_"+index+" td:first").html("<object type='"+file.type+"' data='"+e.target.result+"' style='max-width: 100px; max-height: 100px'></object>"); };
			reader.readAsDataURL(file);
		}else{
			var msg = (kb_size < max_kb ? file.type : "> "+max_kb+" KB");
			$("#file_"+index+" td:first").html("No thumbnail available for <b>"+msg+"</b>");
		}
*/
	}

	function queue_table_remove(index){
		delete queue[index];
		$("#upload-table tr#file_"+index).remove();
		
		// OPTIMIZE refactor to a queue_table_toggle() function
		if($("#upload-table tr[media_entry_id]").length == 0){
			$("#upload-table tr#nofiles_row").show();
			$("#submit_to_2").hide();
		}
		update_totals();
	}

	var total_files;
	function update_totals(){
		total_files = $("#upload-table tr[media_entry_id]").length;
		var uploaded_files = $("#upload-table tr[media_entry_id][media_entry_id!='']").length;
		$("#upload-table #totals #total_files").html(total_files);
		$("#upload-table #totals #uploaded_files").html(uploaded_files);
		if(uploaded_files == 0) update_total_size();
		if((total_files - uploaded_files) == 0){
			$("#ajaxLoading").hide();
			$("#upload_in_progress, #submit_to_3").toggle();
		}
	}

	var total_size = 0;
	function update_total_size(){
		total_size = 0;
		$("#upload-table tr[media_entry_id] [data-size]").each(function(){
			total_size += Number($(this).attr("data-size"));
		});
		upload_estimation();
		$("#upload-table #totals #total_size").html($.formatNumber(total_size, {format:"#,###", locale:"ch"}));
	}

	var elapsed_ms = 0;
	var test_size = Math.pow(2,20);
	function update_estimation_time(){
		var unit;
		elapsed_s = (elapsed_ms * (total_size * 1024) / test_size / 1000) + (total_files * 3); // after upload, we need additionally 3 seconds to process each file
		
		if(elapsed_s > 3600){
			elapsed_time = elapsed_s / 3600;
			unit = "Stunde";
		}else if(elapsed_s > 60){
			elapsed_time = elapsed_s / 60;
			unit = "Minute"; 
		}else{
			elapsed_time = elapsed_s;
			unit = "Sekunde"; 
		}
		if(elapsed_time >= 2) unit += "n"; 
		$("#upload-table #totals #upload_estimation_time").html("(ca. " + $.formatNumber(elapsed_time, {format:"#,###", locale:"ch"}) + " " + unit + ")");
	}

	function upload_estimation(){
		if(elapsed_ms > 0){
			update_estimation_time();
			return;
		}else{
			var start_ms;
			var data = "";
			for (var i = 0; i <= test_size; i++){ data += "0"; }
			$.ajax({
				url: "/upload_estimation.js",
				type: "POST",
				data: data,
				beforeSend: function(response){
					start_ms = new Date().getTime();
				},
				complete: function(response){
					elapsed_ms = new Date().getTime() - start_ms;
					update_estimation_time();
				}
			});
		}
	}
		