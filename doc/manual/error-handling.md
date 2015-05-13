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


## Handling Exceptions

### Generic Exception Rendering

The most simple way to handle an exception in a controller is to `rescue_from` it:

```ruby
rescue_from ForbiddenError do
  render plain: 'YOU SHALL NOT PASS!', status: 403
end
```
