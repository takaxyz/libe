require 'nokogiri'
require 'open-uri'
require 'time'
require 'yaml'
require 'json'

# 対象のURL
urls = open('urls.yml', 'r') { |f| YAML.load(f) }

ENV['TZ'] = 'Asia/Tokyo'

now_jst = Time.new(in: "+09:00")

begin

  schedules = ""
  urls['url'].each do |url|
    # ページを取得
    html = URI.open("https://libe-shinjuku.com/" + url).read
    doc = Nokogiri::HTML.parse(html)

    next if doc.css('dd.profile').length == 0

    name = doc.css('dd.profile')[0].text[3..-1]

    puts name

    sch = "<a href=\"https://libe-shinjuku.com/" + url + "\" target=\"_blank\">" + name + "</a><br>\n"

    # スケジュールが格納されている要素を特定
    # サイト構成に基づき、スケジュールリストを取得（class名などはサイト仕様に合わせる必要があります）
    # 多くの場合、'schedule_list' や 'table' 内にデータがあります

    schedule_date = doc.css('.prof-sched-date')
    schedule_stb = doc.css('.prof-sched-stb')
    schedule_desc = doc.css('.prof-sched-desc')


    schedule_date.each_with_index do |item, i|

      sch += sprintf("%s　%s　%s<br>\n", item.text, schedule_stb[i].text, schedule_desc[i].text.gsub(/[\r\n]/,""))

    end



    # 特定の構造（カレンダー形式など）に対応するための汎用的な抽出
    if schedule_date.empty?
      puts "詳細なスケジュール要素が見つかりませんでした。サイトの構造が変更された可能性があります。"
    end

    if sch.include?("待機") or sch.include?("出勤")
      schedules += sch + "<br>\n"
    else
      schedules += "<a href=\"https://libe-shinjuku.com/" + url + "\" target=\"_blank\">" + name + "</a><br>\n" + "　なし<br><br>\n"
    end
  end

  #puts schedules

  html_content = <<~HTML
  <!DOCTYPE html>
  <html>
  <head><meta charset="utf-8"><title>Schedule</title></head>
  <body>
    <h3>サイト更新情報</h3>
    <p>#{now_jst.strftime("%Y-%m-%d %H:%M:%S")}</p>
    #{schedules}
  </body>
  </html>
  HTML
  
  File.write('index.html', html_content)

rescue OpenURI::HTTPError => e
  puts "サイトにアクセスできませんでした: #{e.message}"
rescue => e
  puts "エラーが発生しました: #{e.message}"
end
