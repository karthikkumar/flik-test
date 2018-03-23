module.exports = (robot) ->

    robot.on 'merge_conflict', (merge_conflict) ->
      room_id = robot.adapter.client.rtm.dataStore.getChannelByName(merge_conflict.room).id
      message =
        {
          "text": ":no_entry_sign: Merge conflict: <#{merge_conflict.pullUrl}|##{merge_conflict.number} #{merge_conflict.pullTitle}> by #{merge_conflict.author}"
        }

      robot.messageRoom room_id, message