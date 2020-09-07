class PictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file
  # storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url(*args)
    "default.png"
  end

  # 画像サイズ設定
  # 詳細表示用：400 * 400の正方形に整形
  version :thumb400 do
    process resize_and_pad(400, 400, background = :transparent, gravity = 'Center')
  end

  # 一覧表示用：200 * 200の正方形に中央から切り抜き
  version :thumb200 do
    process resize_to_fill: [200, 200, "Center"]
  end

  version :thumb100 do
    process resize_to_fit: [100, 100, "Center"]
  end

  def extension_whitelist
    %w(jpg jpeg png)
  end
end
