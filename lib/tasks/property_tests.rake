# frozen_string_literal: true

namespace :test do
  desc "Run property tests (Rantly) as a separate verification step"
  task :property do
    files = Dir[File.expand_path("../../property_test/**/*_test.rb", __dir__)]
    abort "No property tests found under property_test/" if files.empty?
    sh({ "RAILS_ENV" => "test" }, RbConfig.ruby, "-Itest",
       "-e", files.map { |f| "require #{f.dump}" }.join("; "))
  end
end
