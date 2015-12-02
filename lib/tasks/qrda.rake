namespace :qrda do

  task load_patients: :environment do
    filenames = Dir["cat_i_files/*"]
    filenames.each do |filename|
      system("curl -X POST -u USERNAME:PASSWORD -F file=@#{filename} http://localhost:2000/api/patients")
    end
  end

end
