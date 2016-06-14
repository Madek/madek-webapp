# Manual Testing

## Autocomplete (mouse interaction)

- find any Autocompleter (Keywords in MetaDataEdit, Anything in Permissions, …)
- verify that mouse interaction works: clicking on a result selects it

## Async dashboard

- only the first 3 section of the dashboard are loaded initally
- make sure rest load eventually (will show preloaders until then)

## Zencoder Integration

do the following for:
- a video file
- an audio file

steps:
- use any test server with upload capabilty
- on `/entries/new`, upload file
- publish the Entry
- on `/admin/media_entries`, find the Entry
    - Go to it's MediaFile, check that there is 1 ZencoderJob with status 'finished'
