# For pipeline
ENV['CATALYST_URL'] = "http://localhost:9004" if ENV['CATALYST_URL'] == nil
ENV['DOCMANAGER_URL'] = "http://0.0.0.0:3000" if ENV['DOCMANAGER_URL'] == nil

# For instance / project
ENV['PROJECT_INDEX'] = "archive_test" if ENV['PROJECT_INDEX'] == nil
ENV['WRITEABLE'] = "true" if ENV['WRITEABLE'] == nil
