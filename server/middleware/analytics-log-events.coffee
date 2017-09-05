wrap = require 'co-express'
AnalyticsLogEvent = require '../models/AnalyticsLogEvent'

post = wrap (req, res) ->
  # Converts strings to string IDs where possible, and logs the event
  user = req.user?._id
  { event, properties } = req.body
  eventRes = AnalyticsLogEvent.logEvent user, event, properties
  res.status(201).send({})
  event = yield eventRes if eventRes
    
module.exports = {
  post
}
