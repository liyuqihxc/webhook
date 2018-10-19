// 监听的端口
var port = 9091;

// Github webhook secret
var app_secret = 'REPLACE WITH YOUR OWN'

// github-webhook-handler监听路径
var app_path = '/autodeploy'

var self_update = {
    name: 'webhook'
}

// 项目配置
var projects = [
    {
        name: 'PSMS',
        path: 'D:\\PSMS',
        url: 'git@192.168.0.250:liyuqi/PSMS.git',
        exec: 'run-deploy.cmd',
        branch: 'develop'
    }
]

module.exports = {
    projects,
    port,
    app_secret,
    app_path,
    self_update
};
