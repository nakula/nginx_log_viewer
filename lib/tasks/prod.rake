namespace :nginx do
  task :parse => :environment do
    filename = ENV['filename']
    {
      "google" => 'Googlebot',
      "msn" => 'msnbot',
      "yahoo" => 'slurp'
    }.each do |site, crawlername|
      totalrequests = `cat #{filename} | grep '#{crawlername}' | wc -l`.strip
      a200responses = `cat #{filename} | grep '#{crawlername}' | awk 'BEGIN { FS = "[\\[ ]" } $10 == "\\"200\\"" {print $1}' | wc -l`.strip
      urls_for_non_200_responses = `cat #{filename} | grep '#{crawlername}' | awk 'BEGIN { FS = "[\\[ ]" } $10 != "\\"200\\"" {print $1 "|"  $5 "|" $8 "|" $10 "|" $18 "|" $22}'`.split("\n").map{|x| x.split("|")}
      non200coount = urls_for_non_200_responses.length
      a499urls = urls_for_non_200_responses.find_all{|x| x[3] == "\"499\""}
      a301urls = urls_for_non_200_responses.find_all{|x| x[3] == "\"301\""}
      a302urls = urls_for_non_200_responses.find_all{|x| x[3] == "\"302\""}
      a404urls = urls_for_non_200_responses.find_all{|x| x[3] == "\"404\""}
      a500urls = urls_for_non_200_responses.find_all{|x| x[3] == "\"500\""}

      show_pages = `cat #{filename} | grep '#{crawlername}' | awk 'BEGIN { FS = "[\\[ ]" } $8 ~ /^\\/[^\\/]+$/ {print $8}' | wc -l`.strip
      tag_pages = `cat #{filename} | grep '#{crawlername}' | awk 'BEGIN { FS = "[\\[ ]" } $8 ~ /^\\/tag\\/[^\\/]+$/ {print $8}'`.split("\n")
      people_pages = `cat #{filename} | grep '#{crawlername}' | awk 'BEGIN { FS = "[\\[ ]" } $8 ~ /^\\/people\\/[^\\/]+$/ {print $8}'`.split("\n")
      traffic_pages = `cat #{filename} | grep '#{crawlername}' | awk 'BEGIN { FS = "[\\[ ]" } $8 ~ /^\\/traffic\\/[^\\/]+$/ {print $8}'`.split("\n")
      deals_pages = `cat #{filename} | grep '#{crawlername}' | awk 'BEGIN { FS = "[\\[ ]" } $8 ~ /^\\/deals\\/[^\\/]+$/ {print $8}'`.split("\n")
      orig_show_pages = `cat #{filename} | grep '#{crawlername}' | awk 'BEGIN { FS = "[\\[ ]" } $8 ~ /^\\/show\\/.+$/ {print $8}' | wc -l`.strip

      # time based stats
      a0time_requests = `cat #{filename} | grep '#{crawlername}' | awk 'BEGIN { FS = "[\\[ ]" } $10 == "\\"200\\"" {print $1 "|"  $5 "|" $8 "|" $10 "|" $18 "|" $22}'`.split("\n").map{|x| x.split("|")}
      served_by_mongrel = a0time_requests.find_all{|x| if x[5].nil?; puts x.inspect;next;end; x[5].strip != '-' && x[5].strip != '200'}
      t = served_by_mongrel.map{|x| x[5].to_f}
      avg_time = t.sum/served_by_mongrel.length rescue 0
      
      Log.create!(
        :totalrequests => totalrequests,
        :response_200 => a200responses,
        :response_non_200 => non200coount,
        :response_301 => a301urls.length,
        :response_301_urls => a301urls,
        :response_302 => a302urls.length,
        :response_302_urls => a302urls,
        :response_404 => a404urls.length,
        :response_404_urls => a404urls,
        :response_499 => a499urls.length,
        :response_499_urls => a499urls,
        :response_500 => a500urls.length,
        :response_500_urls => a500urls,
        :tag_pages => tag_pages.length,
        :traffic_pages => traffic_pages.length,
        :people_pages => people_pages.length,
        :deals_pages => deals_pages.length,
        :show_pages => show_pages,
        :orig_show_pages => orig_show_pages,
        :avg_mongrel_time => avg_time,
        :mongrel_served_pages => served_by_mongrel.length,
        :deals_pages_urls => deals_pages,
        :people_pages_urls => people_pages,
        :traffic_pages_urls => traffic_pages,
        :tag_pages_urls => tag_pages,
        :crawler => site,
        :cdate => Date.today - 1,
      )
    end
    
    
  end
end