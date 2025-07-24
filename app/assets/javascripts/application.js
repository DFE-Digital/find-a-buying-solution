import { Application } from '@hotwired/stimulus'
import ExternalLinkTrackingController from '../../javascript/controllers/external_link_tracking_controller'
import EngagementTrackingController from '../../javascript/controllers/engagement_tracking_controller'
import SearchToggleController from '../../javascript/controllers/search_toggle_controller'

import 'dfe-frontend/packages/dfefrontend'

import * as govukFrontend from 'govuk-frontend'
govukFrontend.initAll()

const application = Application.start()

window.Stimulus = application
Stimulus.register('search-toggle', SearchToggleController)
Stimulus.register('external-link-tracking', ExternalLinkTrackingController)
Stimulus.register('engagement-tracking', EngagementTrackingController)
