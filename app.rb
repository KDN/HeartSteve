

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



get '/' do 
	haml :index 
end

post '/' do
  uri = URI::parse(params[:original])
  raise "Invalid URL" unless uri.kind_of? URI::HTTP or uri.kind_of? URI::HTTPS
  @url = Url.first_or_create(:original => uri.to_s)
  haml :index
end

get '/:snipped' do redirect Url[params[:snipped].to_i(36)].original end

error do haml :index end

use_in_file_templates!

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://root:root@localhost/snip')
class Url
  include DataMapper::Resource
  property  :id,          Serial
  property  :original,    String, :length => 255
  property  :created_at,  DateTime  
  def snipped() self.id.to_s(36) end  
end