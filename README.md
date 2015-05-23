osu!Notification
===========

##What is it?

osu!のプレイデータをツイートするプログラム。  
cronで一日ごとに指定してあげると前日との差を表示させてあげたりもできます。  
デフォルトだと  
[flum_cat] osu!mania PP:1657(0) Rank:#7638(0) Lv:63(0) ACC:94.0%(0%) Playcount:4206(0) SS:166(0) S:147(0) A:119(0) #osu!Notification  
[flum_cat] osu! PP:1039(0) Rank:#79581(0) Lv:80(0) ACC:94.0%(0%) Playcount:9376(0) SS:11(0) S:147(0) A:219(0) #osu!Notification  
のような感じで二つツイートされます。  
  
動作確認はubuntu14.04 ruby1.9.3p194です。

##How to Use
twitter、 sqlite3のgemをあらかじめインストールしておく必要があります。
#手順１
まず[ここ](https://osu.ppy.sh/p/api)からosu!のAPI_KEYを取得してください。

#手順２
次に[ここ](https://apps.twitter.com/)からツイッターアプリケーションの登録をしてください。  
Key and Access TokensタブのConsumerKey, Consumer Secretは後ほど使うので控えて置いてください。  

#手順３
以下のコマンドを実行する
```
> git clone https://github.com/flum1025/osu!Notification.git
> cd osu!Notification/utility
> ruby gettoken.rb

```
画面にしたがって先ほどのConsumerKey, Consumer Secretを入力して認証すればAccessTokenとAccessTokenSecretが入手できるはずです。
#手順４
```
> cd ../data
> nano setting.rb

```
nanoが開くので  
CONSUMER_KEY,CONSUMER_SECRET,ACCESS_TOKEN,ACCESS_TOKEN_SECRET,API_KEY,OSU_USER_ID  
のそれぞれを書き換えてください。  
API_KEYはosu!のサイトから取得したAPI_KEYでOSU_USER_IDにはosu!のアカウント名を設定してください。
#手順５
```
> cd ..
> ruby osu!_notification.rb

```
無事ツイートされれば成功です。
#改変
自分用にツイートされる内容を変更したい場合はosu!_notification.rbの中身を各自自由に書き換えてください。  
API送信先やパラメータの詳細はresponse exampleと一緒にosu!api.rbに記載してあります。  
osu!_notification.rbは汎用できるように作っていないので、パラメータを書き換えたり別のＧＥＴメソッドを使う場合はほぼ１から作り直す必要があります。
やっつけで作ったので例外処理も入れてません。

質問等ありましたらTwitter:[@flum_](https://twitter.com/flum_)までお願いします。

##License

The MIT License

-------
(c) @2015 flum_
