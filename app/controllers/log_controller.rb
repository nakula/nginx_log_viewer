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
    @stat = {}
    1.upto(14) do |day|
      date = DateTime.strptime((Date.today-day).to_s + ":06:30:00", "%Y-%m-%d:%I:%M:%S")
      @stat[(Date.today-day).to_s] = stat_helper(date)
    end
  end
  
  def detailed_view
    date = DateTime.strptime(params[:date].to_s + ":06:30:00", "%Y-%m-%d:%I:%M:%S")
    if params[:error]
      @logs = Log.find(:all, :conditons => ["request_time >= ? AND request_time < ? AND response_code > 399 AND request_uri != '-'", date, date+1])
    end
  end
  
private
  def stat_helper(day)
    total_reqs = Log.count(:conditions => ["request_time >= ? AND request_time < ?", day, (day+1)])
    non_200 = Log.count(:conditions => ["request_time >= ? AND request_time < ? AND response_code != 200", day, (day + 1)])
    error = Log.count(:conditions => ["request_time >= ? AND request_time < ? AND response_code > 399 AND request_uri != '-'", day, (day + 1)])
    r = [total_reqs, non_200, error]
    ["Googlebot", "msnbot", 'slurp'].each do |crawler|
      r << Log.count(:conditions => ["request_time >= ? AND request_time < ? AND user_agent='#{crawler}'", day, (day+1)])
      r << Log.count(:conditions => ["request_time >= ? AND request_time < ? AND response_code != 200 AND user_agent = '#{crawler}'", day, (day + 1)])
      r << Log.count(:conditions => ["request_time >= ? AND request_time < ? AND response_code > 399 AND user_agent = '#{crawler}'", day, (day + 1)])
    end
    r
  end
end
