require 'twitter'

require './twitter_api.rb'

def bye()
	return "ぅゅ…今日も一日お疲れ様…♥\n明日もがんばルビィ！"
end

if __FILE__ == $0 then #bye.rb自身が実行されたときはおやすみツイートをする
	client = my_client()
	client.update(bye())
	fin = gets
end