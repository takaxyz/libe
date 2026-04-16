require 'nokogiri'
require 'open-uri'
require 'json'

# 対象のURL

URL = {
  "ゆうり" => "https://libe-shinjuku.com/profile-yuuriyokohama.html",
  "ななみ" => "https://libe-tokyo.com/profile-nanami.html",
  "水瀬ななこ" => "https://libe-tokyo.com/profile-nanako.html",
  "有村あいり" => "https://libe-tokyo.com/profile-airi.html",
  "茜さつき" => "https://libe-shinjuku.com/profile-satsuki.html",
  "綾瀬える" => "https://libe-shinjuku.com/profile-ayase.html"
}


begin

  html_contents = ""
  URL.each do |name, url|
    # ページを取得
    html = URI.open(url).read
    doc = Nokogiri::HTML.parse(html)

    html_contents += name + "\n"


    # スケジュールが格納されている要素を特定
    # サイト構成に基づき、スケジュールリストを取得（class名などはサイト仕様に合わせる必要があります）
    # 多くの場合、'schedule_list' や 'table' 内にデータがあります

    sch = Array.new;

    schedule_date = doc.css('.prof-sched-date')
    schedule_stb = doc.css('.prof-sched-stb')
    schedule_desc = doc.css('.prof-sched-desc')

    schedule_date.each_with_index do |item, i|

      html_contents += sprintf("%s %s %s\n", item.text, schedule_stb[i].text, schedule_desc[i].text.gsub(/[\r\n]/,""))
    end


    # 特定の構造（カレンダー形式など）に対応するための汎用的な抽出
    if schedule_date.empty?
      puts "詳細なスケジュール要素が見つかりませんでした。サイトの構造が変更された可能性があります。"
    end

    html_contents += "\n"
  end

  puts html_contents

  File.write('index.html', html_contents)

rescue OpenURI::HTTPError => e
  puts "サイトにアクセスできませんでした: #{e.message}"
rescue => e
  puts "エラーが発生しました: #{e.message}"
end
