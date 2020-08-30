require 'twitter'

require 'rubyserial'

require './twitter_api.rb'
require './hello.rb'
require './bye.rb'
require './message.rb'

def reply(replies) #新着リプライにリプライを行う。1回でも行えばtrueを、そうでなければfalseを返す
	update = false #リプライに更新があったかどうか
	prev_replies = Marshal.load(Marshal.dump(replies)) #深いコピーを行う
	sleep 70
	replies.replace($client.mentions)

	puts "リプライを更新しました"

	(0...replies.size).reverse_each do |i|
		if (!(prev_replies.include?(replies[i])))&&(replies[i].user.screen_name!=$my_id) then
			update = true
			puts replies[i].text
			$client.update("@"+replies[i].user.screen_name+"\n"+message(replies[i]),{:in_reply_to_status_id => replies[i].id})
		end
	end
	return update
end

def favorite(tweets,fav_words)#関連ワードを含んだ新着ツイートにいいねを押す
	prev_tweets = Marshal.load(Marshal.dump(tweets)) #深いコピーを行う
	sleep 70
	tweets.replace($client.home_timeline)
	
	puts "ツイート一覧を更新しました"

	(0...tweets.size).reverse_each do |i|
		if prev_tweets.include?(tweets[i])
			next
		end

		for word in fav_words do
			if tweets[i].text.match(word) != nil && $client.friendship?(tweets[i].user.screen_name, $my_id) then
				puts tweets[i].text
				$client.favorite(tweets[i].id)
				break
			end
		end
	end
end

def isActive?() #起きている時間かどうか判定を行う
	return (4<Time.now.hour && Time.now.hour<23)
end

$client = my_client()

#変数設定、$で始まるのはグローバル変数
$my_id = $client.user.screen_name #自分のIDから@を除いた文字列
replies = $client.mentions #最新20件のみ保存、ゆえに現在のsizeは20固定
tweets = $client.home_timeline() #最新のものから20個とってくる
fav_words = [/[うぅ][ゆゅ]/,/るびぃ/,/ルビィ/,/[Rr]uby/,/ラブライ/] #正規表現
go_to_bed = false

sp = Serial.new('COM3', 9600) #device,とrate。必要に応じて変える

puts "セットアップ完了"

#処理
while true
	signal = sp.read(100) #引数は最大文字数
	if signal != ""
		p signal
		break
	end
	sleep 5
end

if isActive?() && signal.chomp=="morning" && !($client.user_timeline($my_id,{:count => 100}).map(&:text).include?(hello()))
	$client.update(hello())
end

while isActive?() do
	go_to_bed = true
	if reply(replies)
		sp.write "reply"
	end
	favorite(tweets,fav_words)
end

if go_to_bed then
	$client.update(bye())
	sp.write "sleep"
end


