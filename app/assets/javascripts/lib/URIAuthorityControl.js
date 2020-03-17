// Madek Authority Control Providers
//
// concept like https://en.wikipedia.org/wiki/Help:Authority_control
// see their implementation: https://www.wikidata.org/w/index.php?title=MediaWiki:Gadget-AuthorityControl.js&oldid=802023356
// also the early version: https://www.wikidata.org/w/index.php?title=MediaWiki:Gadget-AuthorityControl.js&oldid=179329592

import url from 'url'
import f from 'lodash'

const AUTHORITY_CONTROL_PROVIDERS = {
  GND: {
    label: 'GND',
    name: 'Gemeinsame Normdatei',
    url: 'https://www.dnb.de/DE/Standardisierung/GND/gnd_node.html',
    patterns: [
      ({ hostname, path }) => {
        // https://d-nb.info/gnd/118529579
        return hostname == 'd-nb.info' && path.match(/^\/gnd\/([a-zA-Z0-9]+)$/)
      }
    ]
  },

  LCCN: {
    label: 'LCCN',
    name: 'Library of Congress Control Number',
    url: 'https://lccn.loc.gov/lccnperm-faq.html',
    patterns: [
      // https://lccn.loc.gov/no97021030
      ({ hostname, path }) => {
        return hostname == 'lccn.loc.gov' && path.match(/^\/([a-zA-Z]*\d+)$/)
      },
      // https://id.loc.gov/authorities/names/n79022889
      ({ hostname, path }) => {
        return hostname == 'id.loc.gov' &&
          path.match(/^\/authorities\/names\/([a-zA-Z]*\d+)$/)
      }
    ]
  },

  IMDB: {
    // technical info, via wikidata: https://www.wikidata.org/wiki/Property:P345
    label: 'IMDb ID',
    name: 'Internet Movie Database identifier',
    url: 'https://www.imdb.com/',
    patterns: [
      // https://www.imdb.com/name/nm0251868/
      ({ hostname, path }) => {
        return hostname.replace(/^www./, '') == 'imdb.com' &&
          path.match(/^\/name\/(nm\d{7,8})\/$/)
      }
    ]
  },

  ORCID: {
    label: 'ORCID iD',
    name: 'Open Researcher and Contributor ID',
    url: 'https://www.orcid.org',
    patterns: [
      // https://orcid.org/0000-0002-1825-0097
      ({ hostname, path }) => {
        const pathr = /^\/(\d{4}-\d{4}-\d{4}-\d{3}[\dX]{1})$/
        return hostname == 'orcid.org' && path.match(pathr)
      }
    ]
  },

  ResearcherID: {
    // technical info, via wikidata: https://www.wikidata.org/wiki/Property_talk:P1053
    label: 'ResearcherID',
    name: 'Web of Science ResearcherID',
    url: 'https://www.researcherid.com',
    patterns: [
      // https://www.researcherid.com/rid/K-8011-2013
      ({ hostname, path }) => {
        return hostname.replace(/^www./, '') == 'researcherid.com' &&
          path.match(/^\/rid\/([a-zA-Z\d-]+)$/)
      }
    ]
  },

  VIAF: {
    label: 'VIAF',
    name: 'Virtual International Authority File',
    url: 'https://viaf.org',
    patterns: [
      // https://viaf.org/viaf/75121530
      ({ hostname, path }) => hostname == 'viaf.org' && path.match(/^\/viaf\/(\d+)$/)
    ]
  },

  WIKIDATA: {
    // technical info: <https://www.wikidata.org/wiki/Wikidata:Data_access/de>
    label: 'Wikidata',
    name: 'Wikidata Entity URI',
    url: 'https://www.wikidata.org',
    patterns: [
      // http://www.wikidata.org/entity/Q42
      ({ hostname, path }) => {
        return hostname.replace(/^www./, '') == 'wikidata.org' &&
          path.match(/^\/entity\/(Q\d+)$/)
      }
    ]
  }
}

function detect(parsedUrl) {
  let res =
    f.map(AUTHORITY_CONTROL_PROVIDERS, (provider, kind) => {
      const matches = f.map(provider.patterns, pattern => {
        return pattern(parsedUrl)
      })
      const match = f.find(matches, m => m !== false)
      if (match) {
        return { kind: kind, label: match[1] }
      }
    })
  
  res = f.find(res, el => !f.isEmpty(el))

  if (res) {
    const provider = f.assign({}, AUTHORITY_CONTROL_PROVIDERS[res.kind])
    delete provider.patterns
    res.provider = provider
    return res
  }
}

export function decorateExternalURI(rawURI) {
  const parsedUrl = url.parse(rawURI)
  const isValid = !f.isNil(parsedUrl.hostname)

  return {
    uri: rawURI,
    is_web: f.includes(['http:', 'https:'], parsedUrl.protocol),
    authority_control: isValid ? detect(parsedUrl) : null
  }
}
