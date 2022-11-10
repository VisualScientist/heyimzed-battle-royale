
const notification = new Vue({
	el: '#upper-notification',
	data: {
		showing: false,
		currentText: "Locale not set",
		fadeAnimSet: 'In',
		fadeAnimDir: 'Right',
		currentInterval: undefined,
		currentRing: 0,
		currentRingFormat: 'none',
	},
	methods: {
		show(state) {
			if (state === true) {
				this.fadeAnimSet = "In";
				this.showing = true;
			} else {
				this.fadeAnimSet = "Out";
				setTimeout(function(){
					notification.showing = false;
				}, 1000)
			}
		},
		nextRing(seconds, text) {
			if (this.currentInterval === undefined) {
				this.currentRing = seconds;
				this.currentRingFormat = text;

				this.currentInterval = setInterval(function(){
					notification.currentRing -= 1;
					if (notification.currentRing === 0) {
						clearInterval(notification.currentInterval)
						notification.currentInterval = undefined;
					}
				}, 1000)
			} else {
				clearInterval(this.currentInterval)
				this.currentInterval = undefined;
				this.nextRing(seconds, text);
			}
		}
	}
})

const logbox = new Vue({
	el: '#right-notifications',
	data: {
		showing: false,
		log: []
	},
	methods: {
		add(text) {
			this.log.push(text);
			setTimeout(() => {
				for (const k in logbox.log) {
					if (logbox.log[k] == text) {
						logbox.log.splice(k, 1);
						break;
					}
				}
			}, 5000);
		}
	}
})

const menu = new Vue({
	el: '#game-menu',
	data: {
		fadeAnimSet: 'In',
		fadeAnimDir: 'Left',
		localeArena: 'Waiting load... ',
		localeWins: '',
		showing: false,
		currentArena: 0,
		arenaMaxPlayers: 0,
		arenaStatus: 'Waiting',
		players: [],
	},
	methods: {
		show(status) {
			if (status === undefined) return;
			if (status && !this.showing) {
				this.fadeAnimSet = 'In';
				this.showing = true;
				return true;
			} else if (!status && this.showing) {
				this.fadeAnimSet = 'Out';
				setTimeout(function(){
					menu.showing = false;
				}, 1000);
				return false;
			}
		},
		update(data) {
			if (data.locales) {
				this.localeArena = data.locales.current_arena || this.localeArena;
				this.localeWins = data.locales.wins || this.localeWins;
			}
			this.currentArena = data.arena || this.currentArena;
			this.arenaStatus = data.status || this.arenaStatus;
			this.arenaMaxPlayers = data.max || this.arenaMaxPlayers;
			this.players = data.players || this.players;

			this.show(data.show)
		}
	}
})

window.addEventListener('message', (event) => {
	const data = event.data;

	if (data.action === 'counter') {
		if (data.show !== undefined)
			notification.show(data.show);
		if (data.text !== undefined)
			notification.currentText = data.text
		if (data.nextRing !== undefined)
			notification.nextRing(data.nextRing, data.format);

	}
	else if (data.action === 'log') {
		logbox.add(data.text);
	}
	else if (data.action === 'menu') {
		menu.update(data);
	}
})
