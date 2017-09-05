utils = require '../utils'
Promise = require 'bluebird'
AnalyticsLogEvent = require '../../../server/models/AnalyticsLogEvent'
request = require '../request'
mongoose = require 'mongoose'

describe 'POST /db/analytics.log.event/-/log_event', ->
  it 'posts an event to the log db', utils.wrap ->
    user = yield utils.initUser()
    yield utils.loginUser(user)
    json = {
      event: 'Some Name'
      properties: {
        'some': 'property'
        number: 1234
      }
    }
    url = utils.getUrl('/db/analytics.log.event/-/log_event')
    [res] = yield request.postAsync({url, json})
    expect(res.statusCode).toBe(201)
    yield new Promise((resolve) -> setTimeout(resolve, 50)) # make sure event gets created
    events = yield AnalyticsLogEvent.find({user: user._id})
    expect(events.length).toBe(1)
    expect(events[0].event).toBe(json.event)
    expect(events[0].properties).toDeepEqual(json.properties)
    expect(events[0].user).toBe(user.id)
