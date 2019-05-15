require 'spec_helper'

describe My::GroupsController do
  let(:user) { create :user }
  let(:group) { create :group }

  pending '#index' do

    context 'scope metadata' do
      it 'search for "mediale" with zhdk integration' do

        fail 'ZHdK integration must be on!' unless Settings.zhdk_integration

        expected_detailed_names = [
          'Vertiefung Mediale Künste (DKM_FMK_BMK_VMK.alle)',
          'Vertiefung Mediale Künste (DKM_FMK_VMK.alle)'
        ]

        execute_search('mediale', 'metadata', expected_detailed_names)
      end
    end

    context 'scope permissions' do
      it 'search for "mediale"' do

        fail 'ZHdK integration must be on!' unless Settings.zhdk_integration

        expected_detailed_names = [
          'Bachelor Medien & Kunst - Vertiefung Mediale Künste - ' \
            + 'HS 2009 (DKM_FMK_BMK_VMK_09H.studierende)',
          'Bachelor Medien & Kunst - Vertiefung Mediale Künste - ' \
            + 'HS 2010 (DKM_FMK_BMK_VMK_10H.studierende)',
          'Bachelor Medien & Kunst - Vertiefung Mediale Künste - ' \
            + 'HS 2011 (DKM_FMK_BMK_VMK_11H.studierende)',
          'Bachelor Medien & Kunst - Vertiefung Mediale Künste - ' \
            + 'HS 2012 (DKM_FMK_BMK_VMK_12H.studierende)',
          'Vertiefung Mediale Künste (DKM_FMK_BMK_VMK.alle)',
          'Vertiefung Mediale Künste (DKM_FMK_BMK_VMK.studierende)',
          'Vertiefung Mediale Künste (DKM_FMK_VMK.alle)',
          'Vertiefung Mediale Künste (DKM_FMK_VMK.dozierende)',
          'Vertiefung Mediale Künste (DKM_FMK_VMK.mittelbau)',
          'Vertiefung Mediale Künste (DKM_FMK_VMK.personal)',
          'Vertiefung Mediale Künste (DKM_FMK_VMK.studierende)'
        ]

        execute_search('mediale', 'permissions', expected_detailed_names)
      end

    end
  end
end

private

def execute_search(search_term, scope, expected_result)
  get(
    :index,
    params: { format: :json, search_term: search_term, scope: scope },
    session: { user_id: user.id }
  )

  result = JSON.parse(response.body)

  actual_result = result.map do |group_common|
    group_common['detailed_name']
  end

  expect(actual_result.length).to eq(expected_result.length)

  # Check if intersection of arrays has same length,
  # meaning both contain the same values.
  expect((actual_result & expected_result).length).to eq(expected_result.length)
end
