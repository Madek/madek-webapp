# Error Handling

## Raising Exceptions

Every component in Rails brings along error classes which
are raised in an appropriate situation, e.g.
`ActiveRecord::NotFound` when no resource is found.

In the application itself, those can also be raised in needed, e.g. `ActionController::RoutingError.new('no such file')` when a file is not found.

Rails' `ActionDispatch` also has an [internal mapping](http://guides.rubyonrails.org/configuring.html#configuring-action-dispatch)
of how these errors are *translated into a HTTP status*.
Both examples above translate to `404 Not Found`,
while others are just a `500 Internal Server Error`, etc.

## Adding Exceptions

Rails does not provide exceptions for every error the *application* might raise.
For example, since there is no built-in authentication/access handling,
there is also no component implementing `UnauthorizedError` or `ForbiddenError`.

We can add them ourselves:

```ruby
class ForbiddenError < StandardError
end
# etc…
```

We also need to tell `ActionDispatch` how this exception maps to a HTTP status.
This is done by adding the following to `config.action_dispatch.rescue_responses`:

```ruby
  { 'ForbiddenError' => 403 }
```


## Handling Exceptions

### Generic Exception Rendering

The most simple way to handle an exception in a controller is to `rescue_from` it:

```ruby
rescue_from ForbiddenError do
  render plain: 'YOU SHALL NOT PASS!', status: 403
end
```

But what happens if nothing rescues it?  
Rails goes through the following:

1. is the request considered local?
    - if YES, return a developer-friendly error page
    - can be overriden with `config.consider_all_requests_local = true`

2. is `config.action_dispatch.show_exceptions = false`
    - if YES, return and re-raise the exception (= error message from webserver)

2. is there a "exception handling Rack app" configured?
    - if YES, return control to it (via [`ActionDispatch::ShowExceptions`](http://api.rubyonrails.org/classes/ActionDispatch/ShowExceptions.html))

3. render the error with the built-in "exception handling Rack app",
   [`ActionDispatch::PublicExceptions`](http://api.rubyonrails.org/classes/ActionDispatch/PublicExceptions.html).
   Unsurprisingly, it is a static file server that tries to serve a file
   `#{status_code}.html` from the `/public` folder and falls back to `500.html`.

Building a "exception handling Rack app" is quite easy, too, because
any Rails controller action is also a rack app(!).
When in doubt, the `PublicExceptions` controller linked above is by definition the
authorative source on how to implement an `ErrorsController`.

We add `app/controllers/errors_controller.rb` with a `#show` action (see [actual source](https://github.com/Madek/madek-webapp/blob/madek-v3/app/controllers/errors_controller.rb)
for details):

```ruby
class ErrorsController < ApplicationController
  def show
    # get the exception from env['action_dispatch.exception']
    # and render it with the correct status
  end
end
```

And finally configure Rails to let this controller handle exceptions
by setting `config.exceptions_app` to the following:

```ruby
# put in a lambda because it won't be available until runtime
->(env) { ErrorsController.action(:show).call(env) }
```

This makes sure that all exceptions are properly rendered as error pages,
and not just some "mystery message".

### Application Error Handling

After setting up in-app exception rendering as described above,
`rescue_from` in an application controller still works!

Application errors which commonly occur (and are therefore not *exceptional*),
should still be rescued there.
Letting them raise any further could be an error in itself.
Having the customized rendering just makes debugging easier for errors that
are observed in 'staging' or even 'production' environments.

Furthermore, `rescue_from` allows for context-specific error pages:

- in `important_model_controller`, show a fancy 'Not Found' page:
  ```ruby
  rescue_from ActiveRecord::NotFoundError, with: :fancy_404_page
  rescue_from ActiveController::RoutingError, with: :fancy_404_page
  ```

- in `foo_controller`, redirect 404 to index
  ```ruby
  rescue_from ActiveRecord::NotFoundError do
    redirect to foo_index_path, flash: {
      error: 'No such Foo! Here are all the known Foos:'
    }
  end
  ```

## Testing Errors

Make sure that `config.action_dispatch.show_exceptions = true`
in `test` environment so that custom error pages can be tested.

### Controller Tests

In controller tests, **views are not rendered** by default,
so all errors are raised.
There are two ways to deal with this, depending what should be tested:

**Either:** Just test that the controller does the right thing (raising the Error):

```ruby
context 'authorization' do
  expect { get '/something/forbidden' }
    .to raise_error(Errors::ForbiddenError)
end
```

**Or:** Force the controller test to be a request, to test that the correct error page is rendered:

```ruby
context 'authorization', type: :request do
  get '/something/forbidden'
  assert_response :forbidden
end
```

## Login Flow

There is no *flow*, which would have to be manually managed, like with a
`session[:return_to]` store (working against the statelessness of HTTP).

Just to clarify, these are the steps:

1. request `GET /my`
2. response `401 Unauthorized`
    - `Body: …<html>…` (contains a log form)
3. user fills out correct credentials and submits form
4. request `POST /session/sign_in`
5. response `302 Moved Temporarily`
    - `Location: /my` (referrer of the `POST` request)
