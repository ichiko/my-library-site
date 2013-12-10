require 'rubygems'
require 'rspec'

require 'models/book.rb'

describe Book do
	context 'when initialized' do
		it 'updated_at is an Array' do
			book = Book.new('path/to/book')
			expect(book.updated_at.size).to eq(0)
		end
	end

	context 'when loading' do
		before :each do
			@book = Book.new('path/to/book')
		end

		it '後書きの前では # ではじまる行の 最初のものだけ、タイトルに設定される' do
			expect(@book.title.empty?).to eq(true)
			@book.read_line('# title', false)
			expect(@book.title).to eq('title')
			@book.read_line('# second title', false)
			expect(@book.title).to eq('title')
		end
		it '後書きでは # ではじまる行は、後書きとして保存される' do
			expect(@book.title.empty?).to eq(true)
			expect(@book.afterword.empty?).to eq(true)
			@book.read_line('# dummy title', true)
			expect(@book.title.empty?).to eq(true)
			expect(@book.afterword).to eq('# dummy title')
		end

		it '後書きの前では ## ではじまる行の 最初のものだけ、サブタイトルに設定される' do
			expect(@book.subtitle.empty?).to eq(true)
			@book.read_line('## sub title', false)
			expect(@book.subtitle).to eq('sub title')
			@book.read_line('## second sub title', false)
			expect(@book.subtitle).to eq('sub title')
		end
		it '後書きでは ## ではじまる行は、後書きとして保存される' do
			expect(@book.subtitle.empty?).to eq(true)
			expect(@book.afterword.empty?).to eq(true)
			@book.read_line('## dummy sub title', true)
			expect(@book.subtitle.empty?).to eq(true)
			expect(@book.afterword).to eq('## dummy sub title')
		end

		it '後書きの前では ### ではじまる行は、更新日として記録される' do
			expect(@book.updated_at.size).to eq(0)
			@book.read_line('###2000/10/10', false)
			expect(@book.updated_at.size).to eq(1)
			expect(@book.updated_at[0]).to eq('2000/10/10')
		end
		it '後書きの前では ### ではじまる行は、複数あっても更新日として記録される' do
			expect(@book.updated_at.size).to eq(0)
			@book.read_line('###2000/10/10', false)
			@book.read_line('###2010/11/11', false)
			expect(@book.updated_at.size).to eq(2)
			expect(@book.updated_at[0]).to eq('2000/10/10')
			expect(@book.updated_at[1]).to eq('2010/11/11')
		end
		it '後書きでは ### ではじまる行は、後書きとして保存される' do
			expect(@book.updated_at.size).to eq(0)
			expect(@book.afterword.empty?).to eq(true)
			@book.read_line('###2000/10/10', true)
			expect(@book.updated_at.size).to eq(0)
			expect(@book.afterword).to eq('###2000/10/10')
		end

		it '後書きの前では 記号ではじまらない行は、本文として記録される' do
			expect(@book.body.empty?).to eq(true)
			@book.read_line('ほげほげ', false)
			expect(@book.body).to eq('ほげほげ')
		end
		it '後書きでは ## ではじまる行は、後書きとして記録される' do
			expect(@book.afterword.empty?).to eq(true)
			@book.read_line('##その記号', true)
			expect(@book.afterword).to eq('##その記号')
		end
		it '後書きでは 記号ではじまらない行は、後書きとして記録される' do
			expect(@book.afterword.empty?).to eq(true)
			@book.read_line('ふがふが', true)
			expect(@book.afterword).to eq('ふがふが')
		end

		it '切り替え記号がきたら、後書きフラグが変更される(1)' do
			expect(@book.read_line('ふがふが', false)).to eq(false)
			expect(@book.read_line('---', false)).to eq(true)
		end
		it '切り替え記号がきたら、後書きフラグが変更される(2)' do
			expect(@book.read_line('ふがふが', false)).to eq(false)
			expect(@book.read_line("---\n", false)).to eq(true)
		end

		it '後書き前では フラグ記号 --! がきたら、以降 ++! がくるまで取り込まない' do
			@book.read_line("いちぎょうめ\n", false)
			@book.read_line("--! にぎょうめ\n", false)
			@book.read_line("さんぎょうめ\n", false)
			@book.read_line("よんぎょうめ\n", false)
			@book.read_line("++! ごぎょうめ\n", false)
			@book.read_line("ろくぎょうめ\n", false)

			expected_body = <<EOL
いちぎょうめ
ろくぎょうめ
EOL
			expect(@book.body).to eq(expected_body)
		end
		it '後書き後では フラグ記号 --! がきたら、以降 ++! がくるまで取り込まない' do
			@book.read_line("いちぎょうめ\n", false)
			@book.read_line("--! にぎょうめ\n", false)
			@book.read_line("さんぎょうめ\n", false)
			@book.read_line("よんぎょうめ\n", false)
			@book.read_line("++! ごぎょうめ\n", false)
			@book.read_line("ろくぎょうめ\n", false)

			expected_body = <<EOL
