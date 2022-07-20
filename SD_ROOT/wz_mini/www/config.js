
window.onload = function()
{
	var feed = document.getElementById("current_feed");
	function update_image()
	{
		feed.src = feed.src.split("&")[0] + "&load=" + new Date().getTime();
	}
	setInterval(update_image, 1000);
}
