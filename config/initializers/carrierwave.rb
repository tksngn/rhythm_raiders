# 本番かつ R2_* の環境変数がある時だけ、CarrierWave(音源)を S3互換ストレージへ保存。
# Cloudflare R2 / Supabase Storage どちらも対応（endpoint/region/public URL の設定差のみ）。
# 設定が無ければローカルDisk(従来どおり)にフォールバックするので壊れない。
if Rails.env.production? && ENV['R2_ACCESS_KEY_ID'].present?
  CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     ENV['R2_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['R2_SECRET_ACCESS_KEY'],
      region:                ENV.fetch('R2_REGION', 'auto'), # R2: auto / Supabase: プロジェクトのregion
      endpoint:              ENV['R2_ENDPOINT'], # R2: https://<id>.r2.cloudflarestorage.com / Supabase: https://<ref>.supabase.co/storage/v1/s3
      path_style:            true,
      aws_signature_version: 4
    }
    config.fog_directory  = ENV['R2_BUCKET']
    config.fog_public     = true
    config.asset_host     = ENV['R2_PUBLIC_URL'] # R2: https://pub-xxxx.r2.dev / Supabase: https://<ref>.supabase.co/storage/v1/object/public/<bucket>
    config.fog_attributes = { cache_control: 'public, max-age=31536000' }
  end
end
