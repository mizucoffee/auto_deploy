const express = require("express");
const { exec, execSync, spawn } = require("child_process");

const app = express();

app.use(express.json())
app.use(express.urlencoded({ extended: true }));
app.listen(42953);

exec(`nginx -g "daemon off;"`, (err, stdout, stderr) => {
  if (err) {
    console.error(err);
    return;
  }
  console.log(stdout);
  console.error(stderr);
});

let ps = null;
execSync(`git clone "${process.env.GITHUB_REPO}" /website`)
const branch = process.env.GITHUB_BRANCH || execSync('git symbolic-ref --short HEAD', {cwd: "/website", env: {...process.env}})

if(process.env.GITHUB_BRANCH) execSync(`git checkout ${process.env.GITHUB_BRANCH}`, {cwd: "/website", env: {...process.env}})
if(process.env.PRE_COMMAND) execSync(`${process.env.PRE_COMMAND}`, {cwd: "/website", env: {...process.env}})
const commandArgs = `${process.env.START_COMMAND}`.split(' ')
const command = commandArgs.shift()
ps = spawn(command, commandArgs, { env: {PORT: 3000}, detached: true, cwd: "/website" , env: {...process.env}})
ps.stdout.setEncoding("utf-8")
ps.stderr.setEncoding("utf-8")
ps.stdout.on("data", data => console.log(data.trim()))
ps.stderr.on("data", data => console.log(data.trim()))
ps.on('exit', code => console.log("Finished: " + code))

async function update() {
  process.kill(-ps.pid, 'SIGINT')
  execSync(`git fetch && git reset --hard origin/$(git symbolic-ref --short HEAD)`, {cwd: "/website", env: {...process.env}})
  if(process.env.PRE_COMMAND) execSync(`${process.env.PRE_COMMAND}`, {cwd: "/website", env: {...process.env}})
  ps = spawn(command, commandArgs, { env: {PORT: 3000}, detached: true, cwd: "/website" , env: {...process.env}})
  ps.stdout.setEncoding("utf-8")
  ps.stderr.setEncoding("utf-8")
  ps.stdout.on("data", data => console.log(data.trim()))
  ps.stderr.on("data", data => console.log(data.trim()))
  ps.on('exit', code => console.log("Finished: " + code))
}

app.get("/", (req, res) => {
  res.send("Welcome to Auto Deploy System!");
});

app.post("/webhook", (req, res) => {
  if(req.body?.ref == `refs/heads/${process.env.GITHUB_BRANCH || req.body?.repository?.default_branch}`)
    update();
  res.send("ok");
});
