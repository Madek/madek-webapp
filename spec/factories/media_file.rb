FactoryGirl.define do

  factory :media_file  do
    meta_data { { key: :value } }
    height { 640 }
    width { 429 }
    content_type 'image/jpeg'
    media_type 'image'
    association :media_entry
    association :uploader, factory: :user
  end

  factory :media_file_for_image, class: MediaFile do

    before :create do
      unless File.exist? \
        (Rails.root.join('db/media_files',
                         Rails.env,
                         'attachments/b/b8bf2eb322e04a29a52fbb06d4866af8'))
        System.execute_cmd! \
          %(tar xf #{Rails.root.join 'spec/data/grumpy-cat_files.tar.gz'} \
            -C #{Rails.root.join 'db/media_files/', Rails.env})
      end
    end

    extension 'jpg'
    media_type 'image'
    height 360
    size 54335
    width 480
    content_type 'image/jpeg'
    filename 'grumpy_cat.jpg'
    guid 'b8bf2eb322e04a29a52fbb06d4866af8'
    access_hash 'edbf86ef-8bb5-40c2-8737-368bbf7f75dd'
    meta_data YAML.load '
      File:BitsPerSample: 8
      File:ColorComponents: 3
      File:EncodingProcess: Baseline DCT, Huffman coding
      File:FileType: JPEG
      File:ImageHeight: 360
      File:ImageWidth: 480
      File:MIMEType: image/jpeg
      File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
      Composite:ImageSize: 480x360
      JFIF:JFIFVersion: 1.01
      JFIF:ResolutionUnit: inches
      JFIF:XResolution: 72
      JFIF:YResolution: 72 '
    association :media_entry
    association :uploader, factory: :user

    after :create do |mf|
      previews_data = YAML.load '
      -
        height: 75
        width: 100
        content_type: image/jpeg
        filename: b8bf2eb322e04a29a52fbb06d4866af8_small.jpg
        thumbnail: small
      -
        height: 94
        width: 125
        content_type: image/jpeg
        filename: b8bf2eb322e04a29a52fbb06d4866af8_small_125.jpg
        thumbnail: small_125
      -
        height: 225
        width: 300
        content_type: image/jpeg
        filename: b8bf2eb322e04a29a52fbb06d4866af8_medium.jpg
        thumbnail: medium
      -
        height: 360
        width: 480
        content_type: image/jpeg
        filename: b8bf2eb322e04a29a52fbb06d4866af8_large.jpg
        thumbnail: large
      -
        height: 360
        width: 480
        content_type: image/jpeg
        filename: b8bf2eb322e04a29a52fbb06d4866af8_x_large.jpg
        thumbnail: x_large
      -
        height: 360
        width: 480
        content_type: image/jpeg
        filename: b8bf2eb322e04a29a52fbb06d4866af8_maximum.jpg
        thumbnail: maximum
            '

      previews_data.each do |pd|
        Preview.create! pd.merge(media_file: mf)
      end

    end
  end

  factory :media_file_for_movie, class: MediaFile do
    extension 'mov'
    media_type 'video'
    height 720
    size 922621
    width 1280
    content_type 'video/quicktime'
    filename 'zencoder_test.mov'
    guid '66b1ef50186645438c047179f54ec6e6'
    access_hash '4eb0ffec-58a1-4e9b-9056-b4f6fd4729ae'
    meta_data YAML.load '
      File:FileType: MP4
      File:MIMEType: video/mp4
      Composite:AvgBitrate: 1.45 Mbps
      Composite:ImageSize: 1280x720
      Composite:Rotation: 0
      QuickTime:CompatibleBrands:
      - isom
      - avc1
      QuickTime:CreateDate: 2012:04:02 10:02:06
      QuickTime:CurrentTime: 0 s
      QuickTime:Duration: 5.07 s
      QuickTime:MajorBrand: MP4  Base Media v1 [IS0 14496-12:2003]
      QuickTime:MatrixStructure: 1 0 0 0 1 0 0 0 1
      QuickTime:MinorVersion: 0.0.1
      QuickTime:ModifyDate: 2012:04:02 10:02:06
      QuickTime:MovieDataSize: 920203
      QuickTime:MovieHeaderVersion: 0
      QuickTime:NextTrackID: 3
      QuickTime:PosterTime: 0 s
      QuickTime:PreferredRate: 1
      QuickTime:PreferredVolume: 100.00%
      QuickTime:PreviewDuration: 0 s
      QuickTime:PreviewTime: 0 s
      QuickTime:SelectionDuration: 0 s
      QuickTime:SelectionTime: 0 s
      QuickTime:TimeScale: 600 '
    association :media_entry
    association :uploader, factory: :user
  end

  factory :media_file_for_audio, class: MediaFile do
    extension 'mp3'
    media_type 'audio'
    size 2_793_600
    content_type 'audio/mpeg'
    filename 'audio.mp3'
    guid { UUIDTools::UUID.random_create.hexdigest }
    access_hash { UUIDTools::UUID.random_create.to_s }
    association :media_entry
    association :uploader, factory: :user
  end
end
