// Main UI entry point
// maps routes to views/react components

// NOTE: work in progress, this provides an overview which views are ported.
// this will replace `react/index.coffee` and all require-by-folder bundles

// -----------------------------------------------------------------------------

// main app layout (i.e. everything in <body>),
// it's still wrapped in Rails `_base` layout for <head> etc)
import AppLayout from './views/App/AppLayout'

// all the Views:
import ExplorePage from './views/Explore/ExploreMainPage.cjsx'
import VocabulariesIndex from './views/Vocabularies/VocabulariesIndex'
import VocabularyPage from './views/Vocabularies/VocabularyPage.cjsx'
import VocabularyShow from './views/Vocabularies/VocabularyShow'
import VocabularyKeywords from './views/Vocabularies/VocabularyKeywords.cjsx'

// Routing Table (maps routes/paths to Views/ViewComponents)
const routes = [{
  path: '/',
  component: AppLayout,
  childRoutes: [

    { path: 'explore',
      component: ExplorePage, // 1 view handles index and all childRoutes
      childRoutes: [
        { path: 'catalog', childRoutes: [
          { path: ':sectionId' }] },
        { path: 'featured_set' },
        { path: 'keywords' }
      ]
    },
    { path: 'vocabulary',
      indexRoute: { component: VocabulariesIndex }, // view just for this path
      childRoutes: [
        { path: ':vocabularyId',
          component: VocabularyPage, // base layout for childRoutes
          indexRoute: { component: VocabularyShow },
          childRoutes: [
            { path: 'keywords', component: VocabularyKeywords }
          ]
        }
      ]
    }
  ]
}]

export default routes
