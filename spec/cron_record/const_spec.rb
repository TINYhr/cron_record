RSpec.describe 'CronRecord::Const' do
  describe 'BIT_CONVERT' do
    it 'is list of 2 powers' do
      CronRecord::BIT_CONVERT.each_with_index do |item, idx|
        expect(item).to eq(2 ** idx)
      end
    end
  end
end
