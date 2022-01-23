desc "Deletes unused stock snapshots"
task :stock_snapshot_janitor => :environment do
    p "#{Time.now} running StockSnapshotJanitor"
    StockSnapshotJanitor.delay.run
end