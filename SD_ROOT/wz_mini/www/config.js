
var mac_re = /^[0-9a-f]{1,2}([\.:-])(?:[0-9a-f]{1,2}\1){4}[0-9a-f]{1,2}$/mi;

// https://stackoverflow.com/questions/14636536/how-to-check-if-a-variable-is-an-integer-in-javascript#14794066
function isInt(value) {
  return !isNaN(value) && 
         parseInt(Number(value)) == value && 
         !isNaN(parseInt(value, 10));
}

function scrollTop()
{
window.scrollTo({
        top: 0,
        behavior: "smooth"
    });
}


function compose_rtsp_block(stype,streams)
{
  const formElement = document.querySelector("form");
  var fdata = new FormData(formElement);

  var stype = (typeof stype !== "undefined") ? stype: "RTSP_HI_RES";


  if (fdata.get(stype + "_ENABLED") != "true") {
        console.log(stype + " not enabled");
    return false;
  }

  var auth = "";
  if (fdata.get('RTSP_AUTH_DISABLE') != "true") {
        auth = fdata.get('RTSP_LOGIN') + ':';
        if (fdata.get('RTSP_PASSWORD') != '') {
                auth += fdata.get('RTSP_PASSWORD');
        } else {
                auth += document.body.getAttribute('mac');
        }
        auth += "@";
  }
  
         
  stream = "unicast";
 
  if ((fdata.get('RTSP_HI_RES_ENABLED') == "true") && (fdata.get('RTSP_LOW_RES_ENABLED') == "true")) {
        if (stype == "RTSP_HI_RES") {  stream = streams['high'];   } else { stream = streams['low']; }
 }

  var link = "rtsp://" + auth + document.body.getAttribute("ip") + ":" + fdata.get('RTSP_PORT') + '/' stream;
        
  var vb = document.querySelectorAll('[block_name="VIDEOSTREAM"]')[0];
  var url_block = document.createElement('DIV');
  url_block.innerHTML = 'Stream ' + stype + ' URL: ' + '<a href="' + link +  '">' + link +  '</a>' ;
  vb.appendChild(url_block);
}

function enable_submit()
{
	alert("no guarantees at all on this one. Change values at your own risk");
       document.getElementById("update").disabled = false;

}

window.addEventListener("load", function()
{
          var streams = {'low': 'video2_unicast', 'high':'video1_unicast'};
          if (document.body.getAttribute('camtype') != 'T31')  { streams = {'low': 'video7_unicast', 'high':'video6_unicast'};  }
  
        compose_rtsp_block('RTSP_HI_RES',streams);
        compose_rtsp_block('RTSP_LOW_RES',streams);
	document.querySelector('[name="update_config"]').addEventListener('submit',
	function(e){
          const mac_addrs = document.getElementsByClassName('mac_addr');
	  for (let i=0; i < mac_addrs.length; i++) {
		mac_addrs[i].classList.remove("fail_val");
		if (mac_addrs[i].value == "") { continue; }
		if (!mac_re.test(mac_addrs[i].value)) {  
			mac_addrs[i].classList.add("fail_val");
			scrollTop();
			console.log("failed on mac address test for " + mac_addrs[i].name + " for value " + mac_addrs[i].value);
			e.preventDefault(); 
		}	
	}

	  const numerics = document.getElementsByClassName('numeric');
          for (let i=0; i < numerics.length; i++) {
                numerics[i].classList.remove("fail_val");
                if (numerics[i].value == "") { continue; }
		if (!isInt(numerics[i].value)) {
                  numerics[i].classList.add("fail_val");
                  scrollTop();
	          console.log("failed on integer test for " + numerics[i].name);
                  e.preventDefault(); 
		}
	  }

	}
	);
});
