RSpec.describe CronRecord::Day do
  describe '.from_str' do
    context 'wildcard' do
      it 'return all bits' do
        subject = described_class.from_str('*')

        expect(subject.to_s).to eq('*')
        expect(subject.to_bit).to eq(4294967294) # all bits from 1->31
      end
    end

    # TODO: [AV] Support range
    # context 'range' do
    #   it 'return range bits' do
    #     subject = described_class.from_str('3-9')

    #     # TODO: [AV] Conver back rangr "3,4,5,6,7,8,9" to "3-9"
    #     expect(subject.to_s).to eq('3,4,5,6,7,8,9')
    #     expect(subject.to_bit).to eq(1016)
    #   end
    # end

    context 'single' do
      it 'return single bit' do
        subject = described_class.from_str('7')

        expect(subject.to_s).to eq('7')
        expect(subject.to_bit).to eq(128)
      end
    end

    context 'invalid input' do
      context 'below range' do
        it 'raise error' do
          expect {
            described_class.from_str('0')
          }.to raise_error(/Invalid/)
        end
      end

      context 'above range' do
        it 'raise error' do
          expect {
            described_class.from_str('32')
          }.to raise_error(/Invalid/)
        end
      end

      context 'below range' do
        it 'raise error' do
          expect {
            described_class.from_str('#')
          }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe '.from_bits' do
    context 'wildcard' do
      it 'return all bits' do
        subject = described_class.from_bits(4294967294)

        expect(subject.to_s).to eq('*')
        expect(subject.to_bit).to eq(4294967294) # all bits from 1->32
      end
    end

    # TODO: [AV] Support range
    # context 'range' do
    #   it 'return range bits' do
    #     subject = described_class.from_bits('3-9')

    #     # TODO: [AV] Conver back rangr "3,4,5,6,7,8,9" to "3-9"
    #     expect(subject.to_s).to eq('3,4,5,6,7,8,9')
    #     expect(subject.to_bit).to eq(1016)
    #   end
    # end

    context 'single' do
      it 'return single bit' do
        subject = described_class.from_bits(128)

        expect(subject.to_s).to eq('7')
        expect(subject.to_bit).to eq(128)
      end
    end

    context 'invalid input' do
      context 'below range' do
        it 'raise error' do
          expect {
            described_class.from_bits(1)
          }.to raise_error(/Invalid/)
        end
      end

      context 'above range' do
        it 'raise error' do
          expect {
            described_class.from_bits(4294967295)
          }.to raise_error(/Invalid/)
        end
      end

      context 'below range' do
        it 'raise error' do
          expect {
            described_class.from_bits('#')
          }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
