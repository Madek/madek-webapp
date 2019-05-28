import React from 'react'
import f from 'lodash'
// import setUrlParams from '../../../lib/set-params-for-url.coffee'
// import AppRequest from '../../../lib/app-request.coffee'
// import asyncWhile from 'async/whilst'
// import { parse as parseUrl } from 'url'
// import { parse as parseQuery } from 'qs'
// import Moment from 'moment'
// import currentLocale from '../../../lib/current-locale'
const UI = require('../../ui-components/index.coffee')
import SubSection from '../../ui-components/SubSection'
// import ui from '../../lib/ui.coffee'
// const t = ui.t

// function MyWorkflows(props) {
//   return <pre>{JSON.stringify(props, 0, 2)}</pre>
// }
//
// module.exports = MyWorkflows

const DUMMY_ARK_ID = 'http://pid.zhdk.ch/ark:99999/x9t38rk45c'

class WorkflowsIndex extends React.Component {
  render(props = this.props) {
    const { get, authToken } = props

    const newAction = f.get(get, 'actions.new')

    return (
      <div className="ui-resources-holder pal">
        <div className="ui-container pbl">
          <div className="ui-resources-header">
            <h2 className="title-l ui-resources-title">{'Workflows'}</h2>
          </div>
          {f.isEmpty(get.list) ? (
            'Noch nix'
          ) : (
            <WorkflowsList list={get.list} authToken={authToken} />
          )}
          {!!newAction && (
            <div className="mtl">
              <UI.Button href={newAction.url} className="primary-button">
                {'Neues Projekt'}
              </UI.Button>
            </div>
          )}
        </div>

        <hr />

        <WorkflowEdit />

        <hr />

        <pre>{JSON.stringify(props, 0, 2)}</pre>
      </div>
    )
  }
}

const WorkflowEdit = () => (
  <section className="ui-container bright bordered rounded mtm mbm pas">
    <header>
      <span style={{ textTransform: 'uppercase', fontSize: '85%', letterSpacing: '0.15em' }}>
        Prozess
      </span>
      <h1 className="title-l" style={{ lineHeight: '1.34' }}>
        {'Materialsammlung Forschungsprojekt «Sound Colour Space»'}
      </h1>
    </header>

    <div>
      <SubSection>
        <SubSection.Title tag="h2" className="title-m mts">
          Beteiligte Personen
        </SubSection.Title>

        <ul className="list-inline">
          <li>
            <DummyPerson name="Susanne Schumacher" />
          </li>
          <li>
            <DummyPerson name="Daniel Muzzulini" />
          </li>
        </ul>
      </SubSection>

      <SubSection>
        <SubSection.Title tag="h2" className="title-m mts">
          Set mit Inhalten
        </SubSection.Title>

        <Explainer>
          In diesem Set entaltene Inhalte können vor dem Abschluss nur als Teil dieses Prozesses
          bearbeitet werden.
        </Explainer>

        <div>
          <div className="ui-resources miniature" style={{ margin: 0 }}>
            <DummySetThumb />
          </div>

          <div className="button-group small mas">
            <a className="tertiary-button" href="#/my/upload">
              <span>
                <i className="icon-upload"></i>
              </span>{' '}
              Medien hinzufügen
            </a>
          </div>
        </div>
      </SubSection>

      <SubSection>
        <SubSection.Title tag="h2" className="title-m mts">
          Gemeinsamer Datensatz
        </SubSection.Title>

        <Explainer>
          Diese Daten und Einstellungen gelten für alle enthaltenen Inhalte und werden bei
          Prozessabschluss permanent angewendet.
        </Explainer>

        <SubSection open>
          <SubSection.Title tag="h3" className="title-s mts" style={{ display: 'inline-block' }}>
            Berechtigungen{'  '}
            <small>
              <a href="#edit-permissions">
                <i className="icon-pen" />
              </a>
            </small>
          </SubSection.Title>

          <ul>
            <li>
              <span className="title-s">Verantwortlich: </span>
              <DummyPerson />
            </li>
            <li>
              <span className="title-s">Schreibrechte: </span>{' '}
              <DummyPerson link="/xxx" name="Archiv ZHdK - Forschungsdaten" />
            </li>
            <li>
              <span className="title-s">Leserechte: </span>{' '}
              <DummyPerson link="/xxx" name="[API] sound-colour-space" icon={false} />
            </li>
            <li>
              <span className="title-s">Öffentlicher Zugriff: </span>
              <DummyCheckmark />
            </li>
          </ul>
        </SubSection>

        <SubSection open>
          <SubSection.Title tag="h3" className="title-s mts" style={{ display: 'inline-block' }}>
            MetaDaten{'  '}
            <small>
              <a href="#edit-metadata">
                <i className="icon-pen" />
              </a>
            </small>
          </SubSection.Title>

          <ul>
            <li>
              <b>Beschreibungstext:</b> Material zur Verfügung gestellt im Rahmen des
              Forschungsprojekts «Sound Colour Space»
            </li>
            <li>
              <b>Rechtsschutz:</b> CC-By-SA-CH: Attribution Share Alike
            </li>
            <li>
              <b>ArkID:</b>{' '}
              <a target="_blank" rel="noopener noreferrer" href={DUMMY_ARK_ID}>
                <code>{DUMMY_ARK_ID}</code>
              </a>
            </li>
          </ul>
        </SubSection>
      </SubSection>
    </div>

    <div className="ui-actions phl pbl mtl">
      <a className="link weak" href="#cancel">
        Zurück
      </a>
      {/* <button className="tertiary-button large" type="button">
        Prüfen
      </button> */}
      <button className="primary-button large" type="button">
        Abschliessen…
      </button>
    </div>
  </section>
)

