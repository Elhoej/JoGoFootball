const axios = require('axios').default;

const footballApi = axios.create({
    baseURL: 'https://v3.football.api-sports.io',
    timeout: 10000,
    headers: {
        'x-rapidapi-host': 'v3.football.api-sports.io',
        'x-rapidapi-key': '50b238f5a16a832ca5d5693f67c461c0'
    }
});

Parse.Cloud.job("updateLiveMatches", async (request) =>  {

    const { params, headers, log, message } = request;

    const leagueQuery = new Parse.Query("League");
    const leagueResults = await leagueQuery.find();

    const leagueIds = leagueResults.map((league) => {
        return league.get('leagueId');
    });

    const path = leagueIds.join('-');

    const responses = await fetchLiveMatches(path);

    var updatedMatches = [];
    
    for (let i = 0; i < responses.length; i++) {
        const response = responses[i];
        const matchQuery = new Parse.Query("Match");
        matchQuery.equalTo("matchId", response.fixture.id);
        const match = await matchQuery.first();

        if (match == undefined) { continue; }

        match.set('statusShort', response.fixture.status.short);
        match.set('statusLong', response.fixture.status.long);
        match.set('timeElapsed', response.fixture.status.elapsed);
        match.set('homeTeamScore', response.goals.home);
        match.set('awayTeamScore', response.goals.away);
        updatedMatches.push(match);
    }

    if (Array.isArray(updatedMatches) && updatedMatches.length) {
        console.info(`UPDATING ${updatedMatches.length} LIVE MATCHES`);
        try {
            await Parse.Object.saveAll(updatedMatches, { useMasterKey: true });
            return 'SUCCESS';
        } catch (error) {
            console.error(error);
            return 'ERROR';
        }
    } else {
        console.info(`NO LIVE MATCHES TO UPDATE`);
        return 'SUCCESS';
    }
});

async function fetchLiveMatches(path) {
    try {
        const response = await footballApi.get(`/fixtures?live=${path}`);
        const responses = response.data.response;
        return responses;
    } catch (error) {
        console.error(error);
        return [];
    }
}