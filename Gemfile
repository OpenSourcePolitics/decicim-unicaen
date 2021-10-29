# frozen_string_literal: true

source "https://rubygems.org"

DECIDIM_VERSION = "release/0.23-stable"

ruby RUBY_VERSION

gem "decidim", git: "https://github.com/decidim/decidim.git", branch: DECIDIM_VERSION

gem "decidim-decidim_awesome", "~> 0.6.0"
gem "decidim-term_customizer", git: "https://github.com/mainio/decidim-module-term_customizer.git", branch: "0.23-stable"

gem "bootsnap", "~> 1.4"
gem "dotenv-rails"
gem "faker", "~> 1.9"
gem "letter_opener_web", "~> 1.3"
gem "omniauth-cas"
gem "puma", "~> 4.3.7"
gem "ruby-progressbar"
gem "sprockets", "~> 3.7"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", git: "https://github.com/decidim/decidim.git", branch: DECIDIM_VERSION
end

group :development do
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :production do
  gem "dalli"
  gem "fog-aws"
  gem "lograge"
  gem "newrelic_rpm"
  gem "passenger"
  gem "sendgrid-ruby"
  gem "sentry-rails"
  gem "sentry-ruby"
  gem "sentry-sidekiq"
  gem "sidekiq"
  gem "sidekiq-scheduler"
end
