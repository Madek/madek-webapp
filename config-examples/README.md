# Video.js player config

Video and audio entries use the same player (`webapp/app/javascript/react/ui-components/VideoJs.jsx`). Settings live on the entry’s metadata edit page, tab **Wiedergabe / Playback**.

Two pieces of data drive the player:

| Input | Where | What it controls |
| --- | --- | --- |
| `media_config` JSON | textarea on the Playback tab, stored on the media file | timed logo headers and text overlays |
| WebVTT files | upload form below the JSON | subtitles and timeline chapters |

A `sources` key in the JSON is dropped on save. Resolution is not part of this config.

Samples in this folder: [`video.json`](video.json) (two logo windows, overlay with pause and overlay without), [`song.json`](song.json) (one logo window, one pausing overlay).

Live entries:

- https://manuel.madek.rubydev.zhdk.ch/entries/679113dd-1c08-43ef-9e44-406ef721882c
- https://manuel.madek.rubydev.zhdk.ch/entries/89323f59-15af-4883-91b6-023fa3dac4bd

Times are seconds from the start of the file. A layer is visible while `currentTime` is `>= start` and `< end`.

## Header (icon with link)

`headers` is a list of images shown over the player for a time range. Same behavior for video and song.

| Field | Effect |
| --- | --- |
| `src` | Image URL. `http`/`https`, or a site path starting with `/`. Missing or unsafe URLs drop the header. |
| `alt` | Alt text. |
| `href` | Optional link. Same URL rules as `src`. Without `href` the image is not clickable. |
| `target` | Link target. Defaults to `_blank`. |
| `start`, `end` | Seconds the icon is shown. |

```json
{
  "src": "https://medienarchiv.zhdk.ch/logo.svg",
  "alt": "ZHdK",
  "href": "https://medienarchiv.zhdk.ch/",
  "target": "_blank",
  "start": 0,
  "end": 3
}
```

## Text overlay

`overlays` is a list of texts shown over the player. Same timing rules for video and song. `text` is a map of language code to string (`de`, `en`, …). The language follows the subtitle track that is currently on; if none is on, the default subtitle language is used.

`stop_media_during_overlay` changes whether playback continues:

| Value | Effect |
| --- | --- |
| `true` | Playback pauses when the window starts. The text stays up for the rest of that window, then playback continues. Pressing play during the pause dismisses the overlay and continues. |
| `false` | The text is shown for the window while the media keeps playing. |

```json
{
  "start": 5,
  "end": 8,
  "stop_media_during_overlay": true,
  "text": { "de": "ich pausiere", "en": "im pausing" }
}
```

## Subtitle

Subtitles are WebVTT files, not JSON. On the Playback tab, set **language**, kind **Subtitles**, and upload a `.vtt` file.

- **Video:** cues use the player’s captions control.
- **Song:** a CC button is added to the audio controls. The active cue is also drawn as text on the player (lyrics).

The file whose language matches the current interface language (German or English) is turned on by default. Overlay text uses that same language.

```vtt
WEBVTT

00:00:05.000 --> 00:00:08.000
ich pausiere
```

## Resolution

Resolution is not in `media_config`. It comes from the encoded previews.

- **Video:** profiles whose name ends in `_HD` are labeled **HD**, every other preview **SD**. The quality menu appears when both exist and starts on **SD**. Changing quality keeps the current time and whether it was playing.
- **Song:** no quality menu. Several audio encodings are offered to the browser, with `audio/mpeg` first.

## Timeline sections (chapters)

Chapters are a second WebVTT upload. Same form, kind **Chapters**. Cue text is the section title; cue times are the section on the timeline.

Chapters are not shown as captions. The player uses them as timeline markers. If several chapter files exist, the one in the active subtitle language is used.

```vtt
WEBVTT

00:00:00.000 --> 00:01:00.000
Intro

00:01:00.000 --> 00:02:30.000
Verse
```
