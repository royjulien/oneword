Template.postSubmit.created = ->
  return Session.set 'postSubmitErrors', {}

Template.postSubmit.helpers
  errorMessage: (field) ->
    Session.get('postSubmitErrors')[field]
  errorClass: (field) ->
    if !Session.get('postSubmitErrors')[field] then 'has-error' else ''

Template.postSubmit.events "submit form": (e) ->
  e.preventDefault()
  post =
    url: $(e.target).find("[name=url]").val()
    title: $(e.target).find("[name=title]").val()

  errors = validatePost(post)

  if errors.title or errors.url
    return Session.set('postSubmitErrors', errors)

  Meteor.call 'postInsert', post, (error, result) ->
    throwError error.reason if error

    throwError 'This link has already been posted' if result.postExists
    Router.go 'postPage', {_id: result._id}
