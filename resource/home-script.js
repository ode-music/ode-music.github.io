var seconds = 0
var box = null
var itemsNumber = null

function ticker(){
	if (seconds < 50) {
		seconds = seconds + 0.02
		document.querySelector("#progress-ticker").style = "background: linear-gradient(90deg, rgba(255,255,255,1) " + (50 - seconds) + "%, rgba(0,0,0,1) " + (50 - seconds) + "%, rgba(0,0,0,1) " + (50 + seconds) + "%, rgba(255,255,255,1) " + (50 + seconds) + "%)";
	}
	else {
		seconds = 0
		if (Math.round(box.scrollTop/120) == itemsNumber) {
			box.scrollTo({top: 0, left: 0, behavior: "smooth",})
		}
		else {
			box.scrollTo({top: box.scrollTop + 120, left: 0, behavior: "smooth",})
		}
	}
	setTimeout(ticker, 2);
}

window.onload = function() {
	ticker()
	box = document.querySelector("#artist-scroll")
	itemsNumber = Math.round(box.scrollHeight/box.clientHeight) - 1
}

function flipper(me) {
	if (me.value) {
		if (me.value == 2) {
			me.classList.add("flipper")
		}
		else {
			me.value = me.value + 1
		}
	}
	else {
		me.value = 1
	}
}