const WorkflowsList = ({ list, label = '???', authToken }) => {
  return (
    <div>
      {f.map(list, (project, i) => (
        <div key={i}>
          {!!label && <h4 className="title-s mtl mbm">{label}</h4>}
          <table className="ui-workgroups bordered block aligned">
            <thead>
              <tr>
                <td>
                  <span className="ui-resources-table-cell-content">{'Name'}</span>
                </td>
                <td />
              </tr>
            </thead>
            <tbody>
              {f.map(list, project => (
                <WorkflowRow key={project.uuid} project={project} authToken={authToken} />
              ))}
            </tbody>
          </table>
        </div>
      ))}
    </div>
  )
}

export const WorkflowRow = ({ project }) => {
  return (
    <tr key={project.id}>
      <td>
        <a href={project.url}>{project.name}</a>
      </td>
      <td className="ui-workgroup-actions" />
    </tr>
  )
}

module.exports = WorkflowsIndex
WorkflowsIndex.WorkflowRow = WorkflowRow

const DummySetThumb = () => (
  <div className="ui-resource">
    <div className="ui-resource-body">
      <div className="media-set ui-thumbnail">
        <div className="ui-thumbnail-privacy">
          <i title="private" className="icon-privacy-private" />
        </div>
        <a
          className="link ui-thumbnail-image-wrapper ui-link"
          href="/sets/d0ca4caf-2ae0-4481-b322-79ae4a53d93e"
          target="_blank"
          title="socospa-1">
          <div className="ui-thumbnail-image-holder">
            <div className="ui-thumbnail-table-image-holder">
              <div className="ui-thumbnail-cell-image-holder">
                <div className="ui-thumbnail-inner-image-holder">
                  <img
                    src="/media/d029c4b2-7796-41c6-9044-5b1e286ef7c6"
                    alt="Bild:  socospa-1"
                    className="ui-thumbnail-image ui_picture"
                    title="socospa-1"
                  />
                </div>
              </div>
            </div>
          </div>
        </a>
        <div className="ui-thumbnail-meta">
          <h3 className="ui-thumbnail-meta-title">socospa-1</h3>
          <h4 className="ui-thumbnail-meta-subtitle" />
        </div>
        <div className="ui-thumbnail-actions">
          <ul className="left by-left">
            <li className="ui-thumbnail-action">
              <span className="js-only">
                <a className="link ui-thumbnail-action-checkbox ui-link" title="auswählen">
                  <i className="icon-checkbox" />
                </a>
              </span>
            </li>
            <li className="ui-thumbnail-action">
              <a className="ui-thumbnail-action-favorite" data-pending="false">
                <i className="icon-star" />
              </a>
            </li>
          </ul>
          <ul className="right by-right">
            <li className="ui-thumbnail-action">
              <a
                className="ui-thumbnail-action-favorite"
                href="/sets/d0ca4caf-2ae0-4481-b322-79ae4a53d93e/meta_data/edit/by_context">
                <i className="icon-pen" />
              </a>
            </li>
            <li className="ui-thumbnail-action">
              <a className="ui-thumbnail-action-favorite">
                <i className="icon-trash" />
              </a>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
)

const DummyPerson = ({
  name = 'Rolf Wolfensberger',
  link = '/people/257b433a-1f3d-471a-a8e4-f29903fdaee3',
  icon = 'user-mini'
}) => (
  <span className="small ui-tag-cloud" style={{ display: 'inline-block' }}>
    <span className="ui-tag-cloud-item">
      <a href={link} target="_blank" className="link ui-tag-button ui-link">
        {!!icon && <i className={`ui-tag-icon icon-${icon}`} />}
        {name}
      </a>
    </span>
  </span>
)

const DummyCheckmark = () => (
  <label className="ui-rights-check-label">
    <i className="icon-checkmark" title="Betrachten" />
  </label>
)

const Explainer = ({ children }) => (
  <p className="paragraph-s mts measure-wide" style={{ fontStyle: 'italic' }}>
    {children}
  </p>
)
