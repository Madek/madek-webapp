# Manual Testing

## Zencoder Integration

- use any test server with upload capabilty
- on `/entries/new`, upload either audio or video
- publish the Entry
- on `/admin/media_entries`, find the Entry
    - Go to it's MediaFile, check that there is 1 ZencoderJob with status 'finished'