いちぎょうめ
ろくぎょうめ
EOL
			expect(@book.body).to eq(expected_body)
		end

		it 'ファイルを読んで、正しく取り込める' do
			expected_body = <<EOL

水は流れゆく
おのおのの道を

地は人々を養い
草木を育てる
いつか来る至福の時に向けて

炎は時に激しく荒れ狂い
人々を苦しませ
命を奪う

人は時に彼らに祈り
願いをかける
我らに幸をと

人々の祈り
彼らに教える
神から与えられた大切なことを
彼らの使命を

この世への至福の訪れを悠久の時の中で祈りながら

EOL
			expected_afterword = <<EOL

なんじゃこりゃ、ですね・・・
自分でも何書いてんだか。
そんなに最近かいたわけでもないので、自分でもなぞです。
EOL

			book = Book.load('spec/data/p001.pmd')
			expect(book.id).to eq(1)
			expect(book.file_name).to eq('p001')
			expect(book.title).to eq('神々の詩')
			expect(book.updated_at.size).to eq(1)
			expect(book.updated_at[0]).to eq('2002/09/08')
			expect(book.body).to eq(expected_body)
			expect(book.afterword).to eq(expected_afterword)
		end
	end

	context 'when listing all' do
		it '一覧情報を正しく取得する' do
			expected = [
				{ :id => 1, :file_name => 'p001', :title => '神々の詩'},
				{ :id => 2, :file_name => 'p002', :title => 'テストドキュメント1' },
				{ :id => 3, :file_name => 'p003', :title => 'テストドキュメント2' }
			]
			list = Book.list('spec/data', Book::POEM_DATA_EXT)
			expect(list.size).to eq(3)
			list.zip(expected) { |book, hash|
				expect(book.instance_of?(Book))
				expect(book.id).to eq(hash[:id])
				expect(book.file_name).to eq(hash[:file_name])
				expect(book.title).to eq(hash[:title])
			}
		end
	end

	context 'when listing top N' do
		it '一覧情報を正しく取得する' do
			expected = [
				{ :id => 3, :file_name => 'p003', :title => 'テストドキュメント2' },
				{ :id => 2, :file_name => 'p002', :title => 'テストドキュメント1' }
			]
			list = Book.arrival('spec/data', Book::POEM_DATA_EXT, 2)
			expect(list.size).to eq(2)
			list.zip(expected) { |book, hash|
				expect(book.instance_of?(Book))
				expect(book.id).to eq(hash[:id])
				expect(book.file_name).to eq(hash[:file_name])
				expect(book.title).to eq(hash[:title])
			}
		end
	end

	context 'link to previous/next' do
		it '先頭の場合' do
			book = Book.load('spec/data/p001.pmd')
			expect(book.previous_link).to eq(nil)
			expect(book.next_link).to eq('p002')
		end
		it '中間の場合' do
			book = Book.load('spec/data/p002.pmd')
			expect(book.previous_link).to eq('p001')
			expect(book.next_link).to eq('p003')
		end
		it '末尾の場合' do
			book = Book.load('spec/data/p003.pmd')
			expect(book.previous_link).to eq('p002')
			expect(book.next_link).to eq(nil)
		end
	end
end

describe Poem do

	context 'when listing all' do
		it '一覧情報を正しく取得する' do
			expected = [
				{ :id => 1, :file_name => 'p001', :title => '神々の詩'},
				{ :id => 2, :file_name => 'p002', :title => 'テストドキュメント1' },
				{ :id => 3, :file_name => 'p003', :title => 'テストドキュメント2' }
			]
			list = Poem.list('spec/data')
			expect(list.size).to eq(3)
			list.zip(expected) { |book, hash|
				expect(book.instance_of?(Book))
				expect(book.id).to eq(hash[:id])
				expect(book.file_name).to eq(hash[:file_name])
				expect(book.title).to eq(hash[:title])
			}
		end
	end

	context 'when listing top N' do
		it '一覧情報を正しく取得する' do
			expected = [
				{ :id => 3, :file_name => 'p003', :title => 'テストドキュメント2' },
				{ :id => 2, :file_name => 'p002', :title => 'テストドキュメント1' }
			]
			list = Poem.arrival('spec/data', 2)
			expect(list.size).to eq(2)
			list.zip(expected) { |book, hash|
				expect(book.instance_of?(Book))
				expect(book.id).to eq(hash[:id])
				expect(book.file_name).to eq(hash[:file_name])
				expect(book.title).to eq(hash[:title])
			}
		end
	end
end

