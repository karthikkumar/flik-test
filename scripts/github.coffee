token=""
unmergeablePulls = []

addPullIdToList = (pullId) ->
  return false if pullId in unmergeablePulls

  unmergeablePulls.push pullId
  return true

removePullIdFromList = (pullId) ->
  return if pullId == null

  indexOfPullId = unmergeablePulls.indexOf(pullId)
  unmergeablePulls.splice(indexOfPullId, pullId)

getRequest = (robot, data, callback) ->
    url = "https://api.github.com/repos/karthikkumar/tik-test/pulls/#{data.pullId}"
    console.log("request url: #{url}")
    robot.http(url)
      .headers('Accept': 'application/json')
      .get() (err, res, body) ->
        callback(err, res, body)

checkMergeStatus = (robot, data) ->
    getRequest robot, data, (err, res, body) ->
      try
        #TODO handle err
        response = JSON.parse body
        mergeStatus = response.mergeable
        console.log("mergeable : #{mergeStatus}")
        if (mergeStatus == false)
          if addPullIdToList(robot, data.pullId)
            robot.emit 'merge_conflict', {
              room: data.room,
              pullTitle: response.title,
              author: response.user.login,
              pullUrl: response.html_url,
              pullId: response.number
            }
        else if (mergeStatus == 'unknown')
          setTimeout ->
            checkMergeStatus(robot, data)
          , 1000
        else
          console.log("Skip!")
      catch error
        robot.emit 'error', error

module.exports = (robot) ->
  robot.router.post '/hubot/github/:room', (req, res) ->
      room = req.params.room

      try
        data = req.body
        pull_request =
          {
            room: room,
            url: data.pull_request.url
            pullId: data.pull_request.number
            pullState: data.pull_request.state
          }
        if (pull_request.pullState == 'open' || pull_request.pullState == 'reopened')
          console.log("PR is open!")
          checkMergeStatus robot, pull_request
        res.send 'OK'
      catch error
        robot.emit 'error', error

  robot.on 'error', (error) ->
      console.log("Error: #{error}")
