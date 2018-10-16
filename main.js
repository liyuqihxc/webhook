var WebHookHandler = require('gitlab-webhook-handler');
var http = require('http');
var config = require('./config');
var child_process = require('child_process');
var path = require('path');

let handler = WebHookHandler({ path: config.app_path, secret: config.app_secret });
console.log('Server is listening on http://0.0.0.0:%s%s.', config.port, config.app_path);

http.createServer(function (req, res) {
  handler(req, res, function (err) {
    res.statusCode = 404;
    res.end('no such location');
  })
}).listen(config.port);

handler.on('error', function (err) {
  console.error('Error:', err.message);
});

handler.on('tag_push', function (event) {
  console.log('Received a push event for %s to %s',
    event.payload.repository.name,
    event.payload.ref);
  
  var project = config.projects.find(m => m.name === event.payload.repository.name);
  if (!project)
    return;
  
  var cmd = '';
  if (process.platform === 'win32'){
    cmd = cmd.concat(
      'cmd.exe /c call ',
      '\"' + path.resolve('./sync.cmd') + '\"',
      ' -b ',
      project.branch,
      ' -u ',
      project.url,
      ' -t ',
      event.payload.ref,
      ' -o ',
      '\"' + path.resolve(project.path) + '\"',
      ' -s ',
      project.exec,
      ' > deploy.txt'
    );
  } else {
    throw new Error("Not Implemented.");
  }

  child_process.exec(cmd, {cwd: path.resolve('./'), encoding: 'utf8'}, (err, stdout, stderr) => {
    if (err) {
      console.error(err);
      throw err;
    }
  });
});
