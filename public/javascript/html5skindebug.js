window.onload=function(){
	var arr=document.getElementsByTagName("br"); 
	for(var i=0;i<arr.length;i++){
		if(arr[i].getAttribute("data-zif") != null){
			arr[i].style.display="none";
		}else if(arr[i].getAttribute("data-zelseif") != null){
			arr[i].style.display="none";
		}else if(arr[i].getAttribute("data-zelse") != null){
			arr[i].style.display="none";
		}else if(arr[i].getAttribute("data-zendif") != null){
			arr[i].style.display="none";
		}
	}
 }