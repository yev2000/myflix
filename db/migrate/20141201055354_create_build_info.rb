class CreateBuildInfo < ActiveRecord::Migration
  def change
    create_table :build_info do |t|
      t.string      :build_machine
      t.string      :build_user
      t.timestamps
    end
  end
end
