class LogController < ApplicationController
  before_filter :authenticate
  
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "admin" && password == "nak88ul7"
    end
  end

  def index
    @log_count = {}
    ROBOTLIST.each do |robot|
      @log_count[robot] = {}
      @log_count[robot][:today] = Log.find(:first, :conditions=>["cdate = ? AND crawler = ?", Date.today - 1, robot], :select => "totalrequests, response_non_200, cdate")
      if @log_count[robot][:today].nil?
        @log_count[robot][:today] = Log.find(:first, :conditions=>["cdate = ? AND crawler = ?", Date.today - 2, robot], :select => "totalrequests, response_non_200, cdate")
        @log_count[robot][:yesterday] = Log.find(:first, :conditions=>["cdate = ? AND crawler = ?", Date.today - 2, robot], :select => "totalrequests, response_non_200, cdate")
      else
        @log_count[robot][:yesterday] = Log.find(:first, :conditions=>["cdate = ? AND crawler = ?", Date.today - 2, robot], :select => "totalrequests, response_non_200, cdate")
      end
    end

    ROBOTLIST.each do |robot|
      @log_count[robot][:now] = `cat  #{NGINX_LOGFILE} | grep -i \"#{robot}\" | wc -l`
      @log_count[robot][:now_errors] = `cat  #{NGINX_LOGFILE} | grep -i \"#{robot}\" | awk 'BEGIN { FS = \"[\[ ]\" } $10 != "\\"200\\"" {print $0}' | wc -l`
    end
  end
  
  def showold
    @crawler = params[:id]
    @date = params[:db]
    @log = Log.find_by_cdate_and_crawler(@date, @crawler)
  end
  
  def show
    @crawler = params[:id]
    if params[:code]
      @error_reqs = []
      @all_reqs = `cat #{NGINX_LOGFILE} | grep -i #{@crawler} | awk 'BEGIN { FS = "[\[ ]" } $10 == "\\"#{params[:code]}\\"" {print $1 "|"  $5 "|" $8 "|" $10 "|" $18 "|" $22}'`.split("\n")
    else
      @error_reqs = `cat #{NGINX_LOGFILE} | grep -i #{@crawler} | awk 'BEGIN { FS = "[\[ ]" } $10 != "\\"200\\"" {print $1 "|"  $5 "|" $8 "|" $10 "|" $18 "|" $22}'`.split("\n")
      @all_reqs = `cat #{NGINX_LOGFILE} | grep -i #{@crawler} | awk 'BEGIN { FS = "[\[ ]" } {print $1 "|"  $5 "|" $8 "|" $10 "|" $18 "|" $22}'`.split("\n")
    end
    @currentlength = (params[:start] || "0").to_i + @all_reqs.length
  end

  def showpoll
    @all_reqs = `cat #{NGINX_LOGFILE} | grep -i #{params[:id]} | awk 'BEGIN { FS = "[\[ ]" } {if(NR>#{params[:start]}) print $1 "|"  $5 "|" $8 "|" $10 "|" $18 "|" $22}'`.split("\n")
    @currentlength = (params[:start] || "0").to_i + @all_reqs.length
  end

  def stats
    @stats = Log.find(:all, :conditions=>["cdate >= ?", (Date.today - 7)], :select=>"totalrequests, response_200, response_non_200, response_301, response_302, response_404, response_499, response_500, tag_pages, traffic_pages, people_pages, deals_pages, show_pages, orig_show_pages, mongrel_served_pages, avg_mongrel_time, crawler, cdate", :order=>"cdate desc")
    @google = @stats.find_all{|x| x.crawler == 'Googlebot'}
    @msn = @stats.find_all{|x| x.crawler == 'msnbot'}
    @yahoo = @stats.find_all{|x| x.crawler == 'slurp'}
  end
  
end
