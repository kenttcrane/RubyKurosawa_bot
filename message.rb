
require 'yahoo-japanese-analysis' #gemのキーワード抽出に関する部分が恐らく間違っているので、URLエンコードしたものをAPIに送信するよう修正しなければいけない

def message(reply) #引数replyのテキストstrに含まれる文字列によって違う文字列を返す
    str = reply.text.gsub(/@[[:alnum:]_]* /, '') #ツイートに含まれるID（@~~~）を削除する
    if str.match(/[ほ褒]めて/) then
        return reply.user.name + "さん、すごいね！これからもがんばルビィ！だよ！"
    elsif str.match(/(なぐさ|慰)めて/) then
        return reply.user.name + "さん、すごく大変だったんだね…\nルビィでよければいつでもお話聞くからね！元気出して！"
    elsif str.include?("いいかな") then
        return reply.user.name + "さんが大丈夫だと思ったら大丈夫だよ！自信もって目標に向かってがんばルビィ！だよ！"
    elsif str.match(/(いいよね|いっか|いいか[^な]|いいか$)/) then
        keyword = searchKeyword(str)
        return reply.user.name + "さん、甘えてちゃだめだよ！" + keyword + (keyword=="" ? "" : "は遊びじゃない！")
    elsif str.match(/でき(る|ない)かな/) then
        return reply.user.name + "さんならできるよ！ふんばルビィ！"
    elsif str.include?("がんば") || str.include?("ガンバ") || str.include?("頑張") then
        return "がんばルビィ！"
    elsif str.include?("ずら") then
        return "はなまるちゃあ…"
    elsif str.include?("ブッブ") || str.include?("ぶっぶ") then
        return "おねいちゃあ…"
    else
        return ["ぅゅ…","ぅゅゅ…","ぅゅ！","ピギィ！"].sample
    end
end

def searchKeyword(str) #strにキーワード（おそらく名詞）があればそれを、なければから文字列を返す
    YahooJA.configure do |config|
        config.app_key = "AAAAA" #YahooのAPI使用申請時に発行されるものを代入する
    end

    keywords = YahooJA.keyphrase str.gsub(/(いいよね|いっか|いいか[^な]|いいか$)/, '')
    p keywords
    keyword = ["", -1]
    for k in keywords do #kはlist
        if k[1] > keyword[1] then
            keyword[0] = k[0]
            keyword[1] = k[1]
        end
    end
    return keyword[0]
end