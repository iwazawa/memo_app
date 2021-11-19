# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'cgi'

get '/' do
  @h = ''
  files = Dir.glob('*', base: 'memos')
  files.each do |file|
    File.open("memos/#{file}") do |f|
      string = f.read
      hash = JSON.parse(string)
      @h += "<li><a href=\"/detail?id=#{hash['id']}\">#{hash['title']}</a></li>"
    end
  end
  erb :index
end

get '/new' do
  erb :new
end

get '/detail' do
  @id = params[:id]
  File.open("memos/#{@id}.json") do |file|
    string = file.read
    hash = JSON.parse(string)
    @title = hash['title']
    @body = hash['body']
  end
  erb :detail
end

post '/new' do
  id = SecureRandom.uuid
  title = CGI.escape_html(params[:title])
  body = CGI.escape_html(params[:body])
  created_at = Time.now
  hash = {
    'id' => id,
    'title' => title,
    'body' => body,
    'created_at' => created_at
  }

  File.open("./memos/#{id}.json", 'w') do |file|
    JSON.dump(hash, file)
  end

  redirect '/'
end

delete '/delete' do
  File.delete("./memos/#{params[:id]}.json")

  redirect '/'
end

get '/edit' do
  puts params[:body]
  @id = params[:id]
  @title = params[:title]
  @body = params[:body].gsub('\r\n', "\r\n")
  p @body
  erb :edit
end

patch '/edit' do
  hash = File.open("./memos/#{params[:id]}.json") do |file|
    string = file.read
    JSON.parse(string)
  end

  hash['title'] = CGI.escape_html(params[:title])
  hash['body'] = CGI.escape_html(params[:body])
  hash['update_at'] = Time.now

  File.open("./memos/#{params[:id]}.json", 'w') do |file|
    JSON.dump(hash, file)
  end

  redirect '/'
end

not_found do
  erb :notfound
end
