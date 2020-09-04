#include <SoftwareSerial.h>
#include <DFRobotDFPlayerMini.h>

const int PIN_IN = 4;
const int PIN_OUT = 7; //ソーラー電池の電圧が1~1.5vらしいので、よくわからないけどanalogWriteを使うためPWMの使えるピンを指定したほうがいいのかも。ただ電流だけ大きくならないように330Ω抵抗つけると5Vでも大丈夫だったのでそのまま
bool awake = false; //ルビィちゃんが（自分が）起きているかどうか

SoftwareSerial mySoftwareSerial(10,11); //RX, TX　データの送受信用
DFRobotDFPlayerMini myDFPlayer;

void changeVoltage(int pin); //pin番の電位をHIGHにしてちょっとしたらLOWにする関数、詳細は後述


void setup() {
  // put your setup code here, to run once:

  //ピンの設定
  pinMode(PIN_IN, INPUT);
  pinMode(PIN_OUT, OUTPUT);

  //シリアル通信に関する設定
  Serial.begin(9600); //通信速度
  Serial.setTimeout(100); //タイムアウトまでの時間

  //mp3再生に必要なものをセットアップ（ほぼコピペ）
  mySoftwareSerial.begin(9600);
  if(!myDFPlayer.begin(mySoftwareSerial)){
    Serial.write("player error");
  }
  delay(100); //設定待ち時間は仮置き
  myDFPlayer.volume(10); //音量は0~30
}

void loop() {
  // put your main code here, to run repeatedly:
  int value = digitalRead(PIN_IN);

  //ボタンを押すとルビィちゃんがしゃべる。最初の一度だけ「おはよう」仕様（おはようボイス再生、"morning"を送信）
  if(value == 0){
    if(awake){
      myDFPlayer.play(random(3, 9)); //汎用ボイスを再生する、再生し始めたらすぐ次の行へ飛ぶ
    }else{
      awake = true;
      Serial.write("morning");
      myDFPlayer.play(1); // 1番目のmp3（おはようボイス）
    }
    
    changeVoltage(PIN_OUT); //ルビィちゃんを動かす（LEDとかでもいい）
  }

  //シリアルポートから文字列が送られてきた場合は通知する
  if(Serial.available() > 0){
    String words = Serial.readString(); //タイムアウト（0.1秒）するまで文字列を読み込む
    words.trim(); //最初と最後の改行文字、空白文字を削除
    
    if(!awake){ //寝てるときは実行しない
      return;
    }

    if(words == "reply"){
      myDFPlayer.play(random(3, 9)); //汎用ボイス
    }else if(words == "sleep"){ //awakeをfalseにして寝た状態へ    
      awake = false;
      myDFPlayer.play(2); //おやすみボイス
    }

    changeVoltage(PIN_OUT); //ルビィちゃんを動かす
  }
}

void changeVoltage(int pin){ //pinの電位を変える関数
  digitalWrite(pin, HIGH);
  delay(8*1000);
  digitalWrite(pin, LOW);
}
