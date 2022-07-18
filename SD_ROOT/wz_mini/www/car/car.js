$(document).ready(function() {

$('#forward').click(function() {
$.post("../cgi-bin/car.sh", "forward" );
});

addEventListener("keydown", function (e) {
if (e.key === "w") {  
$.post("../cgi-bin/car.sh", "forward" );
}
});

$('#reverse').click(function() {
$.post("../cgi-bin/car.sh", "reverse" );
});

addEventListener("keydown", function (e) {
if (e.key === "s") {  
$.post("../cgi-bin/car.sh", "reverse" );
}
});

$('#left').click(function() {
$.post("../cgi-bin/car.sh", "left" );
});

addEventListener("keydown", function (e) {
if (e.key === "a") {  
$.post("../cgi-bin/car.sh", "left" );
}
});

$('#right').click(function() {
$.post("../cgi-bin/car.sh", "right" );
});

addEventListener("keydown", function (e) {
if (e.key === "d") {  
$.post("../cgi-bin/car.sh", "right" );
}
});



$('#forward_left').click(function() {
$.post("../cgi-bin/car.sh", "forward_left" );
});


addEventListener("keydown", function (e) {
if (e.key === "q") {  
$.post("../cgi-bin/car.sh", "forward_left" );
}
});

$('#forward_right').click(function() {
$.post("../cgi-bin/car.sh", "forward_right" );
});

addEventListener("keydown", function (e) {
if (e.key === "e") {  
$.post("../cgi-bin/car.sh", "forward_right" );
}
});

$('#reverse_left').click(function() {
$.post("../cgi-bin/car.sh", "reverse_left" );
});

addEventListener("keydown", function (e) {
if (e.key === "z") {  
$.post("../cgi-bin/car.sh", "reverse_left" );
}
});

$('#reverse_right').click(function() {
$.post("../cgi-bin/car.sh", "reverse_right" );
});

addEventListener("keydown", function (e) {
if (e.key === "c") {  
$.post("../cgi-bin/car.sh", "reverse_right" );
}
});

$('#all_stop').click(function() {
$.post("../cgi-bin/car.sh", "all_stop" );
});

addEventListener("keydown", function (e) {
if (e.key === "x") {  
$.post("../cgi-bin/car.sh", "all_stop" );
}
});

$('#headlight').click(function() {
$.post("../cgi-bin/car.sh", "headlight" );
});

addEventListener("keydown", function (e) {
if (e.key === "x") {  
$.post("../cgi-bin/car.sh", "headlight" );
}
});

$('#irled').click(function() {
$.post("../cgi-bin/car.sh", "irled" );
});

addEventListener("keydown", function (e) {
if (e.key === "x") {  
$.post("../cgi-bin/car.sh", "irled" );
}
});

$('#honk').click(function() {
$.post("../cgi-bin/car.sh", "honk" );
});

addEventListener("keydown", function (e) {
if (e.key === "x") {  
$.post("../cgi-bin/car.sh", "honk" );
}
});


});
