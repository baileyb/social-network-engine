require 'open-uri'
require 'digest/md5'
module Util
  def self.save_picture url
    return "" if url.nil? || url.empty?
    profile_pics_path = "#{Rails.root}/public/profile-pics"
    FileUtils.mkdir_p(profile_pics_path) unless File.exists?(profile_pics_path)

    profile_pic_name =  "profile-pics/#{Digest::MD5.hexdigest(url)}.jpg"

    open("#{Rails.root}/public/#{profile_pic_name}", 'wb') do |f|
      f << open(url).read unless url.nil?
    end

    profile_pic_name
  end
end