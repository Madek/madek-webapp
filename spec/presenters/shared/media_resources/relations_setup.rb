RSpec.shared_context 'relations' do

  #                          col_A
  #            ________________|_______________
  #           |                |              |
  #        col_B             col_C           me_1
  # ________|_____     ________|_____
  # |       |     |    |       |     |
  # me_1  me_2  me_3   me_1  me_2  me_4
  #
  # col_D
  # me_5

  before do
    @user = FactoryBot.create(:user)

    # rubocop:disable Style/VariableName
    # rubocop thinks: Use snake_case for variable names
    # I find it OK in this case
    @collection_A = FactoryBot.create(:collection,
                                       responsible_user: @user)
    @collection_B = FactoryBot.create(:collection,
                                       responsible_user: @user)
    @collection_C = FactoryBot.create(:collection,
                                       responsible_user: @user)
    @collection_D = FactoryBot.create(:collection,
                                       responsible_user: @user)
    # rubocop:enable Style/VariableName

    @media_entry_1 = FactoryBot.create(:media_entry_with_image_media_file,
                                        responsible_user: @user)
    @media_entry_2 = FactoryBot.create(:media_entry_with_image_media_file,
                                        responsible_user: @user)
    @media_entry_3 = FactoryBot.create(:media_entry_with_image_media_file,
                                        responsible_user: @user)
    @media_entry_4 = FactoryBot.create(:media_entry_with_image_media_file,
                                        responsible_user: @user)
    @media_entry_5 = FactoryBot.create(:media_entry_with_image_media_file,
                                        responsible_user: @user)

    @collection_A.collections << @collection_B
    @collection_A.collections << @collection_C
    @collection_A.media_entries << @media_entry_1

    @collection_B.media_entries << @media_entry_1
    @collection_B.media_entries << @media_entry_2
    @collection_B.media_entries << @media_entry_3

    @collection_C.media_entries << @media_entry_1
    @collection_C.media_entries << @media_entry_2
    @collection_C.media_entries << @media_entry_4
  end
end
