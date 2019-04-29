# For pipeline
ENV['CATALYST_URL'] = "http://localhost:9004" if ENV['CATALYST_URL'] == nil
ENV['DOCMANAGER_URL'] = "http://0.0.0.0:3000" if ENV['DOCMANAGER_URL'] == nil
ENV['DOCUPLOAD_URL'] = "http://localhost:9292" if ENV['DOCUPLOAD_URL'] == nil
ENV['ARCHIVEADMIN_URL'] = "http://localhost:3002" if ENV['ARCHIVEADMIN_URL'] == nil
ENV['PUBLIC_ARCHIVEADMIN_URL'] = "http://localhost:3002" if ENV['PUBLIC_ARCHIVEADMIN_URL'] == nil
ENV['RAILS_RELATIVE_URL_ROOT'] = "/" if ENV['RAILS_RELATIVE_URL_ROOT'] == nil

# For instance / project (default "archive_test")
ENV['WRITEABLE'] = "true" if ENV['WRITEABLE'] == nil
ENV['PROJECT_INDEX'] = "archive_test_hcfgog" if ENV['PROJECT_INDEX'] == nil
ENV['ARCHIVE_SECRET_KEY'] = "UWSzDa2mcuRoFmmu3epvYOhcm8GMyLVDYH0cngi5bV3+90tQWUGZpSc2ghMYoiIpIabYit7zIcwg5UE3e2iU5nmLbB2lJfIP8NhTYmOe6PsbfM8VnDHk0cP1IRLgqYybJndiPw==" if ENV['ARCHIVE_SECRET_KEY'] == nil
