#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'yaml'
Dir[File.dirname(__FILE__) + '/include/*.rb'].each {|file| require file }


class Public < Sinatra::Base
	get '/' do
    @data = YAML.load_file('episodes.yml')
		erb :public_home
	end
end	

class Protected < Sinatra::Base
	use Rack::Auth::Basic, "Protected Area" do |username, password|
		username == 'foo' && password == 'bar'
	end

	get '/' do
		erb :admin_home
	end

	get '/new' do
		erb :upload_form
	end

	post '/upload' do
		@filename = params[:file][:filename]
		file = params[:file][:tempfile]

		File.open("./public/#{@filename}", 'wb') do |f|
			f.write(file.read)
		end

		yml = YAML.load_file('episodes.yml')
		size = yml.size

		data = Hash.new
		data = {date: params[:date], name: params[:title], filename: @filename, desc: params[:desc]}
		File.open('episodes.yml', 'w') do |f|
			yml[size] = data
			f.write(yml.to_yaml)
		end
		

		"Shit be uploaded, yo. Date:#{params[:date]}, Title:#{params[:title]}, Description: #{params[:desc]}"
	end

end

