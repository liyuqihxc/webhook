var WebHookHandler = require('github-webhook-handler')
var http = require('http')
var config = require('./config')
var child_process = require('child_process')
var path = require('path')

let handler = WebHookHandler({ path: config.app_path, secret: config.app_secret })
console.log('listening on %s.', config.port)

http.createServer(function (req, res) {
  handler(req, res, function (err) {
    res.statusCode = 404
    res.end('no such location')
  })
}).listen(config.port)

handler.on('error', function (err) {
  console.error('Error:', err.message)
})

handler.on('push', function (event) {
  console.log('Received a push event for %s to %s',
    event.payload.repository.name,
    event.payload.ref);
  
  var project = config.projects.find(m => m.name === event.payload.repository.name)
  if (!project || event.payload.ref !== 'refs/heads/'.concat(project.branch))
    return
  
  let cmd = ''.concat(
    'sh ',
    path.resolve('./sync.sh'),
    ' -b ',
    project.branch,
    ' -u ',
    project.url,
    ' -t ',
    path.resolve(project.path),
    ' -s ',
    path.resolve(project.exec)
  )
  console.log(cmd)
  child_process.exec(cmd, (err, stdout, stderr) => {
    if (err) {
      console.error(err);
      return;
    }
    console.log(stdout);
  })
})
