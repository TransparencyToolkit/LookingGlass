# -*- coding: utf-8 -*-

module DocsHelper
  include IndexApi
  include DisplayTypeSwitcher
  include FacetSidebar
  include FieldAttributeGetter
  include HighlightField
  include FacetLinks
  include DropdownFormGen
  include ParamFilters
  include RemoveFacetFilter
  include AddFacetFilter
  include ThreadDocs
  include VersionTracker
  include GenerateThumbnail
end
