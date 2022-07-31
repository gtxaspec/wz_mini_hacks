const queryString = window.location.search;
console.log(queryString);
const urlParams = new URLSearchParams(queryString);

const speed = urlParams.get('speed')
console.log("speed is", speed);

const sleep_timer = urlParams.get('sleep_time')
console.log("sleep_timer is", sleep_timer);

function set_sleep() {
 sleep_timer2 = document.getElementById("sleep_timer").value;
 window.location = "car.html?sleep_time=" + sleep_timer2;
}

function set_vars() {
 sleep_timer2 = document.getElementById("sleep_timer").value;
 var speed = $('input[class="speed"]:checked').val();

 window.location = "car.html?sleep_time=" + sleep_timer2 + "&speed=" + speed;
}


var wz_mini_car = {
  post: function(action)
  {
	$.post( "../cgi-bin/car.sh", { speed: speed, action: action, sleep_time: sleep_timer } );
  }  ,
  init: function() {
    this.logarray = [];
     $("[class*='BUTTON']").on('click',function(e) {
      var action = $(this).attr('id');
      wz_mini_car.post(action);
    });  

    /* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/switch
      switch is strict
    */
    
    addEventListener("keydown", function (e) {
      var action = false;
      switch(e.key) {
        case "w": action = "forward"; break;
        case "s": action = "reverse"; break;
        case "a": action = "left"; break;
        case "d": action = "right"; break;
        case "q": action =  "forward_left" ; break;
        case "e": action = "forward_right"; break;
        case "z": action = "reverse_left"; break;
        case "c": action = "reverse_right" ; break;
        case "x": action = "all_stop" ; break;  
        case "h": action = "headlight_on" ; break;
        case "g": action = "headlight_off" ; break;
        case "j": action = "irled_on" ; break;
        case "k": action = "irled_off" ; break;
        case "b": action = "honk" ; break;
      } 
      if (action) {
        wz_mini_car.post(action);
      }  
    });  
  },
  log: function(text)
  {
    this.logarray.push(text);
  }  
}


$(document).ready(function() {
  wz_mini_car.init();
});

setInterval(function() {
    var myImageElement = document.getElementById('car_feed');
    myImageElement.src = '/cgi-bin/jpeg.cgi?channel=1&rand=' + Math.random();
}, 1000);
