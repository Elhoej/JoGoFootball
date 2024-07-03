const axios = require('axios').default;

const footballApi = axios.create({
    baseURL: 'https://v3.football.api-sports.io',
    timeout: 10000,
    headers: {
        'x-rapidapi-host': 'v3.football.api-sports.io',
        'x-rapidapi-key': '50b238f5a16a832ca5d5693f67c461c0'
    }
});

Parse.Cloud.job("updatePredictions", async (request) =>  {

    const { params, headers, log, message } = request;

    var epochInSeconds = Math.floor(Date.now() / 1000);
    const matchQuery = new Parse.Query("Match");
    matchQuery.lessThan("startTimestamp", epochInSeconds);
    matchQuery.notContainedIn("statusLong", ["Match Finished", "Match Postponed", "Match Abandoned"]);
    matchQuery.limit(999);

    const matchResults = await matchQuery.find();

    console.info(`MATCH COUNT: ${matchResults.length}`);

    if (!Array.isArray(matchResults) || !matchResults.length) {
        console.info('updatePredictions: NO MATCHES TO UPDATE PREDICTIONS');
        return 'SUCCESS';
    }

    var updatedMatches = [];
    var updatedPredictions = [];

    for (let i = 0; i < matchResults.length; i++) {
        const match = matchResults[i];
        const elapsed = match.get('timeElapsed');
        const startTimeStamp = match.get('startTimestamp');
        const timestampDifference = epochInSeconds - startTimeStamp;
        const differenceInHours = Math.floor(timestampDifference / 3600);

        console.info(`ELAPSED: ${elapsed}`);
        console.info(`DIFFERENCE: ${differenceInHours}`);

        if (elapsed >= 85 || differenceInHours >= 2) {
            const matchId = match.get("matchId");
            console.info(`FOUND MATCH TO UPDATE: ${matchId}`);
            const response = await fetchMatch(matchId);

            if (response != undefined) {
                match.set('statusShort', response.fixture.status.short);
                match.set('statusLong', response.fixture.status.long);
                match.set('timeElapsed', response.fixture.status.elapsed);
                match.set('homeTeamScore', response.goals.home);
                match.set('awayTeamScore', response.goals.away);
                updatedMatches.push(match);
    
                const status = response.fixture.status.short;
                if (status == 'FT' || status == 'AET' || status == 'PEN') {
                    const predictions = await updatePredictions(match, response);
                    updatedPredictions.push(...predictions);
                }
            }
        }
    }

    if (Array.isArray(updatedMatches) && updatedMatches.length) {
        console.info(`UPDATING ${updatedMatches.length} MATCHES`);
        try {
            await Parse.Object.saveAll(updatedMatches, { useMasterKey: true });
        } catch (error) {
            console.error(error);
        }
    } else {
        console.info(`NO MATCHES TO UPDATE`);
    }

    if (Array.isArray(updatedPredictions) && updatedPredictions.length) {
        console.info(`UPDATING ${updatedPredictions.length} PREDICTIONS`);
        try {
            await Parse.Object.saveAll(updatedPredictions, { useMasterKey: true });
            return 'SUCCESS';
        } catch (error) {
            console.error(error);
            return 'ERROR';
        }
    } else {
        console.info('NO PREDICTIONS TO UPDATE');
        return 'SUCCESS';
    }
});

async function fetchMatch(id) {
    try {
        const response = await footballApi.get(`/fixtures?id=${id}`);
        const matchResponse = response.data.response[0];
        return matchResponse;
    } catch (error) {
        console.error(error);
        return undefined;
    }
}

async function updatePredictions(match, response) {
    var predictionsToUpdate = [];
    const predictionsQuery = new Parse.Query("Prediction");
    predictionsQuery.equalTo("match", match);
    predictionsQuery.include("user");
    const predictions = await predictionsQuery.find();

    if (predictions == undefined) { return []; }

    for (let i = 0; i < predictions.length; i++) {
        const prediction = predictions[i];
        const teamPrediction = prediction.get('teamPrediction');
        var points = 0;
        switch (teamPrediction) {
            case 'HOME': 
                if (response.goals.home > response.goals.away) {
                    points+=1;
                }
                break;
            case 'DRAW':
                if (response.goals.home == response.goals.away) {
                    points+=1;
                }
                break;
            case 'AWAY':
                if (response.goals.home < response.goals.away) {
                    points+=1;
                }
                break;
            default: break;
        }

        //check for undefined
        const predictionHomeScore = prediction.get('homeTeamScore');
        const predictionAwayScore = prediction.get('awayTeamScore');

        if (predictionHomeScore !== undefined && predictionAwayScore !== undefined) {
            if (response.goals.home == predictionHomeScore && response.goals.away == predictionAwayScore) {
                points+=3;
            }
        }

        prediction.set('points', points);
        predictionsToUpdate.push(prediction);

        if (points > 0) {
            await sendPush(match, prediction, points);
        }
    }

    return predictionsToUpdate;
}

async function sendPush(match, prediction, points) {
    const user = prediction.get('user');
    const userId = user.get('objectId');
    const homeTeamName = match.get('homeTeamName');
    const awayTeamName = match.get('awayTeamName');
    const query = new Parse.Query(Parse.Installation);
    query.equalTo('userId', userId);
    query.limit(1);

    try {
        await Parse.Push.send({
            where: query,
            data: {
                alert: `Du har fået ${points} point fra kampen mellem ${homeTeamName} - ${awayTeamName}`,
            }
        }, { useMasterKey: true });
        console.info("Successfully sent push");
    } catch (error) {
        console.error(error);
    }
}