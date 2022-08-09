var fs = require('fs');
const util = require('util');
const readFileAsync = util.promisify(fs.readFile);

module.exports = async function (context, req) {
    if(context.req.query.file){
        let data;
        try {
            data = await readFileAsync(`./webapp/${context.req.query.file}`);
        } catch (err) {
            context.log.error('ERROR', err);
            throw err;
        }
        context.res = {
            body: data,
            headers: {
                "Content-Type": "application/javascript"
            }};
        context.done();
    }else{
        let data;
        try {
            data = await readFileAsync('./webapp/index.html');
        } catch (err) {
            context.log.error('ERROR', err);
            // This rethrown exception will be handled by the Functions Runtime and will only fail the individual invocation
            throw err;
        }
        context.res = {
            body: data,
            headers: {
                "Content-Type": "text/html"
            }};
        context.done();
    }
    
}
