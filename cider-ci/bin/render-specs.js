#!/usr/bin/env node
const f = require('active-lodash')
const shell = (cmd) => require('child_process').execSync(cmd, {stdio: ['ignore', 'pipe', 'ignore']})
const cheerio = require('cheerio')

const filePath = process.argv[2]

// build header
const gitVersion = shell('git log -n1 --format="%h"')
const gitTree = shell('git log -n1 --format="%T"')
const versionLink = `https://ci.zhdk.ch/cider-ci/ui/workspace/trees/${gitTree}`
const header = `
  <h1>
    Madek Specs
    <small><small>
      <a href=${versionLink}>
        version
        <kbd>${gitVersion}</kbd>
      </a>
    </small></small>
  </h1>`

const stdout = shell(`
  bundle exec rspec --dry-run --order defined --format html ${filePath}`)
if (!f.present(stdout)) throw new Error('no output!')

// load as "DOM"
const $ = cheerio.load(stdout.toString())

// inject header, cleanup & styling
$('#rspec-header h1')
  .replaceWith(header)
$('#duration').add('span.duration').add('script')
  .remove()
$('head').append(`<style type="text/css">
  dt { white-space: pre }
</style>`)

// output
process.stdout.write($.html())