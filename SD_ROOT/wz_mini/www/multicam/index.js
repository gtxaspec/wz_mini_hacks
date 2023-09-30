const canWakeLock = () => 'wakeLock' in navigator;


function releaseWakeState() {
  if(wakelock) wakelock.release();
  wakelock = null;
}

let wakelock;
const requestWakeLock = async () => {
  try {
    const wakeLock = await navigator.wakeLock.request("screen");
  } catch (err) {
    // The wake lock request fails - usually system-related, such as low battery.

    console.log(`${err.name}, ${err.message}`);
  }
};



class helper_dad 
{
	me;
	obj;
	context = "";
	set_me(x)
	{
		this.me = x;
	}
	get_me()
	{
		return this.me;
	}
	test()
	{
		console.log("parent");
	}
		
	log(x)	
	{
		console.log( this.context + ' - ' + x)
	}
}

class cam_obj extends helper_dad
{
  jpeg_url = "";
  status_url = false;
  cam_id = 0;

  set_obj(obj)
  {
    var me = super.get_me();
    me.obj = obj;
    me.obj.addEventListener('click',(e) => {   me.click(); } );
 }

  mark_status(test,text)
  {
    var me = super.get_me();
    var test_val = "OFF";
    me.log(me.cam_id + ' - ' + text);
    if (text.indexOf("ON") !== -1) { test_val = "ON";  }
    else if (text.indexOf("OK") !== -1) { test_val = "OK"; }
    me.obj.setAttribute(test,test_val);
  }

  first_init()
  {
	this.set_me(this);
  }

  constructor(cam_id,jpeg_url)
  {
	super();
	this.set_me(this);
	this.jpeg_url = jpeg_url;
	this.cam_id = cam_id;
	this.context = "cam " + cam_id;
  }

  status_test(test_type) {
	return false;
  }

   night_test()
   {
	var me = super.get_me();
 	me.status_test('night');
   }
   
   irled_test()
   {
        var me = super.get_me();
        me.status_test('irled');
   }

   recording_test()
   {
        var me = super.get_me();
        me.status_test('recording');
   }

   unfocus()
   {
	var me = super.get_me();
	me.obj.classList.remove("first_CAM");
        me.obj.style.order = me.cam_id;
   }


  click() {
       var me = super.get_me();
       if (me.obj.classList.contains('first_CAM')) {
                return cam_tool.focus_click(this);
           }

        for (var i = 0; i < cam_tool.cams.length; i++) {
                cam_tool.cams[i].unfocus();
        }
       me.obj.classList.add("first_CAM");
       me.obj.style.order = 0;
 }

  update()
  {
	var me = super.get_me();
	var i = me.cam_id -1;
                var cam1 = cam_tool.feeds[i];
                if (cam1.getAttribute('current') == "y") {
                        cam1.setAttribute('current','n');
                        var cam = document.querySelector('img.cam_img2[cam="' + (i + 1)  + '"]');
                        cam1.classList.remove('broken_cam');
                } else if (document.querySelector('img.cam_img2[cam="' + (i + 1)  + '"]').getAttribute('current') == "y")
                {
                        var cam =  cam_tool.feeds[i];
                        document.querySelector('img.cam_img2[cam="' + (i + 1)  + '"]').setAttribute('current','n');
                } else {
                        cam1.classList.add('broken_cam');
                        cam_tool.notify(i,'neither is loaded on camera ');
                        return false;
                }
                var load_start = new Date().getTime();
                cam.setAttribute('load_start',load_start);
                cam.src = cam_tool.feeds[i].src.split("&")[0] + "&load=" + load_start;
  }

}


class v3_cam_obj extends cam_obj
{
  constructor(cam_id,jpeg_url)
  {
	super(cam_id,jpeg_url);
        super.set_me(this);
	this.status_url = jpeg_url.substring(0,this.jpeg_url.lastIndexOf("/")+1) + 'status.cgi';

  }

    status_test(test_type) {
        var me = super.get_me();
        fetch(me.status_url + '?test=' + test_type)
        .then( (response) => response.text())
        .then( (text) => me.mark_status(test_type,text) );
  } 

}


