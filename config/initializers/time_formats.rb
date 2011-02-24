# -*- encoding : utf-8 -*-
Time::DATE_FORMATS[:date] = "%d.%m.%Y"
Time::DATE_FORMATS[:time] = "%H:%M"
Time::DATE_FORMATS[:date_time] = "%d.%m.%Y, %H:%M"
Time::DATE_FORMATS[:time_full] = "%H:%M:%S"

Date::DATE_FORMATS[:date] = "%d.%m.%Y"
Date::DATE_FORMATS[:exif_date] = "%Y:%m:%d"

DateTime::DATE_FORMATS[:date_time] = "%d.%m.%Y, %H:%M"
DateTime::DATE_FORMATS[:exif_date_time] = "%Y:%m:%d %H:%M:%S"
DateTime::DATE_FORMATS[:exif_date_time_zone] = "%Y:%m:%d %H:%M:%S%Z"
