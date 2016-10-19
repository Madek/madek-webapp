require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MetaDatum' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
    @media_entry = FactoryGirl.create :media_entry_with_image_media_file,
                                      creator: @user, responsible_user: @user

    TEST_DATE = (Date.new( # some day in the ~5 months ago:
      Time.current.year, Time.current.month, (rand(28) + 1)) - 5.months)
    TEST_STRING = TEST_DATE.strftime('%d.%m.%Y') # '28.04.2012'

    TEST_DATE_END = TEST_DATE + 2.months
    TEST_STRING_END = TEST_DATE_END.strftime('%d.%m.%Y') # '28.06.2012'

    DURATION_STRING = "#{TEST_STRING} - #{TEST_STRING_END}".freeze
  end

  context 'MetaDatumTextDate' do
    background do
      @vocabulary = FactoryGirl.create(:vocabulary)
      @meta_key = FactoryGirl.create(:meta_key_text_date)
      @context_key = FactoryGirl.create(:context_key, meta_key: @meta_key)
      AppSettings.first.update_attributes!(
        contexts_for_entry_edit: [@context_key.context_id],
        context_for_entry_summary: @context_key.context_id)
    end

    example 'add new date text ("Freie Eingabe")' do
      edit_in_meta_data_form_and_save do
        expect_type_switcher_has_options(['text', 'timestamp', 'duration'])
        expect_type_switcher_set_to('text') # 'Freie Eingabe'
        input = find('input')
        expect(input.value).to eq ''
        input.set('A long time ago')
      end

      expect_meta_datum_on_detail_view('A long time ago')
    end

    context 'add new date timestamp ("am")' do
      example 'using calendar picker' do
        edit_in_meta_data_form_and_save do
          expect_type_switcher_has_options(['text', 'timestamp', 'duration'])
          expect_type_switcher_set_to('text')
          input = find('input')
          expect(input.value).to eq ''
          set_type_switcher_to('timestamp')
          # NOTE: input/calendar have focus after switching!
          in_the_calendar_picker do
            calendar_move_months(5, 'backward')
            calendar_select_day(TEST_DATE.day)
          end
          expect(input.value).to eq TEST_STRING
        end

        expect_meta_datum_on_detail_view(TEST_STRING)
      end

      example 'using keyboard' do
        edit_in_meta_data_form_and_save do
          expect_type_switcher_has_options(['text', 'timestamp', 'duration'])
          expect_type_switcher_set_to('text')
          input = find('input')
          expect(input.value).to eq ''
          set_type_switcher_to('timestamp')
          # NOTE: input/calendar have focus after switching!
          input.set(TEST_STRING)
          in_the_calendar_picker do
            expect_calendar_selected_day(TEST_DATE.day)
          end
        end

        expect_meta_datum_on_detail_view(TEST_STRING)
      end

    end

    example 'add new date duration ("von/bis") with calendar' do
      TEST_DATE_END = TEST_DATE + 2.months
      TEST_STRING_END = TEST_DATE_END.strftime('%d.%m.%Y') # '28.04.2012'

      edit_in_meta_data_form_and_save do
        expect_type_switcher_has_options(['text', 'timestamp', 'duration'])
        expect_type_switcher_set_to('text')
        set_type_switcher_to('duration')
        # NOTE: first input/calendar has focus after switching!

        pickers = page.all('.ui-datepicker').to_a
        expect(pickers.length).to be 2
        from_date_picker, to_date_picker = pickers

        within(from_date_picker) do
          input = find('input')
          expect(input.value).to eq ''
          in_the_calendar_picker do
            calendar_move_months(5, 'backward')
            calendar_select_day(TEST_DATE.day)
            expect_calendar_selected_day(TEST_DATE.day)
          end
        end

        within(to_date_picker) do
          input = find('input')
          expect(input.value).to eq ''
          input.click # focus input
          in_the_calendar_picker do
            # NOTE: it starts with the 'from' date, so move 2 month forward!
            calendar_move_months(2, 'forward')
            calendar_select_day(TEST_DATE_END.day)
            expect_calendar_selected_day(TEST_DATE_END.day)
          end
        end

      end

      expect_meta_datum_on_detail_view(DURATION_STRING)
    end

    context 'update existing date' do

      example 'text ("Freie Eingabe")' do
        given_an_exisiting_meta_datum_text_date('Some time ago')
        visit media_entry_path(@media_entry)
        expect_meta_datum_on_detail_view('Some time ago')

        edit_in_meta_data_form_and_save do
          expect_type_switcher_has_options(['text', 'timestamp', 'duration'])
          expect_type_switcher_set_to('text') # 'Freie Eingabe'
          input = find('input')
          expect(input.value).to eq 'Some time ago'
          input.set('A long time ago')
        end

        expect_meta_datum_on_detail_view('A long time ago')
      end

      example 'update existing date timestamp ("am")' do
        given_an_exisiting_meta_datum_text_date(TEST_STRING)

        edit_in_meta_data_form_and_save do
          expect_type_switcher_has_options(['text', 'timestamp', 'duration'])
          expect_type_switcher_set_to('timestamp')
          input = find('input')
          expect(input.value).to eq TEST_STRING
          input.click # focus the input
          in_the_calendar_picker do
            expect_calendar_selected_day(TEST_DATE.day)
            calendar_move_months(2, 'forward')
            calendar_select_day(TEST_DATE_END.day)
          end
          expect(input.value).to eq TEST_STRING_END
        end

        expect_meta_datum_on_detail_view(TEST_STRING_END)
      end

      example 'update existing date duration ("von/bis")' do
        TEST_DATE2 = TEST_DATE + 1.month
        TEST_DATE_END2 = TEST_DATE_END + 1.month
        TEST_STRING2 = TEST_DATE2.strftime('%d.%m.%Y') # '28.04.2012'
        TEST_STRING_END2 = TEST_DATE_END2.strftime('%d.%m.%Y') # '28.06.2012'
        DURATION_STRING2 = "#{TEST_STRING2} - #{TEST_STRING_END2}".freeze

        given_an_exisiting_meta_datum_text_date(DURATION_STRING)

        edit_in_meta_data_form_and_save do
          expect_type_switcher_has_options(['text', 'timestamp', 'duration'])
          expect_type_switcher_set_to('duration')

          pickers = page.all('.ui-datepicker').to_a
          expect(pickers.length).to be 2
          from_date_picker, to_date_picker = pickers

          within(from_date_picker) do
            input = find('input')
            expect(input.value).to eq TEST_STRING
            input.click # focus input
            in_the_calendar_picker do
              calendar_move_months(1, 'forward')
              calendar_select_day(TEST_DATE2.day)
              expect_calendar_selected_day(TEST_DATE2.day)
            end
          end

          within(to_date_picker) do
            input = find('input')
            expect(input.value).to eq TEST_STRING_END
            input.click # focus input
            in_the_calendar_picker do
              # NOTE: it starts with the 'from' date, so move 1 month forward!
              calendar_move_months(1, 'forward')
              calendar_select_day(TEST_DATE_END2.day)
              expect_calendar_selected_day(TEST_DATE_END2.day)
            end
          end
        end

        expect_meta_datum_on_detail_view(DURATION_STRING2)
      end
    end

    example 'remove exisiting data - text ("Freie Eingabe")' do
      given_an_exisiting_meta_datum_text_date('Some time ago')
      visit media_entry_path(@media_entry)
      expect_meta_datum_on_detail_view('Some time ago')

      edit_in_meta_data_form_and_save do
        input = find('input')
        input.set(' ')
      end
      expect_meta_datum_on_detail_view('Some time ago', shown: false)
    end

  end
