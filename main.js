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
  console.log('Received a push event for \"%s\" to \"%s\"',
    event.payload.repository.url,
    event.payload.ref);
  
  var project = config.projects.find(m => m.name === event.payload.repository.name);
  if (!project && event.payload.repository.name != config.self_update.name)
    return;

  var cmd = undefined;
  if (project) {
    cmd = getCmdLine(project.name, project.url, project.branch, event.payload.ref, path.resolve(project.path), project.exec);
  } else {
    var cmdRestart = '';
    if (process.platform === 'win32') {
      cmdRestart = 'taskkill /f /pid ' + process.pid + ' && node main.js';
    } else {
      throw new Error('Not Implemented.')
    }
    cmd = getCmdLine(event.payload.repository.name, event.payload.repository.url, 'master', event.payload.ref, path.resolve('./'), cmdRestart)
  }
  
  child_process.spawn(cmd, [], {cwd: path.resolve('./'), detached: true})
    .unref();
});

function getCmdLine (name, url, branch, ref, outdir, script) {
  var cmd = '';
  if (process.platform === 'win32'){
    cmd = cmd.concat(
      'cmd.exe /c call ',
      '\"' + path.resolve('./sync.cmd') + '\"',
      ' -b ',
      branch,
      ' -u ',
      url,
      ' -t ',
      ref,
      ' -o ',
      '\"' + outdir + '\"',
      ' -s ',
      script,
      ' > logs/' + name + 'deploy.log'
    );
  } else {
    throw new Error("Not Implemented.");
  }
  return cmd;
}
