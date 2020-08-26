require 'twitter'

require './twitter_api.rb'
require './hello.rb'
require './bye.rb'
require './message.rb'

def reply(replies) #リプライを行う、70秒程度かかる
	prev_replies = Marshal.load(Marshal.dump(replies)) #深いコピーを行っている。もともと取得していたリプライのArrayをprev_repliesに代入している
	sleep 70 #70秒待機
	replies.replace($client.mentions) #repliesの更新
	
	puts "リプライを更新しました"

	(0...replies.size).reverse_each do |i| #古い順に返信をしていく
		if (!(prev_replies.include?(replies[i])))&&(replies[i].user.screen_name!=$my_id) then #古いリプライArrayに含まれておらず、自分によるリプライでなければ、それにリプライする
			puts replies[i].text
			$client.update("@"+replies[i].user.screen_name+"\n"+message(replies[i]),{:in_reply_to_status_id => replies[i].id})
		end
	end
end

def favorite(tweets,fav_words) #いいねを行う、70秒程度かかる
	prev_tweets = Marshal.load(Marshal.dump(tweets)) #深いコピーを行っている
	sleep 70
	tweets.replace($client.home_timeline)
	
	puts "ツイート一覧を更新しました"

	(0...tweets.size).reverse_each do |i| #古い順にいいねしていく
		if prev_tweets.include?(tweets[i]) #古いツイートArrayに含まれているならば飛ばす
			next
		end

		for word in fav_words do #いいねの対象となるフレーズが含まれているか各正規表現ごとに調べ、含まれているかつフォロワーのツイートであるならばいいねする
			if tweets[i].text.match(word) != nil && $client.friendship?(tweets[i].user.screen_name, $my_id) then
				puts tweets[i].text
				$client.favorite(tweets[i].id)
				break
			end
		end
	end
end

def isActive?() #起きている時間かどうかをboolで返す
	return (4<Time.now.hour && Time.now.hour<23)
end

$client = my_client()

#変数設定、$で始まるのはグローバル変数
$my_id = $client.user.screen_name #自分のIDから@を除いた文字列
replies = $client.mentions #自分へのリプライを最新20件のみ保存
tweets = $client.home_timeline #ホームの最新のツイート一覧から20個とってくる
fav_words = [/[うぅ][ゆゅ]/,/るびぃ/,/ルビィ/,/[Rr]uby/,/ラブライ/] #正規表現、いいねするツイートに含まれる語句
go_to_bed = false #おやすみツイートをするかどうか

puts "セットアップ完了"

#処理

#もし起きている時間帯で、まだおはようツイートをしていなければ、おはようツイートをする
if isActive?() && !($client.user_timeline($my_id,{:count => 100}).map(&:text).include?(hello())) then
	$client.update(hello())
end

#起きている間、リプライといいねを繰り返す
while isActive?() do
	go_to_bed = true
	reply(replies)
	favorite(tweets,fav_words)
end

#もし寝る時間になったらおやすみツイートをする
if go_to_bed then
	$client.update(bye())
	fin = gets
end