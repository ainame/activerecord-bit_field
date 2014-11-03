require 'spec_helper'

describe ActiveRecord::BitField do
  context 'using bit_field DSL by flags column' do
    let(:dummy) { Dummy.new }
    let(:dummy_invert) { DummyInvert.new }

    describe '#flgas' do
      it 'decide default value by cloumn default value' do
        expect(dummy.flags).to eq({ aaa: false, bbb: false, ccc: false})
        expect(dummy_invert.flags).to eq({ aaa: true, bbb: true, ccc: true})
      end

      context 'enable aaa flag' do
        before do
          dummy.enable_flags_field(:aaa)
          dummy.save!
          dummy_invert.enable_flags_field(:aaa)
          dummy_invert.save!
        end

        it 'default value is all false' do
          expect(dummy.flags).to eq({ aaa: true, bbb: false, ccc: false})
          expect(dummy_invert.flags).to eq({ aaa: true, bbb: true, ccc: true})
        end
      end
    end

    describe '#enable_<column>_field' do
      before do
        dummy_invert.send(:write_attribute, :flags, 1)
        dummy_invert.save!
      end

      it 'should change bit value' do
        expect { dummy.enable_flags_field(:aaa) }.to change {
          dummy.read_attribute(:flags)
        }.from(0).to(1)

        expect { dummy_invert.enable_flags_field(:aaa) }.to change {
          dummy_invert.read_attribute(:flags)
        }.from(1).to(0)
      end
    end

    describe '#disable_<column>_field' do
      before do
        dummy.send(:write_attribute, :flags, 1)
        dummy.save!
      end

      it 'should change bit value' do
        expect { dummy.disable_flags_field(:aaa) }.to change {
          dummy.read_attribute(:flags)
        }.from(1).to(0)

        expect { dummy_invert.disable_flags_field(:aaa) }.to change {
          dummy_invert.read_attribute(:flags)
        }.from(0).to(1)
      end
    end

    describe 'shorthand syntax' do
      it 'has each flags inquire methods' do
        expect(dummy.aaa?).to be(false)
        expect(dummy.bbb?).to be(false)
        expect(dummy.ccc?).to be(false)
        expect(dummy_invert.aaa?).to be(true)
        expect(dummy_invert.bbb?).to be(true)
        expect(dummy_invert.ccc?).to be(true)
      end

      it 'has each flags inquire methods' do
        expect { dummy.enable_aaa }.to change { dummy.aaa? }.from(false).to(true)
        expect { dummy_invert.disable_aaa }.to change { dummy_invert.aaa? }.from(true).to(false)
      end
    end
  end
end
