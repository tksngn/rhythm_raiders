# 本番かつ R2 の環境変数がある時だけ、CarrierWave(音源)を Cloudflare R2(S3互換)へ保存。
# 設定が無ければローカルDisk(従来どおり)にフォールバックするので壊れない。
if Rails.env.production? && ENV['R2_ACCESS_KEY_ID'].present?
  CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     ENV['R2_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['R2_SECRET_ACCESS_KEY'],
      region:                'auto',
      endpoint:              ENV['R2_ENDPOINT'], # 例: https://<accountid>.r2.cloudflarestorage.com
      path_style:            true,
      aws_signature_version: 4
    }
    config.fog_directory  = ENV['R2_BUCKET']
    config.fog_public     = true
    config.asset_host     = ENV['R2_PUBLIC_URL'] # 例: https://pub-xxxx.r2.dev（公開URL）
    config.fog_attributes = { cache_control: 'public, max-age=31536000' }
  end
end