const cam_tool = {
  cam_count : 0,
  feed_interval_frequency : 3000,
  spacing:false,
  feed_interval : false,
  tick: 0,
  feeds : false,
  buttons: [],
  loads: [],
  cams: [],
  load_sum :0,
  load_fails:0,
  focus_click:function(me) {
	 me.classList.toggle('full_CAM');
	return false;
  },
  run_mode: function(e) {
	e.preventDefault();
	e.stopPropagation();

      for (var i = 0; i < cam_tool.modes.length; i++) {
                cam_tool.modes[i].classList.remove('active_button');
        }

	e.target.classList.add('active_button');
	if (e.target.getAttribute("mode") == 'auto') {	
	      	var average = cam_tool.load_sum / cam_tool.loads.length;
        	var use =  parseInt(average * 2 / 10) * 10;
        	cam_tool.feed_interval_frequency = use;
        	cam_tool.calc_spacing();	
	}
	if (e.target.getAttribute("mode") == 'manual') {
		cam_tool.feed_interval_frequency = document.querySelector("DIV.load_mode[mode='manual'] INPUT").value;
                cam_tool.calc_spacing();
	}
  },
  load_cam : function() {
   var cam = this.getAttribute('cam');
   if (this.classList.contains('cam_img2')) {
     var cam_obj =  cam_tool.feeds[cam -1];
   } else {
     var cam_obj = document.querySelector('img.cam_img2[cam="' + cam + '"]');	
   }
   cam_obj.style.zIndex = 1;
   cam_obj.setAttribute('current','n');
   this.setAttribute('current','y');
   this.style.zIndex = 2;


   var load_time = new Date().getTime()  - this.getAttribute('load_start');
	if (load_time < 100000) {
   		cam_tool.load_sum += load_time;
   		cam_tool.loads.push(load_time);
   		var average = cam_tool.load_sum / cam_tool.loads.length;
   		document.getElementById('load_average').innerHTML = parseInt(average);
	} 
  },
  init : function(feed_interval_frequency) {
	this.feed_interval_frequency = feed_interval_frequency;
        var divs = document.getElementsByClassName('cam_DIV');
        	for (var i = 0; i < divs.length; i++) {
		     cam_tool.cams[i].set_obj(divs[i]);
		}

        cam_tool.feeds = document.getElementsByClassName('cam_img');
	for (var i = 0; i < cam_tool.feeds.length; i++) {
		cam_tool.feeds[i].addEventListener('load', cam_tool.load_cam);
	}
	var img2  = document.getElementsByClassName('cam_img2');
        for (var i = 0; i < img2.length; i++) {
                img2[i].addEventListener('load', cam_tool.load_cam);
        }


	cam_tool.buttons["start"] = document.querySelector("BUTTON[action='start']");
        cam_tool.buttons["pause"] = document.querySelector("BUTTON[action='pause']");

	cam_tool.buttons["start"].addEventListener('click',cam_tool.start);
        cam_tool.buttons["pause"].addEventListener('click',cam_tool.pause);


        cam_tool.modes = document.getElementsByClassName('load_mode');
        for (var i = 0; i < cam_tool.modes.length; i++) {
                cam_tool.modes[i].addEventListener('click', cam_tool.run_mode);
        }

	document.querySelector("DIV.load_mode[mode='manual'] INPUT").value = cam_tool.feed_interval_frequency;

        cam_tool.cams[0].obj.click();
	cam_tool.calc_spacing();
        cam_tool.start();


  },
  notify:function(cam,message) {
	console.log("camera " + cam + " - " + message);
  },
  update: function() {
	for (var i= 0; i < cam_tool.feeds.length; i++) {
		var current_tick = cam_tool.tick * 10;
		var target_tick = cam_tool.spacing * i;
		if (((current_tick)  % cam_tool.feed_interval_frequency) == (target_tick ))  { 
			cam_tool.cams[i].update();
			console.log("i" + i +  " tick " + cam_tool.tick + " % interval ("  + cam_tool.feed_interval_frequency + ") " + ((current_tick)  % cam_tool.feed_interval_frequency));  
                } 
                if (((current_tick)  % (cam_tool.feed_interval_frequency * 10)) == (target_tick ))  {
			cam_tool.cams[i].night_test();
		}

	}
	cam_tool.tick++;
  },
  calc_spacing:function() {
        cam_tool.spacing = Math.floor( cam_tool.feed_interval_frequency / (cam_tool.cam_count *10 ) ) * 10;
	console.log('updated frequency to ' + cam_tool.spacing );
  },
  update_freq(event) {
	console.log('set frequency to ' + event.target.value);
	cam_tool.feed_interval_frequency = event.target.value;	
	cam_tool.calc_spacing();
  },
 set_buttons:function(active)
 {
	for (let key in cam_tool.buttons) {
    		cam_tool.buttons[key].classList.remove('active_button');
    		cam_tool.buttons[key].classList.add('inactive_button');
	}
	cam_tool.buttons[active].classList.add("active_button");
	cam_tool.buttons[active].classList.remove("inactive_button");
},
  pause: function() {
	cam_tool.set_buttons('pause');
	clearInterval(cam_tool.feed_interval);
	cam_tool.tick = 0;
	releaseWakeState();
  },
  start : function() {
 	if (cam_tool.feed_interval) { cam_tool.pause(); }
        cam_tool.set_buttons('start');
 	cam_tool.feed_interval = setInterval(cam_tool.update, 10);
	requestWakeLock();
  },
  

  compose:function(cam_count,url,cam_type='other') {
    for (var i = 1; i <= cam_count; i++) 
     { 	
	this.add_camera(i,url.replace('%d',i) ,cam_type);
     }
	
  },
  add_camera:function(i,url,cam_type='other')
  {
	cam_tool.cam_count++;
	var zam =  document.getElementById("za_images");
        var id =  document.createElement('DIV');
        id.innerHTML = '<img class="cam_img" src="' + url  + '" current="y" cam="' + i +  '"  > <img class="cam_img2" cam="' + i + '" src="" current="n" >';
        id.setAttribute('cam',i);
        id.className = "cam_DIV";
        zam.appendChild(id);
	cam_tool.calc_spacing();
	if (cam_type == 'v3') {
		var nc = new v3_cam_obj(i,url);
	} else {
		var nc = new cam_obj(i,url);
	}
	nc.first_init();
	cam_tool.cams.push(nc)
  }
  
}
