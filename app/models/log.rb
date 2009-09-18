class Log < ActiveRecord::Base
  serialize :response_301_urls
  serialize :response_302_urls
  serialize :response_499_urls
  serialize :response_500_urls
  serialize :response_404_urls
  serialize :deals_pages_urls
  serialize :people_pages_urls
  serialize :traffic_pages_urls
  serialize :tag_pages_urls
end
