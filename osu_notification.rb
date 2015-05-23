# Coding: UTF-8
require 'twitter'
require 'json'
require 'sqlite3'
$SourcePath = File.expand_path('../', __FILE__)
require $SourcePath + "/osu_api.rb"
require $SourcePath + "/data/setting.rb"

$db = $SourcePath + "/data/data.db"
  
class Osu_Notification
  def initialize(osu_api_key)
    if CONSUMER_KEY.size == 0 || CONSUMER_SECRET.size == 0 || ACCESS_TOKEN.size == 0 || ACCESS_TOKEN_SECRET.size == 0 || API_KEY == 0 || OSU_USER_ID == 0
      puts "Please set up a setting.rb"
      exit
    end
    @rest_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = CONSUMER_KEY
      config.consumer_secret     = CONSUMER_SECRET
      config.access_token        = ACCESS_TOKEN
      config.access_token_secret = ACCESS_TOKEN_SECRET
    end
    @osu_api = Osu_Application.new(osu_api_key)
    SQLite3::Database.open($db) do |db|
      db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS data_osu
          (username TEXT, playcount INTEGER, level INTEGER, pp_rank INTEGER, pp_raw INTEGER, accuracy INTEGER, count_rank_ss INTEGER, count_rank_s INTEGER, count_rank_a INTEGER)
        SQL
      db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS data_mania
          (username TEXT, playcount INTEGER, level INTEGER, pp_rank INTEGER, pp_raw INTEGER, accuracy INTEGER, count_rank_ss INTEGER, count_rank_s INTEGER, count_rank_a INTEGER)
        SQL
      @row_osu = db.execute("select * from data_osu;")
      @row_mania = db.execute("select * from data_mania;")
    end
  end
  
  def check(json)
    unless json[0]
      puts json[1]
      exit
    end
  end
  
  def save(hash, type)
    if @row_osu.size == 0 || @row_mania.size == 0
      i = 0
      SQLite3::Database.open($db) do |db|
        hash.each do |key, value|
          if i == 0
            db.execute("INSERT INTO data_#{type}(#{key}) values('#{value}')")
            i += 1
          else
            db.execute("UPDATE data_#{type} SET #{key} = '#{value}'")
          end
        end
        @row_osu = db.execute("select * from data_osu;")
        @row_mania = db.execute("select * from data_mania;")
      end 
    else
      SQLite3::Database.open($db) do |db|
        hash.each do |key, value|
          db.execute("UPDATE data_#{type} SET #{key} = '#{value}'")
        end
      end
    end
  end
  
  def osu()
    result = @osu_api.osu_api("/api/get_user", "&u=" + OSU_USER_ID)
    check(result)
    username = result[1][0]['username']
    playcount = result[1][0]['playcount']
    level = result[1][0]['level']
    pp_rank = result[1][0]['pp_rank']
    pp_raw = result[1][0]['pp_raw']
    accuracy = result[1][0]['accuracy']
    count_rank_ss = result[1][0]['count_rank_ss']
    count_rank_s = result[1][0]['count_rank_s']
    count_rank_a = result[1][0]['count_rank_a']
    data = {}
    binding.eval("local_variables").each do |hash|
      var = hash.to_s
      data[var] = binding.eval(var)
    end
    data.delete("data")
    data.delete("result")
    data.delete("text")
    return data
  ensure
    save(data, "osu")
  end
  
  def mania()
    result = @osu_api.osu_api("/api/get_user", "&m=3&u=" + OSU_USER_ID)
    check(result)
    username = result[1][0]['username']
    playcount = result[1][0]['playcount']
    level = result[1][0]['level']
    pp_rank = result[1][0]['pp_rank']
    pp_raw = result[1][0]['pp_raw']
    accuracy = result[1][0]['accuracy']
    count_rank_ss = result[1][0]['count_rank_ss']
    count_rank_s = result[1][0]['count_rank_s']
    count_rank_a = result[1][0]['count_rank_a']
    data = {}
    binding.eval("local_variables").each do |hash|
      var = hash.to_s
      data[var] = binding.eval(var)
    end
    data.delete("data")
    data.delete("result")
    data.delete("text")
    return data
  ensure
    save(data, "mania")
  end
 
  def text(hash, type)
    if type == "osu"
      row = @row_osu
      title = "osu!"
    elsif type == "mania"
      row = @row_mania
      title = "osu!mania"
    end
    text = "[#{hash['username']}] #{title} PP:#{hash['pp_raw'].to_i.round(0)}(#{hash['pp_raw'].to_i.round(0) - row[0][4].round(0)}) Rank:##{hash['pp_rank']}(#{hash['pp_rank'].to_i - row[0][3]}) Lv:#{hash['level'].to_i.round(0)}(#{hash['level'].to_i.round(0) - row[0][2].round(0)}) ACC:#{hash['accuracy'].to_f.round(2)}%(#{(hash['accuracy'].to_f - row[0][5]).round(2)}%) Playcount:#{hash['playcount'].to_i}(#{hash['playcount'].to_i - row[0][1]}) SS:#{hash['count_rank_ss'].to_i}(#{hash['count_rank_ss'].to_i - row[0][6]}) S:#{hash['count_rank_s'].to_i}(#{hash['count_rank_s'].to_i - row[0][7]}) A:#{hash['count_rank_a'].to_i}(#{hash['count_rank_a'].to_i - row[0][8]})"
  end
  
  def main()
    @rest_client.update(text(osu(), "osu"))
    @rest_client.update(text(mania(), "mania"))
  end
end

osu_notification = Osu_Notification.new(API_KEY)
osu_notification.main