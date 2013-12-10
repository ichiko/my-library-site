require 'rubygems'
require 'rspec'

require 'helpers/renderhelper.rb'

describe RenderHelper do
	context 'enableBR' do
		it '対象が<p>を含まないとき、置換は発生しない' do
			input = <<EOL
hogehoge
fugaga
EOL
			result = RenderHelper.enableBR(input)
			expect(result).to eq(input)
		end
		it '対象が<p>を含むとき、その中のみ変更される' do
			input = <<EOL
hogehoge
<p>fugafuga
varvar</p>
fue
EOL
			expected = <<EOL
hogehoge
<p>fugafuga<br>
varvar</p>
fue
EOL
			result = RenderHelper.enableBR(input)
			expect(result).to eq(expected)
		end
		it '対象が<p>を複数含むとき、それぞれの中が変更される' do
			input = <<EOL
hogehoge
<p>fuga
fuga</p>

<p>aaaa
bbbb</p>
eeeee
EOL
			expected = <<EOL
hogehoge
<p>fuga<br>
fuga</p>

<p>aaaa<br>
bbbb</p>
eeeee
EOL
			result = RenderHelper.enableBR(input)
			expect(result).to eq(expected)
		end
	end

end