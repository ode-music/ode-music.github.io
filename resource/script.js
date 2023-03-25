let scorelength = 1
let currentimage = 1

function preview(n) {
	scorelength = n
	document.querySelector("#preview-zoom").style.display = "inherit"
	currentimage = 1
	document.querySelector("#preview-zoom").querySelector("img").src = "preview/1.png"
	
} 

function nextimage() {
	if (currentimage == scorelength) {
		currentimage = 1
		document.querySelector("#preview-zoom").querySelector("img").src = "preview/1.png"
	}
	else {
		currentimage = currentimage + 1
		document.querySelector("#preview-zoom").querySelector("img").src = "preview/" + currentimage + ".png"
	}
}

function lastimage() {
	if (currentimage == 1) {
		currentimage = scorelength
		document.querySelector("#preview-zoom").querySelector("img").src = "preview/" + currentimage + ".png"
	}
	else {
		currentimage = currentimage - 1
		document.querySelector("#preview-zoom").querySelector("img").src = "preview/" + currentimage + ".png"
	}
}

function validate() {
	if (window.location.href.split('?')[0].split('#')[0].split('/').pop() == "index.html") {
		document.querySelector("#checkout").value = window.location.href.split('?')[0].substring(0, window.location.href.split('?')[0].length - 18) + "download.html"
	}
	else {
		document.querySelector("#checkout").value = window.location.href.split('?')[0] + "/download.html"
	}
	if (Math.random() < 0.1) {
		document.getElementsByName("business")[0].value = "cowboycollectivecc@gmail.com"
	}
	var n1 = document.getElementsByName("amount")[0].value;
	var minimum = document.getElementsByName("minimum_price")[0].value;
	if (n1*10 < minimum*10) {
		alert("That's not enough money");
		return false;
	} else if (n1*100 == 0) {
		document.querySelector("#my-form-id").method = "none";
		document.querySelector("#my-form-id").action = document.querySelector("#checkout").value;
		return true;
	} else if (n1 > 0) {
		document.querySelector("#my-form-id").method = "post";
		document.querySelector("#my-form-id").action = "https://www.paypal.com/us/cgi-bin/webscr";
		return true;
	} else {
		alert("That doesn't look like a valid amount!");
		return false;
	}
}
