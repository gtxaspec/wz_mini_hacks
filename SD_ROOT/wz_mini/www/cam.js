
// https://stackoverflow.com/questions/14636536/how-to-check-if-a-variable-is-an-integer-in-javascript#14794066
function isInt(value) {
  return !isNaN(value) && 
         parseInt(Number(value)) == value && 
         !isNaN(parseInt(value, 10));
}


function enable_submit()
{
	alert("no guarantees at all on this one. Change values at your own risk");
       document.getElementById("update").disabled = false;

}

window.addEventListener("load",function()
{
	var sels = document.querySelectorAll('.ii_select').forEach(function(item){
		var row = item.getAttribute("row");
		item.addEventListener('change',function(e){
			var row = this.getAttribute("row");
		        document.querySelector(".ii_value[row='" + row + "']").value = this.value;

		});
		var b = document.querySelector(".ii_value[row='" + row + "']");
                item.value = b.value;

		b.classList.add('ii_shared');
		b.addEventListener('change',function(e){
		        var row = this.getAttribute("row");
                        document.querySelector(".ii_select[row='" + row + "']").value = this.value;

		});
	}); 

	document.querySelector('[name="update_config"]').addEventListener('submit',
	function(e){
	var changed = 0;
        const values = document.getElementsByClassName('ii_value');
	Array.from(values).forEach(function(item){
	if (item.getAttribute('default_value') == item.value) { item.disabled = true; } else { changed++; }
	});
	if (changed == 0) { 
		e.preventDefault();
		Array.from(values).forEach(function(item){ item.disabled = false;  });
	}
	});
});
