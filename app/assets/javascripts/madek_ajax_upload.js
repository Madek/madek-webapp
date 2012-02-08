function transferComplete(evt) {
  var h = "<span class='ui-icon ui-icon-circle-check'/>Upload OK!";
	$("#upload-table tr[media_entry_id]").each(function(){
		$(this).attr("media_entry_id", "-1").find("td:last .progressbar p").html(h);
	});
  update_totals();
}

function transferFailed(evt) {
  console.log("An error occurred while transferring the file.");
}

function transferCanceled(evt) {
  console.log("The transfer has been canceled by the user.");
}

///////////////////////////////////////////////////////////////////////////////
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

function update_total_size(){
	total_size = 0;
	$("#upload-table tr[media_entry_id] [data-size]").each(function(){
		total_size += Number($(this).attr("data-size"));
	});
	upload_estimation();
	$("#upload-table #totals #total_size").html(addCommas(total_size));
}

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
	$("#upload-table #totals #upload_estimation_time").html("(ca. " + addCommas(elapsed_time.toFixed()) + " " + unit + ")");
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
			url: "/upload/estimation.js",
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

///////////////////////////////////////////////////////////////////////////////

function startXHR(upload_form){
	reject_new_files = true;
	activate_step(2);
	update_totals();

	var formData = new FormData();
	formData.append("xhr", 1);
	
	csrf_param = $('meta[name=csrf-param]').attr('content');
	csrf_token = $('meta[name=csrf-token]').attr('content');
	formData.append(csrf_param, csrf_token);
        
	var h = "<div class='progressbar'><p style='margin: 0pt; padding: 0.5em; text-align: left; color: rgb(114, 114, 114);' class='ui-state-default ui-corner-all'>Uploading...</p></div>";

	$("#upload-table tr[media_entry_id]").each(function(){
		$(this).find("td:last").append(h);
		formData.append("uploaded_data[]", $(this).data("file"));
	});

	var xhr = new XMLHttpRequest();
	xhr.addEventListener("load", transferComplete, false);  
	xhr.addEventListener("error", transferFailed, false);  
	xhr.addEventListener("abort", transferCanceled, false);
	xhr.open(upload_form.attr("method"), upload_form.attr("action"), true);
	xhr.send(formData);
	return;
}

function append_to_queue(element){
	if(reject_new_files) return;
	for (i = 0; i < element.files.length; i++){
		append_to_table(element.files[i]);
	}
	element.value = "";
	$(element).closest("form").each(function(){this.reset();});
	update_totals();
	return;
}

function append_to_table(file){
	$("#upload-table tr#nofiles_row").hide();
	$("#submit_to_2").show();

	var kb_size = Number(file.size/1024).toFixed();
	var new_tr = "<tr media_entry_id=''>\
									<td>" + file.name + "</td>\
									<td><span data-size='"+kb_size+"'>" + addCommas(kb_size) + "</span> KB</td>\
									<td><ul id='icons' class='upload_step_1'><li class='ui-state-default ui-corner-all'><a href='#'><span class='ui-icon ui-icon-trash'/></a></li></ul></td>\
						    </tr>";
	$(new_tr).data("file", file).insertBefore("#upload-table #totals");
	return;
}

///////////////////////////////////////////////////////////////////////////////
// from http://ntt.cc/2008/04/25/6-very-basic-but-very-useful-javascript-number-format-functions-for-web-developers.html
function addCommas(nStr)
{
  nStr += '';
  x = nStr.split('.');
  x1 = x[0];
  x2 = x.length > 1 ? '.' + x[1] : '';
  var rgx = /(\d+)(\d{3})/;
  while (rgx.test(x1)) {
    //x1 = x1.replace(rgx, '$1' + ',' + '$2');
    x1 = x1.replace(rgx, '$1' + '\'' + '$2');
  }
  return x1 + x2;
}

///////////////////////////////////////////////////////////////////////////////
var reject_new_files = false;
var total_files;
var total_size = 0;
var elapsed_ms = 0;
var test_size = Math.pow(2,20);

$("#upload-table tr[media_entry_id] span.ui-icon-trash").live('click', function(){
	$(this).closest("tr[media_entry_id]").remove();
	if($("#upload-table tr[media_entry_id]").length == 0){
		$("#upload-table tr#nofiles_row").show();
		$("#submit_to_2").hide();
	}
	update_totals();
	return false;
});

