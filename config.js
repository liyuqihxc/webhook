// 监听的端口
var port = 9091;

// Github webhook secret
var app_secret = 'REPLACE WITH YOUR OWN'

// github-webhook-handler监听路径
var app_path = 'REPLACE WITH YOUR OWN'

// 项目配置
var projects = [
    {
        name: 'liyuqihxc.top',
        path: '/www/liyuqihxc.top',
        url: 'https://github.com/liyuqihxc/liyuqihxc.top.git',//不用ssh可以省去设置ssh key的麻烦
        exec: './shell/blog/blog_deploy.sh',
        branch: 'develop'// default: master
    },
    {
        name: 'PSMS',
        path: 'D:\\PSMS',
        url: 'http://192.168.0.250:9090/liyuqi/PSMS.git',
        exec: './shell/psms/psms_deploy.cmd',
        branch: 'master'
    }
]

module.exports = {
    projects,
    port,
    app_secret,
    app_path
};
