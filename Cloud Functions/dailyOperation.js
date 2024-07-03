const axios = require('axios').default;

Parse.Cloud.job("dailyOperation", async (request) =>  {

    const { params, headers, log, message } = request;

    const dailyMatches = await fetchDailyMatches(request);
    const eventsToUpdate = await updateEvents(request);

    console.info(`SAVED ${dailyMatches.length} MATCHES`);
    console.info(`UPDATED ${eventsToUpdate.length} EVENTS`);

    return 'SUCCESS';
});

async function updateEvents(request) {
    const now = Math.floor(Date.now() / 1000);
    const eventQuery = new Parse.Query("Event");
    eventQuery.notEqualTo("finished", true);
    eventQuery.lessThan("endTimestamp", now);
    eventQuery.limit(999);
    const eventResults = await eventQuery.find();

    var eventsToUpdate = [];

    for (let i = 0; i < eventResults.length; i++) {
        const event = eventResults[i];
        event.set('finished', true);
        eventsToUpdate.push(event);
    }

    try {
        await Parse.Object.saveAll(eventsToUpdate, { useMasterKey: true });
        return eventsToUpdate;
    } catch (error) {
        console.error(error);
        return [];
    }
}

async function fetchDailyMatches(request) {
    const leagueQuery = new Parse.Query("League");
    leagueQuery.equalTo("active", true);
    const leagueResults = await leagueQuery.find();

    console.info(`FETCHING MATCHES FOR ${leagueResults.length} LEAGUES`);

    var dailyMatches = [];
    const dateString = createDateString();

    for (let i = 0; i < leagueResults.length; i++) {
        const league = leagueResults[i];
        const leagueId = league.get('leagueId');
        const responses = await fetchMatches(leagueId, dateString);
        const filteredResponses = responses.filter((response) => {
            const status = response.fixture.status.short;
            return status != 'PST' && status != 'CANC' && status != 'ABD';
        });

        const matches = filteredResponses.map((response) => {

            const Match = Parse.Object.extend("Match");
            const match = new Match();
    
            match.set('matchId', response.fixture.id);
            match.set('startTimestamp', response.fixture.timestamp);
            match.set('date', new Date(response.fixture.date));
            match.set('statusShort', response.fixture.status.short);
            match.set('statusLong', response.fixture.status.long);
            match.set('timeElapsed', response.fixture.status.elapsed);
            match.set('leagueId', leagueId);
            match.set('homeTeamName', response.teams.home.name);
            match.set('homeTeamImageUrl', response.teams.home.logo);
            match.set('awayTeamName', response.teams.away.name);
            match.set('awayTeamImageUrl', response.teams.away.logo);
            match.set('homeTeamScore', response.goals.home);
            match.set('awayTeamScore', response.goals.away);

            return match;
        });

        dailyMatches.push(...matches);
    }

    try {
        await Parse.Object.saveAll(dailyMatches, { useMasterKey: true });
        return dailyMatches;
    } catch (error) {
        console.error(error);
        return [];
    }
}

function createDateString() {
    const today = new Date();
    var dayAfterTomorrow = new Date(today);
    dayAfterTomorrow.setDate(today.getDate() + 2);
    const day = ("0" + dayAfterTomorrow.getDate()).slice(-2);
    const month = ("0" + (dayAfterTomorrow.getMonth() + 1)).slice(-2);
    const year = dayAfterTomorrow.getFullYear();
    const dateString = `${year}-${month}-${day}`;
    return dateString;
}

const footballApi = axios.create({
    baseURL: 'https://v3.football.api-sports.io',
    timeout: 5000,
    headers: {
        'x-rapidapi-host': 'v3.football.api-sports.io',
        'x-rapidapi-key': '50b238f5a16a832ca5d5693f67c461c0'
    }
});

async function fetchMatches(leagueId, dateString) {
    try {
        const response = await footballApi.get(`/fixtures?league=${leagueId}&season=2024&from=${dateString}&to=${dateString}`);
        const responses = response.data.response;
        return responses;
    } catch (error) {
        console.error(`ERROR: ${error}\nREQUEST: ${error.request}`);
        return [];
    }
}