module Listable
	#
	# === 指定フォルダ内のファイルから、すべてを一覧で返します。
	#
	def list_all(dir, ext)
		list = []
		Dir.glob("#{ dir }/*.#{ ext }").each { |f|
			list << load(f)
		}
		return list
	end

	#
	# === 新しい方から、指定の件数のデータを返します。
	#
	def list_arrival(dir, ext, num)
		all = list_all(dir, ext).reverse
		all[0...num]
	end
end # Listable

class Book
	extend Listable

	POEM_DATA_EXT = 'pmd'
	NOVEL_DATA_EXT = 'md'

	attr_reader :id, :file_name, :title, :subtitle, :updated_at, :body, :afterword, :previous_link, :next_link

	def initialize(path)
		@file_name = get_filename(path)
		@id = get_pageid(@file_name)
		@title = ''
		@subtitle = ''
		@updated_at = Array.new
		@body = ''
		@afterword = ''
		@read_flags = {}
		@previous_link = get_previous_link(path)
		@next_link = get_next_link(path)
	end

	def get_filename(path)
		ext = ''
		if /\.([^\.]*)$/ =~ path
			ext = $1
		end
		File.basename(path, ".#{ext}")
	end

	def get_pageid(file_name)
		if /([0-9]*)$/ =~ file_name
			$1.to_i
		else
			0
		end
	end

	def get_previous_link(path)
		exist_increment_path?(path, -1)
	end

	def get_next_link(path)
		exist_increment_path?(path, 1)
	end

	def exist_increment_path?(path, add_num)
		if /^(.*[^0-9])([0-9]*)(\.[^\.]*)$/ =~ path
			num_format = "%0#{ $2.length }d"
			prev_num = sprintf(num_format, $2.to_i + add_num)
			prev_path = "#{ $1 }#{ prev_num }#{ $3 }"
			if File.exist?(prev_path)
				return File.basename(prev_path, "#{ $3 }")
			else
				return nil
			end
		end
		return nil
	end

	#
	#=== 指定のファイルから読みこんで、Bookオブジェクトを返します
	#
	def self.load(path, book = nil)
		book = Book.new(path) if book.nil?
		after_body = false
		File.open(path) { |f|
			while l = f.gets
				after_body = book.read_line(l, after_body)
			end
		}
		return book
	end

	#
	#=== コンテンツデータを読みこみます。
	#
	# 解釈する形式は以下のとおり。
	#
	# - タイトル(title)		: 最初の /^#([^#].*)$/
	# - 更新日付(update_at)	: /^-+$/ が登場するまでの、 /^### (.*)$/ すべて
	# - 本文(body)			: 上記に該当しない、 /^-+$/ までの部分
	# - 後書き				: /^-+$/ 以降
	# - コメント				: /^--!/ - /^\+\+!/ の範囲は取り込まない
	#
	def read_line(l, after_body)
		if /^--!/ =~ l
			@read_flags[:ignore] = true
			return after_body
		elsif /^\+\+!/ =~ l
			@read_flags[:ignore] = false
			return after_body
		end
		if ! @read_flags[:ignore].nil? and @read_flags[:ignore] == true
			return after_body
		end
		unless after_body
			if /^[-]{3,}/ =~ l
				after_body = true
			elsif /^#([^#].*)$/ =~ l
				if @title.empty?
					@title = $1.strip
				else
					@body += l
				end
			elsif /^##([^#].*)$/ =~ l
				if @subtitle.empty?
					@subtitle = $1.strip
				else
					@body += l
				end
			elsif /^###(.*)$/ =~ l
				@updated_at.push $1.strip
			else
				@body += l
			end
		else after_body
			@afterword += l
		end
		return after_body
	end

	#
	# === 指定フォルダ内のファイルから、すべてを一覧で返します。
	#
	def self.list(dir, ext = Book::POEM_DATA_EXT)
		list_all(dir, ext)
	end

	#
	# === 指定フォルダ内のファイルから、降順で指定数を返します。
	#
	def self.arrival(dir, ext, num)
		list_arrival(dir, ext, num)
	end

end # Book

class Poem < Book
	extend Listable

	def self.load(path)
		super path, Poem.new(path)
	end

	def self.list(dir)
		list_all(dir, Book::POEM_DATA_EXT)
	end

	def self.arrival(dir, num)
		list_arrival dir, Book::POEM_DATA_EXT, num
	end
end # Poem

class Novel < Book
	extend Listable

	def self.load(path)
		super path, Novel.new(path)
	end

	def self.list(dir)
		list_all(dir, Book::NOVEL_DATA_EXT)
	end

	def self.arrival(dir, num)
		list_arrival dir, Book::NOVEL_DATA_EXT, num
	end

	#
	#=== コンテンツデータを読みこみます。
	#
	# 親クラスで定義されたものの他に、以下の条件で設定を上書きします。
	# 
	# - 前ページリンク(previous_link)	: 最初の /^--<<(.*)$/
	# - 次ページリンク(next_link)		: 最初の /^-->>[ ]*([^ ])$/
	#
	def read_line(l, after_body)
		if /^--<<(.*)$/ =~ l
			if @read_flags[:previous_link].nil?
				@read_flags[:previous_link] = true
				@previous_link = $1.strip
			end
		elsif /^-->>(.*)$/ =~ l
			if @read_flags[:next_link].nil?
				@read_flags[:next_link] = true
				@next_link = $1.strip
			end
		else
			super
		end
	end
end