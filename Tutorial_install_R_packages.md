# RStudioでのRのパッケージのインストール

AJACS68 (AJACS浜松) [https://events.biosciencedbc.jp/training/ajacs68](https://events.biosciencedbc.jp/training/ajacs68)
January 17, 2018

尾崎 遼
Haruka Ozaki
haruka.ozaki@riken.jp | http://yuifu.github.io | [@yuifu](https://twitter.com/yuifu)

理化学研究所 情報基盤センター バイオインフォマティクス研究開発ユニット 基礎科学特別研究員
Bioinformatics Research Unit, ACCC, RIKEN


----

## 概要

この文章ではRStudioにおいてRのパッケージをインストールする方法を解説します。特にCRANとBioconductorからのインストールについて説明します。

Rに全く触ったことがない人も対象にしているため、やや冗長な書き方になる部分もありますがご了承ください。

## 内容

- RStudioでのRのコマンドの実行
- レポジトリからのパッケージのインストール
  - CRANのパッケージのインストール
  - Bioconductorのパッケージのインストール



## 前提条件

RとRStudioのインストールが完了していることを前提とします。

- Rのインストール: https://cran.r-project.org/
  - Windowsユーザーの方はこちらの日本語記事も参考になるかもしれません https://qiita.com/FukuharaYohei/items/8e0ddd0af11132031355
- RStudioのインストール:　https://www.rstudio.com/products/rstudio/download/


----

## RStudioでのRのコマンドの実行

RStudio を起動すると以下の様にいくつかの区画に仕切られたウィンドウが表示されます。この中で「コンソール (console)」という部分があります。

![](assets/Tutorial_install_R_packages-8fc96.png)


コンソールでRのコマンドを入力し、実行すると、出力結果が表示されます。`>` の右側にRのコマンドを入力することができます。

試しに以下のコマンドを入力し、実行してみましょう。実行するには、Enter (もしくはReturn) キーを押します。

```
plot(cars)
```

すると、右下の区画に散布図のプロットが表示されます。

![](assets/Tutorial_install_R_packages-ac2f9.png)

次に、以下のコマンドを入力し、実行してみましょう。

```
1+1
```

すると、以下の様な出力結果が表示されると思います。

```
> 1+1
[1] 2
```

![](assets/Tutorial_install_R_packages-c8c58.png)

これで、RStudioでRのコマンドを実行できる様になりました。


## レポジトリからのパッケージのインストール

パッケージとはRの機能を拡張する便利なコマンド群です。パッケージをインストールすることで、Rで様々なことができるようになります。

パッケージを配布するために集積する場所をレポジトリと呼びます。

以下では、CRANとBioconductorという２つのレポジトリからのパッケージのインストール方法を説明します。なお、**パッケージのインストールは時間がかかる場合も多いので、時間に余裕がある時に行うこと**をおすすめします。


### CRANのパッケージのインストール
RのパッケージのレポジトリにCRANがあります。

以下のコマンドを実行すると、CRNAから `tidyverse` というパッケージをインストールされます。

```
install.packages("tidyverse")
```

以下のコマンドを実行すると、CRNAから `magrittr` というパッケージをインストールされます。

```
install.packages("magrittr")
```

### Bioconductorのパッケージのインストール

[Bioconductor](https://bioconductor.org/) は生命科学系のデータ解析用のパッケージのレポジトリです。

以下のコマンドを実行すると、Bioconductorの基本パッケージがインストールされます。


```
source("https://bioconductor.org/biocLite.R")
biocLite()
```


----
