@Posts = new Mongo.Collection("posts")

Posts.allow
  update: (userId, post) ->
    ownsDocument userId, post

  remove: (userId, post) ->
    ownsDocument userId, post

Posts.deny
  update: (userId, post, fieldNames) ->
    _.without(fieldNames, 'url', 'title').length > 0

@validatePost= (post) ->
  errors = {}

  if !post.title
    errors.title = 'Huh, no title really'

  if !post.url
    errors.url = 'So yeah, you gotta put a url'

  errors

Meteor.methods postInsert: (postAttributes) ->
  check Meteor.userId(), String
  check postAttributes,
    title: String
    url: String

  postWithSameLink = Posts.findOne(url: postAttributes.url)

  if postWithSameLink
    return (
      postExists: true
      _id: postWithSameLink._id
    )

  user = Meteor.user()
  post = _.extend(postAttributes,
    userId: user._id
    author: user.username
    submitted: new Date()
  )

  postId = Posts.insert(post)
  _id: postId
