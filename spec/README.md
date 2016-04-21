# Manual Testing

## Async dashboard

- only the first 3 section of the dashboard are loaded initally
- make sure rest load eventually (will show preloaders until then)

## Zencoder Integration

- use any test server with upload capabilty
- on `/entries/new`, upload either audio or video
- publish the Entry
- on `/admin/media_entries`, find the Entry
    - Go to it's MediaFile, check that there is 1 ZencoderJob with status 'finished'
