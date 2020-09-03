require 'twitter'

require 'rubyserial'

require './twitter_api.rb'
require './hello.rb'
require './bye.rb'
require './message.rb'

def reply() #新着リプライにリプライを行う。1回でも行えばtrueを、そうでなければfalseを返す
	update = false #リプライに更新があったかどうか

	#replied_idは、自分の最新100ツイートに含まれるリプライのリプライ先のツイートid
	replied_id = $client.user_timeline($my_id,{:count => 100}).map{|x| x.in_reply_to_status_id} #削除されたツイートがあるとエラーになるのでidの状態で比較する
	replied_id.delete_if do |r|
		r.class != Integer
	end

	#repliesは、自分宛てのリプライ最新20件のうち、24時間以内に受け取ったもの
	replies = $client.mentions
	for i in 0...replies.size
		if replies[i].created_at < Time.now - 24 * 60 * 60
			replies.replace(replies[0...i])
			break
		end
	end

	#古い順にリプライしていく
	for reply in replies.reverse
		if (!replied_id.include?(reply.id)) && (reply.user.screen_name!=$my_id)
			update = true
			puts reply.text
			$client.update("@"+reply.user.screen_name+"\n"+message(reply),{:in_reply_to_status_id => reply.id})
		end
	end

	return update
end


def active?() #起きている時間かどうか判定を行う
	return (4<Time.now.hour && Time.now.hour<23)
end

$client = my_client()

#変数設定、$で始まるのはグローバル変数
$my_id = $client.user.screen_name #自分のIDから@を除いた文字列
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

#起きている時間帯に"morning"を受け取り、かつ同様のツイートをしていなければおはようツイートをする
if active?() && signal.chomp=="morning" && !($client.user_timeline($my_id,{:count => 100}).map(&:text).include?(hello()))
	$client.update(hello())
end

#5分おきに返信
while active?() do
	go_to_bed = true
	sleep 5 * 60
	if reply()
		sp.write "reply" #シリアル通信
	end
end

#おやすみツイートをする
if go_to_bed then
	$client.update(bye())
	sp.write "sleep"
	puts "bye"
	fin = gets
end