end

private

def given_an_exisiting_meta_datum_text_date(string)
  FactoryGirl.create(
    :meta_datum_text_date,
    media_entry: @media_entry,
    meta_key: @meta_key,
    string: string)
end

def edit_in_meta_data_form_and_save(context_key = @context_key, &_block)
  visit edit_context_meta_data_media_entry_path(@media_entry)
  within('form[name="resource_meta_data"]') do
    within(form_group(context_key)) { yield }
    submit_form
  end
end

def expect_type_switcher_has_options(types, context_key = @context_key)
  expect(page).to have_select(
    type_switcher_id(context_key),
    options: types.map { |t| I18n.t('meta_data_input_date_type_' + t) })
end

def set_type_switcher_to(option, context_key = @context_key)
  select(
    I18n.t('meta_data_input_date_type_' + option),
    from: type_switcher_id(context_key))
end

def expect_type_switcher_set_to(option, context_key = @context_key)
  expect(page).to have_select(
    type_switcher_id(context_key),
    selected: I18n.t('meta_data_input_date_type_' + option))
end

def type_switcher_id(context_key)
  "#{context_key.id}.select-input-type"
end

def in_the_calendar_picker
  within('.DayPicker--de') { yield }
end

def calendar_move_months(n, dir)
  throw ArgumentError unless ['forward', 'backward'].include?(dir)
  btn = page.find('.DayPicker-NavButton--' + (dir == 'forward' ? 'next' : 'prev'))
  n.times { btn.click }
end

def calendar_select_day(day)
  find_exact_text('.DayPicker-Day', text: day).click
end

def expect_calendar_selected_day(day)
  expect(find_exact_text('.DayPicker-Day--selected', text: day)).to be
end

def form_group(context_key = @context_key)
  find('.ui-form-group', text: context_key.label)
end

def expect_meta_datum_on_detail_view(string, shown: true, key: @context_key)
  wait_until { current_path == media_entry_path(@media_entry) }
  within('.ui-media-overview-metadata') do
    expect(page.has_css?('.media-data-title', text: key.label))
      .to be shown
    expect(page.has_css?('.media-data-content', text: string))
      .to be shown
  end
end
