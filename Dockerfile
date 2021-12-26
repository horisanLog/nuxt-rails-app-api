# rubyのベースイメージを指定する
# インストールされるパッケージについては以下を参照
# その前の検索ではdocker hubからhttps://hub.docker.com/_/ruby を参照する
# https://github.com/docker-library/ruby/blob/1e1d46db1542d9869ef677ebc2dd56aecb4ececa/3.0/alpine3.15/Dockerfile
# FROM ruby:3.0.3-alpine

# # Dockerfile内で使用する変数を定義
# # app
# ARG WORKDIR


# ARG RUNTIME_PACKAGES="nodejs tzdata git"
# ARG DEV_PACKAGES="build-base curl-dev"

# # 環境変数を定義(Dockerfile, コンテナ参照可)
# # Rails ENV["TZ"] => Asia/Tokyo
# ENV HOME=/${WORKDIR} \
#     LANG=C.UTF-8 \
#     TZ=Asia/Tokyo

# # Dockerfile内で指定した命令を実行する ... RUN, COPY, ADD, ENTORYPOINT, CMD
# # 作業ディレクトリを定義
# # コンテナ/app/Railsアプリ
# WORKDIR ${HOME}

# # ホスト側(PC)のファイルをコンテナにコピー
# # COPY コピー元(ホスト) コピー先(コンテナ)
# # Gemfile* ... Gemfileから始まるファイルを全指定(Gemfile, Gemfile.look)
# # コピー元(ホスト) ... Dockerfileがあるディレクトリ以下を指定(api) ../ NG
# # コピー先(コンテナ) ... 絶対パス or 相対パス(./ ... 今いる(カレント)ディレクトリ)
# COPY Gemfile* ./


# # apk ... Alpine Linuxのコマンド
#     # apk update = パッケージの最新リストを取得
# RUN apk update && \
#     # apk upgrade = インストールパッケージを最新のものに
#     apk upgrade && \
#     # apk add = パッケージのインストールを実行
#     # --no-cache = パッケージをキャッシュしない(Dockerイメージを軽量化)
#     apk add --no-cache ${RUNTIME_PACKAGES} && \
#     # --virtual 名前(任意) = 仮想パッケージ
#     apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
#     # Gemのインストールコマンド
#     # -j4(jobs=4) = Gemインストールの高速化
#     bundle install -j4 && \
#     # パッケージを削除(Dockerイメージを軽量化)
#     apk del build-dependencies


# COPY . ./

# CMD ["rails", "server", "-b", "0.0.0.0"]

FROM ruby:3.0.3

# ENV RAILS_ENV=production

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq \
  && apt-get install -y nodejs yarn

WORKDIR ${HOME}
COPY . ./
RUN bundle config --local set path 'vendor/bundle' \
  && bundle install

# COPY start.sh /start.sh
# RUN chmod 744 /start.sh
# CMD ["sh", "/start.sh"]

FROM ruby:3.0.3

ENV LANG=C.UTF-8 \
  TZ=Asia/Tokyo

WORKDIR /app
RUN apt-get update -qq && apt-get install -y nodejs default-mysql-client
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]