describe Novel do
	context 'when listing all' do
		it '一覧情報を正しく取得する' do
			expected = [
				{ :id => 1, :file_name => 'novel_01-01', :title => 'テスト小説', :subtitle => 'サブタイトル(1)' },
				{ :id => 2, :file_name => 'novel_01-02', :title => 'テスト小説', :subtitle => 'サブタイトル(2)' },
				{ :id => 3, :file_name => 'novel_01-03', :title => 'テスト小説', :subtitle => 'サブタイトル(3)' }
			]
			list = Novel.list('spec/data')
			expect(list.size).to eq(3)
			list.zip(expected) { |book, hash|
				expect(book.instance_of?(Book))
				expect(book.id).to eq(hash[:id])
				expect(book.file_name).to eq(hash[:file_name])
				expect(book.title).to eq(hash[:title])
				expect(book.subtitle).to eq(hash[:subtitle])
			}
		end
	end

	context 'when loading' do
		before do
			@book = Novel.new('path/to/novel.md')
		end

		it '後書き前では、--<< ではじまる最初の行が、previous_linkに設定される' do
			expect(@book.previous_link).to eq(nil)
			expect(@book.next_link).to eq(nil)
			expect(@book.body.empty?).to eq(true)
			@book.read_line('--<< link/to/item.html', false)
			expect(@book.previous_link).to eq('link/to/item.html')
			expect(@book.next_link).to eq(nil)
			expect(@book.body.empty?).to eq(true)
			@book.read_line('--<< link/to/next.html', false)
			expect(@book.previous_link).to eq('link/to/item.html')
			expect(@book.next_link).to eq(nil)
		end
		it '後書き前では、" --<<" ではじまる行は、本文に設定される' do
			expect(@book.previous_link).to eq(nil)
			expect(@book.body.empty?).to eq(true)
			@book.read_line(' --<< link/to/item.html', false)
			expect(@book.previous_link).to eq(nil)
			expect(@book.body).to eq(' --<< link/to/item.html')
		end
		it '後書き後では、--<< ではじまる最初の行が、previous_linkに設定される' do
			expect(@book.previous_link).to eq(nil)
			expect(@book.next_link).to eq(nil)
			expect(@book.body.empty?).to eq(true)
			@book.read_line('--<< link/to/item.html', true)
			expect(@book.previous_link).to eq('link/to/item.html')
			expect(@book.next_link).to eq(nil)
			expect(@book.body.empty?).to eq(true)
			@book.read_line('--<< link/to/next.html', true)
			expect(@book.previous_link).to eq('link/to/item.html')
			expect(@book.next_link).to eq(nil)
		end
		it '後書き後では、" --<<" ではじまる行は、後書きに設定される' do
			expect(@book.previous_link).to eq(nil)
			expect(@book.afterword.empty?).to eq(true)
			@book.read_line(' --<< link/to/item.html', true)
			expect(@book.previous_link).to eq(nil)
			expect(@book.afterword).to eq(' --<< link/to/item.html')
		end

		it '後書き前では、-->> ではじまる最初の行が、next_linkに設定される' do
			expect(@book.previous_link).to eq(nil)
			expect(@book.next_link).to eq(nil)
			expect(@book.body.empty?).to eq(true)
			@book.read_line('-->> link/to/item.html', false)
			expect(@book.previous_link).to eq(nil)
			expect(@book.next_link).to eq('link/to/item.html')
			expect(@book.body.empty?).to eq(true)
			@book.read_line('-->> link/to/next.html', false)
			expect(@book.previous_link).to eq(nil)
			expect(@book.next_link).to eq('link/to/item.html')
		end
		it '後書き前では、" -->>" ではじまる行は、本文に設定される' do
			expect(@book.next_link).to eq(nil)
			expect(@book.body.empty?).to eq(true)
			@book.read_line(' -->> link/to/item.html', false)
			expect(@book.next_link).to eq(nil)
			expect(@book.body).to eq(' -->> link/to/item.html')
		end
		it '後書き後では、-->> ではじまる最初の行が、next_linkに設定される' do
			expect(@book.previous_link).to eq(nil)
			expect(@book.next_link).to eq(nil)
			expect(@book.body.empty?).to eq(true)
			@book.read_line('-->> link/to/item.html', true)
			expect(@book.previous_link).to eq(nil)
			expect(@book.next_link).to eq('link/to/item.html')
			expect(@book.body.empty?).to eq(true)
			@book.read_line('-->> link/to/next.html', true)
			expect(@book.previous_link).to eq(nil)
			expect(@book.next_link).to eq('link/to/item.html')
		end
		it '後書き後では、" -->>" ではじまる行は、後書きに設定される' do
			expect(@book.next_link).to eq(nil)
			expect(@book.afterword.empty?).to eq(true)
			@book.read_line(' -->> link/to/item.html', true)
			expect(@book.next_link).to eq(nil)
			expect(@book.afterword).to eq(' -->> link/to/item.html')
		end
	end
end