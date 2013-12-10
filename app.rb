require './models/book'
require './helpers/renderhelper'

class App < Sinatra::Base
  register Sinatra::Namespace
  register Sinatra::Reloader

  HTML_PATTERN = %r{^/(.*)\.html$}

  before do
    @site_name = 'とある中二のサンプル図書館'
  end

  def poemdown(contents)
    RenderHelper.enableBR(RDiscount.new(contents).to_html)
  end

  def haml_render(file, option = {})
    p file, option
    layout = option[:layout].nil? ? :layout : option[:layout]
    haml :"#{file}", layout: layout
  end

  namespace '/poem' do
    before do
      @category = '詩'
      @category_id = 'poem'
    end
    get '.html' do
      haml_render :"poem-contents", type: 'anonymous list'
    end
    get '/p*.html' do
      @book = Poem.load("books/poem/p#{ params[:captures].first }.#{ Book::POEM_DATA_EXT }")
      haml_render :poem, type: 'page'
    end
  end

  namespace '/novel' do
    before do
      @category = '小説'
      @category_id = 'novel'
    end
    get '.html' do
      haml_render :"novel-contents", type: 'anonymous list'
    end
    get '/*.html' do
      @book = Novel.load("books/novel/#{ params[:captures].first }.#{ Book::NOVEL_DATA_EXT }")
      haml_render :novel, type: 'page'
    end
  end

  get HTML_PATTERN do
    haml_render params[:captures].first, type: 'any'
  end

  get '/' do
    haml_render 'index'
  end

  get %r{^/stylesheets/(.*)\.css} do
  	scss :"scss/#{params[:captures].first}"
  end

end