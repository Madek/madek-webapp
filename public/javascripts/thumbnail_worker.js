
onmessage = function(event){
	var reader = new FileReader();
	//reader.onloadstart = function(){ $("#file_"+index+" td:first").html("<img src='/images/spinner.gif'>"); };
	reader.onloadend = function(e){ postMessage(e.target.result); };
	reader.readAsDataURL(event.data);
}
