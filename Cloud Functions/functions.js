const { update } = require('parse-server/lib/rest');

Parse.Cloud.afterSave("Event", async (request) =>  {

    const event = request.object;

    if (event.get('inviteCode') == undefined) {
        const inviteCode = event.id.toUpperCase().slice(0, 6);
        event.set('inviteCode', inviteCode);
        try {
            await event.save();
            return 'SUCCESS';
        } catch (error) {
            console.error(error);
            return 'ERROR';
        }
    }
});