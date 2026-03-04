/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import { globToFlat } from '../../lib/glob-to-nested.js'
import resourceName from '../lib/decorate-resource-names.js'
import propTypes from './propTypes.js'

// Only top-level *.jsx files (NOT subdirectories like ResourcesBox/)
const modules = import.meta.glob('./*.jsx', { eager: true })
const UILibrary = globToFlat(modules)

UILibrary.propTypes = propTypes

// helpers

//# build tag from name and url and provide unique key
UILibrary.labelize = resourceList =>
  resourceList.map((resource, i) => ({
    children: resourceName(resource),
    href: resource.url,
    key: `${resource.uuid}-${i}`
  }))

UILibrary.resourceName = resourceName

// Export all components as named exports for modern usage
export const Link = UILibrary.Link
export const Icon = UILibrary.Icon
export const Thumbnail = UILibrary.Thumbnail
export const Button = UILibrary.Button
export const Preloader = UILibrary.Preloader
export const InputResources = UILibrary.InputResources
export const MediaResourcesBox = UILibrary.MediaResourcesBox
export const Modal = UILibrary.Modal
export const Tabs = UILibrary.Tabs
export const ResourcesBox = UILibrary.ResourcesBox
export const BoxBatchBar = UILibrary.BoxBatchBar
export const RailsForm = UILibrary.RailsForm
export const Dropdown = UILibrary.Dropdown
export const ActionsBar = UILibrary.ActionsBar

// Export helper functions
export const labelize = UILibrary.labelize
export { resourceName }
export { propTypes }

// Default export for backwards compatibility
export default UILibrary
