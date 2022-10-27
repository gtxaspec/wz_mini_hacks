
var feed_interval_frequency = 1000;

window.addEventListener("load",function()
{
	var feed = document.getElementById("current_feed");
	function update_image()
	{
		feed.src = feed.src.split("&")[0] + "&load=" + new Date().getTime();
	}
	feed_interval = setInterval(update_image, feed_interval_frequency);

	feed.addEventListener('click',
	function(e){
		e.preventDefault();
		e.target.classList.toggle("full_JPEG");
	});
	
}
);
