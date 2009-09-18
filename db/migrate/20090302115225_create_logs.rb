class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.integer :totalrequests, :response_200, :response_non_200, :response_301, :response_302, :response_404, :response_499, :response_500, :tag_pages, :traffic_pages, :people_pages, :deals_pages, :show_pages, :orig_show_pages, :mongrel_served_pages
      t.text :response_301_urls, :response_302_urls, :response_404_urls, :response_499_urls, :response_500_urls, :tag_pages_urls, :traffic_pages_urls, :people_pages_urls, :deals_pages_urls
      t.float :avg_mongrel_time
      t.string :crawler
      t.date :cdate
      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end
