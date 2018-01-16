# 実習用環境の準備

AJACS68 (AJACS浜松) [https://events.biosciencedbc.jp/training/ajacs68](https://events.biosciencedbc.jp/training/ajacs68)  
January 17, 2018

尾崎 遼  
Haruka Ozaki  
haruka.ozaki@riken.jp | http://yuifu.github.io | [@yuifu](https://twitter.com/yuifu)

理化学研究所 情報基盤センター バイオインフォマティクス研究開発ユニット 基礎科学特別研究員  
Bioinformatics Research Unit, ACCC, RIKEN


----

## 概要

この文章では実習用環境の準備について説明します。

具体的には:

1. Jupyter notebook へのアクセス
2. 講習用データのダウンロード

実習用資料: https://github.com/yuifu/ajacs68

----


----

## 実習用環境の簡単な説明

Jupyter notebook はRを使うインターフェースの一つです。JupyterHubはたくさんのユーザに統一的なJupyter notebookの実行環境を提供するサーバーです。

受講者の皆さんは、JupyterHubにアクセスし、Jupyter notebookでRを使います。また、実習に使用するデータをダウンロードします。


## 方法
### 1. Jupyter notebook (JupyterHub) へのアクセス

まず `Chrome` を起動し、事前に配られたグループに対応するURLへアクセスしてください。

- グループ1: TODO
- グループ2: TODO
- グループ3: TODO
- グループ4: TODO
- グループ5: TODO

アクセスすると下図のような画面が表示されます。`ADVANCED`をクリックしてください（下図、矢印）。

![](assets/tutorial_00_prepare_environment-bc64f.png)

さらに、`Proceed to [IPアドレス] (unsafe)` をクリックします。

![](assets/tutorial_00_prepare_environment-4c1ef.png)

すると、下図のようなログイン画面がでてきます。事前に配布したユーザ名とパスワードを入力して `Sign in` をクリックします。

![](assets/tutorial_00_prepare_environment-436c2.png)

下図の画面が出たらログイン成功です。

![](assets/tutorial_00_prepare_environment-5f577.png)

### 2. 講習用データのダウンロード

ターミナルを起動します。`New`をクリックするとメニューが表示されます。その中から`Terminal`をクリックします。

![](assets/tutorial_00_prepare_environment-b32a0.png)

![](assets/tutorial_00_prepare_environment-646f1.png)

すると新しいタブでターミナル（黒い画面）が表示されます。

続いて、講習用のデータをダウンロードするコマンドを入力します。以下のコマンドを入力して `Enter` (もしくは`Return`)を押します。しばらく待って`Checking connectivity ... done` と表示されたら成功です。

```
git clone https://github.com/yuifu/ajacs68.git
```

![](assets/tutorial_00_prepare_environment-1f498.png)

さらに以下のコマンドを入力します。`ajac68`と出力されたら成功です。

```
ls
```

![](assets/tutorial_00_prepare_environment-71f59.png)

それでは最初のタブに戻ります。`ajacs68`というディレクトリが新たにできていると思います。

![](assets/tutorial_00_prepare_environment-109e3.png)


----
