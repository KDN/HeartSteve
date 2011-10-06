require 'bundler'
Bundler.require

# require 'dm-core'
# require 'dm-timestamps'
# require 'uri'

# Asset pipeline
project_root = File.expand_path(File.dirname(__FILE__))

assets = Sprockets::Environment.new(project_root) do |env|
  env.logger = Logger.new(STDOUT)
end

#assets.append_path('assets')
assets.append_path(File.join(project_root, 'assets'))
assets.append_path(File.join(project_root, 'assets', 'images'))
assets.append_path(File.join(project_root, 'assets', 'javascripts'))
assets.append_path(File.join(project_root, 'assets', 'stylesheets'))


module AssetHelpers
  def asset_path(name)
    "/assets/#{name}"
  end
end

assets.context_class.instance_eval do
  include AssetHelpers
end

get '/assets/*' do
  new_env = env.clone
  new_env["PATH_INFO"].gsub!("/assets", "")
  assets.call(new_env)
end
# end asset pipeline



get '/', :provides => 'html' do
	haml :index
end


#URL SHORTENER CODE

configure do
	uri = URI.parse(ENV["REDISTOGO_URL"])
	redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end




helpers do
	include Rack::Utils
	alias_method :h, :escape_html

	def random_string(length)
		rand(36**length).to_s(36)
	end
end

get '/' do
	erb :index
end

post '/' do
	if params[:url] and not params[:url].empty?
		@shortcode = random_string 5
		redis.setnx "links:#{@shortcode}", params[:url]
	end
	erb :index
end

get '/:shortcode' do
	@url = redis.get "links:#{params[:shortcode]}"
	redirect @url || '/'
end