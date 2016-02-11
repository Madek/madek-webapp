# Feature Test Developer Notes

## Basic Structure

- top-level: always `feature` with `'Resource: '`, `'Page: '` or `'Feature: …'`
- second-level:
  - for Resources, always `describe 'Action: …`
  - for anything else only when needed
- optional: third-level `context` if more grouping is needed
  ('as public', 'with javascript', …)
- optional: add as many `describe`s as are needed to understand the test cases
- actual tests cases: `it` (alias `example` or `specify` for readability)

Additionally:

- `pending`: **Never** use `pending` *inside* an example!
  (Reason: docs are rendered with `--dry-run`, none of the examples are executed!)
    - DONT: `it 'foo' do pending('bar') end`
    - DO: `pending 'foo'`

- `background`: specify (if any) as "high up" as needed


## Test Case descriptions

- do not indicate test for success ("… and it works"),
  but **do** indicate test for failure ("doing it wrong fails…")
- always specifiy "for logged in user", "for public", etc.,
  either directly in the test case; or in a `context`
  (or even higher up, e.g. when a feature is only supported for logged in users)


## Examples

```rb
# minimal - resourcefull
feature 'Resource: Foo' do
  describe 'Action: bar' do
    it 'does the bar' do end
  end
end

# full example - resourcefull
feature 'Resource: Foo' do
  describe 'Action: bar' do
    context 'for logged in user' do
      it 'does the bar' do end
      example 'when doing it wrong it does not work' do end
      specify 'must baz when Foo is bared!' do end
    end
  end
end


# alternatives: slightly less resourcefull
feature 'Resource: Foo' do
  describe 'Action: bar (from some other place in the App)' do
    it 'bars the Foo via the "bar the Foo" button' do end
  end
end

# non-resourceful view
feature 'Page: Foo' do
  describe 'main section' do
    it 'shows the thing' do end
  end
end

# application-level feature
feature 'Feature: Foo' do
  specify 'app runs in Foo-Mode' do end
end
```
