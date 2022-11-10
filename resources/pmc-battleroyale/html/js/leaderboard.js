
const leaderboard = new Vue({
    el: '#leaderboard',
    data: {
        localeBoard: 'Leaderboard',
        localeScore: '',
        localeDescription: '',
        board: [{name:"--", score:"--"}]
    },
    methods: {
        updateBoard(data) {
            if (data === undefined || data === null) return;
            if (Object.keys(data).length === 0) return;
            data.sort(function(a, b) {
                return b.score - a.score
            });
            this.board = [];
            this.board.push(data[0]);
            this.board.push(data[1]);
            this.board.push(data[2]);
        }
    }
})

window.addEventListener('message', (event)=>{
    const data = event.data;

    if (data.action == 'update') {
        leaderboard.updateBoard(data.board);
        leaderboard.localeBoard = data.locales.leaderboard;
        leaderboard.localeScore = data.locales.wins;
        leaderboard.localeDescription = data.locales.description;
    }
})
