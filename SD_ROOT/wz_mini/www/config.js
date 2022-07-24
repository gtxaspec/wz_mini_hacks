
var feed_interval_frequency = 1000;
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


window.onload = function()
{
	var feed = document.getElementById("current_feed");
	function update_image()
	{
		feed.src = feed.src.split("&")[0] + "&load=" + new Date().getTime();
	}
	feed_interval = setInterval(update_image, feed_interval_frequency);
	

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
}
