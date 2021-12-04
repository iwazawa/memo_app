# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'cgi'

# idに該当するjsonファイルをhashに変換する
def json_parse(id)
  File.open("memos/#{id}.json") do |file|
    JSON.parse(file.read)
  end
end

get '/' do
  @h = ''
  files = Dir.glob('*', base: 'memos')
  files.each do |file|
    id = file.delete('.json')
    memo_contents = json_parse(id)
    @h += "<li><a href=\"/detail?id=#{memo_contents['id']}\">#{memo_contents['title']}</a></li>"
  end
  erb :index
end

get '/new' do
  erb :new
end

get '/detail' do
  @id = params[:id]
  memo_contents = json_parse(@id)
  @title = memo_contents['title']
  @body = memo_contents['body']
  erb :detail
end

post '/new' do
  id = SecureRandom.uuid
  title = CGI.escape_html(params[:title])
  body = CGI.escape_html(params[:body])
  created_at = Time.now
  memo_contents = {
    'id' => id,
    'title' => title,
    'body' => body,
    'created_at' => created_at
  }

  File.open("./memos/#{id}.json", 'w') do |file|
    JSON.dump(memo_contents, file)
  end

  redirect '/'
end

delete '/delete' do
  File.delete("./memos/#{params[:id]}.json")

  redirect '/'
end

get '/edit' do
  @id = params[:id]
  @title = params[:title]
  @body = params[:body].gsub('\r\n', "\r\n")
  erb :edit
end

patch '/edit' do
  memo_contents = json_parse(params[:id])
  memo_contents['title'] = CGI.escape_html(params[:title])
  memo_contents['body'] = CGI.escape_html(params[:body])
  memo_contents['update_at'] = Time.now

  File.open("./memos/#{params[:id]}.json", 'w') do |file|
    JSON.dump(memo_contents, file)
  end

  redirect '/'
end

not_found do
  erb :notfound
end
