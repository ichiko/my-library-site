# 水無月の余韻のWebページ管理ツール

sinatraでページを生成して、丸ごとアップできるようにする。

レイアウト管理とか便利なsinatraで開発して、
yamagata-kozo/modern-web-creating-environment の static-file-maker.rbを使って、静的ファイルに書き出す。

## for Developer

```
bundle install --path vendor/bundle
npm install
grunt install
```

### Test

```
bundle exec rackup
```

open localhost:9292

### Generate Static Files

1. site.json に、nameと、生成するファイルパスを記述します。
	記述は、フォルダ構造に対応して入れ子になっています。

1. 生成タスクを実行します。

	```
	grunt generate
	```

1. static/YYYYmmddHHMMSS_NAME にファイルが生成されます。
	public配下のフォルダを丸っとコピーして、上記、生成したフォルダへ上書きします。

## 謝辞

- yamagata-kozo/modern-web-creating-environment
	静的ファイル生成には、yamagata-kozo/modern-web-creating-environment/static_file_maker.rb を使用しています。
	プロジェクトの取り込みが適さなかったため、該当ファイルのみを取得しています。
	また、ファイルを含まないフォルダが存在するときに、フォルダ生成に失敗する問題を修正しています。
