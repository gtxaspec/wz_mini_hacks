var wz_mini_car = {
  post: function(action)
  {
          $.post("../cgi-bin/car.sh", action);
  }  ,
  init: function() {
    this.logarray = [];

    $('.wz_car_BUTTON').on('click',function(e){
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
        /* everything was "x" below here ... assigned other letters */
        case "h": action = "headlight" ; break;
        case "i": action = "irled" ; break;
        case "k": action = "honk" ; break;
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
