require 'rack'
require 'web_config'
require 'oj'

class UsersController < WebConfig::Controller
  def show 
    response(:json, "Hello, #{params['user']}")
  end
end

class BlogsController < WebConfig::Controller
  def new
    response(:html, 'view/example.html')
  end
end

class WelcomesController < WebConfig::Controller
  def show
    response(:text, "Request method: #{request.request_method}")
  end
end

Application = WebConfig::Router.new do
  get '/aqueous-atoll-31147/:user', 'users#show'
  get '/aqueous-atoll-31147/:user/:blog', 'blogs#new'
  get '/aqueous-atoll-31147', 'welcomes#show'
end
